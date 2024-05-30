#!/bin/bash

# Check if sudo password is cached, if not ask for it
sudo -v || exit 1

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

# Audio step
conf_audio() {
  # Change the audio mix step from 5 to 2
  gsettings set org.gnome.settings-daemon.plugins.media-keys volume-step 2 &> /dev/null
  print_success "[+] Audio step changed from 5 to 2!"
}

# Debloat
debloat_gnome() {
  print_warning "[*] Removing useless packages..."
  if [ "$#" -eq 0 ]; then
    print_error "No packages specified to uninstall!"
    return 1  # Do nothing and exit the function.
  fi

  local packages=("$@")
  # Iterate over the packages and attempt to remove them.
  for package in "${packages[@]}"; do
    if sudo pacman -Rcns --noconfirm "$package" &> /dev/null; then
      print_success "[+] $package removed successfully!"
    else
      print_error "[-] $package failed to remove."
    fi
  done
  print_success "[+] Useless packages removed successfully!"
}

# Default application
default_app() {
  print_warning "[*] Installing default applications..."
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
    whatsapp-for-linux  # WhatsApp
  )
  
  installer "${packages[@]}"

  # Clone my Obsidian vault in Documents
  git clone git@github.com:andreatirelli3/vault.git $HOME/Documents/Obsidian &> /dev/null

  print_success "[+] Default applications installed successfully!"
}

# Theming
theming_gnome() {
  git clone git@github.com:andreatirelli3/wallpapers.git ~/Immagini/wallpaper &> /dev/null
  git clone https://github.com/rafaelmardojai/thunderbird-gnome-theme &> /dev/null
  installer morewaita flat-remix adw-gtk3 bibata-cursor-theme-bin papirus-icon-theme-git papirus-folders-git &> /dev/null
  
  # Enable all the themes
  papirus-folders -C adwaita --theme Papirus &> /dev/null
  gsettings set org.gnome.desktop.interface icon-theme 'Papirus' &> /dev/null
  gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3' &> /dev/null
  gsettings set org.gnome.desktop.interface color-scheme 'default' &> /dev/null

  print_info "Thunderbird is not installed or neither executed for at least one time, I cloned the repo but install it manually."
  print_info "Please copy the .local folder inside the cloned repo to the Thunderbird profile directory."
  print_success "[+] GTK4/3 Libwaita theme consistency done!"
}

# Extensions
gnome_ext() {
  installer jq unzip wget curl &> /dev/null

  # Rounded window
  installer nodejs npm gettext just &> /dev/null
  git clone https://github.com/flexagoon/rounded-window-corners &> /dev/null
  cd rounded-window-corners
  just install
  cd .. && rm -rf rounded-window-corners
  print_success "[+] Rounded window corners installed successfully!"

  # Unite
  url="https://github.com/hardpixel/unite-shell/releases/download/v78/unite-shell-v78.zip"
  extension_dir="$HOME/.local/share/gnome-shell/extensions"
  mkdir -p "$extension_dir"
  curl -sL -o /tmp/unite-shell-v78.zip "$url" || { print_error "[-] Download failed"; exit 1; }
  unzip -qo /tmp/unite-shell-v78.zip -d "$extension_dir" || { print_error "Extraction failed"; exit 1; }
  rm /tmp/unite-shell-v78.zip
  print_success "[+] Unite installed successfully!"

  # Pop shell
  installer typescript &> /dev/null
  git clone https://github.com/pop-os/shell.git &> /dev/null
  cd shell
  make local-install || true
  cd ..
  rm -rf shell
  print_success "[+] Pop shell installed successfully!"

  local EXT_LIST=("$@")
  
  if [ ${#EXT_LIST[@]} -eq 0 ]; then
    print_error "No extensions specified to install!"
    return 1
  fi

  GN_CMD_OUTPUT=$(gnome-shell --version)
  GN_SHELL=${GN_CMD_OUTPUT:12:2}

  for i in "${EXT_LIST[@]}"; do
    VERSION_LIST_TAG=$(curl -Lfs "https://extensions.gnome.org/extension-query/?search=${i}" | jq -c '.extensions[] | select(.uuid=="'"${i}"'")') 
    VERSION_TAG=$(echo "$VERSION_LIST_TAG" | jq -r '.shell_version_map | ."'"${GN_SHELL}"'" | ."pk"')
    
    if [ -n "$VERSION_TAG" ]; then
      wget -qO "${i}.zip" "https://extensions.gnome.org/download-extension/${i}.shell-extension.zip?version_tag=$VERSION_TAG"
      if [ $? -eq 0 ]; then
        gnome-extensions install --force "${i}.zip" &> /dev/null
        rm "${i}.zip"
        print_success "[+] ${i} installed successfully!"
      else
        print_error "[-] ${i} failed to install."
      fi
    else
      print_error "[-] ${i} failed to install."
    fi
  done
}

#============================
# MAIN BODY
#============================

# Move to the home directory
cd $HOME

read -p "Do you want to change the audio step from 5 to 2? (y/n): " audio_choice
if [[ "$audio_choice" == "y" || "$audio_choice" == "Y" ]]; then
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

read -p "Do you want to theme the system (GTK4/3 Libwaita friendly)? (y/n): " theme_choice
if [[ "$theme_choice" == "y" || "$theme_choice" == "Y" ]]; then
  theming_gnome || print_error "[-] Failed to theme GNOME!"
fi

# List of GNOME extensions to install
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

read -p "Do you want to install the GNOME extensions? (y/n): " ext_choice
if [[ "$ext_choice" == "y" || "$ext_choice" == "Y" ]]; then
  gnome_ext "${EXT_LIST[@]}" || print_error "[-] Failed to install GNOME extensions!"
fi