#!/bin/bash

BASE_DIR="$HOME/dotfiles/linux/scripts"

# Import the utils function
source "$BASE_DIR/utils/utils.sh"
# Import the gnome function
source "$BASE_DIR/bin/gnome.sh"

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

FONT_PKG=(
  noto-fonts-emoji  # Google Noto emoji fonts
  nerd-fonts        # Font aggregator, collection, and patcher: 34 patched fonts
)

TUI_PKG=(
  btop           # System resources monitor
  downgrade      # Bash script for downgrading one or more packages
  fastfetch      # Like neofetch, but much faster
  1password-cli  # 	1Password command line tool
  yazi           # Blazing fast terminal file manager
  sioyek         # PDF viewer
  qutebrowser    # VIm-like browser
)

BASE_PKG=(
  kitty              # OpenGL-based terminal emulator
  extension-manager  # GNOME Shell extension manager
  brave-bin          # Web browser that blocks ads and trackers by default
  1password          # Password manager and secure wallet
  vscodium-bin       # Binary releases of VS Code without MS
  obsidian           # Plain text Markdown files
  thunderbird        # Standalone mail and news reader from mozilla.org
  clapper-git        # Modern media player built for the GNOME desktop environment
  smile              # An emoji picker with custom tags support
)

OFFICE_PKG=(
  planify                             # Task manager
  libreoffice-fresh                   # LibreOffice branch which contains new features and program enhancements
  libreoffice-extension-texmaths      # LaTeX equation editor for LibreOffice
  libreoffice-extension-writer2latex  # LibreOffice extensions for converting to and working with LaTeX in LibreOffice
  xmind                               # Brainstorming and Mind Mapping Software
)

MUSIC_PKG=(
  amberol        # Plays music, and nothing else
  spotify        # Music streaming service
  spicetify-cli  # Command-line tool to customize Spotify client
)

SOCIAL_PKG=(
  signal-desktop    # Signal Private Messenger
  telegram-desktop  # Telegram Desktop client
  vesktop-bin       # Snappier Discord experience with Vencord pre-installed
)

OTHER_PKG=(
  obs-studio  # Free, open source software for live streaming and recording
)



# List of GNOME extensions to install:
EXT_LIST=(
  blur-my-shell@aunetx                         # Blur my Shell
  just-perfection-desktop@just-perfection      # Just Perfection
  custom-accent-colors@demiskp                 # Custom Accent Colors
  osd-volume-number@deminder                   # OSD Volume Number
  quick-settings-tweaks@qwreey                 # Quick Settings Tweaks
  aztaskbar@aztaskbar.gitlab.com               # App Icon Taskbar
  smile-extension@mijorus.it                   # Smile
  dash-to-dock@micxgx.gmail.com                # Dash to Dock
  logomenu@aryan_k                             # Logo Menu
  mediacontrols@cliffniff.github.com           # Media Controls
  weatheroclock@CleoMenezesJr.github.io        # Weather O'Clock
  appindicatorsupport@rgcjonas.gmail.com       # AppIndicator and KStatusNotifierItem
  runcat@kolesnikov.se                         # Run cat
  arch-update@RaphaelRochet                    # Arch Linux Updates Indicator
  clipboard-indicator@tudmotu.com              # Clipboard Indicator
  caffeine@patapon.info                        # Caffeine
  Airpod-Battery-Monitor@maniacx.github.com    # Airpod Battery Monitor
  Bluetooth-Battery-Meter@maniacx.github.com   # Bluetooth Battery Meter
  quick-settings-avatar@d-go                   # User Avatar In Quick Settings
  PrivacyMenu@stuarthayhurst                   # Privacy Quick Settings
  gnome-ui-tune@itstime.tech                   # GNOME 4x UI Improvements
  app-hider@lynith.dev                         # App Hider
  AlphabeticalAppGrid@stuarthayhurst           # Alphabetical App Grid
  gsconnect@andyholmes.github.io               # GSConnect
  rounded-window-corners@fxgn                  # Rounded window corners
  window-title-is-back@fthx                    # Window title
  do-not-disturb-while-screen-sharing-or-recording@marcinjahn.com  # Do not disturb while screen sharing or recording
  # workspace-switcher-manager@G-dH.github.com   # WSM
)

#============================
# CONFIGURATION FUNCTIONS
#============================

# [DEPRECATED] - Rounded window
rounded_window_corner() {
  if ! installer nodejs npm gettext just &> /dev/null ||
     ! git clone https://github.com/flexagoon/rounded-window-corners &> /dev/null ||
     ! cd rounded-window-corners ||
     ! just install &> /dev/null; then
    return 1
  fi

  if ! cd .. || ! rm -rf rounded-window-corners; then
    print_warning "[-] Couldn't remove the build files, do it manually."
  fi

  print_success "[+] Rounded window corners installed successfully!"
}

# Unite
unite() {
  installer xorg-xprop

  local url="https://github.com/hardpixel/unite-shell/releases/download/v78/unite-shell-v78.zip"
  local ext_path="$HOME/.local/share/gnome-shell/extensions"
  mkdir -p "$ext_path"
  
  if ! curl -sL -o /tmp/unite-shell-v78.zip "$url" &> /dev/null ||
     ! unzip -qo /tmp/unite-shell-v78.zip -d "$ext_path"; then
    return 1
  fi

  if ! rm /tmp/unite-shell-v78.zip &> /dev/null; then
    print_warning "[-] Couldn't remove the build files, do it manually."
  fi

  print_success "[+] Unite installed successfully!"
}

# Pop shell
pop_shell() {
  if ! installer typescript &> /dev/null ||
     ! git clone https://github.com/pop-os/shell.git &> /dev/null; then
    return 1
  fi

  cd shell
  make local-install || true
  
  if ! cd .. || rm -rf shell; then
    print_warning "[-] Couldn't remove the build files, do it manually."
  fi

  print_success "[+] Pop shell installed successfully!"
}

# Top Bar Organizer
top_bar_organizer() {
  if ! wget https://github.com/jamespo/gnome-extensions/releases/download/gnome46/top-bar-organizerjulian.gse.jsts.xyz.v10.shell-extension.zip &> /dev/null ||
     ! gnome-extensions install -f top-bar-*.zip; then
    return 1
  fi

  print_success "[+] Tob Bar Organizer installed successfully!"
}

# Hanabi
hanabi() {
  if ! git clone https://github.com/jeffshee/gnome-ext-hanabi.git &> /dev/null ||
     ! cd gnome-ext-hanabi &> /dev/null ||
     ! ./run.sh install &> /dev/null; then
    return 1
  fi

  if ! cd .. || ! rm -rf gnome-ext-hanabi; then
    print_warning "[-] Couldn't remove the build files, do it manually."
  fi

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
  remover "${REMOVE_PKG[@]}" || print_error "[-] Failed to remove specified packages!"
fi

# Install prefer application
read -p "Install the desired applications? [y/N]: " choice
if [[ "$choice" =~ ^[Yy]$ ]]; then
  installer "${TUI_PKG[@]}" || print_error "[-] Failed to install TUI packages!"
  installer "${BASE_PKG[@]}" || print_error "[-] Failed to install base packages!"
  installer "${FONT_PKG[@]}" || print_error "[-] Failed to install base packages!"
  installer "${OFFICE_PKG[@]}" || print_error "[-] Failed to install office packages!"
  installer "${MUSIC_PKG[@]}" || print_error "[-] Failed to install music packages!"
  installer "${SOCIAL_PKG[@]}" || print_error "[-] Failed to install social packages!"
  installer "${OTHER_PKG[@]}" || print_error "[-] Failed to install other packages!"
  if ! git clone git@github.com:andreatirelli3/vault.git $HOME/Documenti/Obsidian &> /dev/null; then
    print_warning "[-] Couldn't clone the Obsidian vault, do it manually."
  else
    print_info "[:] Cloned the Obsidian vault in ~/Documenti/Obsidian."
  fi
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
  workspace_binding || print_error "[-] Failed to bind keybinds for workspaces!"
fi

# Rice GNOME
## theming
read -p "Rice GNOME with libwaita theming? [y/N]: " choice
if [[ "$choice" =~ ^[Yy]$ ]]; then
  # Install required packages
  if ! installer morewaita flat-remix adw-gtk3 bibata-cursor-theme-bin papirus-icon-theme-git papirus-folders-git &> /dev/null; then
    print_error "[-] Failed to install specified packages!"
  else 
    # GNOME ricing
    theming || print_error "[-] Failed to rice GNOME!"
  fi
fi

## extensions
read -p "Install GNOME extensions? [y/N]: " choice
if [[ "$choice" =~ ^[Yy]$ ]]; then
  # Install general dependencies
  installer jq unzip wget curl clutter
  # Unite
  unite || print_error "[-] Unite failed to install!"
  # Top Bar organizer
  top_bar_organizer || print_error "[-] Tob Bar Organizer failed to install!"
  # Hanabi
  hanabi || print_error "[-] Hanabi failed to install!"
  # Pop Shell!
  pop_shell || print_error "[-] Pop Shell! failed to install!"
  # Install the extension from list
  ext_installer "${EXT_LIST[@]}"
fi
