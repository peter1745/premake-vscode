local p = premake
local tree = p.tree
local vscode = p.modules.vscode

-- INCLUDES
include("vscode_tasks.lua")
include("vscode_launch.lua")

-- WORKSPACE FILE
vscode.workspace = {}

function vscode.workspace.generateFolders(wks)
    p.push('"folders": [')

    -- Workspace vscode folder
    p.push('{')
    p.w('"path": "."')
    p.pop('},')

    -- Project List
    --tree.traverse(p.workspace.grouptree(wks), {
    --    onleaf = function(n)
    --        local prj = n.project
--
    --        local prjpath = path.getrelative(prj.workspace.location, prj.location)
    --        p.push('{')
    --        p.w('"path": "%s"', prjpath)
    --        p.pop('},')
    --    end,
    --})

    p.pop('],')
end

-- WORKSPACE AND TASK GENERATION
function vscode.workspace.generate(wks)
    p.push('{')

    vscode.workspace.generateFolders(wks)
    vscode.tasks.generate(wks)
    -- Check if there is a startup project specified
    if not (wks.startproject == nil or wks.startproject == "") then
        vscode.launch.generate(wks.projects[wks.startproject]) -- launch/startup project
    -- HACK (minifalafel) If no startproject was specified, just generate for the first project in the workspace
    else
        prj = wks.projects[1]
        if not (prj == nil) then
            vscode.launch.generate(prj)
        end
    end

    p.pop('}')
end
