#!/bin/sh

. ../common-script.sh
. ../common-service-script.sh

setupbspwm() {
    printf "%b\n" "${YELLOW}Installing BSPWM...${RC}"
    case "$PACKAGER" in # Install pre-Requisites
        pacman)
            "$ESCALATION_TOOL" "$PACKAGER" -S --needed --noconfirm base-devel libx11 libxinerama libxft imlib2 git unzip flameshot lxappearance feh mate-polkit
            ;;
        *)
            printf "%b\n" "${RED}Unsupported package manager: ""$PACKAGER""${RC}"
            exit 1
            ;;
    esac
}

setupPicomDependencies() {
    printf "%b\n" "${YELLOW}Installing Picom dependencies if not already installed${RC}"
    
    case "$PACKAGER" in
        pacman)
            "$ESCALATION_TOOL" "$PACKAGER" -S --needed --noconfirm libxcb meson libev uthash libconfig
            ;;
        *)
            printf "%b\n" "${RED}Unsupported package manager: $PACKAGER${RC}"
            exit 1
            ;;
    esac

    printf "%b\n" "${GREEN}Picom dependencies installed successfully${RC}"
}

setup_dotfiles() {
    ./dotfiles-setup.sh
    cd dotfiles/ # Hardcoded path, maybe not the best.
    stow bspwm 
}

install_nerd_font() {
    printf "%b\n" "${YELLOW}Install Nerd-fonts if not already installed${RC}"

    case "$PACKAGER" in
        pacman)
            "$ESCALATION_TOOL" "$PACKAGER" -S --neeeded --noconfirm nerd-fonts
            ;;
        *)
            printf "%b\n" "${RED}Unsupported package manager: $PACKAGER${RC}"
            exit 1
            ;;
    esac

    printf "%b\n" "${GREEN}Nerd-fonts installed successfully${RC}"
}

picom_animations() {
    # clone the repo into .local/share & use the -p flag to avoid overwriting that dir
    mkdir -p "$HOME/.local/share/"
    if [ ! -d "$HOME/.local/share/ftlabs-picom" ]; then
        if ! git clone https://github.com/FT-Labs/picom.git "$HOME/.local/share/ftlabs-picom"; then
            printf "%b\n" "${RED}Failed to clone the repository${RC}"
            return 1
        fi
    else
        printf "%b\n" "${GREEN}Repository already exists, skipping clone${RC}"
    fi

    cd "$HOME/.local/share/ftlabs-picom" || { printf "%b\n" "${RED}Failed to change directory to picom${RC}"; return 1; }

    # Build the project
    if ! meson setup --buildtype=release build; then
        printf "%b\n" "${RED}Meson setup failed${RC}"
        return 1
    fi

    if ! ninja -C build; then
        printf "%b\n" "${RED}Ninja build failed${RC}"
        return 1
    fi

    # Install the built binary
    if ! "$ESCALATION_TOOL" ninja -C build install; then
        printf "%b\n" "${RED}Failed to install the built binary${RC}"
        return 1
    fi

    printf "%b\n" "${GREEN}Picom animations installed successfully${RC}"
}

configure_backgrounds() {
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
}

setupDisplayManager() {
    printf "%b\n" "${YELLOW}Setting up Xorg${RC}"
    case "$PACKAGER" in
        pacman)
            "$ESCALATION_TOOL" "$PACKAGER" -S --needed --noconfirm xorg-xinit xorg-server
            ;;
        *)
            printf "%b\n" "${RED}Unsupported package manager: $PACKAGER${RC}"
            exit 1
            ;;
    esac
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
        printf "%b\b" "${YELLOW}4. Ly - TUI Display Manager ${RC}"
        printf "%b\n" "${YELLOW}5. None ${RC}" 
        printf "%b" "${YELLOW}Please select one: ${RC}"
        read -r choice
        case "$choice" in
            1)
                DM="sddm"
                ;;
            2)
                DM="lightdm"
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
        case "$PACKAGER" in
            pacman)
                "$ESCALATION_TOOL" "$PACKAGER" -S --needed --noconfirm "$DM"
                if [ "$DM" = "lightdm" ]; then
                    "$ESCALATION_TOOL" "$PACKAGER" -S --needed --noconfirm lightdm-gtk-greeter
                fi
                ;;
            *)
                printf "%b\n" "${RED}Unsupported package manager: $PACKAGER${RC}"
                exit 1
                ;;
        esac
        printf "%b\n" "${GREEN}$DM installed successfully${RC}"
        enableService "$DM"
        
    fi
}

checkEnv
checkEscalationTool
setupDisplayManager
setupbspwm
setupPicomDependencies
install_nerd_font
picom_animations
clone_config_folders
configure_backgrounds
