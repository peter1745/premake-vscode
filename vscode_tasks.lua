-- TASK GENERATION

-- Aliases
local p = premake
local vscode = p.modules.vscode
local tasks = vscode.tasks

-- Define tasks object
vscode.tasks = {}

-- Task build functions
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

    for cfg in p.workspace.eachconfig(wks) do
        p.push('{')
        p.w('"type": "shell",')
        p.w('"label": "BUILD-%s",', cfg.name)
        p.w('"command": "%s",', msBuildPath)
        p.w('"args": ["%s", "-p:Configuration=%s"],', solutionFile, cfg.name)
        p.w('"problemMatcher": "$msCompile",')
        p.w('"group": "build",')
        p.pop('},') 
    end
end

function tasks.buildMakefileTask(wks)
    for cfg in p.workspace.eachconfig(wks) do
        p.push('{')
        p.w('"type": "shell",')
        p.w('"label": "BUILD-%s",', cfg.name)
        p.w('"command": "make",')
        p.w('"args": ["config=%s"],', string.lower(cfg.name))
        p.w('"problemMatcher": "$gcc",')
        p.w('"group": "build",')
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


-- COMBINED GENERATION
function tasks.generate(wks)
    p.push('"tasks": {')
    p.w('"version": "2.0.0",')
    p.push('"tasks": [')

    p.callArray(tasks.buildTasks, wks)

    p.pop(']')
    p.pop('},')
end
