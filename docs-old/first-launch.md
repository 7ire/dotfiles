# First access to system setup guide
---
## System stability and tweak
It is recommend to setup system **snapshot**. This will guarantee in case of a bad update or a failed one, it is possible to go back in time and restore the previous "image" of the system and fix the system.

> Important, make your the layout of the partitions is in a way that / is separate from /home. This help because the snapshot will be only for /, because is where the system cloud broke and there is no purpose to snapshot /home with only user file and directories.

Requirement for the next step **btrfs** file system and layout partition.

[System backup - Arch wiki](https://wiki.archlinux.org/title/System_backup)

- Install [snapper](https://wiki.archlinux.org/title/Snapper)

``` bash
# DEVICE can be:
# 
# /dev/mapper/root => crypto disk
# 
# /dev/nvme0n1p2 => (non) crypto disk, partition of the system (lsblk)

# Unmount the subvolume @.snapshots
sudo umount /.snapshots
# Delete the existing mountpoint
sudo rmdir /.snapshots
# Create snapper config for /
sudo snapper -c root create-config /
# Delete the subvolume created by Snapper
sudo btrfs subvolume delete /.snapshots
# Recreate the mountpoint /.snapshots
sudo mkdir /.snapshots
# Remount the subvolume @.snapshots
sudo mount -o subvol=@.snapshots DEVICE /.snapshots

# Enable requirment services
sudo systemctl enable snapper-timeline.timer
sudo systemctl enable snapper-cleanup.timer
```


(ONLY IF IN CHROOT YOU RE-INSTALLED GRUB)

Now that the system is mounted and operating on it, it is possible to clean the **efibootmgr** table.

> Do the steps as root.


- List all efi boot entry
``` bash
efibootmgr
```
- Find the entry to delete, usually /boot/EFI/BOOT/...
- Once found, check the ID, like 003 and delete the entry
``` bash
efibootmgr -b X -B
```

To be sure that the change work correclty do:
- Enable **os-prober** in `/etc/default/grub`
- Regenerate the GRUB config => `grub-mkconfig -o /boot/grub/grub.cfg`

## Additional tweak
If the system is a notebook and have a fingerprint reader, it is possible to configure it to use it to unlock the system.

- Install `fprintd libfprint imagemagick usbutils`
- Configure the following files

`/etc/pam.d/polkit-1` add the following line at EOF or create a new file.

``` bash
/etc/pam.d/polkit-1
---------------------------------------------------------------------------------
auth sufficient pam_fprintd.so
auth include system-auth
account include system-auth
password include system-auth
session include system-auth
```

Copia il file `/etc/polkit-1/rules.d/50-default.rules`

``` bash
cp /usr/share/polkit-1/rules.d/50-default.rules /etc/polkit-1/rules.d/50-default.rules

# Modifica del gruppo di utenti nel file delle regole di polkit
# 
# USER_GROUP=$(id -gn)

sudo sed -i "s/unix-group:wheel/unix-group:$USER_GROUP/" /etc/polkit-1/rules.d/50-default.rules
```

Other step can be:
- [Configure git identity](https://stackoverflow.com/questions/6116548/how-to-tell-git-to-use-the-correct-identity-name-and-email-for-a-given-project)
- [Configure SSH key for github](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent) + `.ssh/config` file if missing

``` bash
.ssh/config
---------------------------------------------------------------------------------
Host github.com
    HostName github.com
	IdentityFile "$HOME/.ssh/keyring/github/github"
	IdentitiesOnly yes
```

- Import VPNs