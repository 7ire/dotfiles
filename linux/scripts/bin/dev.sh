#!/bin/bash

BASE_DIR="$HOME/dotfiles/linux/scripts"

# Import the utils function
source "$BASE_DIR/utils/utils.sh"

# Docker setup
conf_docker() {
  if sudo systemctl enable docker.service &> /dev/null && 
    sudo systemctl enable docker.socket &> /dev/null && 
    sudo usermod -aG docker "$USER"; then
    print_success "[+] Docker configured!"
  else
    return 1
  fi
}

# QEMU and KVM setup
conf_kvm() {
  if sudo systemctl enable --now libvirtd &> /dev/null && \
     sudo sed -i 's/#unix_sock_group = "libvirt"/unix_sock_group = "libvirt"/' /etc/libvirt/libvirtd.conf &> /dev/null && \
     sudo sed -i 's/#unix_sock_ro_perms = "0777"/unix_sock_ro_perms = "0777"/' /etc/libvirt/libvirtd.conf &> /dev/null && \
     sudo sed -i 's/#unix_sock_rw_perms = "0770"/unix_sock_rw_perms = "0770"/' /etc/libvirt/libvirtd.conf &> /dev/null && \
     sudo systemctl restart libvirtd &> /dev/null && \
     sudo usermod -aG libvirt "$USER"; then
    print_success "[+] QEMU and KVM configured!"
  else
    return 1
  fi
}

# Codium extension installation
codium_install_ext() {
  local EXT_LIST=("$@")
  
  for ext in "${EXT_LIST[@]}"; do
    if ! codium --install-extension "$ext"; then
      print_error "[-] Failed to install Codium extension: $ext"
    else
      print_success "[+] Successfully installed Codium extension: $ext"
    fi
  done
}

#============================
# DOCKER CONTAINERS
#============================

# Nebula container
nebula() {
  NEBULA_DIR="$HOME/Sviluppi/containers/vuln_machines/nebula"
  mkdir -p "$NEBULA_DIR"
  cd "$NEBULA_DIR" || { print_error "[-] Failed navigating to nebula directory!"; exit 1; }

  if [[ ! -d .git ]]; then
    git clone https://github.com/packetgeek/nebula-docker . &> /dev/null
  fi

  if wget -O exploit-exercises-nebula-5.iso https://github.com/ExploitEducation/Nebula/releases/download/v5.0.0/exploit-exercises-nebula-5.iso &> /dev/null && \
     chmod +x build build-image &> /dev/null && \
     ./build-image &> /dev/null && \
     ./build &> /dev/null; then
    print_success "[+] Nebula machine installed!"
  else
    return 1
  fi
}

# Protostar container
protostar() {
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
    return 1
  fi
}

# Web4Pentest container
web4pentest() {
  if docker pull justhumanz/web_for_pentest &> /dev/null && \
     docker run -itd --name pentest -p 8888:80 justhumanz/web_for_pentest &> /dev/null; then
    print_success "[+] Web4Pentest machine installed!"
  else
    return 1
  fi
}