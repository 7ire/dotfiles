# Arch Linux installation

## Chroot - base configuration

The following section are reccomended/necessary to the correct working and stability of the Arch linux system.

---

### Pacman

Edit the file `pacman.conf` to personalize the apperence of the package manager and update the mirrorlist with `reflector`.

> [!NOTE]
> If you don't care/want a good looking pacman progress bar, just skip the edit of the package manager configuration.
>
> => {Color and ILoveCandy}.

- Edit the package manager configuration
  
  1. Enable the tag **Color** and **ILoveCandy**.

  ``` bash
  /etc/pacman.conf
  ______________________________________________________________________________________________________
  ...
  Color
  ILoveCandy
  ...
  ```

- Update the package manager **mirrorlist**.

  1. Install the required packages.

  ``` bash
  sudo pacman -S reflector rsync curl
  ```

  2. Backup the old mirrorlist file and update it with `reflector`.

  ``` bash
  # Backup the current mirrorlist
  sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak

  # Generate the new one with reflector
  sudo reflector --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
  ```

### External repository

Add to the package manager or to the system som additional server repository. Below are listed the most popular and common ones:

- [ChaoticAUR](https://aur.chaotic.cx/) - Automated building repo for AUR packages
- [Flatpak](https://flatpak.org/) - building, distributing, and running sandboxed desktop applications on Linux
- [snapcraft](https://snapcraft.io/store?categories=featured) - software packaging and deployment system developed by Canonical

> [!TIP]
> For more info about user/unofficial repository, read the following wiki pages:
>
> - [Arch unofficial user repositories](https://wiki.archlinux.org/title/Unofficial_user_repositories)
> - [Fedora third-tarty repositories](https://docs.fedoraproject.org/en-US/workstation-working-group/third-party-repos/)

