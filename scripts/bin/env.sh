#!/bin/bash

# Import the utils function
source ../utils/utils.sh

gen_grub() {}

conf_git() {}

conf_snapper() {}

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
    # print_error "[-] Failed to generate SSH key!"
    return 1
  fi
}

ssh_keyimport() {}

vpn_import() {}