#!/bin/bash

# Check if sudo password is cached, if not ask for it
sudo -v || exit 1

#============================
# DEBUG FUNCTIONS
#============================

# Output debug - success
print_success() {
  local message="$1"
  # Format message with green text.
  echo -e "\e[32m$message\e[0m"
}

# Output debug - error
print_error() {
  local message="$1"
  # Format message with red text.
  echo -e "\e[31m$message\e[0m"
}

# Output debug - info
print_info() {
  local message="$1"
  # Format message with cyan text.
  echo -e "\e[36m$message\e[0m"
}

# Output debug - warning
print_warning() {
  local message="$1"
  # Format message with yellow text.
  echo -e "\e[33m$message\e[0m"
}

#============================
# UTILITY FUNCTIONS
#============================

# Package installation
# It is an abstraction to not over duplicate the command 'paru -S --noconfirm'.
installer() {
  if [ "$#" -eq 0 ]; then
    print_error "No packages specified to install!"
    return 1  # Do nothing and exit the function
  fi

  # Check if 'paru' is installed
  if ! command -v paru &> /dev/null; then
    print_error "paru is not installed! Please install it first."
    return 1
  fi

  # Check if sudo password is cached, if not ask for it
  sudo -v || exit 1

  local packages=("$@")

  # Update the mirror server
  paru -Syy &> /dev/null

  for package in "${packages[@]}"; do
    # Install the package without confirmation
    if paru -S --noconfirm "$package" &> /dev/null; then
      print_success "[+] $package installed successfully!"
    else
      print_error "[-] $package failed to install."
    fi
  done
}

#============================
# CONFIGURATION FUNCTIONS
#============================

# Development tools
dev_tools() {
  mkdir -p "$HOME/Sviluppi"
  
  print_warning "[*] Installing dev tools ..."
  packages=(
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

  installer "${packages[@]}"

  # Full zsh setup
  if [ -f "$HOME/dotfiles/.zshrc" ]; then
    cp $HOME/dotfiles/.zshrc $HOME/
    print_success "[+] Zsh configured!"
  else
    print_error "[-] Failed to configure Zsh!"
  fi

  # TMUX setup
  if [ -d "$HOME/dotfiles/.config/tmux" ]; then
    mkdir -p $HOME/.config/
    cp -r $HOME/dotfiles/.config/tmux $HOME/.config/
    print_success "[+] TMUX configured!"
  else
    print_error "[-] Failed to configure TMUX!"
  fi

  # Docker setup
  if sudo systemctl enable docker.service &> /dev/null && sudo systemctl enable docker.socket && sudo usermod -aG docker $USER; then
    print_success "[+] Docker configured!"
  else
    print_error "[-] Failed to configure Docker!"
  fi

  # QEMU and KVM setup
  if sudo systemctl enable --now libvirtd &> /dev/null && \
     sudo sed -i 's/#unix_sock_group = "libvirt"/unix_sock_group = "libvirt"/' /etc/libvirt/libvirtd.conf &> /dev/null && \
     sudo sed -i 's/#unix_sock_ro_perms = "0777"/unix_sock_ro_perms = "0777"/' /etc/libvirt/libvirtd.conf &> /dev/null && \
     sudo sed -i 's/#unix_sock_rw_perms = "0770"/unix_sock_rw_perms = "0770"/' /etc/libvirt/libvirtd.conf &> /dev/null && \
     sudo systemctl restart libvirtd &> /dev/null && \
     sudo usermod -aG libvirt "$USER"; then
    print_success "[+] QEMU and KVM configured!"
  else
    print_error "[-] Failed to configure QEMU and KVM!"
  fi
}

hack_tools() {
  print_warning "[*] Installing hacking tools ..."
  packages=(
    ghidra
    wireshark-qt
    termshark-git
  )
  installer "${packages[@]}"

  # [TODO] - Nebula container
  # [TODO] - Protostar container
  # [TODO] - web4pentest container
  # [TODO] - Kali container
  # [TODO] - ParrotOS tools
  # [TODO] - pwn virtualenv
}

#============================
# MAIN BODY
#============================

# Ensure the script is not run as root
if [ "$EUID" -eq 0 ]; then
  print_error "Please do not run this script as root."
  exit 1
fi

# Move to the home directory
cd $HOME

# Prompt user to install development tools
read -p "Do you want to install the development tools? [y/N]: " choice
if [[ "$choice" =~ ^[Yy]$ ]]; then
  dev_tools || print_error "[-] Failed to install development tools. Continuing..."
fi

# Prompt user to install hacking tools
read -p "Do you want to install the hacking tools? [y/N]: " choice
if [[ "$choice" =~ ^[Yy]$ ]]; then
  hack_tools || print_error "[-] Failed to install hacking tools. Continuing..."
fi