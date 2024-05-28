#!/bin/bash

# Debug function
# -------

# Print Functions
print_message() {
    local color="$1"
    local marker="$2"
    local message="$3"
    echo -e "\e[1;${color}m[${marker}] \e[0m$message\e[0m"
}
## errors
print_error() {
    print_message 31 "ERROR" "$1"  # Red color for errors (31)
}
## warnings
print_warning() {
    print_message 33 "WARNING" "$1"  # Yellow color for warnings (33)
}
## success
print_success() {
    print_message 32 "SUCCESS" "$1"  # Green color for successes (32)
}
## general 
print_info() {
    print_message 36 "INFO" "$1"  # Cyan color for general messages (36)
}


# Useful function
# -------

# Package manager configuration
pacman_config() {
  # Path of the configuration file
  local pacman_conf="/etc/pacman.conf"
  # Remove the comment for Color
  sudo sed -i 's/^#Color/Color/' "$pacman_conf"
  # Add the line ILoveCandy after the line Color
  if ! grep -q '^ILoveCandy' "$pacman_conf"; then
    sudo sed -i '/^Color/a ILoveCandy' "$pacman_conf"
  fi

  # General package manager update
  sudo pacman -Syy
  # Install pacman-contrib package
  sudo pacman -S --noconfirm pacman-contrib
  # Enable cronjob that time 7 days to clean the cache
  sudo systemctl enable paccache.timer
}

# Bluetooth
bluetooth_config() {
  # Install the required packages => { bluez, bluez-utils}
  sudo pacman -S --noconfirm bluez bluez-utils
  # Enable bluetooth daemon
  sudo systemctl enable bluetooth
}

# SSH
ssh_config() {
  # Enable sshd daemon
  sudo systemctl enable sshd
}

# AUR Helper
aur_helper_config() {
  # The AUR helper of choice is PARU

  # Download the AUR helper bin
  git clone https://aur.archlinux.org/paru.git && cd paru
  # Build the binary
  makepkg -si
  # Update package manager and AUR helper
  sudo pacman -Syy && paru -Syu
  # Clean files
  cd .. && rm -rf paru
}

# Flatpak
flatpak_config() {
  # Install the package
  sudo pacman -S --noconfirm flatpak
}

# Chaotic AUR
chaotic_aur_config() {
  # Import the key of the repo and the sign
  sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
  sudo pacman-key --lsign-key 3056513887B78AEB
  # Install chaotic AUR keyring
  sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
  # Install chaotic AUR mirrorlist
  sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
  
  # String to add the mirrorlist entry in the conf file
  local chaotic_repo=$(cat <<EOF

[chaotic-aur]
Include = /etc/pacman.d/chaotic-mirrorlist
EOF
  )
  # Add the entry only if not exist
  if ! grep -q "\[chaotic-aur\]" /etc/pacman.conf; then
    echo "$chaotic_repo" | sudo tee -a /etc/pacman.conf > /dev/null
  fi

  # Update the repository of package manager
  sudo pacman -Syy
}

# Mirrorlist
mirrorlist_config() {
  # Install required packages
  sudo pacman -S --noconfirm reflector rsync curl
  # Backup current mirrorlist
  sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
  # Generate the new one with reflector
  sudo reflector --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
}

# Power plan
powerplan_config() {
  # Install the power plan profiles package
  sudo pacman -S --noconfirm power-profiles-daemon
  # Enable the service
  sudo systemctl enable power-profiles-daemon.service
}

# Nvidia driver + GDM + NVENC
nvidia_config() {
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
}

# Windows dualboot
windows_tpm_config() {
  # Install required packages
  sudo pacman -S --noconfirm sbctl os-prober ntfs-3g
  # Install GRUB with TPM module and disabling Shim lock
  sudo grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB --modules="tpm" --disable-shim-lock
  # Regenerate the GRUB configuration
  sudo grub-mkconfig -o /boot/grub/grub.cfg

  # Check if sbctl is in setup mode
  sudo sbctl status
  # Create new keypair and enroll it
  sudo sbctl create-keys && sudo sbctl enroll-keys -m
  # Sign the necessary efi files and kernel
  sudo sbctl sign -s /boot/EFI/GRUB/grubx64.efi && sudo sbctl sign -s /boot/grub/x86_64-efi/core.efi && sudo sbctl sign -s /boot/grub/x86_64-efi/grub.efi && sudo sbctl sign -s /boot/vmlinuz-linux-zen
}

# SSH Key
ssh_key_config() {
  # Ensure the .ssh directory exists
  mkdir -p ~/.ssh/keychain/github && chmod 700 ~/.ssh/keychain/github

  # Generate the key for my identity "ta.tirelliandrea@gmail.com"
  ssh-keygen -t ed25519 -C "ta.tirelliandrea@gmail.com" -f ~/.ssh/keychain/github/github

  # Output the public key
  cat ~/.ssh/keychain/github/github.pub
  # Add to ssh-agent
  eval "$(ssh-agent -s)"
  ssh-add ~/.ssh/keychain/github/github
}


# Main
# -------
# 1.  Pacman configuration
# 2.  [y/n] Bluetooth
# 3.  SSH
# 4.  AUR Helper
# 5.  Flatpak
# 6.  Chaotic AUR
# 7.  Update mirrorlist
# 8.  [y/n] Power plan
# 9.  [y/n] Nvidia + gdm
# 10. [y/n] Windows dualboot
# 11. SSH key (github)

# Change the running location in the home directory
cd "$HOME" || exit 1

# 1. Pacman configuration
read -p "Do you want to configure pacman? (y/n): " pacman_choice
if [[ "$pacman_choice" == "y" || "$pacman_choice" == "Y" ]]; then
  print_info "Configuring package manager ..."
  pacman_config
  print_success "Package manager configured!"
fi

# 2. Bluetooth
read -p "Do you want to configure Bluetooth? (y/n): " bluetooth_choice
if [[ "$bluetooth_choice" == "y" || "$bluetooth_choice" == "Y" ]]; then
  print_info "Configuring Bluetooth ..."
  bluetooth_config
  print_success "Bluetooth configured!"
fi

# 3. SSH
read -p "Do you want to configure SSH? (y/n): " ssh_choice
if [[ "$ssh_choice" == "y" || "$ssh_choice" == "Y" ]]; then
  print_info "Enabling SSH ..."
  ssh_config
  print_success "SSH enabled!"
fi

# 4. AUR Helper
read -p "Do you want to install an AUR helper? (y/n): " aur_choice
if [[ "$aur_choice" == "y" || "$aur_choice" == "Y" ]]; then
  print_info "Install AUR helper ..."
  aur_helper_config
  print_success "AUR helper installed!"
fi

# 5. Flatpak
read -p "Do you want to install Flatpak? (y/n): " flatpak_choice
if [[ "$flatpak_choice" == "y" || "$flatpak_choice" == "Y" ]]; then
  print_info "Installing flatpak ..."
  flatpak_config
  print_success "Flatpak installed!"
fi

# 6. Chaotic AUR
read -p "Do you want to configure the Chaotic AUR repository? (y/n): " chaotic_choice
if [[ "$chaotic_choice" == "y" || "$chaotic_choice" == "Y" ]]; then
  print_info "Configuring Chaotic AUR repository ..."
  chaotic_aur_config
  print_success "Chaotic AUR repostiory configured!"
fi

# 7. Update mirrorlist
read -p "Do you want to update the mirrorlist? (y/n): " mirrorlist_choice
if [[ "$mirrorlist_choice" == "y" || "$mirrorlist_choice" == "Y" ]]; then
  print_info "Updating mirrorlist ..."
  mirrorlist_config
  print_success "Mirrorlist updated!"
fi

# 8. Power plan
read -p "Do you want to configure Power Plan? (y/n): " powerplan_choice
if [[ "$powerplan_choice" == "y" || "$powerplan_choice" == "Y" ]]; then
  print_info "Configuring Power Plan ..."
  powerplan_config
  print_success "Power Plan configured!"
fi

# 9. Nvidia + gdm
read -p "Do you want to configure Nvidia and GDM? (y/n): " nvidia_choice
if [[ "$nvidia_choice" == "y" || "$nvidia_choice" == "Y" ]]; then
  print_info "Configuring Nvidia and GDM ..."
  nvidia_config
  print_success "Nvidia and GDM configured!"
fi

# 10. Windows dualboot
read -p "Do you want to configure Windows Dualboot? (y/n): " dualboot_choice
if [[ "$dualboot_choice" == "y" || "$dualboot_choice" == "Y" ]]; then
  print_info "Configuring Windows Dualboot ..."
  windows_tpm_config
  print_success "Windows Dualboot configured!"
fi

# 11. SSH key (GitHub)
read -p "Do you want to generate a new SSH key? (y/n): " sshkey_choice
if [[ "$sshkey_choice" == "y" || "$sshkey_choice" == "Y" ]]; then
  print_info "Generating and adding a new SSH Key for GitHub ..."
  ssh_key_config
  print_success "SSH Key for GitHub generated and added to SSH-Agent!"
fi

# [TODO] - Import existing sshkey from a hard secure device

print_success "All selected configurations are completed!"

