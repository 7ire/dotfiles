#!/bin/bash

BASE_DIR="$HOME/dotfiles/linux/scripts"

# Import the utils function
source "$BASE_DIR/utils/utils.sh"
# Import the development function
source "$BASE_DIR/bin/dev.sh"

#============================
# CONSTANTS STRUCTS
#============================

# List of CLI packages to install
CLI_PKG=(
  tmux        # Terminal multiplexer
  neovim      # VI imporoved with plugin
  yazi        # File manager
  xh          # Fast HTTP request sender
  rnr         # Regex renamer
  lazygit     # Manage git
  lazydocker  # Manager docker
)

# List of packages to install
INSTALL_PKG=(
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

# List of hacking packages
HACK_PKG=(
  ghidra-desktop  # Ghidra (w/ desktop entry)
  wireshark-qt    # Wireshark
  burpsuite       # Burp Suite
)

# Base extensions
BASE_EXT=(
  pkief.material-icon-theme  # Material Icon Themes
  catppuccin.catppuccin-vsc  # Catppuccin for VSCode
  jeanp413.open-remote-ssh   # Open Remote - SSH
  mhutchie.git-graph         # Git Graph
  bbenoist.doxygen           # Docker
  formulahendry.code-runner  # Code runner
)

# Python extensions
PYTHON_EXT=(
  ms-python.python                          # [Python] Python
  ms-python.debugpy                         # [Python] Python Debugger
  donjayamanne.python-environment-manager   # [Python] Python Environment Manager
  ms-toolsai.jupyter                        # [Python] Jupyter
  ms-toolsai.jupyter-keymap                 # [Python] Jupyter Keymap
  ms-toolsai.jupyter-renderers              # [Python] Jupyter Notebook Renderers
  ms-toolsai.vscode-jupyter-cell-tags       # [Python] Jupyter Cell Tags
  ms-toolsai.vscode-jupyter-slideshow       # [Python] Jupyter Slide Show
)

# C++/Assembly extensions
CPP_ASM_EXT=(
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

# Rust extensions
RUST_EXT=(
  rust-lang.rust-analyzer  # [Rust] rust-analyzer
  vadimcn.vscode-lldb      # [Rust] CodeLLDB
  bungcip.better-toml      # [Rust] Better TOML
)

# Go lang extensions
GOLANG_EXT=(
  golang.go  # [Go] Go
)

# Dart extensions
DART_EXT=(
  dart-code.dart-code  # Dart
  dart-code.flutter    # Flutter
)

# JS extensions
JS_EXT=(
  xabikos.javascriptsnippets     # JavaScript (ES6) code snippets
  hansuxdev.bootstrap5-snippets  # Bootstrap 5 & Font Awesome Snippets
  ritwickdey.liveserver          # Live Server
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
    # Dev folder
    mkdir -p "$HOME/Sviluppi/"

    # Install CLI tools
    installer "${CLI_PKG[@]}" || print_error "[-] Failed to install CLI packages!"

    # Full zsh setup
    if [ -f "$HOME/dotfiles/linux/src/.zshrc" ]; then
      cp "$HOME/dotfiles/linux/src/.zshrc" "$HOME/"
      print_success "[+] Zsh configured!"
    else
      print_error "[-] Failed to configure Zsh!"
    fi

    # Full kitty setup
    if [ -d "$HOME/dotfiles/linux/src/.config/kitty" ]; then
      mkdir -p "$HOME/.config/"
      cp -r "$HOME/dotfiles/linux/src/.config/kitty" "$HOME/.config/"
      print_success "[+] Kitty configured!"
    else
      print_error "[-] Failed to configure Kitty!"
    fi

    # Full tmux setup
    if [ -d "$HOME/dotfiles/linux/src/.config/tmux" ]; then
      mkdir -p "$HOME/.config/"
      cp -r "$HOME/dotfiles/linux/src/.config/tmux" "$HOME/.config/"
      print_success "[+] TMUX configured!"
    else
      print_error "[-] Failed to configure TMUX!"
    fi

    # Full nvim setup
    if [ -d "$HOME/dotfiles/linux/src/.config/nvim" ]; then
      mkdir -p "$HOME/.config/"
      cp -r "$HOME/dotfiles/linux/src/.config/nvim" "$HOME/.config/"
      print_success "[+] Nvim configured!"
    else
      print_error "[-] Failed to configure Nvim!"
    fi
    
    conf_docker || print_error "[-] Failed to configure Docker!"
    conf_kvm || print_error "[-] Failed to configure QEMU and KVM!"

    # Base codium extensions
    codium_install_ext "${BASE_EXT[@]}"

    # Python for codium
    read -p "Do you want to configure codium for Python? [y/N]: " choice
    if [[ "$choice" =~ ^[Yy]$ ]]; then
      codium_install_ext "${PYTHON_EXT[@]}"
    fi

    # C++/ASM for codium
    read -p "Do you want to configure codium for C++/ASM? [y/N]: " choice
    if [[ "$choice" =~ ^[Yy]$ ]]; then
      codium_install_ext "${CPP_ASM_EXT[@]}"
    fi

    # Rust for codium
    read -p "Do you want to configure codium for Rust? [y/N]: " choice
    if [[ "$choice" =~ ^[Yy]$ ]]; then
      codium_install_ext "${RUST_EXT[@]}"
    fi

    # Go for codium
    read -p "Do you want to configure codium for Go? [y/N]: " choice
    if [[ "$choice" =~ ^[Yy]$ ]]; then
      codium_install_ext "${GOLANG_EXT[@]}"
    fi

    # Dart for codium
    read -p "Do you want to configure codium for Dart? [y/N]: " choice
    if [[ "$choice" =~ ^[Yy]$ ]]; then
      codium_install_ext "${DART_EXT[@]}"
    fi

    # Dart for codium
    read -p "Do you want to configure codium for JavaScript? [y/N]: " choice
    if [[ "$choice" =~ ^[Yy]$ ]]; then
      codium_install_ext "${JS_EXT[@]}"
    fi
  fi
fi

# Prompt user to install hack labs
read -p "Do you want to install and configure hacking lab? [y/N]: " choice
if [[ "$choice"  =~ ^[Yy]$ ]]; then
  print_warning "[*] Installing and configuring hacking lab ..."
  
  # Move to the home directory
  cd $HOME
  
  # Install hack tools
  installer "${HACK_PKG[@]}"

  # Vm folder
  mkdir -p "$HOME/Sviluppi/vm"

  # Nebula
  mkdir -p "$HOME/Sviluppi/vm/nebula/"
  cd "$HOME/Sviluppi/vm/nebula/"
  wget https://github.com/ExploitEducation/Nebula/releases/download/v5.0.0/exploit-exercises-nebula-5.iso

  cd "$HOME"

  # Protostar
  mkdir -p "$HOME/Sviluppi/vm/protostar/"
  cd "$HOME/Sviluppi/vm/protostar/"
  wget https://github.com/ExploitEducation/Protostar/releases/download/v2.0.0/exploit-exercises-protostar-2.iso

  cd "$HOME"

  # Web for pentester
  mkdir -p "$HOME/Sviluppi/vm/web4pentest/"
  cd "$HOME/Sviluppi/vm/web4pentest/"
  wget https://pentesterlab.com/exercises/web_for_pentester/iso
fi
