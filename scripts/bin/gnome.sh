#!/bin/bash

# Import the utils function
source ../utils/utils.sh

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
  gsettings set org.gnome.desktop.interface icon-theme 'MoreWaita' &> /dev/null
  gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3' &> /dev/null
  gsettings set org.gnome.desktop.interface color-scheme 'default' &> /dev/null
  
  # Clone my wallpapers repository
  git clone git@github.com:andreatirelli3/wallpapers.git ~/Immagini/wallpaper &> /dev/null

  # Clone Firefox and Thunderbird libwaita theme
  git clone https://github.com/rafaelmardojai/firefox-gnome-theme &> /dev/null
  git clone https://github.com/rafaelmardojai/thunderbird-gnome-theme &> /dev/null

  # TODO: copy .local directory
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