#!/bin/bash

#============================
# DEBUG FUNCTIONS
#============================

# Output debug message with color
print_debug() {
  local color="$1"
  local message="$2"
  echo -e "\e[${color}m${message}\e[0m"
}

# Wrapper functions for specific colors
print_success() {
  print_debug "32" "$1"
}

print_error() {
  print_debug "31" "$1"
}

print_info() {
  print_debug "36" "$1"
}

print_warning() {
  print_debug "33" "$1"
}

#============================
# PRIMITIVE FUNCTIONS
#============================

# Arch Linux: update package manager server
arch_update_server() {
  if ! sudo pacman -Syy &> /dev/null || ! paru -Syy &> /dev/null; then
    return 1
  fi
}

# Arch Linux: install packages
arch_installer() {
  if ! command -v paru &> /dev/null; then
    print_error "[-] Paru is not installed! Please install it first."
    return 1
  fi

  local PKGs=("$@")
  for pkg in "${PKGs[@]}"; do
    if paru -S --noconfirm "$pkg" &> /dev/null; then
      print_success "[+] $pkg installed successfully!"
    else
      print_error "[-] $pkg failed to install!"
    fi
  done
}

# Arch Linux: remove packages
arch_remover() {
  if ! command -v paru &> /dev/null; then
    print_error "[-] Paru is not installed! Please install it first."
    return 1
  fi

  local PKGs=("$@")
  if ! paru -Rcns --noconfirm "${PKGs[@]}" &> /dev/null; then
    return 1
  fi
}

# Fedora: update package manager server
fedora_update_server() {
  if ! sudo dnf makecache &> /dev/null; then
    return 1
  fi
}

# Fedora: install packages
fedora_installer() {
  local PKGs=("$@")
  for pkg in "${PKGs[@]}"; do
    if sudo dnf install -y "$pkg" &> /dev/null; then
      print_success "[+] $pkg installed successfully!"
    else
      print_error "[-] $pkg failed to install!"
    fi
  done
}

# Fedora: remove packages
fedora_remover() {
  local PKGs=("$@")
  if ! sudo dnf remove -y "${PKGs[@]}" &> /dev/null; then
    return 1
  fi
}

# Debian: update package manager server
debian_update_server() {
  if ! sudo apt update &> /dev/null; then
    return 1
  fi
}

# Debian: install packages
debian_installer() {
  local PKGs=("$@")
  for pkg in "${PKGs[@]}"; do
    if sudo apt install -y "$pkg" &> /dev/null; then
      print_success "[+] $pkg installed successfully!"
    else
      print_error "[-] $pkg failed to install!"
    fi
  done
}

# Debian: remove packages
debian_remover() {
  local PKGs=("$@")
  if ! sudo apt remove -y "${PKGs[@]}" &> /dev/null; then
    return 1
  fi
}

#============================
# UTILITY FUNCTIONS
#============================

# Check root execution
root_checker() {
  if [ "$EUID" -eq 0 ]; then
    print_error "[-] FATAL: Please do not run this script as root."
    exit 1
  fi
}

# Detect Linux Distribution
detect_distro() {
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    echo "$ID"
  else
    echo "unknown"
  fi
}

# Update package manager server
update_server() {
  print_info "[:] Updating package manager server ..."

  local distro=$(detect_distro)
  
  case "$distro" in
    arch)
      if ! arch_update_server; then
        print_error "[-] Failed to update Arch package manager server!"
        return 1
      fi
      ;;
    fedora)
      if ! fedora_update_server; then
        print_error "[-] Failed to update Fedora package manager server!"
        return 1
      fi
      ;;
    debian|ubuntu)
      if ! debian_update_server; then
        print_error "[-] Failed to update Debian package manager server!"
        return 1
      fi
      ;;
    *)
      print_error "[-] Unsupported distribution: $distro"
      return 1
      ;;
  esac

  print_success "[+] Package manager server updated successfully!"
}

# Package installation
installer() {
  print_warning "[*] Installing packages ..."

  if [ "$#" -eq 0 ]; then
    print_error "[-] No packages specified to install!"
    return 1
  fi

  if ! update_server; then
    print_warning "[*] I will try anyway to install the specified packages."
  fi

  local distro=$(detect_distro)
  
  case "$distro" in
    arch)
      if ! arch_installer "$@"; then
        print_error "[-] Failed to install specified packages!"
        return 1
      fi
      ;;
    fedora)
      if ! fedora_installer "$@"; then
        print_error "[-] Failed to install specified packages!"
        return 1
      fi
      ;;
    debian|ubuntu)
      if ! debian_installer "$@"; then
        print_error "[-] Failed to install specified packages!"
        return 1
      fi
      ;;
    *)
      print_error "[-] Unsupported distribution: $distro"
      return 1
      ;;
  esac

  print_success "[+] Packages installed successfully!"
}

# Package removal
remover() {
  print_warning "[*] Removing packages ..."

  if [ "$#" -eq 0 ]; then
    print_error "[-] No packages specified to remove!"
    return 1
  fi

  local distro=$(detect_distro)

  case "$distro" in
    arch)
      if ! arch_remover "$@"; then
        print_error "[-] Failed to remove specified packages!"
        return 1
      fi
      ;;
    fedora)
      if ! fedora_remover "$@"; then
        print_error "[-] Failed to remove specified packages!"
        return 1
      fi
      ;;
    debian|ubuntu)
      if ! debian_remover "$@"; then
        print_error "[-] Failed to remove specified packages!"
        return 1
      fi
      ;;
    *)
      print_error "[-] Unsupported distribution: $distro"
      return 1
      ;;
  esac

  print_success "[+] Packages removed successfully!"
}