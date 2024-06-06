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

# BlueZ Configuration Tweaks
tweak_bluez() {
  BLUETOOTH_CONF="/etc/bluetooth/main.conf"
  
  # Update ControllerMode to dual
  if grep -q "^ControllerMode = bredr" "$BLUETOOTH_CONF"; then
    if ! sudo sed -i 's/^ControllerMode = bredr/ControllerMode = dual/' "$BLUETOOTH_CONF"; then
      print_error "[-] Failed to update ControllerMode in Bluetooth configuration!"
      return 1
    fi
  else
    if ! echo "ControllerMode = dual" | sudo tee -a "$BLUETOOTH_CONF" > /dev/null; then
      print_error "[-] Failed to add ControllerMode to Bluetooth configuration!"
      return 1
    fi
  fi

  # Enable Experimental feature
  if grep -q "^\[General\]" "$BLUETOOTH_CONF"; then
    if grep -q "^Experimental = false" "$BLUETOOTH_CONF"; then
      if ! sudo sed -i 's/^Experimental = false/Experimental = true/' "$BLUETOOTH_CONF"; then
        print_error "[-] Failed to update Experimental feature in Bluetooth configuration!"
        return 1
      fi
    elif ! grep -q "^Experimental = true" "$BLUETOOTH_CONF"; then
      if ! sudo sed -i '/^\[General\]/a Experimental = true' "$BLUETOOTH_CONF"; then
        print_error "[-] Failed to add Experimental feature to Bluetooth configuration!"
        return 1
      fi
    fi
  else
    if ! echo -e "\n[General]\nExperimental = true" | sudo tee -a "$BLUETOOTH_CONF" > /dev/null; then
      print_error "[-] Failed to add [General] section and Experimental feature to Bluetooth configuration!"
      return 1
    fi
  fi

  # Restart Bluetooth service
  if ! sudo systemctl restart bluetooth &> /dev/null; then
    print_error "[-] Failed to restart Bluetooth service!"
    return 1
  fi

  print_success "[+] BlueZ tweaks applied and Bluetooth service restarted!"
}

# GNOME Workspace
tweak_workspace() {
  # Reset useless keybinds
  if ! dconf write /org/gnome/shell/keybindings/switch-to-application-1 "@as []" &> /dev/null ||
     ! dconf write /org/gnome/shell/keybindings/switch-to-application-2 "@as []" &> /dev/null ||
     ! dconf write /org/gnome/shell/keybindings/switch-to-application-3 "@as []" &> /dev/null ||
     ! dconf write /org/gnome/shell/keybindings/switch-to-application-4 "@as []" &> /dev/null ||
     ! dconf write /org/gnome/shell/keybindings/switch-to-application-5 "@as []" &> /dev/null ||
     ! dconf write /org/gnome/shell/keybindings/switch-to-application-6 "@as []" &> /dev/null ||
     ! dconf write /org/gnome/shell/keybindings/switch-to-application-7 "@as []" &> /dev/null ||
     ! dconf write /org/gnome/shell/keybindings/switch-to-application-8 "@as []" &> /dev/null ||
     ! dconf write /org/gnome/shell/keybindings/switch-to-application-9 "@as []" &> /dev/null; then
    print_error "[-] Failed to reset useless keybinds!"
    return 1
  fi

  print_success "[+] Reseted useless keybinds!"

  if ! dconf write /org/gnome/desktop/wm/keybindings/switch-to-workspace-1 "['<Super>1']" &> /dev/null ||
     ! dconf write /org/gnome/desktop/wm/keybindings/switch-to-workspace-2 "['<Super>2']" &> /dev/null ||
     ! dconf write /org/gnome/desktop/wm/keybindings/switch-to-workspace-3 "['<Super>3']" &> /dev/null ||
     ! dconf write /org/gnome/desktop/wm/keybindings/switch-to-workspace-4 "['<Super>4']" &> /dev/null ||
     ! dconf write /org/gnome/desktop/wm/keybindings/switch-to-workspace-5 "['<Super>5']" &> /dev/null ||
     ! dconf write /org/gnome/desktop/wm/keybindings/switch-to-workspace-6 "['<Super>6']" &> /dev/null ||
     ! dconf write /org/gnome/desktop/wm/keybindings/switch-to-workspace-7 "['<Super>7']" &> /dev/null ||
     ! dconf write /org/gnome/desktop/wm/keybindings/switch-to-workspace-8 "['<Super>8']" &> /dev/null ||
     ! dconf write /org/gnome/desktop/wm/keybindings/switch-to-workspace-9 "['<Super>9']" &> /dev/null; then
    print_success "[-]  Failed to bind keybinds for workspaces"
    return 1
  fi

  print_success "[+] Workspaces keybinds assigned!"
}

# GNOME Extensions
tweak_ext() {
  # Top Bar Organizer
  if ! wget https://github.com/jamespo/gnome-extensions/releases/download/gnome46/top-bar-organizerjulian.gse.jsts.xyz.v10.shell-extension.zip &> /dev/null ||
     ! gnome-extensions install -f top-bar-*.zip &> /dev/null; then
    print_error "[-] Failed to install Top Bar Organizer!"
    return 1
  fi

  print_success "[+] Extensions installed!"
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

# Prompt user to tweak BlueZ
read -p "Do you want to tweak Bluez with the new features? [y/N]: " choice
if [[ "$choice" =~ ^[Yy]$ ]]; then
  tweak_bluez || print_error "[-] Failed to tweak BlueZ. Continuing..."
fi

# Prompt user to tweak keybinds
read -p "Do you want to tweak GNOME workspaces keybinds? [y/N]: " choice
if [[ "$choice" =~ ^[Yy]$ ]]; then
  tweak_workspace || print_error "[-] Failed to tweak GNOME workspaces keybinds. Continuing..."
fi

# Prompt user to tweak extensions
read -p "Do you want to tweak GNOME extensions? [y/N]: " choice
if [[ "$choice" =~ ^[Yy]$ ]]; then
  tweak_ext || print_error "[-] Failed to tweak GNOME extensions. Continuing..."
fi

print_info "All selected configurations are completed!"
