local ARMORY_EDITOR = {}
local ARMORY_EDITOR_POSITIONS = {
    {Vector(988.873047, -540.876282, -143.968750)}
}


ARMORY_EDITOR_ENTITIES = ARMORY_EDITOR_ENTITIES or {}

function ARMORY_EDITOR:HandlePriorEntities()
    for _, cl in pairs( ARMORY_EDITOR_ENTITIES ) do
        if IsValid(cl) then
            cl:Remove()
        end
    end
    ARMORY_EDITOR_ENTITIES = {}
end
function ARMORY_EDITOR:CreateEntities()
    ARMORY_EDITOR:HandlePriorEntities()
    for _, d in pairs( ARMORY_EDITOR_POSITIONS ) do
        local cl = ClientsideModel('models/grillsprops/fp_guncraft_bench/fp_guncraft_bench.mdl')
        cl:SetPos( d[1] )
        ARMORY_EDITOR_ENTITIES[#ARMORY_EDITOR_ENTITIES] = cl
    end
end
ARMORY_EDITOR:CreateEntities()

-- print(LocalPlayer():GetEyeTrace().HitPos)


hook.Add( "PostDrawOpaqueRenderables", "example", function()
    -- This is where and how our 'cut' will be rendered.
    local vm = LocalPlayer():GetViewModel()
	local pos = vm:GetPos()
	local angle = vm:GetAngles() - Angle(0, 90, 90)-- Flat with the ground.
    local scale = 200 -- 1px in 2d = 200 units in 3d.

        
    render.SetStencilEnable( true )
		render.SetStencilWriteMask( 255 )
		render.SetStencilTestMask( 255 )
        
        -------------------------------------------------------
        -- Part 1: Draw the cut in the world
        -------------------------------------------------------

        render.SetStencilReferenceValue( 57 )
        render.SetStencilCompareFunction( STENCIL_ALWAYS )
        render.SetStencilPassOperation( STENCIL_REPLACE )

        cam.Start3D2D( pos, angle, scale )
            surface.SetDrawColor( Color( 255, 0, 0, 255 ) )
            surface.DrawRect( 0, 0, 1, 1 ) -- a 1 x 1 square

            -- local old = DisableClipping( true ) -- Avoid issues introduced by the natural clipping of Panel rendering
            
            -- DisableClipping( old )
        cam.End3D2D()
        
        -------------------------------------------------------
        -- Part 2: Draw items in the cut (even if they're in the world)
        -------------------------------------------------------

        render.SetStencilCompareFunction( STENCIL_EQUAL )
        cam.IgnoreZ( true ) -- see objects through world 
            for key, prop in pairs(ents.FindByClass( "prop_physics" )) do
                prop:DrawModel()
            end
        cam.IgnoreZ( false )

        -------------------------------------------------------
        -- Part 3: Redraw the view model on top of the items in the cut
        -- to counter the IgnoreZ.  Drawing view models is a touchy process.
        -------------------------------------------------------

        local fov = LocalPlayer():GetActiveWeapon().ViewModelFOV or (LocalPlayer():GetFOV() - 21.5)
        cam.Start3D( EyePos(), EyeAngles(), fov + 15)
        cam.IgnoreZ( true )
            LocalPlayer():GetViewModel():DrawModel()
        cam.IgnoreZ( false )
        cam.End3D()
        
    render.SetStencilEnable( false )
end )
