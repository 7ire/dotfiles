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

  # Check if 'paru' is installed
  if ! command -v paru &> /dev/null; then
    print_error "paru is not installed! Please install it first."
    return 1
  fi

  local packages=("$@")

  # Update the mirror server
  paru -Syy &> /dev/null

  for package in "${packages[@]}"; do
    # print_info "[*] Installing $package ..."
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

# Audio step
conf_audio() {
  # Change the audio mix step from 5 to 2
  gsettings set org.gnome.settings-daemon.plugins.media-keys volume-step 2
  print_success "[+] Audio step changed from 5 to 2!"
}

# Debloat
debloat_gnome() {
  if [ "$#" -eq 0 ]; then
    print_error "No packages specified to uninstall!"
    return 1  # Do nothing and exit the function.
  fi

  local packages=("$@")

  # Iterate over the packages and attempt to remove them.
  for package in "${packages[@]}"; do
    print_info "[*] Removing $package ..."
    if sudo pacman -Rcns --noconfirm "$package" &> /dev/null; then
      print_success "[+] $package removed successfully!"
    else
      print_error "[-] $package failed to remove."
    fi
  done
}

# Default application
default_app() {  
  # Packages list
  packages=(
    # Fonts and Emoji
    noto-fonts-emoji  # Noto Emoji
    nerd-fonts        # Nerd Fonts
    # Base
    blackbox-terminal  # Terminal
    extension-manager  # GNOME Extension manager
    brave-bin          # Browser - Brave
    spotify            # Music - Spotify
    # Office
    obsidian           # Notes - Obsidian
    thunderbird        # Mail client - Thunderbird
    # Libreoffice + LaTeX support
    libreoffice-fresh
    libreoffice-extension-texmaths
    libreoffice-extension-writer2latex
    # Other
    xmind       # Mind maps - XMind
    obs-studio  # Video recorder - OBS
    kdenlive    # Video editor - KDEnlive
    clapper     # Video player - Clapper
    smile       # Emoji picker - Smile
    # Social
    webcord             # WebCord
    telegram-desktop    # Telegram
    # Signal
    whatsapp-for-linux  # WhatsApp
  )
  
  installer "${packages[@]}"
}

# theming
gnome_theming() {
  installer morewaita flat-remix adw-gtk3 bibata-cursor-theme-bin
  # flatpak install --user -y org.gtk.Gtk3theme.adw-gtk3 org.gtk.Gtk3theme.adw-gtk3-dark
  # flatpak remove --unused
  git clone https://github.com/rafaelmardojai/thunderbird-gnome-theme
  git clone git@github.com:andreatirelli3/wallpapers.git ~/Immagini/wallpaper
  
  # Enable all the themes
  gsettings set org.gnome.desktop.interface icon-theme 'MoreWaita'
  # gsettings set org.gnome.desktop.interface icon-theme "Flat-Remix-Blue-Light"
  gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3' && gsettings set org.gnome.desktop.interface color-scheme 'default'

  print_info "Thunderbird is not installed or neither execture for atleast 1 time, I cloned the repo but install it manually."
  print_success "[+] GTK4/3 Libwaita theme consistency done!"
}

# Extensions
gnome_ext() {
  installer jq unzip wget curl

  # Rounded window
  installer nodejs npm gettext just
  git clone https://github.com/flexagoon/rounded-window-corners
  cd rounded-window-corners
  just install
  cd .. && rm -rf rounded-window-corners

  # Unite
  url="https://github.com/hardpixel/unite-shell/releases/download/v78/unite-shell-v78.zip"
  extension_dir="$HOME/.local/share/gnome-shell/extensions"
  mkdir -p "$extension_dir"

  # Download the zip file
  curl -sL -o /tmp/unite-shell-v78.zip "$url" || { print_error "[-] Download failed"; exit 1; }

  # Extract the zip file
  unzip -qo /tmp/unite-shell-v78.zip -d "$extension_dir" || { print_error "Extraction failed"; exit 1; }

  # Clean up
  rm /tmp/unite-shell-v78.zip

  # Pop shell
  sudo pacman -S --noconfirm typescript
  git clone https://github.com/pop-os/shell.git
  cd shell
  make local-install || true
  cd ..
  rm -rf shell

  EXT_LIST=(
    blur-my-shell@aunetx                          # Blur
    just-perfection-desktop@just-perfection       # Perfection
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

  for i in "${EXT_LIST[@]}"; do
    VERSION_LIST_TAG=$(curl -Lfs "https://extensions.gnome.org/extension-query/?search=${i}" | jq -c '.extensions[] | select(.uuid=="'"${i}"'")') 
    VERSION_TAG=$(echo "$VERSION_LIST_TAG" | jq -r '.shell_version_map | ."'"${GN_SHELL}"'" | ."pk"')
    
    if [ -n "$VERSION_TAG" ]; then
      wget -qO "${i}.zip" "https://extensions.gnome.org/download-extension/${i}.shell-extension.zip?version_tag=$VERSION_TAG"
      if [ $? -eq 0 ]; then
        gnome-extensions install --force "${i}.zip"
        rm "${i}.zip"
      else
        print_error "Failed to download extension: ${i}"
      fi
    else
      print_warning "No valid version found for extension: ${i}"
    fi
  done
}

#============================
# MAIN BODY
#============================

# Move to the home directory
cd $HOME

read -p "Do you want to change the audio step from 5 to 2? (y/n): " audio_choice
if [[ "$aur_choice" == "y" || "$aur_choice" == "Y" ]]; then
  conf_audio || print_error "[-] Failed to configure audio step!"
fi

# List of packages to be removed
default_packages=(
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
  gnome-weather
  gnome-clocks
  flatpak
)

read -p "Do you want to remove useless packages? (y/n): " debloat_choice
if [[ "$debloat_choice" == "y" || "$debloat_choice" == "Y" ]]; then
  debloat_gnome "${default_packages[@]}" || print_error "[-] Failed to remove useless packages!"
fi

read -p "Do you want to install the default applications? (y/n): " app_choice
if [[ "$app_choice" == "y" || "$app_choice" == "Y" ]]; then
  default_app || print_error "[-] Failed to install default applications!"
fi














# 1. Flatpak configure
read -p "Do you want to configure Flatpak? (y/n): " flatconfig_choice
if [[ "$flatconfig_choice" == "y" || "$flatconfig_choice" == "Y" ]]; then
  print_info "Configuring the Flathub repo for current user ..."
  flatpak_setup
  print_success "Flathub configured correctly!"
fi

# 2. Audio step
read -p "Do you want to change the audio step from 5 to 2? (y/n): " audio_choice
if [[ "$audio_choice" == "y" || "$audio_choice" == "Y" ]]; then
  print_info "Changing audio step from 5 => 2 ..."
  gnome_audio
  print_success "Audio step changed successfully!"
fi

# 3. Debloating
read -p "Do you want to debloat the system? (y/n): " debloat_choice
if [[ "$debloat_choice" == "y" || "$debloat_choice" == "Y" ]]; then
  print_info "Debloating the system ..."
  gnome_debloat
  print_success "System debloated!"
fi

# 4. Default application
read -p "Do you want to install the default applications? (y/n): " app_choice
if [[ "$app_choice" == "y" || "$app_choice" == "Y" ]]; then
  print_info "Installing default application ..."
  gnome_app
  print_success "Default application installed!"
fi

# 5. Personalization
read -p "Do you want theme the system (GTK4/3 Libwaita friendly)? (y/n): " theme_choice
if [[ "$theme_choice" == "y" || "$theme_choice" == "Y" ]]; then
  print_info "Theming the system ..."
  gnome_theming
  print_success "System themed!"
fi

# 6. Extension
read -p "Do you want to install the gnome extensions? (y/n): " ext_choice
if [[ "$ext_choice" == "y" || "$ext_choice" == "Y" ]]; then
  print_info "Installing extensions ..."
  gnome_ext
  print_success "Extensions installed!"
fi
