#!/bin/bash

# DEBUG FUNCTIONS
print_success() { echo -e "\e[32m$1\e[0m"; }
print_error() { echo -e "\e[31m$1\e[0m"; }
print_info() { echo -e "\e[36m$1\e[0m"; }

# UTILITY FUNCTIONS
installer() {
  [ "$#" -eq 0 ] && { print_error "No packages specified!"; return 1; }
  command -v paru &> /dev/null || { print_error "paru is not installed!"; return 1; }
  paru -Syy &> /dev/null
  for package in "$@"; do
    if paru -S --noconfirm "$package" &> /dev/null; then
      print_success "[+] $package installed!"
    else
      print_error "[-] $package failed to install."
    fi
  done
}

# CONFIGURATION FUNCTIONS
install_aur() {
  [ -d "paru" ] && rm -rf paru
  git clone https://aur.archlinux.org/paru.git &> /dev/null
  (cd paru && makepkg -si)
  sudo pacman -Syy &> /dev/null && paru -Syy &> /dev/null
  rm -rf paru && print_success "[+] AUR helper installed!"
}

conf_bluetooth() {
  installer bluez bluez-utils && sudo systemctl enable bluetooth &> /dev/null
  print_success "[+] Bluetooth configured!"
}

conf_chaoticaur() {
  sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com &> /dev/null &&
  sudo pacman-key --lsign-key 3056513887B78AEB &> /dev/null &&
  sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' &> /dev/null &&
  sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst' &> /dev/null
  local chaotic_repo="[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist"
  ! grep -q "\[chaotic-aur\]" /etc/pacman.conf && echo -e "$chaotic_repo" | sudo tee -a /etc/pacman.conf > /dev/null
  sudo pacman -Syy &> /dev/null && paru -Syy &> /dev/null
  print_success "[+] Chaotic AUR configured!"
}

gen_mirrorilist() {
  installer reflector rsync curl &&
  sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak &&
  sudo reflector --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist &> /dev/null
  print_success "[+] Mirrorlist updated!"
}

conf_pacman() {
  local pacman_conf="/etc/pacman.conf"
  sudo sed -i 's/^#Color/Color/' "$pacman_conf" &&
  sudo sed -i '/^Color/a ILoveCandy' "$pacman_conf" &&
  installer pacman-contrib && sudo systemctl enable paccache.timer &> /dev/null
  print_success "[+] Pacman configured!"
}

activate_ssh() {
  sudo systemctl enable sshd &> /dev/null && print_success "[+] SSH enabled!"
}

conf_powerprofiles() {
  installer power-profiles-daemon && sudo systemctl enable power-profiles-daemon.service &> /dev/null
  print_success "[+] Power plan configured!"
}

conf_nvidia() {
  sudo sed -i 's/^MODULES=(.*)$/& nvidia nvidia_modeset nvidia_uvm nvidia_drm/' /etc/mkinitcpio.conf &&
  sudo sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT="\(.*\)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 nvidia_drm.modeset=1"/' /etc/default/grub &&
  sudo bash -c 'echo "ACTION==\"add\", DEVPATH==\"/bus/pci/drivers/nvidia\", RUN+=\"/usr/bin/nvidia-modprobe -c 0 -u\"" > /etc/udev/rules.d/70-nvidia.rules' &&
  sudo ln -sf /dev/null /etc/udev/rules.d/61-gdm.rules &&
  sudo sed -i 's/^#WaylandEnable=false/WaylandEnable=true/' /etc/gdm/custom.conf &&
  sudo bash -c 'echo "options nvidia NVreg_PreserveVideoMemoryAllocations=1" > /etc/modprobe.d/nvidia-power-mgmt.conf' &&
  sudo mkinitcpio -P &> /dev/null && sudo grub-mkconfig -o /boot/grub/grub.cfg &> /dev/null
  print_success "[+] NVIDIA, NVENC and GDM configured!"
}

windows_tpm_config() {
  installer sbctl os-prober ntfs-3g &&
  sudo grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB --modules="tpm" --disable-shim-lock &> /dev/null &&
  sudo grub-mkconfig -o /boot/grub/grub.cfg &> /dev/null &&
  sudo sbctl status &> /dev/null &&
  sudo sbctl create-keys &> /dev/null &&
  sudo sbctl enroll-keys --microsoft &> /dev/null &&
  sudo sbctl sign -s /boot/EFI/GRUB/grubx64.efi &> /dev/null
  print_success "[+] Windows Dualboot configured!"
}

ssh_key_config() {
  local email="$1" key_name="$2" key_dir="$HOME/.ssh/keyring/$key_name"
  mkdir -p "$key_dir" &&
  ssh-keygen -t ed25519 -C "$email" -f "$key_dir/id_ed25519" -N "" &&
  print_success "[+] SSH key generated in $key_dir!"
}

ssh_key_import() {
  local import_path="$1" target_dir="$HOME/.ssh/keyring"
  mkdir -p "$target_dir" &&
  cp -r "$import_path"/* "$target_dir" && chmod -R 700 "$target_dir" &&
  print_success "[+] SSH keys imported successfully!"
}

vpn_import() {
  local vpn_dir="$HOME/.vpn"
  git clone git@github.com:andreatirelli3/vpn.git "$vpn_dir" &> /dev/null &&
  print_success "[+] VPN configuration imported!"
}

# MAIN BODY
[ "$EUID" -eq 0 ] && { print_error "Please do not run as root."; exit 1; }
cd "$HOME"

read -p "Install AUR helper? (y/n): " aur_choice
[[ "$aur_choice" =~ ^[Yy]$ ]] && install_aur || :

read -p "Configure pacman? (y/n): " pacman_choice
[[ "$pacman_choice" =~ ^[Yy]$ ]] && conf_pacman || :

read - p "Configure Bluetooth? (y/n): " bluetooth_choice
[[ "$bluetooth_choice" =~ ^[Yy]$ ]] && conf_bluetooth || :

read -p "Configure SSH? (y/n): " ssh_choice
[[ "$ssh_choice" =~ ^[Yy]$ ]] && activate_ssh || :

read -p "Install Flatpak? (y/n): " flatpak_choice
[[ "$flatpak_choice" =~ ^[Yy]$ ]] && installer flatpak || :

read -p "Configure Chaotic AUR repository? (y/n): " chaotic_choice
[[ "$chaotic_choice" =~ ^[Yy]$ ]] && conf_chaoticaur || :

read -p "Update mirrorlist? (y/n): " mirrorlist_choice
[[ "$mirrorlist_choice" =~ ^[Yy]$ ]] && gen_mirrorilist || :

read -p "Configure Power Plan? (y/n): " powerplan_choice
[[ "$powerplan_choice" =~ ^[Yy]$ ]] && conf_powerprofiles || :

read -p "Configure Nvidia and GDM? (y/n): " nvidia_choice
[[ "$nvidia_choice" =~ ^[Yy]$ ]] && conf_nvidia || :

read -p "Configure Windows Dualboot? (y/n): " dualboot_choice
[[ "$dualboot_choice" =~ ^[Yy]$ ]] && windows_tpm_config || :

read -p "Generate new SSH key? (y/n): " sshkey_choice
if [[ "$sshkey_choice" =~ ^[Yy]$ ]]; then
read -p "Enter email for SSH key: " ssh_email
read -p "Enter name for SSH key: " ssh_key_name
ssh_key_config "$ssh_email" "$ssh_key_name" || :
fi

read -p "Import SSH keys? (y/n): " sshkey_import_choice
if [[ "$sshkey_import_choice" =~ ^[Yy]$ ]]; then
read -p "Enter path to import SSH keys from: " ssh_import_path
ssh_key_import "$ssh_import_path" || :
fi

read -p "Import VPN configuration? (y/n): " vpn_import_choice
[[ "$vpn_import_choice" =~ ^[Yy]$ ]] && vpn_import || :

print_success "All configurations completed!"
