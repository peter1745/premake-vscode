local p = premake
local project = p.project
local workspace = p.workspace
local tree = p.tree
local vscode = p.modules.vscode

vscode.workspace = {}
local m = vscode.workspace

function m.generate(wks)
	p.utf8()

    p.w('{"folders": [')

    -- Project List
    tree.traverse(workspace.grouptree(wks), {
        onleaf = function(n)
            local prj = n.project

            local prjpath = path.getrelative(prj.workspace.location, prj.location)
            p.w('{')
            p.w('"path": "%s"', prjpath)
            p.w('},')
        end,
    })

    p.w(']}')
end