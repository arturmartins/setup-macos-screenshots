# macOS screenshot location helper

A simple bash script to help setting up where macOS saves screenshots, with automatic migration of existing screenshot files.

## Features
Change macOS screenshot save location
Create target directories if they don't exist
Automatically move existing screenshots from the old location
Instantly apply changes (no restart required)

## Installation

Download the script:
```bash
 curl -O https://raw.githubusercontent.com/arturmartins/setup-macos-screenshots/refs/heads/main/setup-macos-screenshots.sh 
```

Make it executable:
```bash
chmod +x macos-screenshot-setup.sh
```

## Usage

Basic Usage
```bash
./macos-screenshot-setup.sh <target_directory>
```

### Examples
```bash
# Save screenshots to Documents folder
./macos-screenshot-setup.sh ~/Documents/Screenshots

# Save to a custom path
./macos-screenshot-setup.sh /Users/username/Pictures/Screenshots

# Save to Desktop subfolder
./macos-screenshot-setup.sh ~/Desktop/My-Screenshots
```


### Example Output

```txt
Target directory: /Users/username/Documents/Screenshots
Current location: /Users/username/Desktop

Directory '/Users/username/Documents/Screenshots' does not exist.
Create this directory? (y/n): y
Created directory: /Users/username/Documents/Screenshots

Now preparing to move screenshots into the new folder...
Found 5 screenshot(s) on /Users/username/Desktop.
Move them to '/Users/username/Documents/Screenshots'? (y/n): y
Moved: Screenshot 2025-08-25 at 10.30.45.png
Moved: Screenshot 2025-08-25 at 10.31.22.png
Moved: Screenshot 2025-08-25 at 10.32.18.png
Moved: Screenshot 2025-08-25 at 10.33.05.png
Moved: Screenshot 2025-08-25 at 10.34.12.png
Successfully moved 5 file(s).

Screenshots will now be saved to: /Users/username/Documents/Screenshots
Work complete!
```

You should only need to run this script once and then you are more than welcome to delete it.

Have fun!
