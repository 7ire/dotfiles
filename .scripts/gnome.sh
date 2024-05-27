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

# Audio step
gnome_audio() {
  # Change the audio mix step from 5 to 2
  gsettings set org.gnome.settings-daemon.plugins.media-keys volume-step 2
}

# Debloat
gnome_debloat() {
  # List of packages to be removed
  packages=(
    totem
    yelp
    gnome-software
    gnome-tour
    gnome-music
    epiphany
    gnome-maps
    gnome-contacts
    gnome-logs
    gnome-font-viewer
    simple-scan
    orca
    gnome-system-monitor
    gnome-connections
    gnome-characters
    snapshot
    baobab
    gnome-disk-utility
    gnome-text-editor
    gnome-remote-desktop
    gnome-console
    loupe
    gnome-calculator
    gnome-weather
  )

  print_warning "The following packages will be removed:"
  for package in "${packages[@]}"; then
    print_warning "- $package"
  done

  # [TODO] - Fedora support
  # [TODO] - Debian support

  # Remove the packages
  sudo pacman -Rcns "${packages[@]}"

  if [ $? -eq 0 ]; then
    print_success "Packages removed successfully."
  else
    print_error "An error occurred while removing the packages."
  fi
}

# Default application
gnome_app() {
  # Flatpak list
  flatpaks=(
    com.raggesilver.BlackBox
    com.mattjakeman.ExtensionManager
    com.github.tchx84.Flatseal
    org.mozilla.Thunderbird
    md.obsidian.Obsidian
    org.libreoffice.LibreOffice
    com.obsproject.Studio
    com.spotify.Client
    io.github.spacingbat3.webcord
    org.kde.kdenlive
    org.gnome.Loupe
    com.github.rafostar.Clapper
    org.telegram.desktop
    org.signal.Signal
  )
  
  print_info "Installing flatpaks ..."
  # Install flatpaks
  flatpak install flathub "${flatpaks[@]}"
  print_success "Flatpaks installed!"
  
  # [TODO] - Fedora support
  # [TODO] - Debian support

  # Packages list
  packages=(
    brave-bin
  )
  
  print_info "Installing packages"
  # Install packages
  paru -S --noconfirm "${packages[@]}"
  print_success "Packages installed!"
}

# theming
gnome_theming() {
  # [TODO] - Fedora support
  # [TODO] - Debian support

  # Install the following packages:
  #
  # - morewaita
  # - adw-gtk3
  # - bibata cursor
  # - thunderbird libwaita theme
  paru -S --noconfirm morewaita adw-gtk3 bibata-cursor-theme-bin
  # Also theme flatpak
  flatpak install org.gtk.Gtk3theme.adw-gtk3 org.gtk.Gtk3theme.adw-gtk3-dark
  git clone https://github.com/rafaelmardojai/thunderbird-gnome-theme

  # Enable all the themes
  gsettings set org.gnome.desktop.interface icon-theme 'MoreWaita'
  gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3' && gsettings set org.gnome.desktop.interface color-scheme 'default'

  print_info "Thunderbird is not installed or neither execture for atleast 1 time, I cloned the repo but install it manually."
}


# Main
# -------
# 1. Audio step
# 2. Debloat
# 3. Default application
# 4. Personalizzation
# 5. Extensions

# Move to the home directory
cd ~

# 1. Audio step
print_info "Changing audio step from 5 => 2 ..."
gnome_audio
print_success "Audio step changed successfully!"

# 2. Debloating
print_info "Debloating the system ..."
gnome_debloat
print_success "System debloated!"

# 3.

# 4. Personalization
print_info "Theming the system ..."
gnome_theming
print_success "System themed!"
