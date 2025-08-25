#!/bin/bash
#
# macOS Screenshot Location Helper
# 
# A simple script to manage macOS screenshot save locations with automatic
# file migration from the current location.
#
# Author: Artur Martins
# Created: August 2025
# Version: 1.0
# 
# Usage: ./setup-macos-screenshots.sh <target_directory>
#
set -euo pipefail

DESKTOP_DIR="$HOME/Desktop"

# Check if running on macOS
check_macos() {
    if [[ "$(uname -s)" != "Darwin" ]]; then
        echo "Error: This script requires macOS"
        exit 1
    fi
}

# Show usage information
show_usage() {
    echo "Usage: $0 <target_directory>"
    echo "Example: $0 ~/Documents/Screenshots"
    echo "         $0 /Users/$(whoami)/Pictures/Screenshots"
}

# Validate and normalize the input path
validate_path() {
    local input_path="$1"
    
    # Check if path is empty or just whitespace
    if [[ -z "${input_path// }" ]]; then
        echo "Error: Path cannot be empty"
        return 1
    fi
    
    # Expand tilde
    input_path="${input_path/#\~/$HOME}"
    
    # Convert to absolute path if relative
    if [[ "$input_path" != /* ]]; then
        input_path="$(pwd)/$input_path"
    fi
    
    # Check for invalid characters or patterns
    if [[ "$input_path" =~ [[:space:]]$ ]] || [[ "$input_path" =~ :$ ]]; then
        echo "Error: Invalid path format"
        return 1
    fi
    
    # Ensure it's not a system directory
    case "$input_path" in
        /|/System/*|/usr/*|/bin/*|/sbin/*)
            echo "Error: Cannot use system directories"
            return 1
            ;;
    esac
    
    echo "$input_path"
}

# Get current screenshot location
get_current_location() {
    defaults read com.apple.screencapture location 2>/dev/null
}

# Check if two directories are the same
same_directory() {
    local dir1="$1" dir2="$2"
    [[ -d "$dir1" && -d "$dir2" ]] && [[ "$(stat -f "%d:%i" "$dir1")" == "$(stat -f "%d:%i" "$dir2")" ]]
}

# Handle directory creation or confirmation
setup_directory() {
    local target_dir="$1"
    
    if [[ -d "${target_dir}" ]]; then
        echo "Directory '${target_dir}' already exists."
        read -p "Use this folder for screenshots? (y/n): " -r choice
        case "${choice}" in
            [Yy]|[Yy][Ee][Ss]) return 0 ;;
            *) echo "Aborted. Please provide a different path."; exit 0 ;;
        esac
    else
        echo "Directory '${target_dir}' does not exist."
        read -p "Create this directory? (y/n): " -r choice
        case "${choice}" in
            [Yy]|[Yy][Ee][Ss])
                if mkdir -p "${target_dir}"; then
                    echo "Created directory: ${target_dir}"
                else
                    echo "Error: Failed to create directory"
                    exit 1
                fi
                ;;
            *) echo "Aborted. Please provide a different path."; exit 0 ;;
        esac
    fi
}

# Move existing screenshots from Desktop
move_desktop_screenshots() {
    local target_dir="$1"
    local current_location="$2"
    
    echo "Now preparing to move screenshots into the new folder..."
    
    # Only move if current location is Desktop
    if ! same_directory "${current_location}" "$DESKTOP_DIR"; then
        echo "No screenshots found on ${current_location}. No moving needed."
        return 0
    fi
    
    # Find screenshot files on Desktop
    local screenshots=()
    while IFS= read -r -d '' file; do
        screenshots+=("$file")
    done < <(find "$DESKTOP_DIR" -maxdepth 1 -name "Screenshot *" -type f -print0 2>/dev/null)
    
    if [[ ${#screenshots[@]} -eq 0 ]]; then
        echo "No screenshots found on $DESKTOP_DIR. No moving needed."
        return 0
    fi
    
    echo "Found ${#screenshots[@]} screenshot(s) on $DESKTOP_DIR."
    read -p "Move them to '${target_dir}'? (y/n): " -r choice
    
    case "${choice}" in
        [Yy]|[Yy][Ee][Ss])
            local moved=0
            for file in "${screenshots[@]}"; do
                if mv "$file" "${target_dir}/"; then
                    echo "Moved: $(basename "$file")"
                    ((moved++))
                fi
            done
            echo "Successfully moved $moved file(s)."
            ;;
        *)
            echo "Skipped moving files."
            ;;
    esac
}

# Set new screenshot location
set_location() {
    local target_dir="$1"
    defaults write com.apple.screencapture location "${target_dir}"
    killall SystemUIServer 2>/dev/null || true
    echo "Screenshots will now be saved to: ${target_dir}"
}

# Main function
main() {
    check_macos
    
    # Require path argument
    if [[ $# -eq 0 ]]; then
        echo "Error: No target directory specified."
        echo ""
        show_usage
        exit 1
    fi
    
    # Validate and normalize the input path
    local target_dir
    if ! target_dir="$(validate_path "$1")"; then
        echo ""
        show_usage
        exit 1
    fi
    
    local current_location
    current_location="$(get_current_location)"
    
    # Expand tilde in current location for proper comparison
    local current_expanded="${current_location/#\~/$HOME}"
    
    echo "Target directory: ${target_dir}"
    echo "Current location: ${current_location}"
    echo ""
    
    # Check if already configured
    if same_directory "${current_expanded}" "${target_dir}"; then
        echo "Screenshots are already saved to this location. No changes needed."
        echo "Goodbye"
        exit 0
    fi
    
    # Setup target directory
    setup_directory "${target_dir}"
    
    # Move existing screenshots if needed
    move_desktop_screenshots "${target_dir}" "${current_location}"
    
    # Apply new setting
    set_location "${target_dir}"

    #The End
    echo "Work complete!"
}

main "$@"
