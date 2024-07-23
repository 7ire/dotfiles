# NVIDIA driver

In this guide are present the necessary step to configure correctly the NVIDIA driver:

- NVENC, video encoder
- Enable GDM + Wayland with NVIDIA driver

## Requirments

Check if in the following file if the kernel modules and params are enabled and loaded at kernel startup.

> [!NOTE]
> It is shown for GRUB, if using another bootloader check the proper guide.

- **grub** check if `nvidia-drm.modeset=1` is in the file, if not add it (like shown).

  ``` bash
  /etc/default/grub
  ______________________________________________________________________________________________________
  ...
  GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet nvidia_drm.modeset=1"
  ...
  ```

- **mkinitcpio**, check if `nvidia_modeset`, `nvidia_uvm`, and `nvidia_drm` modules are loaded with the kernel, if not add it (like shown).

  ``` bash
  /etc/mkinitcpio.conf
  ______________________________________________________________________________________________________
  ...
  MODULES=(... nvidia nvidia_modeset nvidia_uvm nvidia_drm)
  ...
  ```

If you applied some changes, regenerate kernel and GRUB configurations.

``` bash
# Update the kernel moduels 
mkinitcpio -P
# Generate the GRUB configuration
grub-mkconfig -o /boot/grub/grub.cfg
```

## NVENC

Add a `udev` rule to use and make avaible the **NVENC** encoder.

``` bash
/etc/udev/rules.d/70-nvidia.rules
______________________________________________________________________________________________________
ACTION=="add", DEVPATH=="/bus/pci/drivers/nvidia", RUN+="/usr/bin/nvidia-modprobe -c 0 -u"
```

## GDM + Wayland

> [!NOTE]
> This might be an unecessary step, but do it just in case. It don't break anything, just force to use **Wayland** in the selector menu of **GDM**.

- Disable GDM **udev** rule which force NVIDIA user the use **Xorg** 

  ``` bash
  ln -s /dev/null /etc/udev/rules.d/61-gdm.rules
  ```

- Enable **Wayland** in the **GDM** configuration

  ``` bash
  /etc/gdm/custom.conf
  ______________________________________________________________________________________________________
  "WaylandEnable=true"
  ```

## Fix suspsension

Fix some graphical bug derivated from the suspension of the host machine.

> [!NOTE]
> This might getting fixed in the following versions of **Wayland** or on other **DE/WM** so read additional documentations about it.

``` bash
/etc/modprobe.d/nvidia-power-mgmt.conf
---------------------------------------------------------------------------------
options nvidia NVreg_PreserveVideoMemoryAllocations=1
```