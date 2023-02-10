
include( 'shared.lua' )

Falcon = Falcon or {}

for i = 1, 300 do
	surface.CreateFont( "F" .. tostring(i), {
		font = "Teko",
		size = ScreenScale( i )
	})
end

for i = 1, 300 do
	surface.CreateFont( "S" .. tostring(i), {
		font = "Aurek-Besh",
		size = ScreenScale( i )
	})
end

function GM:InitPostEntity()
	local ply = LocalPlayer()
	if ply.Loaded then return end

	net.Start('FALCON:SENDCLIENTFILES')
	net.SendToServer()
end


REST_ENTITIES = REST_ENTITIES or {}
local globalScroll
local globalContent
local globalList
net.Receive("FALCON:SENDCLIENTFILES", function()
	local binary_count = net.ReadUInt( 32 )
	local compiled_code = net.ReadData( binary_count )
	local decompiledList = util.Decompress(compiled_code)
	local list = util.JSONToTable(decompiledList) or {}
	REST_ENTITIES = {}
	for filePath, data in pairs(list) do
		local code = data["Code"]
		local path = data["Path"]
		local entityClass = data["Entity"]
		local entityID = data["EntityID"]

		if entityClass ~= "" then
			if entityID == 1 then
				code = 'local ENT = scripted_ents.Get( ' .. entityClass .. ' ) or {} ENT.Base = ENT.Base or "base_gmodentity" ENT.Type = ENT.Type or "anim"  ' .. code .. ' scripted_ents.Register(ENT, "' .. entityClass .. '")' .. [[
					if not REST_ENTITIES[ENT.Category or 'UNKNOWN CATEGORY'] then
						REST_ENTITIES[ENT.Category or 'UNKNOWN CATEGORY'] = {}
					end	
					table.insert(REST_ENTITIES[ENT.Category or 'UNKNOWN CATEGORY'], {ENT.PrintName or 'NO NAME', 1, ']] .. entityClass .. [['})
				]]
			elseif entityID == 2 then
				code = 'local SWEP = weapons.Get(' .. entityClass .. ') or {} SWEP.Base = "weapon_base"  ' .. code .. ' weapons.Register(SWEP, "' .. entityClass .. '")' .. [[
					if not REST_ENTITIES[SWEP.Category or 'UNKNOWN CATEGORY'] then
						REST_ENTITIES[SWEP.Category or 'UNKNOWN CATEGORY'] = {}
					end	
					table.insert(REST_ENTITIES[SWEP.Category or 'UNKNOWN CATEGORY'], {SWEP.PrintName or 'NO NAME', 2, ']] .. entityClass .. [['})
				]]
			end
		end

		print("Running CLIENT File!:", path)

		local f = CompileString(code, path, true)
		f()
	end
	if IsValid(globalScroll) then
		globalScroll.Categories = {}
		globalContent:Clear()
		globalScroll:Clear()
	end
	-- PrintTable {REST_ENTITIES}
end)


local function loadEntitiesOrSweps( category )
	local List = vgui.Create( "DIconLayout", globalContent )
	List:SetSpaceY( 5 )
	List:SetSpaceX( 5 )
	List:SetSize( globalContent:GetSize() )

	for _, ent in pairs(globalScroll.Categories[category][1]) do
		local ListItem = List:Add( "DButton" )
		ListItem:SetSize( 103, 103 )
		ListItem:SetPos( (_ - 1) * 105, 0 )
		ListItem:SetText( ent[1] )
		function ListItem:DoClick()
			net.Start('FALCON:SPAWN:ENTITY')
				net.WriteString(ent[3])
				net.WriteInt(ent[2], 10)
			net.SendToServer()
		end	
	end
end

local function createCategory( par, category )
	local w, h = par:GetSize()
	local btn = vgui.Create('DButton', par)
	btn:SetSize( w, h * 0.05 )
	btn:Dock( TOP )
	function btn:DoClick()
		loadEntitiesOrSweps( category )
	end

	return btn
end

local function reloadContent( scrollPnl )
	scrollPnl:Clear()
	for category, entity in pairs(REST_ENTITIES) do
		if not scrollPnl.Categories[category] then
			local btn = createCategory( scrollPnl, category )
			btn:SetText( category )
			scrollPnl.Categories[category] = {}
		end
		table.insert( scrollPnl.Categories[category], entity )
	end
end

hook.Add( "AddToolMenuTabs", "myHookClass", function()
	spawnmenu.AddCreationTab( "Falcon's Entities", function( arg1, arg2, arg3 )
		local F = vgui.Create('DPanel')
		function F:Paint( w, h )
			draw.RoundedBox(0, 0, 0, w, h, Color(0,0,0,195))
		end
		local w, h = ScrW(), ScrH()
		local scrollPnl = vgui.Create('DScrollPanel', F)
		scrollPnl:SetSize( w * 0.13, h * 0.8 )
		scrollPnl:SetPos( 0, h * 0.05)
		scrollPnl.Categories = {}
		globalScroll = scrollPnl

		local contentPnl = vgui.Create( "DScrollPanel", F ) -- Create the Scroll panel
		contentPnl:SetSize( w * 0.5, h * 0.8 )
		contentPnl:SetPos( w * 0.13, 0 )
		globalContent = contentPnl

		
		
		reloadContent( scrollPnl )


		local btn = vgui.Create('DButton', F)
		btn:SetSize( w * 0.13, h * 0.05 )
		btn:SetText( 'RELOAD' )
		function btn:DoClick()
			scrollPnl.Categories = {}
			reloadContent( scrollPnl )
		end

		return F
	end, "icon16/control_repeat_blue.png", 200 )
end )