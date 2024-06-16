#!/bin/bash

# Import the utils function
source ../utils/utils.sh

# Generate GRUB configuration
gen_grub() {
  if ! sudo grub-mkconfig -o /boot/grub/grub.cfg &> /dev/null; then
    return 1
  fi

  print_success "[+] GRUB configuration regenerated successfully!"
}

# Fingerprint reader
conf_fingerprint() {}

# Git identity + SSH key
conf_git() {
  local email="$1"
  local name="$2"

  git config --global user.email "$email"
  git config --global user.name "$name"

  # Create ~/.ssh directory if it doesn't exist
  mkdir -p "$HOME/.ssh"

  # Add the SSH key to the config file
  cat <<EOF >> ~/.ssh/config
Host github.com
  HostName github.com
  IdentityFile "$HOME/.ssh/keyring/github/github"
  IdentitiesOnly yes
EOF
  
  print_success "[+] git configured and its key added to ~/.ssh/config"
}

# System Snappshot
conf_snapper() {
  local device=$1
  
  if [[ -z "$device" ]]; then
    print_error "[-] No device specified!"
    return 1
  fi

  if [ ! -b "$device" ]; then
    print_error "[-] The specified device does not exist!"
    return 1
  fi

  # Verify that file system is Btrfs
  if ! sudo blkid "$device" | grep -q 'TYPE="btrfs"'; then
    print_error "[-] The specified device is not a Btrfs file system!"
    return 1
  fi

  # Check if the subvolume @.snapshots is mounted
  if mount | grep -q 'on /.snapshots type btrfs'; then
    print_info "[*] Unmounting the @.snapshots subvolume ..."
    
    # Unmount the subvolume @.snapshots
    if ! sudo umount /.snapshots; then
      print_error "[-] Failed to unmount /.snapshots!"
      return 1
    fi

    # Delete the existing mountpoint
    if ! sudo rmdir /.snapshots; then
      print_error "[-] Failed to delete the /.snapshots mountpoint!"
      return 1
    fi
  else
    print_info "[*] No existing @.snapshots subvolume mount found."
  fi

  # Create Snapper configuration
  if ! sudo snapper -c root create-config /; then
    print_error "[-] Failed to create Snapper config!"
    return 1
  fi

  # Delete the subvolume created by Snapper
  if ! sudo btrfs subvolume delete /.snapshots; then
    print_error "[-] Failed to delete the Snapper-created subvolume!"
    return 1
  fi

  # Recreate the mountpoint /.snapshots
  if ! sudo mkdir /.snapshots; then
    print_error "[-] Failed to re-create the /.snapshots mountpoint!"
    return 1
  fi

  # Remount the subvolume @.snapshots
  if ! sudo mount -o subvol=@.snapshots "$device" /.snapshots; then
    print_error "[-] Failed to re-mount the @.snapshots subvolume!"
    return 1
  fi

  # Enable Snapper timers
  if ! sudo systemctl enable snapper-timeline.timer &> /dev/null ||
     ! sudo systemctl enable snapper-cleanup.timer &> /dev/null; then
    print_error "[-] Failed to activate snapper service!"
    return 1
  fi

  print_success "[+] Snapper configured successfully!"
}

# ZSH
conf_zsh() {
  # Install Oh My Zsh
  if ! sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended; then
    print_error "[-] Failed to install Oh My Zsh!"
    return 1
  fi

  # Install Powerlevel10k theme
  if ! git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k &> /dev/null; then
    print_error "[-] Failed to install Powerlevel10k theme!"
    return 1
  fi

  sed -i 's|^ZSH_THEME=.*|ZSH_THEME="powerlevel10k/powerlevel10k"|' $HOME/.zshrc

  # Install Plugins
  local plugins=(zsh-autosuggestions zsh-syntax-highlighting zsh-completions)
  for plugin in "${plugins[@]}"; do
    if ! git clone "https://github.com/zsh-users/$plugin" ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/$plugin &> /dev/null; then
      print_error "[-] Failed to install $plugin!"
      return 1
    fi
  done

  sed -i 's|^plugins=.*|plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-completions)|' $HOME/.zshrc

  # Install fzf (fuzzy finder)
  if ! installer fd &> /dev/null || ! git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf &> /dev/null || ! ~/.fzf/install --all &> /dev/null; then
    print_error "[-] Failed to install fzf!"
    return 1
  fi

  print_success "[+] Zsh, Oh My Zsh, themes, plugins, and fzf configured!"
}

# Generate SSH keys
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
    return 1
  fi
}

# Import existing SSH keys
ssh_keyimport() {
  local import_path="$1"
  print_info "[*] Importing SSH keys from $import_path ..."
  local target_dir="$HOME/.ssh/keyring"
  mkdir -p "$target_dir"
  if cp -r "$import_path"/* "$target_dir" && chmod -R 700 "$target_dir"; then
    print_success "[+] SSH keys imported successfully!"
  else
    return 1
  fi
}

# VPN import
vpn_import() {
  local vpn_dir="$HOME/.vpn"
  if ! git clone git@github.com:andreatirelli3/vpn.git "$vpn_dir" &> /dev/null; then
    return 1
  fi
  print_success "[+] VPN configuration imported!"
}