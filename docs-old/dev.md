# Development configuration guide
---
## Packages

First of all start by  installing  useful packages for an optimal development environment.

- Useful TUI packages:

| Package        | Description                   |
| -------------- | ----------------------------- |
| **tmux**       | Terminal multiplexer          |
| **neovim**     | VIm with plugins and LSP      |
| **yazi**       | File manager with VI motion   |
| **xh**         | Cool HTTP request/response    |
| **rnr**        | Regex renamer                 |
| **lazygit**    | Manage git project            |
| **lazydocker** | Manage docker container/image |

Useful GUI packages:
- **postman-bin**, HTTP request;
- **QEMU/KVM**, virtual machine (good alternative for VirtualBox)
	- For more details refer to [Hacking environment guide](hacking.md)

Environment packages:
-  **pyenv**, manage different python version in the system
	- **pyenv-virtualenv**, extension of pyenv to create env with different  version
- **docker**, manager lightweight containers

>  **tmux** and **neovim** will be configured in automatically by the script. If is need to do a manual installation, refer in the `linux\src\.config`.
## VSCode extensions

To improve and simplify the code experience install the following extensions to support each language in VSCode.

> By reference it is use **vscodium**, but it is equal also for vscode.

Must have:
- Material Icon Themes
- Catppuccin for VSCode
- Open Remote - SSH
- Git Graph
- Docker
- Code runner

Python:
- Python
- Python Debugger
- Python Environment Manager
- Jupyter
- Jupyter Keymap
- Jupyter Notebook Renderers
- Jupyter Cell Tags
- Jupyter Slide Show

C/C++/Assembly:
- x86 and x86_64 Assembly
- Doxygen
- Doxygen Documentation Generator
- cmake-format
- CMake
- C/C++ Runner
- C/C++ Config
- Better C++ Syntax
- C/C++ Extension Pack

Rust:
- rust-analyzer
- CodeLLDB
- Better TOML

Go:
- Go

Dart/Flutter:
- Dart
- Flutter

JavaScript:
- JavaScript (ES6) code snippets
- Bootstrap 5 & Font Awesome Snippets
- Live server

## Additional tools
- Jupyter Lab separete env w/ pyenv.

``` bash
pyenv-virtualenv jupyter
pyenv activate jupyter
```

