#!/bin/bash

# Import the utils function
source ../utils/utils.sh

#============================
# UTILITY FUNCTIONS
#============================

# Change the audio step from X to Y
audio_steps() {
  # X = 5, Y = 2
  gsettings set org.gnome.settings-daemon.plugins.media-keys volume-step 2 &> /dev/null
}

# Rice system theme and application
theming() {
  # Wallpapers
  git clone git@github.com:andreatirelli3/wallpapers.git ~/Immagini/wallpaper &> /dev/null

  # Packages
  ## arch
  installer morewaita flat-remix adw-gtk3 bibata-cursor-theme-bin papirus-icon-theme-git papirus-folders-git &> /dev/null
  ## TODO: fedora
  ## TODO: debian

  # Enable themes
  gsettings set org.gnome.desktop.interface icon-theme 'MoreWaita' &> /dev/null
  gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3' &> /dev/null
  gsettings set org.gnome.desktop.interface color-scheme 'default' &> /dev/null

  # TODO: clone firefox and thunderbird theme

  # TODO: copy .local directory
}