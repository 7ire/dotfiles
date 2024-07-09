#!/bin/bash

BASE_DIR="$HOME/dotfiles/linux/scripts"

# Import the utils function
source "$BASE_DIR/utils/utils.sh"

#============================
# UTILITY FUNCTIONS
#============================

# Change the audio step
audio_steps() {
  # Desire step value given as argument by user
  local STEP="$1"

  # Change the GNOME audio step
  if ! gsettings set org.gnome.settings-daemon.plugins.media-keys volume-step "$STEP" &> /dev/null; then
    return 1
  fi
}

# Install gnome extensions
ext_installer() {
  # Extensions list
  local EXT_LIST=("$@")

  # Check if there are specified extensions to install
  if [ ${#EXT_LIST[@]} -eq 0 ]; then
    print_error "[-] No extensions specified to install!"
    return 1
  fi

  # Obtain the current gnome shell version
  GN_CMD_OUTPUT=$(gnome-shell --version)
  GN_SHELL=${GN_CMD_OUTPUT:12:2}

  # Iterate for each extension
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
        print_error "[-] ${i} failed to install!"
      fi
    else
      print_error "[-] ${i} GNOME Shell version not supported!"
    fi
  done
}

# Rice system theme and application
theming() {
  # Enable themes - mandatory to be installed before the function call on the main script
  if ! gsettings set org.gnome.desktop.interface icon-theme 'MoreWaita' &> /dev/null ||
     ! gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3' &> /dev/null ||
     ! gsettings set org.gnome.desktop.interface color-scheme 'default' &> /dev/null; then
    return 1
  fi

  cd $HOME

  mkdir -p "$HOME/Temi"
  cd "$HOME/Temi"

  # Install catppucin shell themes
  mkdir "Catppucin-shell" && cd "Catppucin-shell"
  curl -LsSO "https://raw.githubusercontent.com/catppuccin/gtk/v1.0.3/install.py"

  # Light - latte
  python3 install.py latte blue &> /dev/null
  python3 install.py latte red &> /dev/null

  # Dark - mocha
  python3 install.py mocha blue &> /dev/null
  python3 install.py mocha red &> /dev/null
  cd ..

  # Install marble shell themes
  git clone https://github.com/imarkoff/Marble-shell-theme.git Marble-shell &> /dev/null
  cd Marble-shell

  # Install the Marble shell theme
  python install.py -a --filled --panel_no_pill &> /dev/null
  cd ..

  # Clone Thunderbird libwaita theme
  if ! git clone https://github.com/rafaelmardojai/thunderbird-gnome-theme Thunderbird-theme &> /dev/null; then
    print_warning "[-] Couldn't clone Thunderbird libwaita theme, do it manually."
  fi

  # Clone Rofi themes
  if ! git clone https://github.com/lr-tech/rofi-themes-collection.git Rofi-themes &> /dev/null; then
    print_warning "[-] Couldn't clone Rofi themes, do it manually."
  else
    # If you don't have the directories needed for the install create them with
    mkdir -p ~/.local/share/rofi/themes/
    # Copy the themes to the Rofi directory
    cp -r Rofi-themes/themes/spotlight.rasi "$HOME/.local/share/rofi/themes"
  fi

  cd $HOME
  
  # Clone my wallpapers repository
  if ! git clone git@github.com:7ire/wallpapers.git ~/Immagini/wallpaper &> /dev/null; then
    print_warning "[-] Couldn't clone the Wallpeper repo, do it manually."
  fi

  # Copy .local directory
  if ! cp -r "$HOME/dotfiles/linux/src/.local/share/bin" "$HOME/.local/share" &> /dev/null; then
    print_warning "[-] Couldn't copy bin/ inside .local/share, do it manually."
  fi

  print_success "[+] GNOME riced successfully!"
}

workspace_binding() {
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

  print_info "[:] Reseted useless keybinds!"

  # Swith to N workspace
  if ! dconf write /org/gnome/desktop/wm/keybindings/switch-to-workspace-1 "['<Super>1']" &> /dev/null ||
     ! dconf write /org/gnome/desktop/wm/keybindings/switch-to-workspace-2 "['<Super>2']" &> /dev/null ||
     ! dconf write /org/gnome/desktop/wm/keybindings/switch-to-workspace-3 "['<Super>3']" &> /dev/null ||
     ! dconf write /org/gnome/desktop/wm/keybindings/switch-to-workspace-4 "['<Super>4']" &> /dev/null ||
     ! dconf write /org/gnome/desktop/wm/keybindings/switch-to-workspace-5 "['<Super>5']" &> /dev/null ||
     ! dconf write /org/gnome/desktop/wm/keybindings/switch-to-workspace-6 "['<Super>6']" &> /dev/null ||
     ! dconf write /org/gnome/desktop/wm/keybindings/switch-to-workspace-7 "['<Super>7']" &> /dev/null ||
     ! dconf write /org/gnome/desktop/wm/keybindings/switch-to-workspace-8 "['<Super>8']" &> /dev/null ||
     ! dconf write /org/gnome/desktop/wm/keybindings/switch-to-workspace-9 "['<Super>9']" &> /dev/null; then
    return 1
  fi

  # Switch current application to the N workspace
  if ! dconf write /org/gnome/desktop/wm/keybindings/move-to-workspace-1 "['<Shift><Super>1']" &> /dev/null ||
     ! dconf write /org/gnome/desktop/wm/keybindings/move-to-workspace-2 "['<Shift><Super>2']" &> /dev/null ||
     ! dconf write /org/gnome/desktop/wm/keybindings/move-to-workspace-3 "['<Shift><Super>3']" &> /dev/null ||
     ! dconf write /org/gnome/desktop/wm/keybindings/move-to-workspace-4 "['<Shift><Super>4']" &> /dev/null ||
     ! dconf write /org/gnome/desktop/wm/keybindings/move-to-workspace-5 "['<Shift><Super>5']" &> /dev/null ||
     ! dconf write /org/gnome/desktop/wm/keybindings/move-to-workspace-6 "['<Shift><Super>6']" &> /dev/null ||
     ! dconf write /org/gnome/desktop/wm/keybindings/move-to-workspace-7 "['<Shift><Super>7']" &> /dev/null ||
     ! dconf write /org/gnome/desktop/wm/keybindings/move-to-workspace-8 "['<Shift><Super>8']" &> /dev/null ||
     ! dconf write /org/gnome/desktop/wm/keybindings/move-to-workspace-9 "['<Shift><Super>9']" &> /dev/null; then
    return 1
  fi

  print_success "[+] Workspaces keybinds assigned!"
}