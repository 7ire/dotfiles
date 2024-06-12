#!/bin/bash

#============================
# DEBUG FUNCTIONS
#============================

# Output debug message with color
print_debug() {
  local color="$1"
  local message="$2"
  # Format message with specified color.
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
  if ! sudo pacman -Syy &> /dev/null ||
     ! paru -Syy &> /dev/null; then
    return 1
  fi
}

# Fedora: update package manager server
fedora_update_server() {
  if ! sudo dnf makecache &> /dev/null; then
    return 1
  fi
}

# Debian: update package manager server
debian_update_server() {
  if ! sudo apt update &> /dev/null; then
    return 1
  fi
}

# Arch Linux: install packages
arch_installer() {
  # Check if 'paru' is installed
  if ! command -v paru &> /dev/null; then
    print_error "[-] Paru is not installed! Please install it first."
    return 1
  fi

  # List of packages to install given as arg to function call
  local PKGs=("$@")

  # Iterate for each package
  for pkg in "${PKGs[@]}"; do
    # Install package without confirmation
    if paru -S --noconfirm "$pkg" &> /dev/null; then
      # Success
      print_success "[+] $pkg installed successfully!"
    else
      # Error in installation
      print_error "[-] $pkg failed to install!"
    fi
  done
}

# Fedora: install packages
fedora_installer() {
  # List of packages to install given as arg to function call
  local PKGs=("$@")

  # Iterate for each package
  for pkg in "${PKGs[@]}"; do
    # Install package without confirmation
    if sudo dnf install -y "$pkg" &> /dev/null; then
      # Success
      print_success "[+] $pkg installed successfully!"
    else
      # Error in installation
      print_error "[-] $pkg failed to install!"
    fi
  done
}

# Debian: install packages
debian_installer() {
  # List of packages to install given as arg to function call
  local PKGs=("$@")

  # Iterate for each package
  for pkg in "${PKGs[@]}"; do
    # Install package without confirmation
    if sudo apt install -y "$pkg" &> /dev/null; then
      # Success
      print_success "[+] $pkg installed successfully!"
    else
      # Error in installation
      print_error "[-] $pkg failed to install!"
    fi
  done
}

#============================
# UTILITY FUNCTIONS
#============================

# Check root excetuion
root_checker() {
  # Ensure the script is not run as root
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
}

# Package installation
installer() {
  # Check if there are specify packages to install
  if [ "$#" -eq 0 ]; then
    print_error "[-] No packages specified to install!"
    return 1
  fi

  # Update the package manager server
  if ! update_server; then
    print_warning "[*] I will try anyway to install the specified packages."
  fi

  local distro=$(detect_distro)
  
  case "$distro" in
    arch)
      arch_installer "$@"
      ;;
    fedora)
      fedora_installer "$@"
      ;;
    debian|ubuntu)
      debian_installer "$@"
      ;;
    *)
      print_error "[-] Unsupported distribution: $distro"
      return 1
      ;;
  esac
}
