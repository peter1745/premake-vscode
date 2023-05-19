# premake-vscode
An extension for premake that adds project and workspace generation for Visual Studio Code.

I got inspired to write this extension when I found these already existing extensions: [https://github.com/Enhex/premake-vscode](https://github.com/Enhex/premake-vscode) and [https://github.com/paullackner/premake-vscode](https://github.com/paullackner/premake-vscode), however they're a bit out-dated at the moment, and neither of them supports the premake features that I require, so I decided to write my own extension based on theirs.

My goal with this extension is to support most of the C++ configuration properties that premake offers, I might also support C and C# in the future, but for now C++ is the main focus.

## Usage
To use this extension add this repository to one of the Premake [search paths](https://premake.github.io/docs/Locating-Scripts/), and then add the following inside `premake-system.lua`:
```lua
require("premake-vscode")
```

Or add the following to your `premake5.lua` script if you added this repository in your own project:
```lua
require("path/to/this/repo/vscode")
```
