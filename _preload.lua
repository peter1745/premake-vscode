local p = premake

newaction {
    -- Metadata
    trigger = "vscode",
    shortname = "VS Code",
    description = "Generate Visual Studio Code Projects",

    -- Capabilities
    valid_kinds = { "ConsoleApp", "WindowedApp", "Makefile", "SharedLib", "StaticLib", "Utility" },
    valid_languages = { "C", "C++" },
    valid_tools = { "gcc", "clang", "msc" },

    -- Workspace Generation
    onWorkspace = function(wks)
        p.modules.vscode.generateWorkspace(wks)
    end,

    -- Project Generation
    onProject = function(prj)
        p.modules.vscode.generateProject(prj)
    end
}

return function(cfg)
    return _ACTION == "vscode"
end