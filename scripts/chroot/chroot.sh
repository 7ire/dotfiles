#!/bin/bash

# Funzioni di stampa
print_success() {
    local message="$1"
    echo -e "\e[32m$message\e[0m"  # Testo verde
}

print_error() {
    local message="$1"
    echo -e "\e[31m$message\e[0m"  # Testo rosso
}

print_info() {
    local message="$1"
    echo -e "\e[36m$message\e[0m"  # Testo ciano
}

# Funzione per installare pacchetti usando paru
installer() {
  # Check if there aren't any packages specified to install
  if [ "$#" -eq 0 ]; then
    print_error "No packages specified to install."
    return 1  # Do nothing and exit the function
  fi

  if ! command -v paru &> /dev/null; then
    print_error "paru is not installed. Please install it first."
    return 1
  fi

  local packages=("$@")    # List of packages to install

  for package in "${packages[@]}"; do
    print_info "[*] Installing $package ..."
    
    # Install the package and redirect the output to /dev/null
    if paru -S --noconfirm "$package" &> /dev/null; then
      print_success "[+] $package installed successfully!"
    else
      print_error "[-] $package failed to install."
    fi
  done
}

# Package manager configuration
pacman_config() {
  print_info "[*] Configuring pacman ..."
  local pacman_conf="/etc/pacman.conf"             # pacman configuration file
  sudo sed -i 's/^#Color/Color/' "$pacman_conf"    # Remove the comment from the Color tag
  if ! grep -q '^ILoveCandy' "$pacman_conf"; then  # Add the ILoveCandy tag if not exist
    sudo sed -i '/^Color/a ILoveCandy' "$pacman_conf"
  fi
  sudo pacman -Syy  # Update pacman

  installer pacman-contrib              # Install pacman-contrib
  sudo systemctl enable paccache.timer  # Enable paccache timer cronjob
  print_success "[+] Pacman configured!"
}

# Bluetooth
bluetooth_config() {
  print_info "[*] Configuring Bluetooth ..."
  installer bluez bluez-utils      # Install bluez and bluez-utils
  sudo systemctl enable bluetooth  # Enable bluetooth daemon
  print_success "[+] Bluetooth configured!"
}

# SSH
ssh_config() {
  print_info "[*] Enabling SSH ..."
  sudo systemctl enable sshd  # Enable sshd daemon
  print_success "[+] SSH enabled!"
}

# AUR
aur_install() {
  print_info "[*] Installing an AUR helper ..."
  if [ -d "paru" ]; then
    rm -rf paru
  fi
  git clone https://aur.archlinux.org/paru.git && cd paru  # Download PARU binary
  
  makepkg -si                    # Build and install the package
  sudo pacman -Syy && paru -Syu  # Update the package managers
  
  cd .. && rm -rf paru  # Clean up
  print_success "[+] AUR helper installed!"
}

# Flatpak
flatpak_config() {
  print_info "[*] Installing Flatpak ..."
  installer flatpak  # Install flatpak
  print_success "[+] Flatpak installed!"
}

# Chaotic AUR
chaotic_aur_config() {
  print_info "[*] Configuring Chaotic AUR repository ..."
  
  sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com  # Add the key
  sudo pacman-key --lsign-key 3056513887B78AEB  # Sign the key

  sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'     # Install the keyring
  sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'  # Install the mirrorlist
  
  # Add the repository in the pacman configuration file
  local chaotic_repo=$(cat <<EOF

[chaotic-aur]
Include = /etc/pacman.d/chaotic-mirrorlist
EOF
  )
  # Add the entry only if not exist
  if ! grep -q "\[chaotic-aur\]" /etc/pacman.conf; then
    echo "$chaotic_repo" | sudo tee -a /etc/pacman.conf > /dev/null
  fi

  sudo pacman -Syy # Update pacman
  print_success "[+] Chaotic AUR repository configured!"
}

# Mirrorlist
mirrorlist_config() {
  print_info "[*] Updating mirrorlist ..."
  installer reflector rsync curl  # Install reflector, rsync, and curl
  sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak  # Backup the old mirrorlist
  sudo reflector --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist  # Generate a new mirrorlist

  print_success "[+] Mirrorlist updated!"
}

# Power plan
powerplan_config() {
  print_info "[*] Configuring power plan ..."
  installer power-profiles-daemon  # Install the power plan profiles package
  sudo systemctl enable power-profiles-daemon.service  # Enable the power plan daemon
  print_success "[+] Power plan configured!"
}

# Nvidia driver + GDM + NVENC
nvidia_config() {
  print_info "[*] Configuring NVIDIA, NVENC and GDM ..."
  
  # Add nvidia to kernel modules
  sudo sed -i 's/^MODULES=(.*)$/& nvidia nvidia_modeset nvidia_uvm nvidia_drm/' /etc/mkinitcpio.conf
  # Add GRUB flag to load nvidia module driver
  sudo sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT="\(.*\)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 nvidia_drm.modeset=1"/' /etc/default/grub
  # Add NVENC
  sudo bash -c 'echo "ACTION==\"add\", DEVPATH==\"/bus/pci/drivers/nvidia\", RUN+=\"/usr/bin/nvidia-modprobe -c 0 -u\"" > /etc/udev/rules.d/70-nvidia.rules'
  # Disable udev rule for gdm in nvidia system
  sudo ln -sf /dev/null /etc/udev/rules.d/61-gdm.rules
  # Enable the support for Wayland entry in gdm
  sudo sed -i 's/^#WaylandEnable=false/WaylandEnable=true/' /etc/gdm/custom.conf
  # Fix NVIDIA suspension
  sudo bash -c 'echo "options nvidia NVreg_PreserveVideoMemoryAllocations=1" > /etc/modprobe.d/nvidia-power-mgmt.conf'

  # Regenerate all configuration
  sudo mkinitcpio -P
  sudo grub-mkconfig -o /boot/grub/grub.cfg
  print_success "[+] NVIDIA, NVENC and GDM configured!"
}

# Windows dualboot
windows_tpm_config() {
  print_info "[*] Configuring Windows Dualboot with TPM ..."

  installer sbctl os-prober ntfs-3g  # Install required packages
  # Install GRUB with TPM module and disabling Shim lock
  sudo grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB --modules="tpm" --disable-shim-lock
  sudo grub-mkconfig -o /boot/grub/grub.cfg  # Regenerate the GRUB configuration

  sudo sbctl status          # Check the status of sbctl
  sudo sbctl create-keys     # Create the necessary keys
  sudo sbctl enroll-keys -m  # Enroll the keys
  # Sign the necessary efi files and kernel
  sudo sbctl sign -s /boot/EFI/GRUB/grubx64.efi && sudo sbctl sign -s /boot/grub/x86_64-efi/core.efi && sudo sbctl sign -s /boot/grub/x86_64-efi/grub.efi && sudo sbctl sign -s /boot/vmlinuz-linux-zen

  print_success "[+] Windows Dualboot with TPM configured!"
}

# SSH Key
ssh_key_config() {
  print_info "[*] Generating and adding a new SSH Key for GitHub ..."

  # Ensure the .ssh directory exists
  mkdir -p ~/.ssh/keychain/github && chmod 700 ~/.ssh/keychain/github

  # Generate the key for my identity "ta.tirelliandrea@gmail.com"
  ssh-keygen -t ed25519 -C "ta.tirelliandrea@gmail.com" -f ~/.ssh/keychain/github/github

  cat ~/.ssh/keychain/github/github.pub  # Output the public key
  eval "$(ssh-agent -s)"                 # Start the ssh-agent
  ssh-add ~/.ssh/keychain/github/github  # Add the key to the ssh-agent

  print_success "[+] SSH Key for GitHub generated and added to SSH-Agent!"
}

# Main
print_info "Starting the configuration script ..."

# Change the running location in the home directory
cd "$HOME" || exit 1

read -p "Do you want to install an AUR helper? (y/n): " aur_choice
if [[ "$aur_choice" == "y" || "$aur_choice" == "Y" ]]; then
  aur_install
fi

read -p "Do you want to configure pacman? (y/n): " pacman_choice
if [[ "$pacman_choice" == "y" || "$pacman_choice" == "Y" ]]; then
  pacman_config
fi

read -p "Do you want to configure Bluetooth? (y/n): " bluetooth_choice
if [[ "$bluetooth_choice" == "y" || "$bluetooth_choice" == "Y" ]]; then
  bluetooth_config
fi

read -p "Do you want to configure SSH? (y/n): " ssh_choice
if [[ "$ssh_choice" == "y" || "$ssh_choice" == "Y" ]]; then
  ssh_config
fi

read -p "Do you want to install Flatpak? (y/n): " flatpak_choice
if [[ "$flatpak_choice" == "y" || "$flatpak_choice" == "Y" ]]; then
  flatpak_config
fi

read -p "Do you want to configure the Chaotic AUR repository? (y/n): " chaotic_choice
if [[ "$chaotic_choice" == "y" || "$chaotic_choice" == "Y" ]]; then
  chaotic_aur_config
fi

read -p "Do you want to update the mirrorlist? (y/n): " mirrorlist_choice
if [[ "$mirrorlist_choice" == "y" || "$mirrorlist_choice" == "Y" ]]; then
  mirrorlist_config
fi

read -p "Do you want to configure Power Plan? (y/n): " powerplan_choice
if [[ "$powerplan_choice" == "y" || "$powerplan_choice" == "Y" ]]; then
  powerplan_config
fi

read -p "Do you want to configure Nvidia and GDM? (y/n): " nvidia_choice
if [[ "$nvidia_choice" == "y" || "$nvidia_choice" == "Y" ]]; then
  nvidia_config
fi

read -p "Do you want to configure Windows Dualboot? (y/n): " dualboot_choice
if [[ "$dualboot_choice" == "y" || "$dualboot_choice" == "Y" ]]; then
  windows_tpm_config
fi

read -p "Do you want to generate a new SSH key? (y/n): " sshkey_choice
if [[ "$sshkey_choice" == "y" || "$sshkey_choice" == "Y" ]]; then
  ssh_key_config
fi

print_success "All selected configurations are completed!"
