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

conf_snapper() {}

conf_nvidia() {}

conf_win_dualboot() {}

conf_zsh() {
  print_warning "[*] Configuring Zsh ..."
  
  # Install zsh and set it as default shell
  if ! installer zsh &> /dev/null || ! chsh -s /bin/zsh; then
    print_error "[-] Failed to install and set Zsh as default shell!"
    return 1
  fi

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

ssh_keyimport() {
  local import_path="$1"
  print_info "[*] Importing SSH keys from $import_path ..."
  local target_dir="$HOME/.ssh/keyring"
  mkdir -p "$target_dir"
  if cp -r "$import_path"/* "$target_dir" && chmod -R 700 "$target_dir"; then
    print_success "[+] SSH keys imported successfully!"
  else
    print_error "[-] Failed to import SSH keys!"
    return 1
  fi
}