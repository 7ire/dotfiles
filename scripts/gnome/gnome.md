# GNOME Configuration guide
---
## TL;TR
1. Audio step 5 to 2
2. Debloat of useless application
3. Install default/prefer applications
4. Theme libwaita personalizzation
5. Extensions installation
6. Shortcut
## Audio step
Change the behavior of the shell in the audio step, decreasing it from 5 to 2.
``` bash
# Change the audio mix step from 5 to 2
gsettings set org.gnome.settings-daemon.plugins.media-keys volume-step 2
```
## System debloat
Uninstall useless application that come already pre-shipped in the **gnome** package group.

[Arch Linux repo - GNOME group pkg](https://archlinux.org/groups/x86_64/gnome/)
``` bash
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

# Remove the packages
sudo pacman -Rcns "${packages[@]}"
```
## Default/prefer application
## Theme libwaita personalizzation
## Extensions installation
## Shortcut

| Action                                             | Bind                  |
| -------------------------------------------------- | --------------------- |
| App - Terminal                                     | `super + T`           |
| App - Browser                                      | `super + F`           |
| App - File                                         | `super + E`           |
| App - Settings                                     | `super + I`           |
| App - Obsidian                                     | `super + N`           |
| Navigation - Workspace 1                           | `super + 1`           |
| Navigation - Workspace 2                           | `super + 2`           |
| Navigation - Workspace 3                           | `super + 3`           |
| Navigation - Workspace 4                           | `super + 4`           |
| Navigation - Last workspace                        | `super + 0`           |
| Navigation - Next workspace                        | `super + tab`         |
| Navigation - Previous workspace                    | `super + shift + tab` |
| Navigation - Move focus application to N workspace | `super + shift + 'N'` |
| Navigation - Close current application             | `super + Q`           |
