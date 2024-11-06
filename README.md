# This repository is archived
This fork is currently the most well maintained: [https://github.com/MiniFalafel/premake-vscode](https://github.com/MiniFalafel/premake-vscode)

# premake-vscode
An extension for premake that adds project and workspace generation for Visual Studio Code.

This project was originally created [by peter](https://github.com/peter1745)

This was initially inspired by these repositories:
*   [https://github.com/Enhex/premake-vscode](https://github.com/Enhex/premake-vscode)
*   [https://github.com/paullackner/premake-vscode](https://github.com/paullackner/premake-vscode)

The goal of this project was to create a more up to date extension with more feature support!

Namely, 
*   Most of the C++ configuration properties that premake offers
*   Might also support C and C# in the future, but for now C++ is the main focus.


## Supported Languages

### C++
Supported Premake `"CppDialect"` options:
*   `C++98`, `C++11`, `C++14`, `C++17`, `C++20`, `C++2a`, `gnu++98`, `gnu++11`, `gnu++14`, `gnu++17`, `gnu++20`

C++ Compilers for Windows:
*   `msvc`, `clang`

C++ Compilers for Linux:
*   `gcc`, `clang`


## Usage
To use this extension add this repository to one of the Premake [search paths](https://premake.github.io/docs/Locating-Scripts/), and then add the following inside `premake-system.lua`:
```lua
require("premake-vscode")
```

Or add the following to your `premake5.lua` script if you added this repository in your own project:
```lua
require("path/to/this/repo/vscode")
```

Then, you can invoke generation like so:
```bash
$ premake vscode
```
