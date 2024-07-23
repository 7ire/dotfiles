# Arch Linux installation

## Pre Requirements

First of all get the latest **Arch Linux** ISO image, you can download it [here](https://archlinux.org/download/). It is necessary a bootable USB:

Start by downloading the latest ISO image version available of **Arch Linux**. You can download it [here](https://archlinux.org/download/).
Make sure to have a free USB stick of at least 4GB, you need it to make the bootable USB stick with the ISO installation.

To make a bootable USB you can use one of the following programs:

- [Rufus](https://rufus.ie/it/) (Windows)
- [Impression](https://apps.gnome.org/it/Impression/) (Linux)

Now you are ready to install Arch linux. Just enter in the boot select of your system and boot in the USB stick.
To enter in the boot selector, these are some common keys:

- DEL
- F1
- F8
- F11
- F12

> [!WARNING]
> It is necessary to disable **Secure boot** to boot inside the Arch linux USB installation. Otherwise you will get an error when accessing it.

Before running `archinstall`, do:

1. update the package manager servers
2. install/update some packages
   - [archlinux-keyring](https://archlinux.org/packages/core/any/archlinux-keyring/)
   - [archinstall](https://wiki.archlinux.org/title/archinstall)
3. run `archinstall`

``` bash
pacman -Syy && pacman -S --noconfirm archlinux-keyring archinstall && archinstall
```

> [!IMPORTANT]
> If you are not connect via cable, but with WiFi, read the manuale page of `iwctl` for connecting to a WiFi network.
>
> - [iwctl(1) - Arch manual pages](https://man.archlinux.org/man/iwctl.1)

### Easy installation via SSH

For an easy installation of the system, connect to the machine with `ssh` from your host.

1. set `passwd` for the ISO media installation user - root
2. check the `ip address`
3. from your host connect via `ssh root@<ip>`

> [!NOTE]
> The **sshd** service should be running by default. Is is not running, start the service.
>
> `systemctl start sshd.service`

## Chroot - base configuration

The following section are reccomended/necessary to the correct working and stability of the Arch linux system.

---

### Pacman configuration

Edit the file `pacman.conf` to personalize the apperence of the package manager.

> [!NOTE]
> If you don't care/want a good looking pacman progress bar, just skip it.

- Enable the tag **Color** and **ILoveCandy**.

``` bash
/etc/pacman.conf
______________________________________________________________________________________________________
...
Color
ILoveCandy
...
```

### Mirrorlist updating

Update the default **mirrorlist** for the package manager with `reflector`.

1. Install the `reflector` package and it is dependencies.

``` bash
sudo pacman -S reflector curl rsync
```

2. Backup the current (default) mirrorlist.

``` bash
sudo sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak 
```

3. Generate a new mirrorlist with `reflector` desired options.

``` bash
sudo reflector --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
```

### Enable services

Enable the services that you desired to be on at the system startup.

> [!IMPORTANT]
> You can customize and add at your preference some other services, but be sure to atleast have this enabled to the correct work and stability of the Arch linux system.

- **paccache**, 
  1. Install `pacman-contrib` package. (For more information, read the [wiki](https://archlinux.org/packages/extra/x86_64/pacman-contrib/))

  ``` bash
  sudo pacman -S pacman-contrib`
  ```

  2. Enable the service `paccache`. (For more information, read the [wiki](https://wiki.archlinux.org/title/Pacman#Cleaning_the_package_cache))

  ``` bash
  sudo systemctl enable paccache.timer
  ```

- **reflector**
  - Enable the service `reflector.timer`

  ``` bash
  sudo systemctl enable reflector.timer
  ```

  > [!IMPORTANT]
  > Read the wiki about [reflector - systemd timer](https://wiki.archlinux.org/title/Reflector#systemd_service) and [systemd - running services after the network is up](https://wiki.archlinux.org/title/Systemd#Running_services_after_the_network_is_up). This will help you to setup correctly the service.

- **bluetooth**
  1. Install `bluez` and `bluez-utils` packages.

  ``` bash
  sudo pacman -S bluez bluez-utils
  ```

  2. Enable the service `bluetooth.service`

  ``` bash
  sudo systemctl enable bluetooth
  ```

  > [!NOTE]
  > The next step is optional but reccomended to have a better support of all type of bluetooth devices.

  3. In the service configuration enable:
    - **Experimental features**
    - **dual ControllerMode**

  ``` bash
  /etc/bluetooth/main.conf
  ---------------------------------------------------------------------------------
  [General]
  ...
  ControllerMode = dual
  ...
  # Enables D-Bus experimental interfaces
  # Possible values: true or false
  Experimental = true

  # Enables kernel experimental features, alternatively a list of UUIDs
  # can be given.
  # Possible values: true,false,<UUID List>
  # Possible UUIDS:
  ...
  # Defaults to false.
  KernelExperimental = true
  ```

- **ssh**
  - Enable the service `sshd.service`

  ``` bash
  sudo systemctl enable sshd
  ```
