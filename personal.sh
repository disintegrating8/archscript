#!/bin/bash

. ./common-script.sh

SYSTEM_UTILS=(htop btop lazygit stow fastfetch fzf zip unzip wget curl timeshift)

DEV_TOOLS=(vim neovim yazi bat starship kitty git github-desktop-bin)

APP=(brave-bin libreoffice-fresh mpv obs-studio gimp)

FONTS=(ttf-meslo-nerd noto-fonts noto-fonts-cjk noto-fonts-emoji)

FLATPAKS=(net.cozic.joplin_desktop com.discordapp.Discord)

run_install() {
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

checkEnv
run_install

echo "Setup complete! You may want to reboot your system."
