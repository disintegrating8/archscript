#!/bin/bash

ibus=(
  ibus
  ibus-hangul
)

fcitx=(
  fcitx5-im
  fcitx5-hangul
)

cjk_input(){        
    printf "%b\n" "${YELLOW}--------------------------${RC}" 
    printf "%b\n" "${YELLOW}Pick CJK Input Method ${RC}"
    printf "%b\n" "${YELLOW}1. Ibus ${RC}"
    printf "%b\n" "${YELLOW}2. Fcitx ${RC}"
    printf "%b\n" "${YELLOW}3. Kime ${RC}"
    printf "%b\n" "${YELLOW}4. None ${RC}"
    printf "%b" "${YELLOW}Please select one: ${RC}"
    read -r choice
    case "$choice" in
        1)
            sudo pacman -S --needed --noconfirm ibus{,-hangul}
            ;;
        2)
            sudo pacman -S --needed --noconfirm fcitx5-{im,hangul} 
            ;;
        3)
            yay -S --needed --noconfirm kime-bin
            ;;
        4)
            printf "%b\n" "${GREEN}No input method will be installed${RC}"\
            ;;
        *)
            printf "%b\n" "${RED}Invalid selection! Please choose 1, 2, 3, or 4.${RC}"
            ;;
    esac
}
