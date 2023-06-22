local p = premake
local project = p.project
local workspace = p.workspace
local tree = p.tree
local vscode = p.modules.vscode

vscode.workspace = {}
vscode.workspace.tasks = {}

local m = vscode.workspace

function m.generate(wks)
	p.utf8()

    p.push('{')
    p.push('"folders": [')

    -- Project List
    tree.traverse(workspace.grouptree(wks), {
        onleaf = function(n)
            local prj = n.project

            local prjpath = path.getrelative(prj.workspace.location, prj.location)
            p.push('{')
            p.w('"path": "%s"', prjpath)
            p.pop('},')
        end,
    })

    -- HACK(Peter): Hack around the tasks not being picked up when workspace is opened
    local prjpath = path.getrelative(wks.location, "Tasks")
    p.push('{')
    p.w('"path": "%s"', prjpath)
    p.pop('}')

    p.pop(']')
    p.pop('}')
end

local tasks = vscode.workspace.tasks
--[[tasks.taskLabels = {}

tasks.toolsetPaths = {
    ["windows"] = {
        ["msc"] = "C:/Program Files/Microsoft Visual Studio/2022/Community/VC/Tools/MSVC/14.35.32215/bin/Hostx64/x64/cl.exe",
        ["clang"] = "C:/Program Files/Microsoft Visual Studio/2022/Community/VC/Tools/Llvm/x64/bin/clang-cl.exe"
    },
    ["linux"] = {
        ["gcc"] = "/usr/bin/g++",
        ["clang"] = "/usr/bin/clang++"
    }
}
tasks.problemMatchers = {
    ["msc"] = "msCompile",
    ["clang"] = "gcc", -- No problem matcher for clang currently?
    ["gcc"] = "gcc"
}

tasks.configProps = function(prj, cfg)
    return {
        tasks.gatherFiles,
        tasks.type,
        tasks.label,
        tasks.command,
        tasks.args,
        tasks.problemMatcher,
        tasks.dependsOn
    }
end

function tasks.gatherFiles(prj, cfg)
    local tr = project.getsourcetree(prj)
    tree.traverse(tr, {
		onleaf = function(node, depth)
			table.insert(prj.__vscode.files, node.abspath)
        end
	}, true)
end

function tasks.type(prj, cfg)
    p.w('"type": "shell",')
end

function tasks.getTaskLabel(prj, cfg)
    local configName = vscode.configName(cfg, #prj.workspace.platforms > 1)
    local toolsetName = vscode.getToolsetName(cfg)
    local taskLabel = "C/C++: Build " .. prj.name .. " (" .. configName .. ", " .. toolsetName .. ")"
    return taskLabel
end

-- Label: C/C++: Build {ProjectName} {ToolsetName}
function tasks.label(prj, cfg)
    local taskLabel = tasks.getTaskLabel(prj, cfg)
    p.w('"label": "%s",', taskLabel)
end

function tasks.command(prj, cfg)
    local toolsetName = vscode.getToolsetName(cfg)
    local compileCommand = tasks.toolsetPaths[cfg.system][toolsetName]
    p.w('"command": "%s",', compileCommand)
end

function tasks.args(prj, cfg)
    local toolsetName = vscode.getToolsetName(cfg)
    local toolsetModule = nil

    if toolsetName == "msc" then
        toolsetModule = vscode.msc
    end

    if toolsetModule == nil then
        error("Unknown toolset")
    end

    local compilerFlags = toolsetModule.getCompilerFlags(prj, cfg)

    p.push('"args": [')
    for _, flag in ipairs(compilerFlags) do
        p.w('"%s",', vscode.esc(flag))
    end

    for _, file in ipairs(prj.__vscode.files) do
        p.w('"%s",', vscode.esc(file))
    end

    p.pop('],')
end

function tasks.problemMatcher(prj, cfg)
    local toolsetName = vscode.getToolsetName(cfg)
    p.w('"problemMatcher": "$%s",', tasks.problemMatchers[toolsetName])
end

function tasks.dependsOn(prj, cfg)
    local dependencies = project.getdependencies(prj, cfg)

    if #dependencies > 0 then
        p.push('"dependsOn": [')
        for _, dependency in ipairs(dependencies) do
            local dependencyTaskName = tasks.getTaskLabel(dependency, cfg)
            p.w('"%s",', dependencyTaskName)
        end
        p.pop(']')
    end
end]]--

function tasks.buildSolutionTask(wks)
    local solutionFile = p.filename(wks, ".sln")

    local enablePreReleases = _OPTIONS["enable_prereleases"]
    local vswhere = '"C:\\Program Files (x86)\\Microsoft Visual Studio\\Installer\\vswhere.exe" -latest';

    if enablePreReleases then
        vswhere = vswhere .. ' -prerelease'
    end

    vswhere = vswhere .. ' -find MSBuild'

    local msBuildPath, err = os.outputof(vswhere)
    msBuildPath = path.normalize(path.join(msBuildPath, "Current", "Bin", "MSBuild.exe"))

    for cfg in workspace.eachconfig(wks) do
        p.push('{')
        p.w('"type": "shell",')
        p.w('"label": "Build All (%s)",', cfg.name)
        p.w('"command": "%s",', msBuildPath)
        p.w('"args": ["%s", "-p:Configuration=%s"],', solutionFile, cfg.name)
        p.w('"problemMatcher": "$msCompile",')
        p.w('"group": "build"')
        p.pop('},') 
    end
end

function tasks.buildMakefileTask(wks)
    for cfg in workspace.eachconfig(wks) do
        p.push('{')
        p.w('"type": "shell",')
        p.w('"label": "Build All (%s)",', cfg.name)
        p.w('"command": "make",')
        p.w('"args": ["-j$((`nproc` - 1))", "config=%s"],', cfg.name)
        p.w('"problemMatcher": "$gcc",')
        p.w('"group": "build"')
        p.pop('},')
    end
end

tasks.buildTasks = function(wks)
    if _TARGET_OS == "windows" then
        return {
            tasks.buildSolutionTask
        }
    else
        return {
            tasks.buildMakefileTask
        }
    end

end

function tasks.generate(wks)
    p.push('{')
    p.w('"version": "2.0.0",')
    p.push('"tasks": [')

    p.callArray(tasks.buildTasks, wks)

    p.pop(']')
    p.pop('}')
end
