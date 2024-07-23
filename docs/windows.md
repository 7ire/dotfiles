# GRUB Windows dualboot

In this guide is shown how to setup correctly **GRUB** to support Microsoft certificate for a dualboot with **TPM 2.0**.

1. Install the required packages

- `os-prober`
- `sbctl`
- `ntfs-3g`

``` bash
sudo pacman -S os-prober sbctl ntfs-3g
```

2. Install **GRUB** with module **TPM** and *disable Shim*

``` bash
grub-mkconfig -o /boot/grub/grub.cfg
```

3. Check if sbctl is in **Setup mode**

``` bash
sbctl status
```

4. Generate a new key pair

``` bash
sbctl create-keys && sbctl enroll-keys -m
```

5. Sign the necessary bootloader and kernel images (Check manualty in the /boot mount point)

``` bash
sbctl sign -s /boot/EFI/GRUB/grubx64.efi
sbctl sign -s /boot/grub/x86_64-efi/core.efi
sbctl sign -s /boot/grub/x86_64-efi/grub.efi
sbctl sign -s /boot/vmlinuz-linux*
```

> [!NOTE]
> By doing those command, in the efi table will remain the previous entry of the grub boot loader that didn't support TPM, to clean the entry follow the next commands. 

## EFI entry table cleanup

> [!WARNING]
> Be careful with these command, might broke the system, if you are not sure or insecure, please read this documentation.

- [efibootmgr - Arch manual pages](https://man.archlinux.org/man/efibootmgr.8.en)
- [Use Linux efibootmgr Command to Manage UEFI Boot Menu - LinuxBabe](https://www.linuxbabe.com/command-line/how-to-use-linux-efibootmgr-examples)

In the `/boot/EFI` and remove the directory called `BOOT`. 
``` bash
# Remove the old boot entry 
sudo efibootmgr -b X -B
```