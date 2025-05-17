#!/bin/bash

. ./common-script.sh
. ./common-service-script.sh

SYSTEM_UTILS=(htop btop lazygit stow fastfetch fzf zip unzip wget curl timeshift)

DEV_TOOLS=(vim neovim yazi bat starship kitty git github-desktop-bin)

APP=(brave-bin libreoffice-fresh mpv obs-studio gimp)

FONTS=(ttf-meslo-nerd noto-fonts noto-fonts-cjk noto-fonts-emoji)

FLATPAKS=(net.cozic.joplin_desktop com.discordapp.Discord)

# Function to check if a package is installed
is_installed() {
  pacman -Qi "$1" &> /dev/null
}

# Function to check if a package is installed
is_group_installed() {
  pacman -Qg "$1" &> /dev/null
}

# Function to install packages if not already installed
install_packages() {
  local packages=("$@")
  local to_install=()

  for pkg in "${packages[@]}"; do
    if ! is_installed "$pkg" && ! is_group_installed "$pkg"; then
      to_install+=("$pkg")
    fi
  done

  if [ ${#to_install[@]} -ne 0 ]; then
    echo "Installing: ${to_install[*]}"
    yay -S --noconfirm "${to_install[@]}"
  fi
}

install_flatpak() {
  for pak in "${FLATPAKS[@]}"; do
    if ! flatpak list | grep -i "$pak" &> /dev/null; then
      echo "Installing Flatpak: $pak"
      flatpak install --noninteractive "$pak"
    else
      echo "Flatpak already installed: $pak"
    fi
  done
}

run_instal() {
  echo "Installing system utilities..."
  install_packages "${SYSTEM_UTILS[@]}"

  echo "Installing development tools..."
  install_packages "${DEV_TOOLS[@]}"

  echo "Installing apps..."
  install_packages "${APP[@]}"

  echo "Installing fonts..."
  install_packages "${FONTS[@]}"

  echo "Installing flatpaks..."
  install_flatpak "${FLATPAKS[@]}"
}

echo "Setup complete! You may want to reboot your system."
