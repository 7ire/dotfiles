#!/bin/bash

# Import the utils function
source ../utils/utils.sh

bt_controllermode_dua() {}

bt_enable_kernel_exp() {}

generate_mirrorlist() {
  # Update the mirrorlist using reflector
  if ! sudo reflector -n 20 -p https --sort rate --save /etc/pacman.d/mirrorlist --country 'Italy,Germany,France' --latest 20 &> /dev/null; then
    print_error "[-] Failed to update mirrorlist!"
    return 1
  fi

  # Create Reflector configuration for systemd service
  if ! sudo tee /etc/xdg/reflector/reflector.conf > /dev/null <<EOL
# Reflector configuration file for the systemd service.
#
# Empty lines and lines beginning with "#" are ignored.  All other lines should
# contain valid reflector command-line arguments. The lines are parsed with
# Python's shlex modules so standard shell syntax should work. All arguments are
# collected into a single argument list.
#
# See "reflector --help" for details.

# Recommended Options

# Set the output path where the mirrorlist will be saved (--save).
--save /etc/pacman.d/mirrorlist

# Select the transfer protocol (--protocol).
--protocol https

# Select the country (--country).
# Consult the list of available countries with "reflector --list-countries" and
# select the countries nearest to you or the ones that you trust. For example:
--country Italy,Germany,France

# Use only the most recently synchronized mirrors (--latest).
--latest 20

# Sort the mirrors by download speed (--sort).
--sort rate
EOL
  then
    print_error "[-] Failed to create Reflector config!"
    return 1
  fi

  # Restart and enable Reflector service
  if ! sudo systemctl enable reflector.service &> /dev/null; then
    print_error "[-] Failed to restart and enable Reflector service!"
    return 1
  fi
}

conf_git() {}

conf_snapper() {}

conf_nvidia() {}

conf_win_dualboot() {}

conf_zsh() {}

ssh_keygen() {
  local email="$1"
  local key_name="$2"
  print_info "[*] Generating SSH key for $email ..."
  local key_dir="$HOME/.ssh/keyring/$key_name"
  mkdir -p "$key_dir"

  # Set permissions to 700 for keyring and SSH key directory
  chmod 700 "$HOME/.ssh"
  chmod 700 "$HOME/.ssh/keyring"
  chmod 700 "$key_dir"

  # Generate SSH key using ed25519 algorithm
  if ssh-keygen -t ed25519 -C "$email" -f "$key_dir/$key_name"; then
    print_success "[+] SSH key generated successfully in $key_dir!"
    eval "$(ssh-agent -s)"
    ssh-add "$key_dir/$key_name"
    cat "$key_dir/$key_name.pub"

    print_success "[+] SSH key added to ~/.ssh/config!"
  else
    print_error "[-] Failed to generate SSH key!"
    return 1
  fi
}

ssh_keyimport() {}