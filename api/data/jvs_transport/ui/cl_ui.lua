local FRAME = {}
FRAME.PANELS = {}
local mats = {
    'jvs_transport/sith.png',
    'jvs_transport/korriban.png',
    'jvs_transport/tatooine.png',
    'jvs_transport/ilum.png',
    'jvs_transport/yavin.png',
    'jvs_transport/tython.png',
    'jvs_transport/rep.png',
}

function FRAME:SelectPlanet( planetID, content )
    for i = 1, 7 do
        if i == planetID then continue end
        FRAME.PANELS[i]:Hide()
    end
    local c = FRAME.PANELS[planetID]
    c.Selected = true
    c.SetActive = false


    local prevSpotX, prevSpotY = c:GetPos()
    local prevSpotW, prevSpotH = c:GetSize()


    local w, h = content:GetSize()
    

    local planet = vgui.Create('DModelPanel', content)
    planet:SetSize( w * 0.65, h )
    planet:SetPos( w * 0.35, 0 )
    planet:SetModel('models/immigrant/starwars/planet.mdl')
    
    function planet:LayoutEntity(ent)
    end
    local ent = planet.Entity
    ent:SetPos( Vector(0, 0, 40) )
    planet:SetFOV( 60 )
    planet:SetAlpha(0)

    -- local planetShield = vgui.Create('DModelPanel', planet)
    -- planetShield:SetSize( planet:GetSize() )
    -- planetShield:SetModel('models/immigrant/starwars/planet.mdl')
    -- local ent = planetShield.Entity
    -- ent:SetPos( Vector(0, 0, 40) )
    -- ent:SetMaterial( 'models/props_combine/portalball001_sheet' )
    -- ent:SetAlpha(0)
    -- planetShield:SetFOV( 60 )



    local back = vgui.Create('DButton', content)
    back:SetSize( w * 0.1, h * 0.04 )
    back:SetPos( w * 0.01, h * 0.95)
    back:SetAlpha(0)
    function back:Paint(w, h)
        draw.RoundedBox(0, 0, 0, h, h, color_white)
        draw.DrawText( 'ESC', "F10", h * 0.5, h * 0.2, Color(0,0,0,255), TEXT_ALIGN_CENTER)
    end
    function back:Think()
        local a = self:GetAlpha()
        if self._Stream then
            a = math.Clamp(a + (FrameTime() * 1.2 * 255), 0, 255)
        else
            if a == 0 and self._HasChanged then
                self:Remove()
                planet:Remove()
                -- planetShield:Remove()
                return
            end
            a = math.Clamp(a - (FrameTime() * 1.2 * 255), 0, 255)
        end
        self:SetAlpha( a )
        planet:SetAlpha( a )
        -- planetShield.Entity:SetAlpha( a )
    end
    function back:DoClick()
        self._Stream = false
        c:SizeTo( prevSpotW, prevSpotH, 1, 0, -1 )
        c:MoveTo( prevSpotX, prevSpotY, 1, 0, -1, function()
            for i = 1, 7 do
                FRAME.PANELS[i]:Show()
            end
            c.Selected = false
            FRAME:OpenHandler( content:GetParent(), content, true )

        end)
    end    

    c:SizeTo( w * 0.33, h * 0.94, 1, 0, -1 )
    c:MoveTo( w * 0.01, 0, 1, 0, -1, function()
        back._Stream = true
        back._HasChanged = true
    end)
end

function FRAME:OpenHandler( p )
    local w, h = p:GetSize()
    local CONTENT = content or vgui.Create('DPanel', p)
    CONTENT:SetSize( w, h * 0.94 )
    CONTENT:SetPos( 0, h * 0.06 ) 
    CONTENT.Paint = nil

    local w, h = CONTENT:GetSize()
    local l = (w / 7) * 0.875

    for i = 1, 7 do
        local dodgerIsCool = vgui.Create('DButton', CONTENT)
        dodgerIsCool:SetSize( l, h  * 0.9 )
        dodgerIsCool:SetPos( l/2.75 + (l*1.05 * (i - 1)), h * 0.0875)
        dodgerIsCool.Paint = nil
        function dodgerIsCool:OnCursorEntered()
            if IsValid(CONTENT.AGESAGO) then
                local c = CONTENT.AGESAGO
                c.SetActive = false
            end
            CONTENT.AGESAGO = FRAME.PANELS[i]
            local c = CONTENT.AGESAGO
            c:MoveToFront()
            c.SetActive = true
            p.IMG:SetImage( mats[i] )
        end
        function dodgerIsCool:DoClick()
            CONTENT:Remove()
            FRAME:SelectPlanet( i, p.MAINCONTENT )
        end
    end
end

function FRAME:OpenCascaede( p, content, planetID )
    local w, h = p:GetSize()
    local CONTENT = vgui.Create('DPanel', p)
    CONTENT:SetSize( w, h * 0.94 )
    CONTENT:SetPos( 0, h * 0.06 ) 
    CONTENT.Paint = nil
    p.MAINCONTENT = CONTENT
    CONTENT.ButtonAlpha = 0
    function CONTENT:Think()
        local a = self.ButtonAlpha
        if self._Fade then
            a = math.Clamp(a + (FrameTime() * 1.2 * 255), 0, 255)
        else
            a = math.Clamp(a - (FrameTime() * 1.2 * 255), 0, 255)
        end
        self.ButtonAlpha = a
    end


    local w, ch = CONTENT:GetSize()
    local l = (w / 7) * 0.875

    if not planetID then
        for i = 1, 7 do
            local dodgerIsCool = vgui.Create('DPanel', CONTENT)
            dodgerIsCool:SetPos( (l * (i)), ch * 0.1 )
            dodgerIsCool:SetSize( l, ch * 0.8 )
            local w, h, oH = l, ch * 0.8, ch
            dodgerIsCool.RunningInt = 0
            dodgerIsCool.ActiveCol = color_white
            function dodgerIsCool:Think()
                if self.Selected then return end
                self:SetAlpha( CONTENT.ButtonAlpha )
                if self.SetActive then
                    self.RunningInt = Lerp(FrameTime()*6, self.RunningInt, 1)
                    self.ActiveCol = LerpVector(FrameTime()*5.5, self.ActiveCol:ToVector(), Vector(0, 0, 0)):ToColor()
                else
                    self.RunningInt = Lerp(FrameTime()*6, self.RunningInt, 0)
                    self.ActiveCol = LerpVector(FrameTime()*5.5, self.ActiveCol:ToVector(), Vector(1, 1, 1)):ToColor()
                end


                local newW = Lerp(self.RunningInt, w, w * 2.5)
                self:SetSize( newW, Lerp(self.RunningInt, h, h * 1.2) )
                local newX = math.Clamp(Lerp(self.RunningInt, l/2.15 + (w*1.01 * (i - 1)), (w * (i - 1)) - (w * 0.25)), 0, ScrW())
                if self:GetX() + newW > ScrW() then
                    local changeInWidth = newW - self:GetWide()
                    newX = self:GetX() - changeInWidth
                    self:SetPos( math.Clamp(Lerp(self.RunningInt, self:GetX(), (w * (i - 1)) - (w * 0.25)), 0, newX), math.Clamp(Lerp(self.RunningInt, (ch * 0.1), 0), 0, ScrH()) )
                elseif newX + newW < ScrW() then
                    self:SetPos( newX, math.Clamp(Lerp(self.RunningInt, (ch * 0.1), 0), 0, ScrH()) )
                end
            end
            local m = Material(mats[i])
            function dodgerIsCool:Paint( w, h )
                draw.NoTexture()
                local triangle = {
                    { x = 0, y = h * 0.2 - ((h * 0.1) * (self.RunningInt)) },
                    { x = w, y = h * 0.2 },
                    { x = w, y = h * 0.4 },
                    { x = 0, y = h * 0.4 + ((h * 0.1) * (self.RunningInt)) },
                }
                -- surface.SetTexture( surface.GetTextureID(mats[i]) )
                surface.SetMaterial(m)
                surface.SetDrawColor( 255, 255, 255, 255 )
                surface.DrawTexturedRect( -(w * 0.25), ((h * 0.1) * (self.RunningInt)), 1.3 * w, h*0.5 + (h*0.1 * self.RunningInt) )
                surface.SetDrawColor( self.ActiveCol )
                draw.NoTexture()
                
                local triangle = {
                    { x = 0, y = h * 0.4 + ((h * 0.1) * (self.RunningInt)) },
                    { x = w, y = h * 0.4 },
                    { x = w, y = h * 1 - ((h * 0.1) * (self.RunningInt)) },
                    { x = 0, y = h * 1 },
                }

                surface.DrawPoly( triangle )  
                local triangle = {
                    { x = 0, y = 0 },
                    { x = w, y = ((h * 0.1) * (self.RunningInt)) },
                    { x = w, y = h * 0.2 },
                    { x = 0, y = h * 0.2 - ((h * 0.1) * (self.RunningInt)) },
                }
                surface.DrawPoly( triangle )  
            end
            FRAME.PANELS[i] = dodgerIsCool
        end
    end

    timer.Simple(1, function()
        if not IsValid(CONTENT) then return end
        CONTENT._Fade = true
        FRAME:OpenHandler( p )
    end)
end


function FRAME:OpenFrame( entity )
    local w, h = ScrW(), ScrH()
    local F = vgui.Create('DFrame')
    F:SetSize(w, h)
    F:Center()
    F:MakePopup()
    F.AlphaFade = 0
    F._Delay = 0
    F.StartVector = LocalPlayer():GetPos()
    F.time = SysTime()

    F.IMG = vgui.Create('DImage', p)
    F.IMG:SetSize( F:GetSize() )
    F.IMG:SetKeepAspect( true )

    F.IMG.Paint = nil

    local startPos = LocalPlayer():GetPos()
    FRAME.PANELS = {}

    function F:Paint( w, h )
        if not self.StopRunning then
            local x, y = self:GetPos()
            local old = DisableClipping( true )
            self.StartVector = util.TraceLine( {
                start = self.StartVector,
                endpos = self.StartVector + Vector( 0, 0, FrameTime()*3500 ),
                filter = function( ent )
                    return ent:IsWorld()
                end
            } ).HitPos

            render.RenderView( {
                origin = self.StartVector,
                angles = Angle( 90, 0, 0 ),
                x = x, y = y,
                w = w, h = h
            } )
            DisableClipping( old )
        else
            Derma_DrawBackgroundBlur( self, self.time )
            self.IMG:PaintAt( 0, 0, w, h )
            draw.RoundedBox( 0, 0, 0, w, h, Color(0, 0, 0, 230) )
            
        end

        draw.RoundedBox( 0, 0, 0, w, h, Color(0, 0, 0, self.AlphaFade) )
        if self._Fade then
            self.AlphaFade = math.Clamp(self.AlphaFade + (FrameTime() * 1.6 * 255), 0, 255)
            if self.AlphaFade == 255 then
                self._Delay = CurTime() + 0.75
                self._Fade = false
            end
        else
            if self._Delay < CurTime() then 
                self.AlphaFade = math.Clamp(self.AlphaFade - (FrameTime() * 1.6 * 255), 0, 255)
            end
        end
    end

    function F:Think()
        if not self._StopThinkView then
            local dis = startPos:Distance( self.StartVector )
            if dis > 2000 then
                F._Fade = true
                self._StopThinkView = true
                timer.Simple(0.8, function()
                    F.StopRunning = true
                    F.start = SysTime()
                    FRAME:OpenCascaede( F )
                    F.IMG:SetImage( mats[1] )
                    local remove = vgui.Create('DButton', F)
                    local w, h = F:GetSize()
                    remove:SetSize( w * 0.03, w * 0.03 )
                    remove:SetPos( w * 0.971, 0 )
                    function remove:DoClick()
                        F:Close()
                    end
                end)
            end
        end
    end
end

concommand.Add('open_transport', function()
    FRAME:OpenFrame()
end)
