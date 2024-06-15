#!/bin/bash

# Import the utils function
source ../utils/utils.sh

# Bluetooth ControllerMode = dual
bt_controllermode_dual() {
  # Bluetooth configuration file
  local BLUETOOTH_CONF="/etc/bluetooth/main.conf"

  # Update ControllerMode to dual
  if grep -q "^#*ControllerMode = dual" "$BLUETOOTH_CONF"; then
    if ! sudo sed -i 's/^#*ControllerMode = dual/ControllerMode = dual/' "$BLUETOOTH_CONF"; then
      return 1
    fi
  else
    if ! echo "ControllerMode = dual" | sudo tee -a "$BLUETOOTH_CONF" > /dev/null; then
      return 1
    fi
  fi
}

# Bluetooth Kernel Experimental
bt_kernel_exp() {
  # Bluetooth configuration file
  local BLUETOOTH_CONF="/etc/bluetooth/main.conf"

  # Enable Experimental feature
  if grep -q "^\[General\]" "$BLUETOOTH_CONF"; then
    if grep -q "^#*Experimental = false" "$BLUETOOTH_CONF"; then
      if ! sudo sed -i 's/^#*Experimental = false/Experimental = true/' "$BLUETOOTH_CONF"; then
        return 1
      fi
    elif ! grep -q "^Experimental = true" "$BLUETOOTH_CONF"; then
      if ! sudo sed -i '/^\[General\]/a Experimental = true' "$BLUETOOTH_CONF"; then
        return 1
      fi
    fi
  else
    if ! echo -e "\n[General]\nExperimental = true" | sudo tee -a "$BLUETOOTH_CONF" > /dev/null; then
      return 1
    fi
  fi
}

# Generate mirrorlist
gen_mirrorlist() {
  # Backup existing mirrorlist
  if ! sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak; then
    print_warning "[-] Failed to backup existing mirrorlist! I will continue anyway ..."
  fi

  # Update the mirrorlist using reflector
  if ! sudo reflector -n 20 -p https --sort rate --save /etc/pacman.d/mirrorlist --country 'Italy,Germany,France' --latest 20 &> /dev/null; then
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

  print_success "[+] Mirrorlist updated and Reflector service configured successfully!"
}

# Configurazione NVIDIA, NVENC e GDM
conf_nvidia() {
  # Add necessary modules to mkinitcpio.conf
  if ! sudo sed -i '/^MODULES=/ s/(\(.*\))/(\1 nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /etc/mkinitcpio.conf ||
     # Update GRUB configuration
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
    return 1
  fi
  print_success "[+] NVIDIA, NVENC and GDM configured!"
}

# Windows Dualboot Configuration
win_dualboot() {
  # Install necessary packages and configure GRUB for TPM
  if ! sudo grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB --modules="tpm" --disable-shim-lock &> /dev/null ||
     ! sudo grub-mkconfig -o /boot/grub/grub.cfg &> /dev/null ||
     # Setup Secure Boot with sbctl
     ! sudo sbctl status &> /dev/null ||
     ! sudo sbctl create-keys &> /dev/null ||
     ! sudo sbctl enroll-keys --microsoft &> /dev/null ||
     ! sudo sbctl sign -s /boot/EFI/GRUB/grubx64.efi ||
     ! sudo sbctl sign -s /boot/grub/x86_64-efi/core.efi ||
     ! sudo sbctl sign -s /boot/grub/x86_64-efi/grub.efi ||
     ! sudo sbctl sign -s /boot/vmlinuz-linux-zen; then
    return 1
  fi
  print_success "[+] Windows Dualboot configured!"
}