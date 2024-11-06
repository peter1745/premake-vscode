-- LAUNCH CONFIG GENERATION

-- aliases (for nicer code and less writing)
local p = premake
local project = p.project
local vscode = p.modules.vscode

-- Initialize premake module object
vscode.launch = {}
local launch = vscode.launch

-- Function reflection
launch.configProps = function(prj, cfg)
    -- Returns an array of the generation functions for each property (if any new are created, they should be added here).
    return {
        launch.type,
        launch.request,
        launch.program,
        launch.args,
        launch.stopAtEntry,
        launch.cwd,
        launch.environment,
        launch.preLaunchTask
    }
end


-- GENERATION --

function launch.type(prj, cfg)
    if cfg.system == "windows" then
        p.w('"type": "cppvsdbg",')
    else
        p.w('"type": "cppdbg",')
    end
end

function launch.request(prj, cfg)
    p.w('"request": "launch",')
end

-- build target
function launch.program(prj, cfg)
    local targetdir = project.getrelative(prj, cfg.buildtarget.directory)
    local targetname = cfg.buildtarget.name
    p.w('"program": "%s/%s",', prj.location, path.join(targetdir, targetname))
end

function launch.args(prj, cfg)
    p.w('"args": [],')
end

function launch.stopAtEntry(prj, cfg)
    p.w('"stopAtEntry": false,')
end

function launch.cwd(prj, cfg)
    -- I think this currently launches from the workspace directory since launch configs now generate in the ".code-workspace" file
    -- TODO: Make sure that these are running from proper project directories. Otherwise programs that depend on files relative to the program in some resource file won't be able to find the files.'
    p.w('"cwd": "./",')
end

function launch.environment(prj, cfg)
    p.w('"environment": [],')
end

-- Pre-launch task
function launch.preLaunchTask(prj, cfg)
    -- Calls the relevant build task before launching.
    local configName = vscode.configName(cfg, #prj.workspace.platforms > 1)
    p.w('"preLaunchTask": "BUILD-%s",', cfg.name)
end

function launch.generate(prj)
    -- Generates ".json" formatted launch configs to generate in the ".code-workspace" file.
    -- *    NOTE: This doesn't need to return anything since the scope that it's called in should have an open file that it's writing to through premake's API
    
    -- Start launch options block
    p.push('"launch": {')
    p.w('"version": "0.2.0",')
    
    -- Start configurations array
    p.push('"configurations": [')

    -- Loop through each project's configs
    for cfg in project.eachconfig(prj) do
        p.push('{')
        
        -- Set Launch name (name that shows in launch menu in vscode)
        local configName = vscode.configName(cfg, #prj.workspace.platforms > 1)
        p.w('"name": "Launch %s",', configName)

        -- Call each of the config generation functions for this project configuration
        -- *    TODO: Find a way to get rid of the extra comma after the last property (avoiding hard-coding). I think vscode still parses it just fine, but it does show some scary errors in the generated files if you open them (not ideal).
        p.callArray(launch.configProps, prj, cfg)

        p.pop('},')
    end
    -- Done
    p.pop(']')
    p.pop('}')
end
