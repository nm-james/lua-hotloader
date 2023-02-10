
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

util.AddNetworkString('FALCON:SENDCLIENTFILES')
net.Receive('FALCON:SENDCLIENTFILES', function()
end)

local isLoaded = false
local isServiceUp = {}
isServiceUp.url = "http://localhost:3000/"
isServiceUp.method = "GET"

function isServiceUp:success( res )
    if not isLoaded then
        require('falcons-drm')
        isLoaded = true
    end
    
    print('\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\/////////////////////////////')
    print('\\\\\\\\\\\\\\\\\\\\ FALCON INITIALIZE ////////////////////')
    print('\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\/////////////////////////////')
    initiaizeFiles('productKey')

    local clientFiles = util.Compress(getClientFiles()) or ""
    local clientFilesSize = #clientFiles
    function syncClientFiles()
        net.Start("FALCON:SENDCLIENTFILES")
            net.WriteUInt( clientFilesSize, 32)
            net.WriteData( clientFiles, clientFilesSize )
        net.Broadcast()
    end
    syncClientFiles()
    net.Receive('FALCON:SENDCLIENTFILES', function( _, ply )
        net.Start("FALCON:SENDCLIENTFILES")
            net.WriteUInt( clientFilesSize, 32)
            net.WriteData( clientFiles, clientFilesSize )
        net.Send( ply )
    end)
end

local function loadAddon()
    HTTP(isServiceUp)
end

concommand.Add('falcon_reload_addon', function()
    loadAddon()
end)


local isLoaded = false
local shouldUpdate = {}
shouldUpdate.url = "http://localhost:3000/shouldUpdate"
shouldUpdate.method = "GET"
function shouldUpdate:success( res )
    local test = string.find( res, 'true')
    if test then
        loadAddon()
    end
end

local updateDelay = 0
hook.Add('Think', 'FALCON:CHECKUDATES', function()
    if updateDelay and updateDelay > CurTime() then return end
    HTTP(shouldUpdate)
    updateDelay = CurTime() + 2
end)

hook.Add('Initialize', 'FALCON:LOADCONTENT', function()
    loadAddon()
end)

util.AddNetworkString('FALCON:SPAWN:ENTITY')
net.Receive('FALCON:SPAWN:ENTITY', function( len, ply )
    -- if not ply:IsAdmin() then return end
    local entClass = net.ReadString()
    local id = net.ReadInt( 10 )
    if id == 1 then
        local hitpos = ply:GetEyeTrace().HitPos
        local ent = ents.Create(entClass)
        ent:SetPos( hitpos )
        ent:Spawn()
    elseif id == 2 then
        ply:Give( entClass )
    end
end)
