local p = premake

p.modules.vscode = { _VERSION = "1.0.0" }

local vscode = p.modules.vscode
local project = p.project

function vscode.generateWorkspace(wks)
    p.eol("\r\n")    
    p.indent("\t")
    p.generate(wks, ".code-workspace", vscode.workspace.generate)
end

function vscode.generateProject(prj)
    p.eol("\r\n")    
    p.indent("\t")

    if (project.isc(prj) or project.iscpp(prj)) then
        p.generate(prj, prj.location .. "/.vscode/c_cpp_properties.json", vscode.project.generateLanguageProperties)
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
    local default = iif(cfg.system == p.WINDOWS, "msc", "clang")
    return _OPTIONS.cc or cfg.toolset or default
end

function vscode.getCompiler(cfg)
    local default = iif(cfg.system == p.WINDOWS, "msc", "clang")
    local toolset = p.tools[_OPTIONS.cc or cfg.toolset or default]
    if not toolset then
        error("Invalid toolset '" .. (_OPTIONS.cc or cfg.toolset) "'")
    end
    return toolset
end

include("vscode_workspace.lua")
include("vscode_project.lua")

include("_preload.lua")

return vscode