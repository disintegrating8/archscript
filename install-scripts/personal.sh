#!/bin/bash


utils=(
  htop
  btop
  timeshift
  fzf
  zip
  unzip
  wget
  curl 
  timeshift
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
  gamescope
  gamemode
)

FONTS=(ttf-meslo-nerd noto-fonts noto-fonts-cjk noto-fonts-emoji)

FLATPAKS=(net.cozic.joplin_desktop dev.vencord.Vesktop)

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

