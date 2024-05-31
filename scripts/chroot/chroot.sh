#!/bin/bash

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

# AUR Helper Installation
install_aur() {
  print_warning "[*] Installing AUR helper ..."
  if [ -d "paru" ]; then
    # Remove the 'paru' directory if it exists
    rm -rf paru
  fi

  # Clone the 'paru' repository and install it
  if ! git clone https://aur.archlinux.org/paru.git &> /dev/null || ! cd paru || ! makepkg -si; then
    print_error "[-] Failed to install AUR helper!"
    return 1
  fi

  sudo -v

  # Update the package database
  sudo pacman -Syy &> /dev/null && paru -Syy &> /dev/null
  cd .. && rm -rf paru
  print_success "[+] AUR helper installed!"
}

# Bluetooth Configuration
conf_bluetooth() {
  sudo -v
  # Install bluez and bluez-utils packages, and enable Bluetooth service
  if ! installer bluez bluez-utils || ! sudo systemctl enable bluetooth &> /dev/null; then
    print_error "[-] Failed to configure Bluetooth!"
    return 1
  fi
  print_success "[+] Bluetooth configured!"
}

# Chaotic AUR Configuration
conf_chaoticaur() {
  sudo -v
  print_warning "[*] Configuring Chaotic AUR repository ..."
  # Add the Chaotic AUR key and install the repository
  if ! sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com &> /dev/null ||
     ! sudo pacman-key --lsign-key 3056513887B78AEB &> /dev/null ||
     ! sudo pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' &> /dev/null ||
     ! sudo pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst' &> /dev/null; then
    print_error "[-] Failed to configure Chaotic AUR repository!"
    return 1
  fi

  local chaotic_repo=$(cat <<EOF

[chaotic-aur]
Include = /etc/pacman.d/chaotic-mirrorlist
EOF
  )

  # Add the Chaotic AUR repository to pacman configuration if not already present
  if ! grep -q "\[chaotic-aur\]" /etc/pacman.conf; then
    echo "$chaotic_repo" | sudo tee -a /etc/pacman.conf > /dev/null
  fi

  # Update the package database
  sudo pacman -Syy &> /dev/null && paru -Syy &> /dev/null
  print_success "[+] Chaotic AUR repository configured!"
}

# Mirrorlist Configuration
gen_mirrorilist() {
  sudo -v
  # Install necessary packages and update the mirrorlist using reflector
  if ! installer reflector rsync curl || ! sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak ||
     ! sudo reflector --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist &> /dev/null; then
    print_error "[-] Failed to update mirrorlist!"
    return 1
  fi
  print_success "[+] Mirrorlist updated!"
}

# Pacman Configuration
conf_pacman() {
  sudo -v
  local pacman_conf="/etc/pacman.conf"
  # Enable color in pacman output
  if ! sudo sed -i 's/^#Color/Color/' "$pacman_conf" ||
     # Add 'ILoveCandy' option to pacman configuration
     ! grep -q '^ILoveCandy' "$pacman_conf" && ! sudo sed -i '/^Color/a ILoveCandy' "$pacman_conf" ||
     # Install pacman-contrib package and enable paccache.timer
     ! installer pacman-contrib || ! sudo systemctl enable paccache.timer &> /dev/null; then
    print_error "[-] Failed to configure pacman!"
    return 1
  fi
  print_success "[+] Pacman configured!"
}

# SSH Configuration
activate_ssh() {
  sudo -v
  # Enable SSH service
  if ! sudo systemctl enable sshd &> /dev/null; then
    print_error "[-] Failed to enable SSH!"
    return 1
  fi
  print_success "[+] SSH enabled!"
}

# Power Plan Configuration
conf_powerprofiles() {
  sudo -v
  # Install power-profiles-daemon package and enable the service
  if ! installer power-profiles-daemon || ! sudo systemctl enable power-profiles-daemon.service &> /dev/null; then
    print_error "[-] Failed to configure power plan!"
    return 1
  fi
  print_success "[+] Power plan configured!"
}

# Nvidia, NVENC and GDM Configuration
conf_nvidia() {
  sudo -v
  print_warning "[*] Configuring NVIDIA, NVENC and GDM ..."
  # Add necessary modules to mkinitcpio.conf and update GRUB configuration
  if ! sudo sed -i 's/^MODULES=(.*)$/& nvidia nvidia_modeset nvidia_uvm nvidia_drm/' /etc/mkinitcpio.conf ||
     ! sudo sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT="\(.*\)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 nvidia_drm.modeset=1"/' /etc/default/grub ||
     # Create udev rule for NVIDIA
     ! sudo bash -c 'echo "ACTION==\"add\", DEVPATH==\"/bus/pci/drivers/nvidia\", RUN+=\"/usr/bin/nvidia-modprobe -c 0 -u\"" > /etc/udev/rules.d/70-nvidia.rules' ||
     # Disable GDM rule
     ! sudo ln -sf /dev/null /etc/udev/rules.d/61-gdm.rules ||
     # Enable Wayland in GDM
     ! sudo sed -i 's/^#WaylandEnable=false/WaylandEnable=true/' /etc/gdm/custom.conf ||
     # Add NVIDIA power management option
     ! sudo bash -c 'echo "options nvidia NVreg_PreserveVideoMemoryAllocations=1" > /etc/modprobe.d/nvidia-power-mgmt.conf' ||
     # Regenerate initramfs and update GRUB configuration
     ! sudo mkinitcpio -P &> /dev/null ||
     ! sudo grub-mkconfig -o /boot/grub/grub.cfg &> /dev/null; then
    print_error "[-] Failed to configure NVIDIA, NVENC and GDM!"
    return 1
  fi
  print_success "[+] NVIDIA, NVENC and GDM configured!"
}

# Windows Dualboot Configuration
windows_tpm_config() {
  sudo -v
  print_warning "[*] Configuring Windows Dualboot ..."
  # Install necessary packages and configure GRUB for TPM
  if ! installer sbctl os-prober ntfs-3g ||
     ! sudo grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB --modules="tpm" --disable-shim-lock &> /dev/null ||
     ! sudo grub-mkconfig -o /boot/grub/grub.cfg &> /dev/null ||
     # Setup Secure Boot with sbctl
     ! sudo sbctl status &> /dev/null ||
     ! sudo sbctl create-keys &> /dev/null ||
     ! sudo sbctl enroll-keys --microsoft &> /dev/null ||
     ! sudo sbctl sign -s /boot/EFI/GRUB/grubx64.efi &> /dev/null; then
    print_error "[-] Failed to configure Windows Dualboot!"
    return 1
  fi
  print_success "[+] Windows Dualboot configured!"
}

# SSH Key Generation
ssh_key_gen() {
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

# SSH Key import
ssh_key_import() {
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

# VPN import
vpn_import() {
  local vpn_dir="$HOME/.vpn"
  if ! git clone git@github.com:andreatirelli3/vpn.git "$vpn_dir" &> /dev/null; then
    print_error "[-] Failed to import VPN configuration!"
    return 1
  fi
  print_success "[+] VPN configuration imported!"
}

# Git config
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

# ZSH config
conf_zsh() {
  print_info "[*] Configuring Zsh ..."
  
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


#============================
# MAIN BODY
#============================

# Ensure the script is not run as root
if [ "$EUID" -eq 0 ]; then
  print_error "Please do not run this script as root."
  exit 1
fi

# Move to the home directory
cd "$HOME"

# Prompt user to install an AUR helper
read -p "Do you want to install the AUR helper? [y/N]: " choice
if [[ "$choice" =~ ^[Yy]$ ]]; then
  install_aur || print_error "[-] Failed to install AUR helper. Continuing..."
fi

# Prompt user to configure pacman
read -p "Do you want to configure pacman? [y/N]: " choice
if [[ "$choice" =~ ^[Yy]$ ]]; then
  conf_pacman || print_error "[-] Failed to configure pacman. Continuing..."
fi

# Prompt user to configure Chaotic AUR repository
read -p "Do you want to configure Chaotic AUR? [y/N]: " choice
if [[ "$choice" =~ ^[Yy]$ ]]; then
  conf_chaoticaur || print_error "[-] Failed to configure Chaotic AUR repository. Continuing..."
fi

# Prompt user to update the mirrorlist
read -p "Do you want to update the mirrorlist? [y/N]: " choice
if [[ "$choice" =~ ^[Yy]$ ]]; then
  gen_mirrorilist || print_error "[-] Failed to update mirrorlist. Continuing..."
fi

# Prompt user to configure SSH
read -p "Do you want to enable SSH? [y/N]: " choice
if [[ "$choice" =~ ^[Yy]$ ]]; then
  activate_ssh || print_error "[-] Failed to enable SSH. Continuing..."
fi

# Prompt user to configure Bluetooth
read -p "Do you want to configure Bluetooth? [y/N]: " choice
if [[ "$choice" =~ ^[Yy]$ ]]; then
  conf_bluetooth || print_error "[-] Failed to configure Bluetooth. Continuing..."
fi

# Prompt user to install Flatpak
read -p "Do you want to install Flatpak? [y/N]: " choice
if [[ "$choice" =~ ^[Yy]$ ]]; then
  installer flatpak || print_error "[-] Failed to install Flatpak. Continuing..."
fi

# Prompt user to configure Power Plan
read -p "Do you want to configure power plan? [y/N]: " choice
if [[ "$choice" =~ ^[Yy]$ ]]; then
  conf_powerprofiles || print_error "[-] Failed to configure power plan. Continuing..."
fi

# Prompt user to configure Nvidia and GDM
read -p "Do you want to configure NVIDIA, NVENC and GDM? [y/N]: " choice
if [[ "$choice" =~ ^[Yy]$ ]]; then
  conf_nvidia || print_error "[-] Failed to configure NVIDIA, NVENC and GDM. Continuing..."
fi

# Prompt user to configure Windows Dualboot
read -p "Do you want to configure Windows dualboot? [y/N]: " choice
if [[ "$choice" =~ ^[Yy]$ ]]; then
  windows_tpm_config || print_error "[-] Failed to configure Windows Dualboot. Continuing..."
fi

# Prompt user to generate a new SSH key
read -p "Do you want to generate a new SSH key? [y/N]: " choice
if [[ "$choice" =~ ^[Yy]$ ]]; then
  read -p "Enter the email for the SSH key: " ssh_email
  read -p "Enter the name for the SSH key: " ssh_key_name
  ssh_key_gen "$ssh_email" "$ssh_key_name" || print_error "[-] Failed to generate SSH key. Continuing..."
fi

# Prompt user to import SSH keys
read -p "Do you want to import SSH keys? [y/N]: " choice
if [[ "$choice" =~ ^[Yy]$ ]]; then
  read -p "Enter the path to import SSH keys from: " ssh_import_path
  ssh_key_import "$ssh_import_path" || print_error "[-] Failed to import SSH keys. Continuing..."
fi

# Prompt user to configure Git
read -p "Do you want to configure Git? [y/N]: " choice
if [[ "$choice" =~ ^[Yy]$ ]]; then
  read -p "Enter the email for the Git config: " git_email
  read -p "Enter the name for the Git config: " git_name
  conf_git "$git_email" "$git_name" || print_error "[-] Failed to configure Git. Continuing..."
fi

# Prompt user to import VPN configuration
read -p "Do you want to import a VPN configuration? [y/N]: " choice
if [[ "$choice" =~ ^[Yy]$ ]]; then
  vpn_import || print_error "[-] Failed to import VPN configuration. Continuing..."
fi

# Prompt user to configure Zsh
read -p "Do you want to configure Zsh? [y/N]: " choice
if [[ "$choice" =~ ^[Yy]$ ]]; then
  conf_zsh || print_error "[-] Failed to configure Zsh. Continuing..."
fi

print_success "All selected configurations are completed!"
