# Windows 11 guide
---
## Installation pre-requisite

Download the latest Windows 11 version [here](https://www.microsoft.com/it-it/software-download/windows11). Install the **Windows 11 Pro** version.

Windows installer tricks:
- Change the "Time and currency format" to `English (World)`
- Turn off the inet cable and do an [offline installation](https://pureinfotech.com/bypass-internet-connection-install-windows-11/):
	- When get the error, press `Shift + F10`;
	- In the terminal type `OOBE\BYPASSNRO`.

To bring back the correct language GOTO: **Settings > Time & Language > Language & region** and select **Windows display language**.
## Guides

Follow those guide to optimize the performance and user experience of Windows 11:

- [CTT Tools guide](https://www.youtube.com/watch?v=6UQZ5oQg8XA)
- [General opt](https://www.youtube.com/watch?v=iBiNfa32AnE)
- [Amits Timer Resoltuion - win11](https://www.youtube.com/watch?v=AcCFZ8hhXi8)
- [Win32Priority](https://www.youtube.com/watch?v=wTdeyFk8Xv0)

### CTT Tools guide

- Launch the **CTT Tools** via Administrator Terminal (Power-shell)

``` powershell
irm christitus.com/win | iex
```

- Install the necessary programs
- Tweaks > `Desktop` profile, plus
	- Disable mouse accel
	- UTC Time - for dualboot
	- Add the necessary power profiles
- Updates > Security
### General opt

Follow the guide for more details, because are really specific

- Unpark CPU
- Services
- Register tweak
- System explorer
- Telemetry removal
- Windows tweaker
### Amits Timer Resolution - win11

> Follow the guide linked before, because it is necessary to do manual steps/tweaks based on the system.

### Win32Priority

Change the values best on what need, the register key is:

`Computer\HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\PriorityControl`

The recommended value are:

- 42 for latency
- 22 for fps
- 24 for both

All value are express in decimal, change it also in the reg key.