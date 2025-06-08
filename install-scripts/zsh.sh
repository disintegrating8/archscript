#!/bin/bash

zsh_pkg=(
  lsd
  zsh
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-completions
  fzf
  starship
)

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
LOG="Install-Logs/install-$(date +%d-%H%M%S)_zsh.log"

# Installing core zsh packages
printf "\n%s - Installing ${SKY_BLUE}zsh packages${RESET} .... \n" "${NOTE}"
for ZSH in "${zsh_pkg[@]}"; do
  install_package "$ZSH" "$LOG"
done 

# Check if the zsh-completions directory exists
if [ -d "zsh-completions" ]; then
    rm -rf zsh-completions
fi

# Set zsh as default shell
if command -v zsh >/dev/null; then
  # Check if the current shell is zsh
  current_shell=$(basename "$SHELL")
  if [ "$current_shell" != "zsh" ]; then
    printf "${NOTE} Changing default shell to ${MAGENTA}zsh${RESET}..."
    printf "\n%.0s" {1..2}

    # Loop to ensure the chsh command succeeds
    while ! chsh -s "$(command -v zsh)"; do
      echo "${ERROR} Authentication failed. Please enter the correct password." 2>&1 | tee -a "$LOG"
      sleep 1
    done

    printf "${INFO} Shell changed successfully to ${MAGENTA}zsh${RESET}" 2>&1 | tee -a "$LOG"
  else
    echo "${NOTE} Your shell is already set to ${MAGENTA}zsh${RESET}."
  fi
fi

printf "\n%.0s" {1..2}
