#!/bin/sh

. ./common-script.sh

setup_bspwm() {
    printf "%b\n" "${YELLOW}Installing BSPWM...${RC}"
    sudo pacman -S --needed --noconfirm base-devel bspwm sxhkd picom libxcb flameshot lxappearance feh mate-polkit
}

setup_pipewire() {
    systemctl --user disable --now pulseaudio.socket pulseaudio.service
    printf "%b\n" "${YELLOW}Installing pipewire if not already installed${RC}"
    sudo pacman -S --needed --noconfirm pipewire wireplumber pipewire-audio pipewire-alsa pipewire-pulse sof-firmware
    systemctl --user --enable --now pipewire.socket pipewire-pulse.socket wireplumber.service pipewire.service
}

setup_thunar() {
    printf "%b\n" "${YELLOW}Installing thunar if not already installed${RC}"
    sudo pacman -S thunar thunar-volman tumbler ffmpegthumbnailer thunar-archive-plugin xarchiver
}
setup_dotfiles() {
    ./dotfiles-setup.sh
    cd dotfiles/ # Hardcoded path, maybe not the best.
    stow bspwm 
}

setup_bluetooth() {
    sudo pacman -S --needed --noconfirm bluez bluez-utils blueman
    sudo systemctl enable --now bluetooth.service
}

install_nerd_font() {
    printf "%b\n" "${YELLOW}Install Nerd-fonts if not already installed${RC}"
    sudo pacman -S --neeeded --noconfirm nerd-fonts
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
    sudo pacman -S --needed --noconfirm xorg-xinit xorg-server
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
        enableService "$DM" 
    fi
}

checkEnv
checkEscalationTool
setupDisplayManager
setupbspwm
install_nerd_font
setup_dotfiles
configure_backgrounds
