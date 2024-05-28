#!/bin/bash

set -e  # Interrompe lo script se un qualsiasi comando restituisce un codice di uscita diverso da zero

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
  for package in "${packages[@]}"; do
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
    com.raggesilver.BlackBox           # Terminal
    com.mattjakeman.ExtensionManager   # Extension manager
    com.github.tchx84.Flatseal         # Flatpaks manager
    com.brave.Browser                  # Browser
    org.mozilla.Thunderbird            # Email client
    md.obsidian.Obsidian               # Notes
    org.libreoffice.LibreOffice        # Document office
    net.xmind.XMind                    # Mind maps
    com.obsproject.Studio              # Video recorder
    com.spotify.Client                 # Spotify
    io.github.spacingbat3.webcord      # Discord
    org.kde.kdenlive                   # Video editor
    org.gnome.Loupe                    # Image visualizer
    com.github.rafostar.Clapper        # Video player
    org.telegram.desktop               # Telegram
    org.signal.Signal                  # Signal
    it.mijorus.smile                   # Emoji picker
    org.gnome.Calculator               # Calculator
  )
  
  print_info "Installing flatpaks ..."
  # Install flatpaks
  sudo flatpak install flathub -y "${flatpaks[@]}"
  print_success "Flatpaks installed!"
  
  # [TODO] - Fedora support
  # [TODO] - Debian support

  # Packages list
  packages=(
    noto-fonts-emoji
    nerd-fonts
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
  # - flat remix
  # - adw-gtk3
  # - bibata cursor
  # - thunderbird libwaita theme
  paru -S --noconfirm morewaita flat-remix adw-gtk3 bibata-cursor-theme-bin
  # Also theme flatpak
  sudo flatpak install -y org.gtk.Gtk3theme.adw-gtk3 org.gtk.Gtk3theme.adw-gtk3-dark
  git clone https://github.com/rafaelmardojai/thunderbird-gnome-theme

  # Enable all the themes
  # gsettings set org.gnome.desktop.interface icon-theme 'MoreWaita'
  gsettings set org.gnome.desktop.interface icon-theme "Flat-Remix-Blue-Light"
  gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3' && gsettings set org.gnome.desktop.interface color-scheme 'default'

  print_info "Thunderbird is not installed or neither execture for atleast 1 time, I cloned the repo but install it manually."

  # Clone wallpaper repository
  git clone git@github.com:andreatirelli3/wallpapers.git ~/Immagini/wallpaper
}

# Extensions
gnome_ext() {
  # [TODO] - Fedora support
  # [TODO] - Debian support
  sudo pacman -S --noconfirm jq

  EXT_LIST=(
    blur-my-shell@aunetx                          # Blur
    just-perfection-desktop@just-perfection       # Perfection
    gnome-ui-tune@itstime.tech                    # UI
    osd-volume-number@deminder                    # OSD Volume
    quick-settings-tweaks@qwreey                  # QS Tweak
    quick-settings-avatar@d-go                    # Avatar qs
    nightthemeswitcher@romainvigier.fr            # Night theme
    custom-accent-colors@demiskp                  # Accent color
    smile-extension@mijorus.it                    # Emoji
    app-hider@lynith.dev                          # App hider
    workspace-switcher-manager@G-dH.github.com    # Workspace switcher
    compact-quick-settings@gnome-shell-extensions.mariospr.org # Compact qs
    Airpod-Battery-Monitor@maniacx.github.com     # AirPods battery
    Bluetooth-Battery-Meter@maniacx.github.com    # Bluetooth battery
    caffeine@patapon.info                         # Caffeine
    logomenu@aryan_k                              # (left) Logo
    window-title-is-back@fthx                     # (left) Window title
    mediacontrols@cliffniff.github.com            # (center) Media player
    clipboard-indicator@tudmotu.com               # (right) Clipboard
    just-another-search-bar@xelad0m               # (right) Search
    IP-Finder@linxgem33.com                       # (right) IP
    arch-update@RaphaelRochet                     # (right) Updates
    extension-list@tu.berry                       # (right) Extension list
    openweather-extension@penguin-teal.github.io  # (right) Weather
    tophat@fflewddur.github.io                    # (right) Resource usage
    appindicatorsupport@rgcjonas.gmail.com        # (right) Sys tray
  )

  GN_CMD_OUTPUT=$(gnome-shell --version)
  GN_SHELL=${GN_CMD_OUTPUT:12:2}
  for i in "${EXT_LIST[@]}"
  do
    VERSION_LIST_TAG=$(curl -Lfs "https://extensions.gnome.org/extension-query/?search=${i}" | jq '.extensions[] | select(.uuid=="'"${i}"'")') 
    VERSION_TAG="$(echo "$VERSION_LIST_TAG" | jq '.shell_version_map |."'"${GN_SHELL}"'" | ."pk"')"
    wget -qO "${i}".zip "https://extensions.gnome.org/download-extension/${i}.shell-extension.zip?version_tag=$VERSION_TAG"
    gnome-extensions install --force "${i}".zip
    rm ${i}.zip
  done

  # Rounded window
  sudo pacman -S --noconfirm nodejs npm gettext just
  git clone https://github.com/flexagoon/rounded-window-corners
  cd rounded-window-corners
  just install
  cd .. && rm -rf rounded-window-corners
  
  # Unite
  # URL of the zip file
  url="https://github.com/hardpixel/unite-shell/releases/download/v78/unite-shell-v78.zip"
  # Directory to extract the extension
  extension_dir="$HOME/.local/share/gnome-shell/extensions"

  # Create the directory if it doesn't exist
  mkdir -p "$extension_dir"

  # Download the zip file
  curl -sL -o /tmp/unite-shell-v78.zip "$url" || { print_error "Download failed"; exit 1; }

  # Extract the zip file
  unzip -qo /tmp/unite-shell-v78.zip -d "$extension_dir" || { print_error "Extraction failed"; exit 1; }

  # Clean up
  rm /tmp/unite-shell-v78.zip

  # Pop shell
  sudo pacman -S --noconfirm typescript
  git clone https://github.com/pop-os/shell.git
  cd shell
  make local-install
  cd ..
  rm -rf shell
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

# 3. Default application
print_info "Installing default application ..."
gnome_app
print_success "Default application installed!"

# 4. Personalization
print_info "Theming the system ..."
gnome_theming
print_success "System themed!"

# 5. Extension
print_info "Installing extensions ..."
gnome_ext
print_success "Extensions installed!"

