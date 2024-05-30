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

# Install base dev tools
dev_tools() {
  # [TODO] Fedora support
  # [TODO] Debian support

  # Flatpak list
  flatpaks=(
    com.vscodium.codium     	# VS Codium
    com.getpostman.Postman  	# Postman
    io.github.shiftey.Desktop   # Git
  )

  flatpak install flathub -y "${flatpaks[@]}"
  
  # [TODO] tmux install and conf
  # [TODO] neovim install and conf

  # OpenVPN
  sudo pacman -S networkmanager-openvpn

  # Install docker
  sudo pacman -S docker
  # Enable the services
  sudo systemctl enable docker.service
  sudo systemctl enable docker.socket
  # Add the usergroup
  sudo usermod -aG docker $USER

  # QEMU and KVM
  sudo pacman -S --noconfirm qemu-full virt-manager virt-viewer dnsmasq vde2 bridge-utils openbsd-netcat
  sudo systemctl enable --now libvirtd

  sudo sed -i 's/#unix_sock_group = "libvirt"/unix_sock_group = "libvirt"/' /etc/libvirt/libvirtd.conf
  sudo sed -i 's/#unix_sock_ro_perms = "0777"/unix_sock_ro_perms = "0777"/' /etc/libvirt/libvirtd.conf
  sudo sed -i 's/#unix_sock_rw_perms = "0770"/unix_sock_rw_perms = "0770"/' /etc/libvirt/libvirtd.conf

  sudo systemctl restart libvirtd
  sudo usermod -aG libvirt $USER
  
  # Configure ZSH
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
  git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions 
  git clone https://github.com/agkozak/zsh-z $ZSH_CUSTOM/plugins/zsh-z
  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && sudo pacman -S fd && ~/.fzf/install

  # Install eza
  sudo pacman -S eza

  # Install pyenv and pyenv-virtualenv
  paru -S --noconfirm pyenv pyenv-virtualenv

  # [TODO] Move .zshrc file
} 

# Hacking tools
hack_tools() {
  flatpaks=(
    org.ghidra_sre.Ghidra    # Ghidra
    org.wireshark.Wireshark  # Wireshark
    org.radare.iaito	     # Radare
  )

  flatpak install flathub -y "${flatpaks[@]}"
  
  # [TODO] - Nebula container
  # [TODO] - Protostar container
  # [TODO] - web4pentest container
  # [TODO] - Kali container
  # [TODO] - ParrotOS tools
  # [TODO] - pwn virtualenv
}
