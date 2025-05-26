bspwm_pkgs(){
    LOG="Install-Logs/install-$(date +%d-%H%M%S)_bspwm-pkgs.log"

    # Installation of main components
    printf "\n%s - Installing ${SKY_BLUE}Necessary packages${RESET} .... \n" "${NOTE}"

    for PKG1 in "${bspwm_package[@]}"; do
      install_package "$PKG1" "$LOG"
    done

    printf "\n%.0s" {1..2}
}

inputgroup(){
    LOG="Install-Logs/install-$(date +%d-%H%M%S)_input.log"

    # Check if the 'input' group exists
    if grep -q '^input:' /etc/group; then
        echo "${OK} ${MAGENTA}input${RESET} group exists."
    else
        echo "${NOTE} ${MAGENTA}input${RESET} group doesn't exist. Creating ${MAGENTA}input${RESET} group..."
        sudo groupadd input
        echo "${MAGENTA}input${RESET} group created" >> "$LOG"
    fi

    # Add the user to the 'input' group
    sudo usermod -aG input "$(whoami)"
    echo "${OK} ${YELLOW}user${RESET} added to the ${MAGENTA}input${RESET} group. Changes will take effect after you log out and log back in." >> "$LOG"

    printf "\n%.0s" {1..2}
}

bluetooth(){
    LOG="Install-Logs/install-$(date +%d-%H%M%S)_bluetooth.log"

    printf "${NOTE} Installing ${SKY_BLUE}Bluetooth${RESET} Packages...\n"
     for BLUE in "${blue[@]}"; do
       install_package "$BLUE" "$LOG"
      done

    printf " Activating ${YELLOW}Bluetooth${RESET} Services...\n"
    sudo systemctl enable --now bluetooth.service 2>&1 | tee -a "$LOG"

    printf "\n%.0s" {1..2}
}

dotfiles(){
    # Check if dotfiles exists
    printf "${NOTE} Cloning and Installing ${SKY_BLUE}dotfiles${RESET}....\n"

    #check if stow installed
    if ! command -v stow &> /dev/null; then
      echo "Stow not installed! Installing Stow..."
      if ! sudo pacman -S stow --noconfirm; then
        echo -e "Failed to install Stow. Exiting."
      fi
    fi

    if [ -d dotfiles ]; then
      cd dotfiles
      git stash && git pull
      stow bspwm

    else
      if git clone --depth=1 https://github.com/disintegrating8/dotfiles; then
        cd dotfiles || exit 1
        stow bspwm gtk-3.0 qt5ct qt6ct
      else
        echo -e "$ERROR Can't download ${YELLOW}dotfiles${RESET} . Check your internet connection"
      fi
    fi

    printf "\n%.0s" {1..2}
}

fonts(){
    LOG="Install-Logs/install-$(date +%d-%H%M%S)_fonts.log"

    # Installation of main components
    printf "\n%s - Installing necessary ${SKY_BLUE}fonts${RESET}.... \n" "${NOTE}"

    for PKG1 in "${fonts[@]}"; do
      install_package "$PKG1" "$LOG"
    done

    printf "\n%.0s" {1..2}
}

app_theme(){
    LOG="Install-Logs/install-$(date +%d-%H%M%S)_themes.log"

    for PKG in "${theme[@]}"; do
        install_package "$PKG" "$LOG"
    done

    # Check if the directory exists and delete it if present
    if [ -d "GTK-themes-icons" ]; then
        echo "$NOTE GTK themes and Icons directory exist..deleting..." 2>&1 | tee -a "$LOG"
        rm -rf "GTK-themes-icons" 2>&1 | tee -a "$LOG"
    fi

    echo "$NOTE Cloning ${SKY_BLUE}GTK themes and Icons${RESET} repository..." 2>&1 | tee -a "$LOG"
    if git clone --depth=1 https://github.com/disintegrating8/GTK-themes-icons.git ; then
        cd GTK-themes-icons
        chmod +x auto-extract.sh
        ./auto-extract.sh
        cd ..
        echo "$OK Extracted GTK Themes & Icons to ~/.icons & ~/.themes directories" 2>&1 | tee -a "$LOG"
    else
        echo "$ERROR Download failed for GTK themes and Icons.." 2>&1 | tee -a "$LOG"
    fi
    printf "\n%.0s" {1..2}
}

setupDisplayManager() {
    printf "%b\n" "${YELLOW}Setting up Xorg${RC}"
    sudo pacman -S --needed --noconfirm xorg-xinit xorg-server xorg-xrandr xorg-xinput
    printf "%b\n" "${GREEN}Xorg installed successfully${RC}"
    printf "%b\n" "${YELLOW}Setting up Display Manager${RC}"
    currentdm="none"
    for dm in gdm sddm lightdm; do
        if command -v "$dm" >/dev/null 2>&1 || isServiceActive "$dm"; then
            currentdm="$dm"
            break
        fi
    done
    printf "%b\n" "${GREEN}Current display manager: $currentdm${RC}"
    if [ "$currentdm" = "none" ]; then
        printf "%b\n" "${YELLOW}--------------------------${RC}" 
        printf "%b\n" "${YELLOW}Pick your Display Manager ${RC}" 
        printf "%b\n" "${YELLOW}1. SDDM ${RC}" 
        printf "%b\n" "${YELLOW}2. LightDM ${RC}" 
        printf "%b\n" "${YELLOW}3. GDM ${RC}"
        printf "%b\n" "${YELLOW}4. Ly - TUI Display Manager ${RC}"
        printf "%b\n" "${YELLOW}5. None ${RC}" 
        printf "%b" "${YELLOW}Please select one: ${RC}"
        read -r choice
        case "$choice" in
            1)
                DM="sddm"
                ;;
            2)
                DM="lightdm-gtk-greeter"
                ;;
            3)
                DM="gdm"
                ;;
            4)
                DM="ly"
                ;;
            5)
                printf "%b\n" "${GREEN}No display manager will be installed${RC}"
                return 0
                ;;
            *)
                printf "%b\n" "${RED}Invalid selection! Please choose 1, 2, 3, 4, or 5.${RC}"
                return 1
                ;;
        esac
        sudo pacman -S --needed --noconfirm "$DM"
        printf "%b\n" "${GREEN}$DM installed successfully${RC}"
        sudo systemctl enable "$DM"
    fi
}
cjk_input(){        
    printf "%b\n" "${YELLOW}--------------------------${RC}" 
    printf "%b\n" "${YELLOW}Pick CJK Input Method ${RC}"
    printf "%b\n" "${YELLOW}1. Ibus ${RC}"
    printf "%b\n" "${YELLOW}2. Fcitx ${RC}"
    printf "%b\n" "${YELLOW}3. Kime ${RC}"
    printf "%b\n" "${YELLOW}4. None ${RC}"
    read -r choice
    case "$choice" in
        1)
            sudo pacman -S --noconfirm ibus{,-hangul}
            ;;
        2)
            sudo pacman -S --noconfirm fcitx5-{im,hangul} 
            ;;
        3)
            paru -S --noconfirm kime-bin
            ;;
        4)
            printf "%b\n" "${GREEN}No input method will be installed${RC}"\
            ;;

        *)
            printf "%b\n" "${RED}Invalid selection! Please choose 1, 2, 3, or 4.${RC}"
            ;;
    esac
}

nvidia(){
  # Set the name of the log file to include the current date and time
  LOG="Install-Logs/install-$(date +%d-%H%M%S)_nvidia.log"

  # Install Nvidia packages
  printf "${YELLOW} Installing ${SKY_BLUE}Nvidia Packages and Linux headers${RESET}...\n"
  for krnl in $(cat /usr/lib/modules/*/pkgbase); do
    for NVIDIA in "${krnl}-headers" "${nvidia_pkg[@]}"; do
      install_package "$NVIDIA" "$LOG"
    done
  done

  # Check if the Nvidia modules are already added in mkinitcpio.conf and add if not
  if grep -qE '^MODULES=.*nvidia. *nvidia_modeset.*nvidia_uvm.*nvidia_drm' /etc/mkinitcpio.conf; then
    echo "Nvidia modules already included in /etc/mkinitcpio.conf" 2>&1 | tee -a "$LOG"
  else
    sudo sed -Ei 's/^(MODULES=\([^\)]*)\)/\1 nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /etc/mkinitcpio.conf 2>&1 | tee -a "$LOG"
    echo "${OK} Nvidia modules added in /etc/mkinitcpio.conf"
  fi

  printf "\n%.0s" {1..1}
  printf "${INFO} Rebuilding ${YELLOW}Initramfs${RESET}...\n" 2>&1 | tee -a "$LOG"
  sudo mkinitcpio -P 2>&1 | tee -a "$LOG"

  printf "\n%.0s" {1..1}

  # Additional Nvidia steps
  NVEA="/etc/modprobe.d/nvidia.conf"
  if [ -f "$NVEA" ]; then
    printf "${INFO} Seems like ${YELLOW}nvidia_drm modeset=1 fbdev=1${RESET} is already added in your system..moving on."
    printf "\n"
  else
    printf "\n"
    printf "${YELLOW} Adding options to $NVEA..."
    sudo echo -e "options nvidia_drm modeset=1 fbdev=1" | sudo tee -a /etc/modprobe.d/nvidia.conf 2>&1 | tee -a "$LOG"
    printf "\n"
  fi

  # Additional for GRUB users
  if [ -f /etc/default/grub ]; then
      printf "${INFO} ${YELLOW}GRUB${RESET} bootloader detected\n" 2>&1 | tee -a "$LOG"
      
      # Check if nvidia-drm.modeset=1 is present
      if ! sudo grep -q "nvidia-drm.modeset=1" /etc/default/grub; then
          sudo sed -i -e 's/\(GRUB_CMDLINE_LINUX_DEFAULT=".*\)"/\1 nvidia-drm.modeset=1"/' /etc/default/grub
          printf "${OK} nvidia-drm.modeset=1 added to /etc/default/grub\n" 2>&1 | tee -a "$LOG"
      fi

      # Check if nvidia_drm.fbdev=1 is present
      if ! sudo grep -q "nvidia_drm.fbdev=1" /etc/default/grub; then
          sudo sed -i -e 's/\(GRUB_CMDLINE_LINUX_DEFAULT=".*\)"/\1 nvidia_drm.fbdev=1"/' /etc/default/grub
          printf "${OK} nvidia_drm.fbdev=1 added to /etc/default/grub\n" 2>&1 | tee -a "$LOG"
      fi

      # Regenerate GRUB configuration 
      if sudo grep -q "nvidia-drm.modeset=1" /etc/default/grub || sudo grep -q "nvidia_drm.fbdev=1" /etc/default/grub; then
         sudo grub-mkconfig -o /boot/grub/grub.cfg
         printf "${INFO} ${YELLOW}GRUB${RESET} configuration regenerated\n" 2>&1 | tee -a "$LOG"
      fi
    
      printf "${OK} Additional steps for ${YELLOW}GRUB${RESET} completed\n" 2>&1 | tee -a "$LOG"
  fi

  # Additional for systemd-boot users
  if [ -f /boot/loader/loader.conf ]; then
      printf "${INFO} ${YELLOW}systemd-boot${RESET} bootloader detected\n" 2>&1 | tee -a "$LOG"
    
      backup_count=$(find /boot/loader/entries/ -type f -name "*.conf.bak" | wc -l)
      conf_count=$(find /boot/loader/entries/ -type f -name "*.conf" | wc -l)
    
      if [ "$backup_count" -ne "$conf_count" ]; then
          find /boot/loader/entries/ -type f -name "*.conf" | while read imgconf; do
              # Backup conf
              sudo cp "$imgconf" "$imgconf.bak"
              printf "${INFO} Backup created for systemd-boot loader: %s\n" "$imgconf" 2>&1 | tee -a "$LOG"
              
              # Clean up options and update with NVIDIA settings
              sdopt=$(grep -w "^options" "$imgconf" | sed 's/\b nvidia-drm.modeset=[^ ]*\b//g' | sed 's/\b nvidia_drm.fbdev=[^ ]*\b//g')
              sudo sed -i "/^options/c${sdopt} nvidia-drm.modeset=1 nvidia_drm.fbdev=1" "$imgconf" 2>&1 | tee -a "$LOG"
          done

          printf "${OK} Additional steps for ${YELLOW}systemd-boot${RESET} completed\n" 2>&1 | tee -a "$LOG"
      else
          printf "${NOTE} ${YELLOW}systemd-boot${RESET} is already configured...\n" 2>&1 | tee -a "$LOG"
      fi
  fi

  printf "\n%.0s" {1..2}
}

nouveau(){
  LOG="Install-Logs/install-$(date +%d-%H%M%S)_nvidia.log"

  printf "${INFO} ${SKY_BLUE}blacklist nouveau${RESET}...\n"
  # Blacklist nouveau
  NOUVEAU="/etc/modprobe.d/nouveau.conf"
  if [ -f "$NOUVEAU" ]; then
    printf "${OK} Seems like ${YELLOW}nouveau${RESET} is already blacklisted..moving on.\n"
  else
    echo "blacklist nouveau" | sudo tee -a "$NOUVEAU" 2>&1 | tee -a "$LOG"

    # To completely blacklist nouveau (See wiki.archlinux.org/title/Kernel_module#Blacklisting 6.1)
    if [ -f "/etc/modprobe.d/blacklist.conf" ]; then
      echo "install nouveau /bin/true" | sudo tee -a "/etc/modprobe.d/blacklist.conf" 2>&1 | tee -a "$LOG"
    else
      echo "install nouveau /bin/true" | sudo tee "/etc/modprobe.d/blacklist.conf" 2>&1 | tee -a "$LOG"
    fi
  fi

  printf "\n%.0s" {1..2}
}
pacman(){
  LOG="Install-Logs/install-$(date +%d-%H%M%S)_pacman.log"

  echo -e "${NOTE} Adding ${MAGENTA}Extra Spice${RESET} in pacman.conf ... ${RESET}" 2>&1 | tee -a "$LOG"
  pacman_conf="/etc/pacman.conf"

  # Remove comments '#' from specific lines
  lines_to_edit=(
      "Color"
      "CheckSpace"
      "VerbosePkgLists"
      "ParallelDownloads"
  )

  # Uncomment specified lines if they are commented out
  for line in "${lines_to_edit[@]}"; do
      if grep -q "^#$line" "$pacman_conf"; then
          sudo sed -i "s/^#$line/$line/" "$pacman_conf"
          echo -e "${CAT} Uncommented: $line ${RESET}" 2>&1 | tee -a "$LOG"
      else
          echo -e "${CAT} $line is already uncommented. ${RESET}" 2>&1 | tee -a "$LOG"
      fi
  done

  # Add "ILoveCandy" below ParallelDownloads if it doesn't exist
  if grep -q "^ParallelDownloads" "$pacman_conf" && ! grep -q "^ILoveCandy" "$pacman_conf"; then
      sudo sed -i "/^ParallelDownloads/a ILoveCandy" "$pacman_conf"
      echo -e "${CAT} Added ${MAGENTA}ILoveCandy${RESET} after ${MAGENTA}ParallelDownloads${RESET}. ${RESET}" 2>&1 | tee -a "$LOG"
  else
      echo -e "${CAT} It seems ${YELLOW}ILoveCandy${RESET} already exists ${RESET} moving on.." 2>&1 | tee -a "$LOG"
  fi

  echo -e "${CAT} ${MAGENTA}Pacman.conf${RESET} spicing up completed ${RESET}" 2>&1 | tee -a "$LOG"


  # updating pacman.conf
  printf "\n%s - ${SKY_BLUE}Synchronizing Pacman Repo${RESET}\n" "${INFO}"
  sudo pacman -Sy

  printf "\n%.0s" {1..2}
}

pipewire(){
  LOG="Install-Logs/install-$(date +%d-%H%M%S)_pipewire.log"

  # Disabling pulseaudio to avoid conflicts and logging output
  echo -e "${NOTE} Disabling pulseaudio to avoid conflicts..."
  systemctl --user disable --now pulseaudio.socket pulseaudio.service >> "$LOG" 2>&1 || true

  # Pipewire
  echo -e "${NOTE} Installing ${SKY_BLUE}Pipewire${RESET} Packages..."
  for PIPEWIRE in "${pipewire[@]}"; do
      install_package "$PIPEWIRE" "$LOG"
  done

  for PIPEWIRE2 in "${pipewire_2[@]}"; do
      install_package_pacman "$PIPEWIRE" "$LOG"
  done

  echo -e "${NOTE} Activating Pipewire Services..."
  # Redirect systemctl output to log file
  systemctl --user enable --now pipewire.socket pipewire-pulse.socket wireplumber.service 2>&1 | tee -a "$LOG"
  systemctl --user enable --now pipewire.service 2>&1 | tee -a "$LOG"

  echo -e "\n${OK} Pipewire Installation and services setup complete!" 2>&1 | tee -a "$LOG"

  printf "\n%.0s" {1..2}
}

thunar(){
    LOG="Install-Logs/install-$(date +%d-%H%M%S)_thunar.log"

    # Thunar
    printf "${INFO} Installing ${SKY_BLUE}Thunar${RESET} Packages...\n"  
      for THUNAR in "${thunar[@]}"; do
        install_package "$THUNAR" "$LOG"
      done

    printf "\n%.0s" {1..1}

     # Check for existing configs and copy if does not exist
    for DIR1 in gtk-3.0 Thunar xfce4; do
      DIRPATH=~/.config/$DIR1
      if [ -d "$DIRPATH" ]; then
        echo -e "${NOTE} Config for ${MAGENTA}$DIR1${RESET} found, no need to copy." 2>&1 | tee -a "$LOG"
      else
        echo -e "${NOTE} Config for ${YELLOW}$DIR1${RESET} not found, copying from assets." 2>&1 | tee -a "$LOG"
        cp -r assets/$DIR1 ~/.config/ && echo "${OK} Copy $DIR1 completed!" || echo "${ERROR} Failed to copy $DIR1 config files." 2>&1 | tee -a "$LOG"
      fi
    done

    printf "\n%.0s" {1..2}
}
