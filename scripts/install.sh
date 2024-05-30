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
    echo -e "@andreatirelli3 dotfiles"
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

while true; do
    show_menu
    read -r choice
    case $choice in
        1)
            echo "Running the chroot script..."
            if [ -f "chroot/chroot.sh" ]; then
                bash chroot/chroot.sh
            else
                echo "The chroot script was not found."
            fi
            ;;
        2)
            echo "Running the GNOME setup script..."
            if [ -f "gnome/gnome.sh" ]; then
                bash gnome/gnome.sh
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
