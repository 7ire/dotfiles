#!/bin/bash

set -e  # Interrompe lo script se un qualsiasi comando restituisce un codice di uscita diverso da zero

# Debug function
# -------

# Print Functions
print_message() {
    local color="$1"
    local marker="$2"
    local message="$3"
    echo -e "\e[1;${color}m[${marker}] \e[0m$message\e[0m"
}
## errors
print_error() {
    print_message 31 "ERROR" "$1"  # Red color for errors (31)
}
## warnings
print_warning() {
    print_message 33 "WARNING" "$1"  # Yellow color for warnings (33)
}
## success
print_success() {
    print_message 32 "SUCCESS" "$1"  # Green color for successes (32)
}
## general 
print_info() {
    print_message 36 "INFO" "$1"  # Cyan color for general messages (36)
}

# Useful function
# -------

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
