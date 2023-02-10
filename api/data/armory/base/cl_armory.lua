local ARMORY = {}
function ARMORY:GetWeaponScopes()
    return { {'models/jajoff/sps/cgiweapons/tc13j/dc15x_scope.mdl', '2x'} }
end
ARMORY[1] = function( parent )
    local w, h = parent:GetSize()
    local SCOPES = vgui.Create('DPanel', parent)
    SCOPES:SetSize( w * 0.3, h * 0.75 )
    SCOPES:SetPos( w * 0.06, h * 0.08 )
    function SCOPES:Paint( w, h )
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 220) )
        surface.SetDrawColor( 255, 255, 255, 255 )
        surface.DrawOutlinedRect( 0, 0, w, h )
    end

    local w, h = SCOPES:GetSize()
    local content = vgui.Create('DScrollPanel', SCOPES)
    content:SetSize( w, h )
    


    local F = parent:GetParent()
    local cl = F.WeaponENT
    local ang = cl:GetAngles()
    SCOPES.BeforeEntity = F.ScopeENT
    function SCOPES:OnRemove()
        if IsValid( self.BeforeEntity ) then
            self.BeforeEntity:SetNoDraw( false )
        end
        -- self.ScopeENT:Remove()
    end
    if IsValid( SCOPES.BeforeEntity ) then
        SCOPES.BeforeEntity:SetNoDraw( true )
    end

    F.StartVector = F.FinalVector
    F.StartAngle = F.FinalAngle

    F.FinalVector = cl:GetPos() + ang:Forward() * 50 + ang:Up() * 23 + ang:Right()*3
    F.FinalAngle = Angle( 52, -51, 0 )
    local scopes = ARMORY:GetWeaponScopes()
    SCOPES.ScopeENT = ClientsideModel(scopes[1][1])
    SCOPES.ScopeENT:SetPos( cl:GetPos() + ang:Forward() * 35 + ang:Up() * 5.3 + ang:Right() * 1.5 )
    SCOPES.ScopeENT:SetAngles( ang )
    SCOPES.ScopeENT:SetSubMaterial( 1, 'models/props_lab/Tank_Glass001' )    

    local wep = weapons.Get( parent.ClassName or 'falcon_dc15a' ).Scopes
    
    for _, sc in pairs( scopes ) do

    end
end

function ARMORY:OpenCategory( id, parent )
    parent:Clear()
    ARMORY[id]( parent )
end

function ARMORY:OpenMainContent( parent )
    parent:Clear()

    local w, h = parent:GetSize()
    local scopeBtn = vgui.Create('DButton', parent)
    scopeBtn:SetSize( w * 0.05, w * 0.05 )
    scopeBtn:SetPos( w * 0.36, h * 0.265 )
    scopeBtn:SetAlpha( 0 )
    function scopeBtn:Paint(w, h)
        draw.RoundedBox( 0, 0, 0, w, h, Color(0, 0, 0, 200 ) )
        surface.SetDrawColor( color_white )
        surface.DrawOutlinedRect( 0, 0, w, h )
    end
    function scopeBtn:Think()
        self:SetAlpha( Lerp(FrameTime()*6, self:GetAlpha(), 255) )
    end
    function scopeBtn:DoClick()
        ARMORY:OpenCategory( 1, parent )
    end

end

function ARMORY:OpenFrame( entityID )
    local F = vgui.Create('DFrame')
    F:SetSize( ScrW(), ScrH() )
    F:Center()
    F:SetTitle('')
    F:MakePopup()

    function F:OnRemove()
        self.WeaponENT:Remove()  
    end

    local cl = ARMORY_EDITOR_ENTITIES[entityID]
    local ang = cl:GetAngles()
    local pos = cl:GetPos() - ang:Forward()*45 + ang:Up() * 50

    local model = ClientsideModel('models/jajoff/sps/cgiweapons/tc13j/dc15a.mdl')
    local center = model:OBBCenter()
    local mins = model:GetModelBounds()
    mins.z = 0
    mins.y = 5 * mins.y

    model:SetPos( cl:GetPos() + ang:Up() * 50 + (mins/2) )
    model:SetAngles( Angle(0, 90, 0) )
    F.WeaponENT = model
    F.StartAngle = Angle( 0, 0, 0 )
    F.StartVector = pos

    F.FinalAngle = Angle( 0, 0, 0 )
    F.FinalVector = pos

    function F:Paint( w, h )
        local x, y = self:GetPos()
        local old = DisableClipping( true ) 
        self.StartVector = LerpVector(FrameTime()*2.5, self.StartVector, self.FinalVector)
        self.StartAngle = LerpAngle(FrameTime()*2.5, self.StartAngle, self.FinalAngle)

        render.RenderView( {
            origin = self.StartVector,
            angles = self.StartAngle,
            x = x, y = y,
            w = w, h = h
        } )
        DisableClipping( old )

    end

    local content = vgui.Create('DPanel', F)
    content:SetSize( ScrW(), ScrH() * 0.985 )
    content:SetPos( 0, ScrH() * 0.015 )
    content.Paint = nil
    
    self:OpenMainContent( content )

    

end

concommand.Add('open_armory', function()
    ARMORY:OpenFrame( 0 )
end)

