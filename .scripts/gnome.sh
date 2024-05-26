#!/bin/bash

# Get distro
# Scan of the distro running in the system.
get_distro() {
  # Read the file /etc/os-release
  # Extract the value of ID
  local distro_id=$(grep -E '^ID=' /etc/os-release | cut -d'=' -f2)
  # Sanitize the output
  distro_id=${distro_id//\"/}
  # Return the value
  echo "$distro_id"
}

# [TODO] - Funzioni log di debug

# GNOME Audio
# Change the audio volume steps from 5 to 2.
gnome_audio_step() {
  gsettings set org.gnome.settings-daemon.plugins.media-keys volume-step 2
}

# [TODO] - Debloat

# [TODO] - Applicazioni di default

# [TODO] - Personalizzazioni
gnome_customization() {
  if [ "" = "arch" ]; then
    # Install the packages
    paru -S --noconfirm morewaita adw-gtk3 bibata-cursor-theme-bin
    flatpak install org.gtk.Gtk3theme.adw-gtk3 org.gtk.Gtk3theme.adw-gtk3-dark
    git clone https://github.com/rafaelmardojai/thunderbird-gnome-theme

    # morwaita
    gsettings set org.gnome.desktop.interface icon-theme 'MoreWaita'
    # adw-gtk3
    gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3' && gsettings set org.gnome.desktop.interface color-scheme 'default'

  else
    # [TODO]: Fedora
    # [TODO]: Debian
  fi
}

# GNOME Extensions
# Install the extensions listend inside the list.
gnome_ext() {
  # Extension list
  # [TODO] - Populate the list
  EXT_LIST=()
  
  GN_CMD_OUTPUT=$(gnome-shell --version)  # Version output
  GN_SHELL=${GN_CMD_OUTPUT:12:2}          # Sanitazie output version
  
  # Iterate through the extension list
  for i in "${EXT_LIST[@]}"
  do
    # Version list for the current extension
    VERSION_LIST_TAG=$(curl -Lfs "https://extensions.gnome.org/extension-query/?search=${i}" | jq '.extensions[] | select(.uuid=="'"${i}"'")') 
    # Find the version matching the gnome shell version
    VERSION_TAG="$(echo "$VERSION_LIST_TAG" | jq '.shell_version_map |."'"${GN_SHELL}"'" | ."pk"')"
    
    # HTTP request to the compose URL and get as .zip
    wget -O "${i}".zip "https://extensions.gnome.org/download-extension/${i}.shell-extension.zip?version_tag=$VERSION_TAG"
    # Install
    gnome-extensions install --force "${i}".zip
    rm ${i}.zip
  done
}

# Main
# -------
distro=$(get_distro_id)  # Get distro

