# GNOME configuration guide
---
## General base configuration
Start by removing useless application that come with the GNOME desktop environment and install the desired one.

My list of application that I remove from my GNOME desktop environment.

> Warning, take a closer look of which application you remove and there is in the following list, might be useful for you and you want to keep it. But no panic, you can always reinstall it in a second moment.

``` bash
totem yelp epiphany orca snapshot baobab flatpak simple-scan gnome-software gnome-tour gnome-music gnome-maps gnome-contacts gnome-logs gnome-font-viewer gnome-system-monitor gnome-connections gnome-characters gnome-disk-utility gnome-remote-desktop gnome-console gnome-clocks
```

My list of application that I rock in my GNOME system:
- TUI Application

| Package       | Description               |
| ------------- | ------------------------- |
| **fastfetch** | Show system information   |
| **downgrade** | Downgrade package version |

- GUI Application

| Package                                           | Description                                    |
| ------------------------------------------------- | ---------------------------------------------- |
| **kitty**                                         | Terminal emulator                              |
| **blackbox-terminal**                             | Terminal emulator                              |
| **extension-manager**                             | GNOME Extension manager                        |
| **brave-bin**                                     | Browser - Brave                                |
| **firefox**                                       | Browser - Firefox                              |
| **spotify**                                       | Music - Spotify                                |
| **amberol**                                       | Music - Amberol                                |
| **vscodium-bin**                                  | IDE - VSCodium                                 |
| **obsidian**                                      | Note - Obsidian                                |
| **thunderbird**                                   | Mail client - Thunderbird                      |
| **planify**                                       | Productivity - Planify                         |
| **libreoffice-fresh**                             | Office - Libre Office                          |
| [Arch BTW] **libreoffice-extension-texmaths**     | Office - Libre Office support of math equation |
| [Arch BTW] **libreoffice-extension-writer2latex** | Office - Libre Office support of LaTeX         |
| **xmind**                                         | Mind map - XMind                               |
| **obs-studio**                                    | Video recorder - OBS                           |
| **kdenlive**                                      | Video editor - KDEnlive                        |
| **clapper**                                       | Video player - Clapper                         |
| **smile**                                         | Emoji picker - Smile                           |
| **vesktop-bin**                                   | Vesktop - Discord                              |
| **telegram-desktop**                              | Telegram                                       |
| **signal-desktop**                                | Signal                                         |


Some tweaking of the system, to have more control and better workflow of the GNOME desktop environment.

> For kitty, copy the config file inside the `.config` folder of the dotfiles.

One annoying thing is the audio step, that by default is set to 5. For more or less control and accuracy of the audio volume, change it with the desire value, in this case.
- Volume step = `2`

``` bash
gsettings set org.gnome.settings-daemon.plugins.media-keys volume-step 2
```

Next is it possible to bind some shortcut to improve the workflow of the system.

- Launch applications:

| Command                  | Shortcut    |
| ------------------------ | ----------- |
| **Terminal**             | `super + T` |
| **Browser**              | `super + F` |
| **File manager**         | `super + E` |
| **System settings**      | `super + I` |
| **Note taking**          | `super + N` |
| **Application launcher** | `super + A` |

- Motion and control

| Command                         | Shortcut              |
| ------------------------------- | --------------------- |
| **Kill application**            | `super + Q`           |
| **Go to last workspace**        | `super + 0`           |
| **Move to the right workspace** | `super + TAB`         |
| **Move to the left workspace**  | `super + shift + TAB` |

> For the next binding - workspace, keep in mind to disable **dynamic workspaces** in the **gnome-control-settings** to a better usability of each shortcut and more organization of each workspace.

- Switch to a desire workspace:

| Command         | Shortcut    |
| --------------- | ----------- |
| **Workspace 1** | `super + 1` |
| **Workspace 2** | `super + 2` |
| **Workspace 3** | `super + 3` |
| **Workspace 4** | `super + 4` |
| **Workspace 5** | `super + 5` |
| **Workspace 6** | `super + 6` |
| **Workspace 7** | `super + 7` |
| **Workspace 8** | `super + 8` |
| **Workspace 9** | `super + 9` |
> It is recommend to use the command binding provided by **dconf** because the *gnome-control-center* is limited to 4 workspace.

`dconf write /org/gnome/desktop/wm/keybindings/switch-to-workspace-1 "['<Super>1']"`

And edit the value `1` based on the X workspace binding.

- Move application to a desire workspace:

| Command                             | Shortcut            |
| ----------------------------------- | ------------------- |
| **Move application to workspace 1** | `super + shift + 1` |
| **Move application to workspace 2** | `super + shift + 2` |
| **Move application to workspace 3** | `super + shift + 3` |
| **Move application to workspace 4** | `super + shift + 4` |
| **Move application to workspace 5** | `super + shift + 5` |
| **Move application to workspace 6** | `super + shift + 6` |
| **Move application to workspace 7** | `super + shift + 7` |
| **Move application to workspace 8** | `super + shift + 8` |
| **Move application to workspace 9** | `super + shift + 9` |
> It is recommend to use the command binding provided by **dconf** because the *gnome-control-center* is limited to 4 workspace.

`dconf write /org/gnome/desktop/wm/keybindings/move-to-workspace-1 "['<Shift><Super>1']"` 

And edit the value `1` based on the X workspace binding. 
## Ricing of the desktop environment
To rice a bit the system, install some packages for GNOME shell theme, icon theme, cursor and extensions. This is all about preferences so fell free to ignore the recommendations and all the packages installed in the following sections to make your own system.

GNOME-shell/theme:
- [gtk-catppucin](https://github.com/catppuccin/gtk/blob/main/docs/USAGE.md)

Icons:
- [MoreWaita](https://github.com/somepaulo/MoreWaita)
- [adw-gkt3](https://github.com/lassekongo83/adw-gtk3)
- [papirus-icon-theme](https://github.com/PapirusDevelopmentTeam/papirus-icon-theme)
	- extend with [papirus-folder-git](https://github.com/PapirusDevelopmentTeam/papirus-folders)
- [flat-remix](https://github.com/daniruiz/flat-remix)

Cursor:
- [bibata-cursor](https://github.com/ful1e5/Bibata_Cursor)

Application:
- [Firefox](https://github.com/rafaelmardojai/firefox-gnome-theme)
	- [ShyFox](https://www.reddit.com/r/unixporn/comments/1dl1xzx/oc_shyfox_theme_for_firefox_i_made/)
- [Thunderbird](https://github.com/rafaelmardojai/thunderbird-gnome-theme)
- Spotify:
	- [spicetify](https://spicetify.app/docs/advanced-usage/installation/#note-for-linux-users)
	- [spicetify-theme](https://github.com/spicetify/spicetify-themes)
- Venvcord:
	- [catppucin](https://github.com/catppuccin/discord)

Put this in the customCSS file (Venvcord settings, inside Discord)
``` css
/* mocha */
@import url("https://catppuccin.github.io/discord/dist/catppuccin-mocha.theme.css");
```

For more custom experience in the GNOME desktop environment it is possible to install some extensions. There are listed some of my favorite one:
- [pop-shell!](https://github.com/pop-os/shell.git)
- [unite](https://github.com/hardpixel/unite-shell/)
- [Top bar organizer](https://github.com/jamespo/gnome-extensions/releases/download/gnome46/top-bar-organizerjulian.gse.jsts.xyz.v10.shell-extension.zip)

This are some of my extensions that I install in my system, for more details, please check the dotfiles and the `ext_installer` and the list of all extensions passed to the installer.
## Additional notes
- Fix **Arch Linux update indicator**

`blackbox -- /bin/sh -c "echo 'Starting update...' && sudo pacman -Syu && echo 'Done - Press enter to exit' && read _"`
