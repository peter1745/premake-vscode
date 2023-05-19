local p = premake

for _, file in ipairs(dofile("_manifest.lua")) do
    include(file)
end