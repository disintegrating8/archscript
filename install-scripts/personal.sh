#!/bin/bash

dev_tools=(
  htop
  btop
  timeshift
  zip
  neovim
  bat
)

apps=(
  github-desktop-bin
  brave-bin
  libreoffice-fresh
  mpv
  obs-studio
  gimp
  steam
  prismlauncher
  gamescope
  gamemode
)

flatpaks=(
  net.cozic.joplin_desktop 
  com.discordapp.Discord 
  com.github.iwalton3.jellyfin-media-player
  com.vysp3r.ProtonPlus
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
LOG="Install-Logs/install-$(date +%d-%H%M%S)_personal-pkgs.log"

# Check if flatpak is installed
if ! command -v flatpak &>/dev/null; then
  printf "%b\n" "Installing Flatpak..."
  sudo pacman -S --noconfirm flatpak
  printf "%b\n" "Adding Flathub remote..."
  sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
  printf "%b\n" "Applications installed by Flatpak may not appear on your desktop until the user session is restarted..."
else
  if ! flatpak remotes | grep -q "flathub"; then
    printf "%b\n" "Adding Flathub remote..."
    sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
  else
    printf "%b\n" "Flatpak is installed"
  fi
fi

echo "Installing development tools..."
for PKG in "${dev_tools[@]}"; do
  install_package "$PKG" "$LOG"
done

echo "Installing apps..."
for PKG in "${apps[@]}"; do
  install_package "$PKG" "$LOG"
done

echo "Installing flatpaks..."
for FLAT in "${flatpaks[@]}"; do
  install_package_flatpak "$FLAT" "$LOG"
done
