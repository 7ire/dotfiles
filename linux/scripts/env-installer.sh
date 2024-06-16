#!/bin/bash

# Get the absolute directory of the current script
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# Import the utils function
source "$SCRIPT_DIR/utils/utils.sh"
# Import the envirorment function
source "$SCRIPT_DIR/bin/env.sh"

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

# Prompt user to regenerate GRUB conf
read -p "Do you want to regenerate GRUB configuration (Do it if you are in win dualboot) ? [y/N]: " choice
if [[ "$choice" =~ ^[Yy]$ ]]; then
  print_warning "[*] Regenerating GRUB configuration ..."

  gen_grub || print_error "[-] Failed to regenerate GRUB configuration!"
fi

# Prompt user to configure system snapshot
read -p "Do you want to configure system snapshot? [y/N]: " choice
if [[ "$choice" =~ ^[Yy]$ ]]; then
  print_warning "[*] Installing and configuring Snapper ..."

  # Install Snapper
  if ! installer snapper; then
    print_error "[-] Failed to install Snapper!"
  else
    read -rp "Enter the device (e.g., /dev/mapper/root or /dev/nvme0n1p2): " device
    conf_snapper "$device"
  fi
fi

# TODO: fingerprint configuration

# Prompt user to generate a new SSH key
read -p "Do you want to generate a new SSH key? [y/N]: " choice
if [[ "$choice" =~ ^[Yy]$ ]]; then
  print_warning "[*] Generating new SSH key ..."

  read -p "Enter the email for the SSH key: " ssh_email
  read -p "Enter the name for the SSH key: " ssh_key_name
  ssh_keygen "$ssh_email" "$ssh_key_name" || print_error "[-] Failed to generate SSH key!"
fi

# Prompt user to import SSH keys
read -p "Do you want to import SSH keys? [y/N]: " choice
if [[ "$choice" =~ ^[Yy]$ ]]; then
  print_warning "[*] Importing SSH keys ..."

  read -p "Enter the path to import SSH keys from: " ssh_import_path
  ssh_keyimport "$ssh_import_path" || print_error "[-] Failed to import SSH keys!"
fi

# Prompt user to configure Git
read -p "Do you want to configure Git? [y/N]: " choice
if [[ "$choice" =~ ^[Yy]$ ]]; then
  print_warning "[*] Configuring git indenity + SSH key ..."

  read -p "Enter the email for the Git config: " git_email
  read -p "Enter the name for the Git config: " git_name
  conf_git "$git_email" "$git_name" || print_error "[-] Failed to configure Git!"
fi

# Prompt user to import VPN configuration
read -p "Do you want to import a VPN configuration? [y/N]: " choice
if [[ "$choice" =~ ^[Yy]$ ]]; then
  print_warning "[*] Importing VPN configuration files ..."

  vpn_import || print_error "[-] Failed to import VPN configuration!"
fi

# Prompt user to configure Zsh
read -p "Do you want to configure Zsh? [y/N]: " choice
if [[ "$choice" =~ ^[Yy]$ ]]; then
  print_warning "[*] Configuring Zsh ..."

  # Install zsh and set it as default shell
  if ! installer zsh &> /dev/null || ! chsh -s /bin/zsh; then
    print_error "[-] Failed to install and set Zsh as default shell!"
  else
    conf_zsh
  fi
fi

# Prompt user to configure fingerprint hardware
read -p "Do you want to configure fingerprint login? [y/N]: "  choice
if [[ "$choice" =~ ^[Yy]$ ]]; then
  print_warning "[*] Importing VPN configuration files ..."

  if ! installer fprintd libfprint imagemagick usbutils; then
    print_error "[-] Failed to install required packages for fingerprint reader!"
  else
    sudo usermod -aG input "$USER"

    conf_fprint
  fi
fi