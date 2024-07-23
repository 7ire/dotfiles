# GNOME Configuration

## Volume steps keys

Change the default value of the GNOME media key **volume-step**.

- Default = `5`

``` bash
gsettings set org.gnome.settings-daemon.plugins.media-keys volume-step 2
```

## Workstation application

Install the necessary/prefer application for your workstation. Above there is my application picks for each category/purpose.

> [!IMPORTANT]
> All the packages are reference at the AUR repository, so for **Arch linux**. But the same packages or similar can be found in your current running linux distribution or other repository like [AppImage](https://appimage.org/), [Flatpak](https://flatpak.org/) or [Snapcraft](https://snapcraft.io/).

- TUI:
  - [kitty](https://archlinux.org/packages/extra/x86_64/kitty/)
  - [fastfetch](https://archlinux.org/packages/extra/x86_64/fastfetch/)
  - [btop](https://archlinux.org/packages/extra-staging/x86_64/btop/)
  - [yazi](https://archlinux.org/packages/extra/x86_64/yazi/)
  - [sioyek](https://aur.archlinux.org/packages/sioyek)
  - [qutebrowser](https://archlinux.org/packages/extra/any/qutebrowser/)
  
  ``` bash
  paru -S --noconfirm kitty fastfetch btop yazi sioyek qutebrowser
  ```

- GNOME control and customization:
  - [extension-manager](https://aur.archlinux.org/packages/extension-manager)
  - [grub-customizer](https://archlinux.org/packages/extra/x86_64/grub-customizer/)

  ``` bash
  paru -S --noconfirm extension-manager grub-customizer
  ```

- General usage:
  - [firefox](https://archlinux.org/packages/extra/x86_64/firefox/)
  - [brave-bin](https://aur.archlinux.org/packages/brave-bin)
  - [thunderbird](https://archlinux.org/packages/extra/x86_64/thunderbird/)
  - [obsidian](https://archlinux.org/packages/extra/x86_64/obsidian/)
  - [1password](https://aur.archlinux.org/packages/1password)
  
  ``` bash
  paru -S --noconfirm firefox brave-bin thunderbird obsidian 1password
  ```

- Office:
  - [libreoffice-fresh](https://archlinux.org/packages/extra/x86_64/libreoffice-fresh/)
  - [libreoffice-extension-texmaths](https://archlinux.org/packages/extra/any/libreoffice-extension-texmaths/)
  - [libreoffice-extension-writer2latex](https://archlinux.org/packages/extra/any/libreoffice-extension-writer2latex/)
  - [planify](https://aur.archlinux.org/packages/planify)
  - [xmind](https://aur.archlinux.org/packages/xmind)
  
  ``` bash
  paru -S --noconfirm libreoffice-fresh libreoffice-extension-texmaths libreoffice-extension-writer2latex planify xmind
  ```

- Media/Music:
  - [spotify](https://aur.archlinux.org/packages/spotify)
  - [spicetify-cli](https://aur.archlinux.org/packages/spicetify-cli)
  - [amberol](https://aur.archlinux.org/packages/amberol)
  - [clapper](https://archlinux.org/packages/extra-testing/x86_64/clapper/)
  
  ``` bash
  paru -S --noconfirm spotify spicetify-cli amberol clapper
  ```

- Other useful packages:
  - Fonts:
    - [nerd-fonts](https://archlinux.org/groups/x86_64/nerd-fonts/)
    - [noto-fonts-emoji](https://archlinux.org/packages/extra/any/noto-fonts-emoji/)
    - [smile](https://aur.archlinux.org/packages/smile)
  - Social:
    - [vesktop-bin](https://aur.archlinux.org/packages/vesktop-bin)
    - [telegram-desktop](https://archlinux.org/packages/extra/x86_64/telegram-desktop/)
    - [signal-desktop](https://archlinux.org/packages/extra/x86_64/signal-desktop/)
  - Recording/Editing:
    - [obs-studio](https://archlinux.org/packages/extra/x86_64/obs-studio/)
    - [obs-pipewire-audio-capture-bin](https://aur.archlinux.org/packages/obs-pipewire-audio-capture-bin)
    - [kdenlive](https://archlinux.org/packages/extra/x86_64/kdenlive/)
    - [upscaler](https://aur.archlinux.org/packages/upscaler)
  - Utils:
    - [ulauncher](https://aur.archlinux.org/packages/ulauncher)
    - [impression](https://aur.archlinux.org/packages/impression)
    - [fragments](https://archlinux.org/packages/extra/x86_64/fragments/)
    - [grub-customizer](https://archlinux.org/packages/extra/x86_64/grub-customizer/)
    - [gdm-settings](https://aur.archlinux.org/packages/gdm-settings)
  - File manager - Nemo:
    - [nemo](https://archlinux.org/packages/extra/x86_64/nemo/)
    - [nemo-fileroller](https://archlinux.org/packages/extra/x86_64/nemo-fileroller/)
    - [nemo-image-converter](https://archlinux.org/packages/extra/x86_64/nemo-image-converter/)
    - [nemo-preview](https://archlinux.org/packages/extra/x86_64/nemo-preview/)
    - [nemo-seahorse](https://archlinux.org/packages/extra/x86_64/nemo-seahorse/)
    - [nemo-dropbox-git](https://aur.archlinux.org/packages/nemo-dropbox-git)

> [!NOTE]
> If you installed `nemo` as a file manager, to configure correctly the right-click option "*Open in Terminal*"  use the following **gsettings** command to assign your default/prefer terminal emulator.

``` bash
gsettings set org.cinnamon.desktop.default-applications.terminal exec <terminal>
```

## Workflow

## Ricing

- Firefox:
  - [EdgyArg](https://github.com/artsyfriedchicken/EdgyArc-fr)

- Thunderbird:
  - [Libadwaita](https://github.com/rafaelmardojai/thunderbird-gnome-theme)

- Spotify:
  - [spicetify](https://spicetify.app/docs/advanced-usage/installation/#note-for-linux-users)
  - [spicetify-theme](https://github.com/spicetify/spicetify-themes)

- Venvcord:
  - [catppucin](https://github.com/catppuccin/discord)

    ``` css
    /* mocha */
    @import url("https://catppuccin.github.io/discord/dist/catppuccin-mocha.theme.css");
    ```

  - [system24](https://github.com/refact0r/system24)
