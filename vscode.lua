-- VSCODE MODULE


-- Include workspace and project files

include("vscode_workspace.lua")
include("vscode_project.lua")

-- preload
include("_preload.lua")


-- Aliases
local p = premake
local project = p.project
local vscode = p.modules.vscode

vscode = { _VERSION = "1.0.0" }

-- Workspace Generation
function vscode.generateWorkspace(wks)
    p.eol("\r\n")    
    p.indent("\t")
    -- NOTE: the .code-workspace file contains the tasks and launch configurations.
    p.generate(wks, ".code-workspace", vscode.workspace.generate)
end

-- Project Generation
function vscode.generateProject(prj)
    p.eol("\r\n")    
    p.indent("\t")

    -- C/C++ Support
    -- *    This is where support for other languages will eventually be specified
    if (project.isc(prj) or project.iscpp(prj)) then
        p.generate(prj, prj.location .. "/.vscode/c_cpp_properties.json", vscode.project.cCppProperties.generate)
    end
    
end

function vscode.configName(config, includePlatform)
    if includePlatform then
        return config.platform .. "-" .. config.buildcfg
    else
        return config.buildcfg
    end
end

function vscode.getToolsetName(cfg)
    -- MSC for windows, CLANG for everything else
    local default = iif(cfg.system == p.WINDOWS, "msc", "clang")
    return _OPTIONS.cc or cfg.toolset or default
end

function vscode.getCompiler(cfg)
    -- MSC for windows, CLANG for everything else
    local default = iif(cfg.system == p.WINDOWS, "msc", "clang")
    local toolset = p.tools[_OPTIONS.cc or cfg.toolset or default]
    if not toolset then
        error("Invalid toolset '" .. (_OPTIONS.cc or cfg.toolset) "'")
    end
    return toolset
end

function vscode.esc(value)
    value = value:gsub('\\', '\\\\')
    value = value:gsub('"', '\\"')
    return value
end

return vscode
