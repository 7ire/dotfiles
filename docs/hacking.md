# Hacking environment guide
---
Before starting the configurations of all environments and tools, check if in the system are installed the following packages and tools:
- python environment separation and virtualization:
	- [pyenv](https://github.com/pyenv/pyenv)
	- [pyenv-virtualenv](https://github.com/pyenv/pyenv-virtualenv)
- Virtualization/emulation software:
	- VirtualBox/VMWare
	- [QEMU](https://github.com/qemu/qemu) and [KVM](https://www.linux-kvm.org/page/Code)
- Debuggers:
	- [gdb](https://sourceware.org/gdb/)

Other resources and tutorials:
- [KVM-based Virtual Machine Instrospection](https://github.com/KVM-VMI/kvm-vmi)
- [Ditch VirtualBox, instead use QEMU/Virt Manager](https://www.youtube.com/watch?v=wxxP39cNJOs)
## Hacking lab
Download and install the following VMs, that contains challenges and training about exploitation and web security:
- [Nebula](https://exploit.education/nebula/)
- [Protostar](https://exploit.education/protostar/)
- [Phoenix](https://exploit.education/phoenix/)
- [Web4Pentester](https://pentesterlab.com/exercises/web_for_pentester/course)
- [OWASP Broken Web Applications](https://sourceforge.net/projects/owaspbwa/)

Last install another VMs, this is useful to do tasks about **binary exploitation**, especially when is needed that the system running the binary have disable:
- ASLR
- Memory address randomization
- gcc-multilib

VM:
- TODO: ubuntu

> The VM is already configured and come with pre installed tools, but if something is missing, it is possible to install packages inside it.


To start the VMs in QEMU/virt manager via terminal, so it is like a vm as a service, just do:

``` bash
# start the VM
virsh --connect qemu:///system start "VM-NAME"
# connect to the VM
virt-manager --connect qemu:///system --show-domain-console "VM-NAME"
```

- [How to start QEMU VM from command line?](https://unix.stackexchange.com/questions/638844/how-to-start-qemu-vm-from-command-line)
- [How to open Virt-manager VM from command line?](https://unix.stackexchange.com/questions/704325/how-to-open-virt-manager-vm-from-command-line)
## Hacking environment and tools
Based on which task is require to perform, there are specific tools/task to be install. All tools and task are divided by category. (So if a package/tool is repeated you can just ignore and keep the last version of that tool installed in the system).

- **General purpose tools**

| Package            | Description                             |
| ------------------ | --------------------------------------- |
| **ghidra-desktop** | Reverse engineering tool                |
| **wireshark-qt**   | Traffic packet sniffer                  |
| **burpsuite**      | HTTP request/response handler and proxy |

- **pwn**

*Install al the package inside a python virtualenv, you can call it with the category name.*

| Package       | Description                                                         |
| ------------- | ------------------------------------------------------------------- |
| **ropper**    | ROP gadget finder written in Python                                 |
| **ROPGadget** | Another powerful ROP gadget finder - stronger for ARM arch          |
| **pwntools**  | CTF framework written in Python                                     |
| **radare2**   | Disassembler, debugger and binary analysis tool                     |
| **pwndbg**    | GDB plugin that greatly enhances its exploit development capability |
> For **radare2** and **pwndbg** that are tools installed system wide, so my recommendation is to clone their repos inside a hidden directory, like **.local/share/bin** or just **."package"**.


- crypto