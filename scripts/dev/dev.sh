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

  # Nebula container
  NEBULA_DIR="$HOME/Sviluppi/containers/vuln_machines/nebula"
  mkdir -p "$NEBULA_DIR"
  cd "$NEBULA_DIR" || { print_error "[-] Failed navigating to nebula directory!"; exit 1; }

  if [[ ! -d .git ]]; then
    git clone https://github.com/packetgeek/nebula-docker . &> /dev/null
  fi

  if wget -O exploit-exercises-nebula.iso https://github.com/ExploitEducation/Nebula/releases/download/v5.0.0/exploit-exercises-nebula-5.iso &> /dev/null && \
     chmod +x build build-image &> /dev/null && \
     ./build-image &> /dev/null && \
     ./build &> /dev/null; then
    print_success "[+] Nebula machine installed!"
  else
    print_error "[-] Failed to install Nebula machine!"
  fi
  cd - &> /dev/null

  # Protostar container
  PROTOSTAR_DIR="$HOME/Sviluppi/containers/vuln_machines/protostar"
  mkdir -p "$PROTOSTAR_DIR"
  cd "$PROTOSTAR_DIR" || { print_error "[-] Failed navigating to protostar directory!"; exit 1; }

  if [[ ! -d .git ]]; then
    git clone https://github.com/th3happybit/protostar-docker.git . &> /dev/null
  fi

  if chmod u+x protostar.sh &> /dev/null && \
     ./protostar.sh build &> /dev/null && \
     ./protostar.sh run &> /dev/null; then
    print_success "[+] Protostar machine installed!"
  else
    print_error "[-] Failed to install Protostar machine!"
  fi
  cd - &> /dev/null

  # web4pentest container
  if docker pull justhumanz/web_for_pentest &> /dev/null && \
     docker run -itd --name pentest -p 8888:80 justhumanz/web_for_pentest &> /dev/null; then
    print_success "[+] Web4Pentest machine installed!"
  else
    print_error "[-] Failed to install Web4Pentest machine!"
  fi

  # [TODO] - Kali container
  # [TODO] - ParrotOS tools

  # PWN virtualenv
  if pyenv virtualenv pwn &> /dev/null && \
     pyenv activate pwn &> /dev/null && \
     pip install ropper ROPgadget pwntools &> /dev/null && \
     git clone https://github.com/radareorg/radare2 $HOME/.radare2 &> /dev/null && \
     $HOME/.radare2/sys/install.sh &> /dev/null && \
     git clone https://github.com/pwndbg/pwndbg $HOME/.pwndbg &> /dev/null && \
     $HOME/.pwndbg/setup.sh &> /dev/null; then
    print_success "[+] PWN environment configured!"
  else
    print_error "[-] Failed to configure PWN environment!"
  fi
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