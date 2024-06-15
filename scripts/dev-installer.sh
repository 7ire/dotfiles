#!/bin/bash

# Import the utils function
source utils/utils.sh
# Import the development function
source bin/dev.sh

#============================
# CONSTANTS STRUCTS
#============================

# List of packages to install
INSTALL_PKG=(
  tmux                    # tmux
  neovim                  # neovim
  postman-bin             # Postman
  docker                  # Docker
  networkmanager-openvpn  # OpenVPN
  # QEMU and KVM
  qemu-full
  virt-manager
  virt-viewer
  dnsmasq
  vde2
  bridge-utils
  openbsd-netcat
  # Pyenv
  pyenv
  pyenv-virtualenv
  eza   # Better ls
)

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

# Prompt user to install and configure base development kits
read -p "Do you want to install base development kits? [y/N]: " choice
if [[ "$choice" =~ ^[Yy]$ ]]; then
  print_warning "[*] Installing and configuring base develompment kits"

  if ! installer "${INSTALL_PKG[@]}"; then
    print_error "[-] Failed to install specified packages!"
  else
    # Full zsh setup
    if [ -f "$HOME/dotfiles/.zshrc" ]; then
      cp "$HOME/dotfiles/.zshrc" "$HOME/"
      print_success "[+] Zsh configured!"
    else
      print_error "[-] Failed to configure Zsh!"
    fi
    
    docker || print_error "[-] Failed to configure Docker!"
    kvm || print_error "[-] Failed to configure QEMU and KVM!"
  fi
fi