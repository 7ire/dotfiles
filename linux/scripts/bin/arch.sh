#!/bin/bash

# Get the absolute directory of the current script
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# Import the utils function
source "../utils/utils.sh"

#============================
# UTILITY FUNCTIONS
#============================

# AUR helper
aur() {
  # Check if there are conflict directory named 'paru'
  if [ -d "paru" ]; then
    # Remove the 'paru' directory if it exists
    rm -rf paru
  fi

  # Clone paru repository and install it
  if ! git clone https://aur.archlinux.org/paru.git &> /dev/null ||
     ! cd paru ||
     ! makepkg -si; then
    return 1
  fi

  # Update package manager server
  update_server

  if ! cd .. || ! rm -rf paru; then
    print_warning "[-] Couldn't remove the build files, do it manually."
  fi
  
  print_success "[+] AUR helper installed!"
}

# Pacman Configuration
conf_pacman() {
  # Pacman configuration file
  local PACMAN_CONF="/etc/pacman.conf"

  # Enable cool output in pacman
  if ! sudo sed -i 's/^#Color/Color/' "$PACMAN_CONF" ||
     ! grep -q '^ILoveCandy' "$PACMAN_CONF" && ! sudo sed -i '/^Color/a ILoveCandy' "$PACMAN_CONF"; then
     print_warning "[-] Couldn't rice pacman, do it manually."
  fi

  # Support services and packages for pacman
  if ! installer pacman-contrib ||
     ! sudo systemctl enable paccache.timer &> /dev/null; then
    return 1
  fi

  print_success "[+] Pacman configured!"
}

# Chaotic AUR
chaoticaur() {
  # Add the Chaotic AUR key and install the repository
  if ! sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com &> /dev/null ||
     ! sudo pacman-key --lsign-key 3056513887B78AEB &> /dev/null ||
     ! sudo pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' &> /dev/null ||
     ! sudo pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst' &> /dev/null; then
    return 1
  fi

  local chaotic_repo=$(cat <<EOF

[chaotic-aur]
Include = /etc/pacman.d/chaotic-mirrorlist
EOF
  )

  # Add the Chaotic AUR repository to pacman configuration if not already present
  if ! grep -q "\[chaotic-aur\]" /etc/pacman.conf; then
    echo "$chaotic_repo" | sudo tee -a /etc/pacman.conf > /dev/null
  fi

  # Update package manager server
  update_server

  print_success "[+] Chaotic AUR repository configured!"
}

