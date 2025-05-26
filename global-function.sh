dotfiles(){
    printf "${NOTE} Cloning and Installing ${SKY_BLUE}dotfiles${RESET}....\n"
    REPO_URL="https://github.com/disintegrating8/dotfiles.git"
    REPO_DIR="$HOME/dotfiles"

    if ! command -v stow &> /dev/null
    then
      echo "Stow not installed! Installing Stow..."
      if ! sudo pacman -S stow --noconfirm; then
        echo "Failed to install Stow. Exiting."
        exit 1
      fi
    fi

    cd ~

    # Check if git is installed
    if ! command -v git &> /dev/null
    then
        echo "${INFO} Git not found! ${SKY_BLUE}Installing Git...${RESET}"
        if ! sudo pacman -S git --noconfirm; then
            echo "Failed to install Git. Exiting."
            exit 1
        fi
    fi

    if [ -d "$REPO_DIR" ]; then
        echo "${YELLOW}$REPO_DIR exists. Updating the repository... ${RESET}"
        cd "$REPO_DIR"
        git stash && git pull
    else
        echo "${MAGENTA}$Distro_DIR does not exist. Cloning the repository...${RESET}"
        git clone --depth=1 "$REPO_URL" "$REPO_DIR"
        cd "$REPO_DIR"
    fi


    # Check if the repository already exists
    if [ -d "$REPO_NAME" ]; then
      echo "Repository '$REPO_NAME' already exists. Skipping clone"
    else
      git clone --depth=1 "$REPO_URL"
    fi

    # Check if the clone was successful
    if [ $? -eq 0 ]; then
      cd "$REPO_DIR"
      #stow --adopt bash
      #stow --adopt starship
      #stow --adopt kitty
      #stow --adopt nvim
    else
      echo "Failed to clone the repository."
      exit 1
    fi
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

