#!/bin/bash

# Import the utils function
source utils/utils.sh
# Import the gnome function
source bin/gnome.sh

#============================
# CONSTANTS STRUCTS
#============================

# List of packages to remove
REMOVE_PKG=(
  totem
  yelp
  epiphany
  orca
  snapshot
  baobab
  flatpak
  simple-scan
  gnome-software
  gnome-tour
  gnome-music
  gnome-maps
  gnome-contacts
  gnome-logs
  gnome-font-viewer
  gnome-system-monitor
  gnome-connections
  gnome-characters
  gnome-disk-utility
  gnome-remote-desktop
  gnome-console
  gnome-clocks
)

# List of packages to install
INSTALL_PKG=(
  # Fonts and Emoji
  noto-fonts-emoji  # Noto Emoji
  nerd-fonts        # Nerd Fonts
  # Base
  blackbox-terminal  # Terminal
  extension-manager  # GNOME Extension manager
  brave-bin          # Browser - Brave
  firefox            # Browser - Firefox
  spotify            # Music - Spotify
  amberol            # Music - Amberol
  # Office
  vscodium-bin       # Text editor - VSCodium
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
  signal-desktop      # Signal
)

# List of GNOME extensions to install
EXT_LIST=(
  blur-my-shell@aunetx                         # Blur my Shell
  just-perfection-desktop@just-perfection      # Just Perfection
  nightthemeswitcher@romainvigier.fr           # Night Theme Switcher
  custom-accent-colors@demiskp                 # Custom Accent Colors
  osd-volume-number@deminder                   # OSD Volume Number
  workspace-switcher-manager@G-dH.github.com   # WSM
  smile-extension@mijorus.it                   # Smile
  burn-my-windows@schneegans.github.com        # Burn my Windows
  dash-to-dock@micxgx.gmail.com                # Dash to Dock
  logomenu@aryan_k                             # Logo Menu
  aztaskbar@aztaskbar.gitlab.com               # App Icon Taskbar (optional)
  mediacontrols@cliffniff.github.com           # Media Controls
  weatheroclock@CleoMenezesJr.github.io        # Weather O'Clock
  media-progress@krypion17                     # Media Progress (optional)
  appindicatorsupport@rgcjonas.gmail.com       # AppIndicator and KStatusNotifierItem (optional)
  monitor@astraext.github.io                   # Astra Monitor
  netspeed@alynx.one                           # Net Speed (optional)
  tophat@fflewddur.github.io                   # TopHat (optional)
  arch-update@RaphaelRochet                    # Arch Linux Updates Indicator
  extension-list@tu.berry                      # Extension List
  clipboard-indicator@tudmotu.com              # Clipboard Indicator
  IP-Finder@linxgem33.com                      # IP Finder (optional)
  caffeine@patapon.info                        # Caffeine
  Airpod-Battery-Monitor@maniacx.github.com    # Airpod Battery Monitor
  Bluetooth-Battery-Meter@maniacx.github.com   # Bluetooth Battery Meter
  quick-settings-avatar@d-go                   # User Avatar In Quick Settings
  PrivacyMenu@stuarthayhurst                   # Privacy Quick Settings
  quick-settings-audio-panel@rayzeq.github.io  # Quick Settings Audio Panel
  gnome-ui-tune@itstime.tech                  # GNOME 4x UI Improvements
  app-hider@lynith.dev                        # App Hider
  AlphabeticalAppGrid@stuarthayhurst          # Alphabetical App Grid
)

#============================
# CONFIGURATION FUNCTIONS
#============================
rounded_window_corner() {
  # Rounded window
  installer nodejs npm gettext just &> /dev/null
  git clone https://github.com/flexagoon/rounded-window-corners &> /dev/null
  cd rounded-window-corners
  just install
  cd .. && rm -rf rounded-window-corners
  print_success "[+] Rounded window corners installed successfully!"
}

unite() {
  # Unite
  local url="https://github.com/hardpixel/unite-shell/releases/download/v78/unite-shell-v78.zip"
  local ext_path="$HOME/.local/share/gnome-shell/extensions"
  mkdir -p "$ext_path"
  curl -sL -o /tmp/unite-shell-v78.zip "$url" || { print_error "[-] Download failed"; exit 1; }
  unzip -qo /tmp/unite-shell-v78.zip -d "$ext_path" || { print_error "Extraction failed"; exit 1; }
  rm /tmp/unite-shell-v78.zip
  print_success "[+] Unite installed successfully!"
}

pop_shell() {
  # Pop shell
  installer typescript &> /dev/null
  git clone https://github.com/pop-os/shell.git &> /dev/null
  cd shell
  make local-install || true
  cd ..
  rm -rf shell
  print_success "[+] Pop shell installed successfully!"
}

top_bar_orhanizer() {
  # Top Bar Organizer
  if ! wget https://github.com/jamespo/gnome-extensions/releases/download/gnome46/top-bar-organizerjulian.gse.jsts.xyz.v10.shell-extension.zip &> /dev/null ||
     ! gnome-extensions install -f top-bar-*.zip; then
    print_error "[-] Tob Bar Organizer failed to install."
    return 1
  fi
}

hanabi() {
  # Hanabi
  if ! git clone https://github.com/jeffshee/gnome-ext-hanabi.git &> /dev/null ||
     ! cd gnome-ext-hanabi &> /dev/null ||
     ! ./run.sh install &> /dev/null; then
    print_error "[-] Hanabi failed to install!"
    return 1
  fi
  cd .. && rm -rf gnome-ext-hanabi
  print_success "[+] Hanabi installed successfully!"
}

#============================
# MAIN BODY
#============================

# Ensure the script is not run as root
root_checker

# Move to the home directory
cd $HOME

# Debloat GNOME system
read -p "Debloat GNOME? [y/N]: " choice
if [[ "$choice" =~ ^[Yy]$ ]]; then
  remover "${REMOVE_PKG[@]}"
fi

# Install prefer application
read -p "Install the desired applications? [y/N]: " choice
if [[ "$choice" =~ ^[Yy]$ ]]; then
  installer "${INSTALL_PKG[@]}"
fi

# GNOME tweak
## audio steps
read -p "Change the audio steps? [y/N]: " choice
if [[ "$choice" =~ ^[Yy]$ ]]; then
  print_warning "[*] Changing the system audio steps ..."
  audio_steps 2 || print_error "[-] Failed to change the system audio steps!"
fi
## workspace keybinds
read -p "Bind shortcut for workspace? [y/N]: " choice
if [[ "$choice" =~ ^[Yy]$ ]]; then
  workspace_binding
fi

# Rice GNOME
## theming
read -p "Rice GNOME with libwaita theming? [y/N]: " choice
if [[ "$choice" =~ ^[Yy]$ ]]; then
  # Install required packages
  installer morewaita flat-remix adw-gtk3 bibata-cursor-theme-bin papirus-icon-theme-git papirus-folders-git &> /dev/null
  # GNOME ricing
  theming
fi


## extensions
read -p "Install GNOME extensions? [y/N]: " choice
if [[ "$choice" =~ ^[Yy]$ ]]; then
  # Rounded window
  rounded_window_corner
  # Unite
  unite
  # Top Bar organizer
  top_bar_orhanizer
  # Hanabi
  hanabi
  # Install the extension from list
  ext_installer "${EXT_LIST[@]}"
fi