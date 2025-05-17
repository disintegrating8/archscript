#!/bin/bash

. ./common-script.sh
. ./common-service-script.sh

GNOME_SETUP() {
  # Install gnome specific things to make it like a tiling WM
  echo "Installing Gnome extensions..."
  . gnome/gnome-extensions.sh
  echo "Setting Gnome hotkeys..."
  . gnome/gnome-hotkeys.sh
  echo "Configuring Gnome..."
  . gnome/gnome-settings.sh
}

GNOME_SETUP
