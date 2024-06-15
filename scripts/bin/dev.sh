#!/bin/bash

# Import the utils function
source ../utils/utils.sh

conf_nvim() {}

conf_tmux() {}

conf_zsh() {}

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
kvm() {
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

# Codium Extension installer
codium_install_ext() {
  for ext in "${EXT_LIST[@]}"; do
    if ! codium --install-extension "$ext"; then
      print_error "[-] Failed to install Codium extension: $ext"
    fi
  done
}

# Python
python_env() {
  local EXT_LIST=(
    ms-python.python                          # [Python] Python
    ms-python.debugpy                         # [Python] Python Debugger
    donjayamanne.python-environment-manager   # [Python] Python Environment Manager
    ms-toolsai.jupyter                        # [Python] Jupyter
    ms-toolsai.jupyter-keymap                 # [Python] Jupyter Keymap
    ms-toolsai.jupyter-renderers              # [Python] Jupyter Notebook Renderers
    ms-toolsai.vscode-jupyter-cell-tags       # [Python] Jupyter Cell Tags
    ms-toolsai.vscode-jupyter-slideshow       # [Python] Jupyter Slide Show
  )

  for ext in "${EXT_LIST[@]}"; do
    if ! codium --install-extension "$ext"; then
      print_error "[-] Failed to install Codium extension: $ext"
    fi
  done
}

# C++/Assembly
cpp_env() {
  local EXT_LIST=(
    13xforever.language-x86-64-assembly         # [C/C++] x86 and x86_64 Assembly
    bbenoist.doxygen                            # [C/C++] Doxygen
    cschlosser.doxdocgen                        # [C/C++] Doxygen Documentation Generator
    cheshirekow.cmake-format                    # [C/C++] cmake-format
    twxs.cmake                                  # [C/C++] CMake
    franneck94.c-cpp-runner                     # [C/C++] C/C++ Runner
    franneck94.vscode-c-cpp-config              # [C/C++] C/C++ Config
    jeff-hykin.better-cpp-syntax                # [C/C++] Better C++ Syntax
    franneck94.vscode-c-cpp-dev-extension-pack  # [C/C++] C/C++ Extension Pack
  )
  
  for ext in "${EXT_LIST[@]}"; do
    if ! codium --install-extension "$ext"; then
      print_error "[-] Failed to install Codium extension: $ext"
    fi
  done
}

# Rust
rust_env() {
  local EXT_LIST=(
    rust-lang.rust-analyzer  # [Rust] rust-analyzer
    vadimcn.vscode-lldb      # [Rust] CodeLLDB
    bungcip.better-toml      # [Rust] Better TOML
  )
  
  for ext in "${EXT_LIST[@]}"; do
    if ! codium --install-extension "$ext"; then
      print_error "[-] Failed to install Codium extension: $ext"
    fi
  done
}

golang_env() {
  local EXT_LIST=(
    golang.go  # [Go] Go
  )
  
  for ext in "${EXT_LIST[@]}"; do
    if ! codium --install-extension "$ext"; then
      print_error "[-] Failed to install Codium extension: $ext"
    fi
  done
}

dart_env() {}

js_env() {}