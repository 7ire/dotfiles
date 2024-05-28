# Arch Linux Installation Guide
---
## TL;TR
1. Arch linux installation
	1. Connect via ssh
		a. (optional) wifi via iwctl
		b. setup root password
	2. Install `archlinux-keyring` and `archinstall`
	3. Install the system
2. CHROOT setup the system
	1. Package manager configuration - `pacman`
	2. (optional) Bluetooth configuration
	3. Enable the SSH daemon
	4. Install AUR helper - PARU
	5. Configurate `flatpak`
	6. Setup Chaotic AUR repository server
	7. Update mirrorlist
	8. (optional) Power plan
	9. (optional) gdm + NVIDIA
	10. (optional) Windows dualboot
## Arch Linux Installation
> Just follow the options that `archinstall` show to us.
## CHROOT
### Package manager configuration
Configure the package manager cache clean using `paccache.timer` daemon provide in the `pacman-contrib` and improve the readability of the progress bar of it by adding **Color** and **ILoveCandy** tag in the configuration file.
``` bash
# Path of the configuration file
pacman_conf="/etc/pacman.conf"
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
```
### Bluetooth configuration
> Do this step only if the system support the Bluetooth module.

[Arch Linux wiki - Bluetooth](https://wiki.archlinux.org/title/Bluetooth)
Install `bluez` and `bluez-utils` package to support the *bluetooth* module.
``` bash
# Install the required packages => { bluez, bluez-utils}
sudo pacman -S --noconfirm bluez bluez-utils
# Enable bluetooth daemon
sudo systemctl enable bluetooth
```
### Enable SSH daemon
Enable the **SSH** daemon to open the SSH service at the start of the system at connect it remotely.
[Arch Linux wiki - Secure SHell](https://wiki.archlinux.org/title/Secure_Shell)
``` bash
# Enable sshd daemon
sudo systemctl enable sshd
```
### AUR Helper
Install an AUR helper binary to let the system be able to download the package in the *AUR repository*. The AUR helper of choice is **PARU**.
[GitHub repository - paru](https://github.com/Morganamilo/paru)
``` bash
# Download the AUR helper bin
git clone https://aur.archlinux.org/paru.git && cd paru
# Build the binary
makepkg -si
# Update package manager and AUR helper
sudo pacman -Syy && paru -Syu
# Clean files
cd .. && rm -rf paru
```
### Flatpak configuration
**Flatpak** in a linux software provide that ship cross platform linux application running in sandbox environment.
[Flatpak - setup](https://flatpak.org/setup/Arch)
``` bash
# Install the package
sudo pacman -S --noconfirm flatpak
```
### Chaotic AUR repostiory server
**Chaotic AUR**, automated building repo for [AUR](https://aur.archlinux.org/) packages.
[Chaotic AUR - How to use it](https://aur.chaotic.cx/)
``` bash
# Import the key of the repo and the sign
sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
sudo pacman-key --lsign-key 3056513887B78AEB
# Install chaotic AUR keyring
sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
# Install chaotic AUR mirrorlist
sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
  
# String to add the mirrorlist entry in the conf file
chaotic_repo=$(cat <<EOF

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
```
### Mirrorlist updating
> *Maintaining up-to-date mirror list in your Arch Linux gives some major benefits. If you use updated mirrorlist, you could easily avoid slow download rate, and timed-out error messages while installing, and updating packages.*

[Retrieve Latest Mirror List Using Reflector In Arch Linux](https://ostechnix.com/retrieve-latest-mirror-list-using-reflector-arch-linux/)
``` bash
# Install required packages
sudo pacman -S --noconfirm reflector rsync curl
# Backup current mirrorlist
sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
# Generate the new one with reflector
sudo reflector --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
```
### Power plan
[Power management](https://en.wikipedia.org/wiki/Power_management "wikipedia:Power management") is a feature that turns off the power or switches system components to a low-power state when inactive.
[Arch Linux wiki - power plan](https://wiki.archlinux.org/title/Power_management)
``` bash
# Install the power plan profiles package
sudo pacman -S --noconfirm power-profiles-daemon
# Enable the service
sudo systemctl enable power-profiles-daemon.service
```
### NVIDIA + GDM
...
[Arch Linux wiki - NVIDIA](https://wiki.archlinux.org/title/NVIDIA)
[NVIDIA and Wayland setup](https://linuxiac.com/nvidia-with-wayland-on-arch-setup-guide/)
[Arch Linux wiki - GDM troubleshooting](https://wiki.archlinux.org/title/GDM#Troubleshooting)
``` bash
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
```
### Windows dualboot
...
[r/archlinux - My easy method for setting up Secure Boot with GRUB](https://www.reddit.com/r/archlinux/comments/10pq74e/my_easy_method_for_setting_up_secure_boot_with/)
``` bash
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
```