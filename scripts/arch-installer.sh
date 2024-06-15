#!/bin/bash

# Import the utils function
source utils/utils.sh
# Import the system function
source bin/sys.sh
# Import the arch function
source bin/arch.sh

#============================
# CONSTANTS STRUCTS
#============================

#============================
# CONFIGURATION FUNCTIONS
#============================

#============================
# MAIN BODY
#============================

# Ensure the script is not run as root
root_checker

# Move to the home directory
cd $HOME

# Prompt user to install an AUR helper
read -p "Do you want to install the AUR helper? [y/N]: " choice
if [[ "$choice" =~ ^[Yy]$ ]]; then
  print_warning "[*] Installing AUR helper ..."
  aur || print_error "[-] Failed to install AUR helper!"
fi

# Prompt user to configure pacman
read -p "Do you want to configure pacman? [y/N]: " choice
if [[ "$choice" =~ ^[Yy]$ ]]; then
  print_warning "[*] Configuring pacman ..."
  conf_pacman || print_error "[-] Failed to configure pacman!"
fi

# Prompt user to configure Chaotic AUR repository
read -p "Do you want to configure Chaotic AUR? [y/N]: " choice
if [[ "$choice" =~ ^[Yy]$ ]]; then
  print_warning "[*] Configuring Chaotic AUR repository ..."
  chaoticaur || print_error "[-] Failed to configure Chaotic AUR repository!"
fi

# Prompt user to update the mirrorlist
read -p "Do you want to update the mirrorlist? [y/N]: " choice
if [[ "$choice" =~ ^[Yy]$ ]]; then
  print_warning "[*] Generating mirrorlist with reflector ..."
  
  # Install necessary packages
  if ! installer reflector rsync curl; then
    print_error "[-] Failed to install necessary packages!"
  else
    gen_mirrorlist || print_error "[-] Failed to update mirrorlist!"
  fi
fi

# Prompt user to configure SSH
read -p "Do you want to enable SSH? [y/N]: " choice
if [[ "$choice" =~ ^[Yy]$ ]]; then
  print_warning "[*] Enabling SSH ..."

  if ! sudo systemctl enable sshd &> /dev/null; then
    print_error "[-] Failed to enable SSH!"
  else
    print_success "[+] SSH enabled!"
  fi
fi

# Prompt user to configure Bluetooth
read -p "Do you want to configure Bluetooth? [y/N]: " choice
if [[ "$choice" =~ ^[Yy]$ ]]; then
  print_warning "[*] Configuring Bluetooth ..."

  # Install the required packages
  if ! installer bluez bluez-utils || ! sudo systemctl enable bluetooth &> /dev/null; then
    print_error "[-] Failed to install Bluetooth in the system!"
  else
    # Enable ControllerMode = dual
    bt_controllermode_dual || print_warning "[-] Failed to update ControllerMode in Bluetooth configuration! (Check bluetooth main.conf and do it manually)"
    # Enable Experimental Kernel
    bt_kernel_exp || print_warning "[-] Failed to update Experimental feature in Bluetooth configuration! (Check bluetooth main.conf and do it manually)"

    # Restart Bluetooth service
    if ! sudo systemctl restart bluetooth &> /dev/null; then
      print_warning "[-] Failed to restart Bluetooth service! I will continue the script, just reboot after the script it is done"
    fi

    print_success "[+] Bluetooth configured!"
  fi
fi