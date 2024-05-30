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

  if ! command -v paru &> /dev/null; then
    print_error "paru is not installed! Please install it first."
    return 1
  fi

  local packages=("$@")

  # Update the mirrorserver
  paru -Syy &> /dev/null

  for package in "${packages[@]}"; do
    print_info "[*] Installing $package ..."
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
  print_info "[*] Installing an AUR helper ..."
  if [ -d "paru" ]; then
    rm -rf paru
  fi

  if ! git clone https://aur.archlinux.org/paru.git &> /dev/null || ! cd paru || ! makepkg -si &> /dev/null; then
    print_error "[-] Failed to install AUR helper!"
    return 1
  fi

  sudo pacman -Syy &> /dev/null && paru -Syy &> /dev/null
  cd .. && rm -rf paru
  print_success "[+] AUR helper installed!"
}

# Bluetooth Configuration
conf_bluetooth() {
  print_info "[*] Configuring Bluetooth ..."
  if ! installer bluez bluez-utils || ! sudo systemctl enable bluetooth &> /dev/null; then
    print_error "[-] Failed to configure Bluetooth!"
    return 1
  fi
  print_success "[+] Bluetooth configured!"
}

# Chaotic AUR Configuration
conf_chaoticaur() {
  print_info "[*] Configuring Chaotic AUR repository ..."
  if ! sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com &> /dev/null ||
     ! sudo pacman-key --lsign-key 3056513887B78AEB &> /dev/null ||
     ! sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' &> /dev/null ||
     ! sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst' &> /dev/null; then
    print_error "[-] Failed to configure Chaotic AUR repository!"
    return 1
  fi

  local chaotic_repo=$(cat <<EOF

[chaotic-aur]
Include = /etc/pacman.d/chaotic-mirrorlist
EOF
  )
  if ! grep -q "\[chaotic-aur\]" /etc/pacman.conf; then
    echo "$chaotic_repo" | sudo tee -a /etc/pacman.conf > /dev/null
  fi

  sudo pacman -Syy &> /dev/null && paru -Syy &> /dev/null
  print_success "[+] Chaotic AUR repository configured!"
}

# Mirrorlist Configuration
gen_mirrorilist() {
  print_info "[*] Updating mirrorlist ..."
  if ! installer reflector rsync curl || ! sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak ||
     ! sudo reflector --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist &> /dev/null; then
    print_error "[-] Failed to update mirrorlist!"
    return 1
  fi
  print_success "[+] Mirrorlist updated!"
}

# Pacman Configuration
conf_pacman() {
  print_info "[*] Configuring pacman ..."
  local pacman_conf="/etc/pacman.conf"
  if ! sudo sed -i 's/^#Color/Color/' "$pacman_conf" ||
     ! grep -q '^ILoveCandy' "$pacman_conf" && ! sudo sed -i '/^Color/a ILoveCandy' "$pacman_conf" ||
     ! installer pacman-contrib || ! sudo systemctl enable paccache.timer &> /dev/null; then
    print_error "[-] Failed to configure pacman!"
    return 1
  fi
  print_success "[+] Pacman configured!"
}

# SSH Configuration
activate_ssh() {
  print_info "[*] Enabling SSH ..."
  if ! sudo systemctl enable sshd &> /dev/null; then
    print_error "[-] Failed to enable SSH!"
    return 1
  fi
  print_success "[+] SSH enabled!"
}

# Power Plan Configuration
conf_powerprofiles() {
  print_info "[*] Configuring power plan ..."
  if ! installer power-profiles-daemon || ! sudo systemctl enable power-profiles-daemon.service &> /dev/null; then
    print_error "[-] Failed to configure power plan!"
    return 1
  fi
  print_success "[+] Power plan configured!"
}

# Nvidia, NVENC and GDM Configuration
conf_nvidia() {
  print_info "[*] Configuring NVIDIA, NVENC and GDM ..."
  if ! sudo sed -i 's/^MODULES=(.*)$/& nvidia nvidia_modeset nvidia_uvm nvidia_drm/' /etc/mkinitcpio.conf ||
     ! sudo sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT="\(.*\)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 nvidia_drm.modeset=1"/' /etc/default/grub ||
     ! sudo bash -c 'echo "ACTION==\"add\", DEVPATH==\"/bus/pci/drivers/nvidia\", RUN+=\"/usr/bin/nvidia-modprobe -c 0 -u\"" > /etc/udev/rules.d/70-nvidia.rules' ||
     ! sudo ln -sf /dev/null /etc/udev/rules.d/61-gdm.rules ||
     ! sudo sed -i 's/^#WaylandEnable=false/WaylandEnable=true/' /etc/gdm/custom.conf ||
     ! sudo bash -c 'echo "options nvidia NVreg_PreserveVideoMemoryAllocations=1" > /etc/modprobe.d/nvidia-power-mgmt.conf' ||
     ! sudo mkinitcpio -P &> /dev/null ||
     ! sudo grub-mkconfig -o /boot/grub/grub.cfg &> /dev/null; then
    print_error "[-] Failed to configure NVIDIA, NVENC and GDM!"
    return 1
  fi
  print_success "[+] NVIDIA, NVENC and GDM configured!"
}

# Windows Dualboot Configuration
windows_tpm_config() {
  print_info "[*] Configuring Windows Dualboot with TPM ..."
  if ! installer sbctl os-prober ntfs-3g ||
     ! sudo grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB --modules="tpm" --disable-shim-lock &> /dev/null ||
     ! sudo grub-mkconfig -o /boot/grub/grub.cfg &> /dev/null ||
     ! sudo sbctl status &> /dev/null ||
     ! sudo sbctl create-keys &> /dev/null && ! sudo sbctl enroll-keys -m &> /dev/null ||
     ! sudo sbctl sign -s /boot/EFI/GRUB/grubx64.efi &> /dev/null && ! sudo sbctl sign -s /boot/grub/x86_64-efi/core.efi &> /dev/null &&
     ! sudo sbctl sign -s /boot/grub/x86_64-efi/grub.efi &> /dev/null && ! sudo sbctl sign -s /boot/vmlinuz-linux-zen &> /dev/null; then
    print_error "[-] Failed to configure Windows Dualboot with TPM!"
    return 1
  fi
  print_success "[+] Windows Dualboot with TPM configured!"
}

# SSH Key Configuration
ssh_key_config() {
  local email="$1"
  local key_name="$2"

  if [ -z "$email" ] || [ -z "$key_name" ]; then
    print_error "Email and key name must be provided!"
    return 1
  fi

  print_info "[*] Generating SSH key for $email with name $key_name ..."

  key_dir="$HOME/.ssh/keyring/$key_name"
  mkdir -p "$key_dir"

  if ssh-keygen -t ed25519 -C "$email" -f "$key_dir/id_ed25519" -N ""; then
    print_success "[+] SSH key generated successfully in $key_dir!"
  else
    print_error "[-] Failed to generate SSH key!"
    return 1
  fi
}

#============================
# MAIN BODY
#============================

# Move to the home directory
cd $HOME

read -p "Do you want to install an AUR helper? (y/n): " aur_choice
if [[ "$aur_choice" == "y" || "$aur_choice" == "Y" ]]; then
  install_aur || print_error "[-] Failed to install AUR helper. Continuing..."
fi

read -p "Do you want to configure pacman? (y/n): " pacman_choice
if [[ "$pacman_choice" == "y" || "$pacman_choice" == "Y" ]]; then
  conf_pacman || print_error "[-] Failed to configure pacman. Continuing..."
fi

read -p "Do you want to configure Bluetooth? (y/n): " bluetooth_choice
if [[ "$bluetooth_choice" == "y" || "$bluetooth_choice" == "Y" ]]; then
  conf_bluetooth || print_error "[-] Failed to configure Bluetooth. Continuing..."
fi

read -p "Do you want to configure SSH? (y/n): " ssh_choice
if [[ "$ssh_choice" == "y" || "$ssh_choice" == "Y" ]]; then
  activate_ssh || print_error "[-] Failed to enable SSH. Continuing..."
fi

read -p "Do you want to install Flatpak? (y/n): " flatpak_choice
if [[ "$flatpak_choice" == "y" || "$flatpak_choice" == "Y" ]]; then
  installer flatpak || print_error "[-] Failed to install Flatpak. Continuing..."
fi

read -p "Do you want to configure the Chaotic AUR repository? (y/n): " chaotic_choice
if [[ "$chaotic_choice" == "y" || "$chaotic_choice" == "Y" ]]; then
  conf_chaoticaur || print_error "[-] Failed to configure Chaotic AUR repository. Continuing..."
fi

read -p "Do you want to update the mirrorlist? (y/n): " mirrorlist_choice
if [[ "$mirrorlist_choice" == "y" || "$mirrorlist_choice" == "Y" ]]; then
  gen_mirrorilist || print_error "[-] Failed to update mirrorlist. Continuing..."
fi

read -p "Do you want to configure Power Plan? (y/n): " powerplan_choice
if [[ "$powerplan_choice" == "y" || "$powerplan_choice" == "Y" ]]; then
  conf_powerprofiles || print_error "[-] Failed to configure power plan. Continuing..."
fi

read -p "Do you want to configure Nvidia and GDM? (y/n): " nvidia_choice
if [[ "$nvidia_choice" == "y" || "$nvidia_choice" == "Y" ]]; then
  conf_nvidia || print_error "[-] Failed to configure NVIDIA, NVENC and GDM. Continuing..."
fi

read -p "Do you want to configure Windows Dualboot? (y/n): " dualboot_choice
if [[ "$dualboot_choice" == "y" || "$dualboot_choice" == "Y" ]]; then
  windows_tpm_config || print_error "[-] Failed to configure Windows Dualboot. Continuing..."
fi

read -p "Do you want to generate a new SSH key? (y/n): " sshkey_choice
if [[ "$sshkey_choice" == "y" || "$sshkey_choice" == "Y" ]]; then
  read -p "Enter the email for the SSH key: " ssh_email
  read -p "Enter the name for the SSH key: " ssh_key_name
  ssh_key_config "$ssh_email" "$ssh_key_name" || print_error "[-] Failed to generate SSH key. Continuing..."
fi

print_success "All selected configurations are completed!"
