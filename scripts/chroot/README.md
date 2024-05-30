# Configuration Script Documentation

This Bash script automates various system configurations for an Arch Linux installation. Below are the main functions and how to use them.

## Script Structure

### Debug Functions

- **print_success(message)**: Prints a success message in green.
- **print_error(message)**: Prints an error message in red.
- **print_info(message)**: Prints an informational message in cyan.

### Utility Functions

- **installer(packages)**: Installs the specified packages using `paru`. It also updates the mirror servers.

### Configuration Functions

- **install_aur()**: Installs an AUR helper (in this case, `paru`).
- **conf_bluetooth()**: Configures Bluetooth by installing the `bluez` and `bluez-utils` packages and enabling the Bluetooth service.
- **conf_chaoticaur()**: Configures the Chaotic AUR repository.
- **gen_mirrorilist()**: Updates the mirrorlist using `reflector`.
- **conf_pacman()**: Configures `pacman`, enabling color, adding `ILoveCandy`, and enabling `paccache.timer`.
- **activate_ssh()**: Enables the SSH service.
- **conf_powerprofiles()**: Configures the power plan by installing `power-profiles-daemon` and enabling the service.
- **conf_nvidia()**: Configures NVIDIA, NVENC, and GDM.
- **windows_tpm_config()**: Configures dual boot with Windows and TPM.
- **ssh_key_config(email, key_name)**: Generates a new SSH key.

### Main Script

- Checks that the script is not being run as root.
- Executes various configurations based on user choices.

## How to Use the Script

1. **Running the Script**

   Download and make the script executable:
   ```bash
   chmod +x config_script.sh
   ./config_script.sh
   ```

2. **User Interaction**

   The script will ask if you want to perform various configurations. Answer `y` (yes) or `n` (no) for each prompt.

3. **Available Functions**

   - **Install AUR Helper**: Installs an AUR helper (`paru`).
   - **Configure Pacman**: Configures `pacman` to enable color, add `ILoveCandy`, and enable `paccache.timer`.
   - **Configure Bluetooth**: Configures and enables the Bluetooth service.
   - **Enable SSH**: Enables the SSH service.
   - **Install Flatpak**: Installs `flatpak`.
   - **Configure Chaotic AUR**: Configures the Chaotic AUR repository.
   - **Update Mirrorlist**: Updates the mirrorlist using `reflector`.
   - **Configure Power Plan**: Configures the power plan.
   - **Configure Nvidia and GDM**: Configures NVIDIA, NVENC, and GDM.
   - **Configure Dualboot with Windows**: Configures dual boot with Windows and TPM.
   - **Generate SSH Key**: Generates a new SSH key.

## Example Execution

Run the script and answer the questions to configure your system according to your needs.

```bash
./config_script.sh
```

## Technical Details

### Function `print_success(message)`

```bash
print_success() {
  local message="$1"
  echo -e "\e[32m$message\e[0m"
}
```
Prints a success message in green.

### Function `print_error(message)`

```bash
print_error() {
  local message="$1"
  echo -e "\e[31m$message\e[0m"
}
```
Prints an error message in red.

### Function `print_info(message)`

```bash
print_info() {
  local message="$1"
  echo -e "\e[36m$message\e[0m"
}
```
Prints an informational message in cyan.

### Function `installer(packages)`

```bash
installer() {
  if [ "$#" -eq 0 ]; then
    print_error "No packages specified to install!"
    return 1
  fi

  if ! command -v paru &> /dev/null; then
    print_error "paru is not installed! Please install it first."
    return 1
  fi

  local packages=("$@")

  paru -Syy &> /dev/null

  for package in "${packages[@]}"; do
    print_info "[*] Installing $package ..."
    if paru -S --noconfirm "$package" &> /dev/null; then
      print_success "[+] $package installed successfully!"
    else
      print_error "[-] $package failed to install."
    fi
  done
}
```
Installs the specified packages using `paru`. It also updates the mirror servers.

### Function `install_aur()`

```bash
install_aur() {
  print_info "[*] Installing an AUR helper ..."
  if [ -d "paru" ]; then
    rm -rf paru
  fi

  if ! git clone https://aur.archlinux.org/paru.git &> /dev/null || ! cd paru || ! makepkg -si &> /dev/null; then
    print_error "[-] Failed to install AUR helper!"
    return 1
  fi

  sudo pacman -Syy &> /dev/null && paru -Syy &> /dev/null
  cd .. && rm -rf paru
  print_success "[+] AUR helper installed!"
}
```
Installs an AUR helper (`paru`).

### Function `conf_bluetooth()`

```bash
conf_bluetooth() {
  print_info "[*] Configuring Bluetooth ..."
  if ! installer bluez bluez-utils || ! sudo systemctl enable bluetooth &> /dev/null; then
    print_error "[-] Failed to configure Bluetooth!"
    return 1
  fi
  print_success "[+] Bluetooth configured!"
}
```
Configures Bluetooth by installing the `bluez` and `bluez-utils` packages and enabling the Bluetooth service.

### Function `conf_chaoticaur()`

```bash
conf_chaoticaur() {
  print_info "[*] Configuring Chaotic AUR repository ..."
  if ! sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com &> /dev/null ||
     ! sudo pacman-key --lsign-key 3056513887B78AEB &> /dev/null ||
     ! sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' &> /dev/null ||
     ! sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst' &> /dev/null; then
    print_error "[-] Failed to configure Chaotic AUR repository!"
    return 1
  fi

  local chaotic_repo=$(cat <<EOF

[chaotic-aur]
Include = /etc/pacman.d/chaotic-mirrorlist
EOF
  )

  if ! grep -q "\[chaotic-aur\]" /etc/pacman.conf; then
    echo "$chaotic_repo" | sudo tee -a /etc/pacman.conf > /dev/null
  fi

  sudo pacman -Syy &> /dev/null && paru -Syy &> /dev/null
  print_success "[+] Chaotic AUR repository configured!"
}
```
Configures the Chaotic AUR repository.

### Function `gen_mirrorilist()`

```bash
gen_mirrorilist() {
  print_info "[*] Updating mirrorlist ..."
  if ! installer reflector rsync curl || ! sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak ||
     ! sudo reflector --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist &> /dev/null; then
    print_error "[-] Failed to update mirrorlist!"
    return 1
  fi
  print_success "[+] Mirrorlist updated!"
}
```
Updates the mirrorlist using `reflector`.

### Function `conf_pacman()`

```bash
conf_pacman() {
  print_info "[*] Configuring pacman ..."
  local pacman_conf="/etc/pacman.conf"
  if ! sudo sed -i 's/^#Color/Color/' "$pacman_conf" ||
     ! grep -q '^ILoveCandy' "$pacman_conf" && ! sudo sed -i '/^Color/a ILoveCandy' "$pacman_conf" ||
     ! installer pacman-contrib || ! sudo systemctl enable paccache.timer &> /dev/null; then
    print_error "[-] Failed to configure pacman!"
    return 1
  fi
  print_success "[+] Pacman configured!"
}
```
Configures `pacman`, enabling color, adding `ILoveCandy`, and enabling `paccache.timer`.

### Function `activate_ssh()`

```bash
activate_ssh() {
  print_info "[*] Enabling SSH ..."
  if ! sudo systemctl enable sshd &> /dev/null; then
    print_error "[-] Failed to enable SSH!"
    return 1
  fi
  print_success "[+] SSH enabled!"
}
```
Enables the SSH service.

### Function `conf_powerprofiles()`

```bash
conf_powerprofiles() {
  print_info "[*] Configuring Power Profiles ..."
  if ! installer power-profiles-daemon || ! sudo systemctl enable power-profiles-daemon &>