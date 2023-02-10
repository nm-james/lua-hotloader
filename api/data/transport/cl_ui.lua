local FRAME = {}
FRAME.MODELS = {
    {'models/immigrant/starwars/planet.mdl', 16, 'YAVIN 4', 'THE MIDSTS OF THE UNKNOWN AND KNOWN', 'jvs_transport/tython.png', {
        {},
    } }, -- YAVIN 4
    {'models/immigrant/starwars/planet.mdl', 13, 'TATOOINE', 'HEATWAVES AND HUNTERS LURK THE SEAS', '', {
        {},
    } }, -- TATOOINE
    {'models/immigrant/starwars/planet.mdl', 4, 'ILUM', 'A COLD FRONT OF THE FORCE', '', {
        {},
    } }, -- ILLUM
    {'models/immigrant/starwars/starkiller_base.mdl', 0, 'REPUBLIC CLASS', 'THOSE WHO SHANT FALL VICTIM TO THE DARK SIDE', '', {
        {},
    } }, -- REPU
    {'models/immigrant/starwars/planet.mdl', 8, 'TYTHON', 'THE BEGINNINGS OF A TRUTHFUL ADVENTURE', '', {
        {},
    } }, --TYTHON
    {'models/immigrant/starwars/planet.mdl', 5, 'KORRIBAN', 'A PLACE THROUGH STRENGTH AND FORTITUDE', '', {
        {},
    } }, --KORRI
    {'models/immigrant/starwars/starkiller_base.mdl', 0, 'EMPIRE CLASS', 'THE WILLS AND WANTS CONSUMED BY THE DARKNESS', '', {
        {},
    } }, --EMPIR
}


FRAME.ENTITIES = {
    {},
    {},
    {},
    {},
    {},
    {},
    {},
}

function FRAME:OpenPlanet( MAIN, planetID )
    MAIN:Clear()
    local d = FRAME.MODELS[planetID]
    local bg = vgui.Create('DImage', MAIN)
    bg:Dock( FILL )
    bg:SetImage( d[5] )


    local F = MAIN:GetParent()
    local overlay = vgui.Create('DPanel', MAIN)
    overlay:SetSize( MAIN:GetWide(), MAIN:GetTall() )
    function overlay:Think()
        if F._FadeAlpha == 0 then
            self:Remove()
        end
    end
    function overlay:Paint(w, h)
        draw.RoundedBox( 0, 0, 0, w, h, Color(0, 0, 0, F._FadeAlpha) )
    end
end

function FRAME:OpenFrame()
    local F = vgui.Create('DFrame')
    F:SetSize( ScrW(), ScrH() )
    F:Center()
    F:MakePopup()
    F._FadeAlpha = 0
    local MAIN = vgui.Create('DPanel', F )
    MAIN:SetSize( F:GetWide(), F:GetTall() )
    MAIN.Paint = nil

    local stars = {}
    local w, h = ScrW(), ScrH()
    for i = 1, 250 do
        stars[i] = { math.random(1, w), math.random(1, h), math.random(1, w*0.005) }
    end

    function F:Think()
        local a = self._FadeAlpha
        if self._Fade then
            self._FadeAlpha = ( math.Clamp(a + (FrameTime() * 2 * 255), 0, 255) )
            if a == 255 then
                self._Next()
                self._Delay = CurTime() + (self._NextDelay or 2)
                self._Fade = false
            end
        else
            if self._Delay and self._Delay > CurTime() then return end
            self._FadeAlpha = ( math.Clamp(a - (FrameTime() * 2 * 255), 0, 255) )

        end
    end

    function F:Paint( w, h )
        local col = color_white
        if LocalPlayer():IsAdmin() or math.random(1, 100) == 1 then
            col = HSVToColor( ( CurTime() * 550 ) % 360, 1, 1 )
        end
        draw.RoundedBox( 0, 0, 0, w, h, Color(0, 0, 0, 255) )

        for _, d in pairs( stars ) do
            draw.RoundedBox( 360, d[1], d[2], d[3], d[3], col )
        end
    end


    local w, h = MAIN:GetSize()
    local upperPnl = vgui.Create('DPanel', MAIN)
    upperPnl:SetSize( w * 0.65, h * 0.33 )
    upperPnl:SetPos( w * 0.175, h * 0.11 )
    upperPnl.Paint = nil
 
    local lowerPnl = vgui.Create('DPanel', MAIN)
    lowerPnl:SetSize( w * 0.865, h * 0.33 )
    lowerPnl:SetPos( w * 0.0675, h * 0.52 )
    lowerPnl.Paint = nil
    local r = h * 0.33
    local paddW = h * 0.018

    for i = 1, 7 do
        local par = lowerPnl
        if i > 0 and i < 4 then
            par = upperPnl
        end
        local backGround = vgui.Create('DPanel', par)
        backGround:SetSize( r, r )
        backGround:Dock( LEFT )
        backGround:DockMargin( paddW, 0, 0, 0 )
        backGround.Paint = nil
        local newR = r / 2
        function backGround:Think()
            self:SetAlpha( 255 - F._FadeAlpha )
        end
        function backGround:Paint( w, h )
            draw.RoundedBox(360, 0, 0, w, h, Color( 155, 155, 155, 100 ) )
            surface.DrawCircle( newR, newR, newR, 255, 255, 255, 255 )
        end
    
        local d = FRAME.MODELS[i]
        local planet = vgui.Create('DModelPanel', backGround)
        planet:Dock( FILL )
        planet:SetModel( d[1] )
        planet:SetFOV( 60 )
        local ent = planet.Entity
        ent:SetPos( Vector(0, 0, 40) )
        ent:SetModelScale( 0.92 )
        ent:SetSkin( d[2] or 0 )
        local btn = vgui.Create('DButton', planet)
        btn:Dock( FILL )
        btn:SetAlpha( 0 )
        function btn:Think()
            if self:IsHovered() then
                self:SetAlpha( math.Clamp(self:GetAlpha() + (FrameTime() * 4.5 * 255), 0, 255) )
                planet.Entity:SetModelScale( math.Clamp(planet.Entity:GetModelScale() + FrameTime()*0.7, 0.92, 1.0) )
            else
                self:SetAlpha( math.Clamp(self:GetAlpha() - (FrameTime() * 4.5 * 255), 0, 255) )
                planet.Entity:SetModelScale( math.Clamp(planet.Entity:GetModelScale() - FrameTime()*0.7, 0.92, 1.0) )
            end
        end
        function btn:Paint( w, h )
            draw.RoundedBox(360, 0, 0, w, h, Color( 0, 0, 0, 220 ) )
            draw.RoundedBox(0, 0, h * 0.375, w, h * 0.25, Color( 0, 0, 0, 220 ))
            surface.DrawCircle( newR, newR, newR, 255, 255, 255, 255 )
            surface.SetDrawColor( 255, 255, 255, 255 )
            surface.DrawLine(w * 0.025, h*0.375, w * 0.975, h*0.375)
            surface.DrawLine(w * 0.025, h*0.625, w * 0.975, h*0.625)
            draw.DrawText( d[3] or 'PLANET', "F25", w * 0.5, h * 0.375, color_white, TEXT_ALIGN_CENTER )
            draw.DrawText( d[4] or '', "F11", w * 0.5, h * 0.5125, color_white, TEXT_ALIGN_CENTER )
        end
        function btn:DoClick()
            F._Next = function()
                FRAME:OpenPlanet( MAIN, i )
            end
            F._Fade = true
        end
    end

    local remove = vgui.Create('DButton', F)
    local w, h = F:GetSize()
    remove:SetSize( w * 0.03, w * 0.03 )
    remove:SetPos( w * 0.971, 0 )
    function remove:DoClick()
        F:Close()
    end
end 

concommand.Add('transport', function()
    FRAME:OpenFrame()
end)
