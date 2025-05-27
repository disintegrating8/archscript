#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || { echo "${ERROR} Failed to change directory to $PARENT_DIR"; exit 1; }
# Source the global functions script
if ! source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"; then
  echo "Failed to source Global_functions.sh"
  exit 1
fi

# Set the name of the log file to include the current date and time
LOG="Install-Logs/install-$(date +%d-%H%M%S)_backgrounds.log"

# Set the variable PIC_DIR which stores the path for images
PIC_DIR="$HOME/Pictures"

# Set the variable BG_DIR to the path where backgrounds will be stored
BG_DIR="$PIC_DIR/backgrounds"

# Check if the ~/Pictures directory exists
if [ ! -d "$PIC_DIR" ]; then
    # If it doesn't exist, print an error message and return with a status of 1 (indicating failure)
    printf "%b\n" "${RED}Pictures directory does not exist${RC}"
    mkdir ~/Pictures
    printf "%b\n" "${GREEN}Directory was created in Home folder${RC}"
fi

# Check if the backgrounds directory (BG_DIR) exists
if [ ! -d "$BG_DIR" ]; then
    # If the backgrounds directory doesn't exist, attempt to clone a repository containing backgrounds
    if ! git clone https://github.com/ChrisTitusTech/nord-background.git "$PIC_DIR/nord-background"; then
        # If the git clone command fails, print an error message and return with a status of 1
        printf "%b\n" "${RED}Failed to clone the repository${RC}"
        return 1
    fi
    # Rename the cloned directory to 'backgrounds'
    mv "$PIC_DIR/nord-background" "$PIC_DIR/backgrounds"
    # Print a success message indicating that the backgrounds have been downloaded
    printf "%b\n" "${GREEN}Downloaded desktop backgrounds to $BG_DIR${RC}"    
else
    # If the backgrounds directory already exists, print a message indicating that the download is being skipped
    printf "%b\n" "${GREEN}Path $BG_DIR exists for desktop backgrounds, skipping download of backgrounds${RC}"
fi

printf "\n%.0s" {1..2}
