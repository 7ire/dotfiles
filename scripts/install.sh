#!/bin/bash

#============================
# ASCII ART FUNCTION
#============================

show_ascii_art() {
    c6="\e[36m"
    c4="\e[34m"
    reset="\e[0m"
    echo -e "${c6}       /\\"
    echo -e "${c6}      /  \\"
    echo -e "${c6}     /\\   \\"
    echo -e "${c4}    /      \\"
    echo -e "${c4}   /   ,,   \\"
    echo -e "${c4}  /   |  |  -\\"
    echo -e "${c4} /_-''    ''-_\\${reset}"
    echo -e "@andreatirelli3 dotfiles${reset}"
}

#============================
# MENU FUNCTION
#============================

show_menu() {
    clear
    show_ascii_art
    echo "1) Run chroot script"
    echo "2) Run GNOME setup script"
    echo "q) Quit"
    echo -n "Choose an option: "
}

#============================
# MAIN LOGIC
#============================

# Get the absolute directory of the current script
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

while true; do
    show_menu
    read -r choice
    case $choice in
        1)
            echo "Running the chroot script..."
            if [ -f "$SCRIPT_DIR/../chroot/chroot.sh" ]; then
                bash "$SCRIPT_DIR/../chroot/chroot.sh"
            else
                echo "The chroot script was not found."
            fi
            ;;
        2)
            echo "Running the GNOME setup script..."
            if [ -f "$SCRIPT_DIR/../gnome/gnome.sh" ]; then
                bash "$SCRIPT_DIR/../gnome/gnome.sh"
            else
                echo "The GNOME setup script was not found."
            fi
            ;;
        q|Q)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid option, please try again."
            ;;
    esac
    echo -n "Press Enter to continue..."
    read -r
done
