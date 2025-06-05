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
printf "%b\n" "Current display manager: $currentdm"
if [ "$currentdm" = "none" ]; then
    printf "%b\n" "${YELLOW}--------------------------" 
    printf "%b\n" "${YELLOW}Pick your Display Manager" 
    printf "%b\n" "${YELLOW}1. SDDM" 
    printf "%b\n" "${YELLOW}2. LightDM" 
    printf "%b\n" "${YELLOW}3. GDM ${RC}"
    printf "%b\n" "${YELLOW}4. Ly - TUI Display Manager"
    printf "%b\n" "${YELLOW}5. None" 
    printf "%b" "${YELLOW}Please select one:"
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
    printf "%b\n" "$DM installed successfully"
    sudo systemctl enable "$DM"
fi


