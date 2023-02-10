local FRAME = {}
function FRAME:HandleMovement( self )
    local newCamPos = Vector()
    local newCamAngle = self:GetLookAng()
    local x, y = input.GetCursorPos()

    if input.IsKeyDown( KEY_R ) then
        local diffX = x - self.LastX
        newCamAngle = (newCamAngle + Angle(0, diffX * -0.1, 0))
        newCamAngle.p, newCamAngle.y, newCamAngle.x = math.Clamp(newCamAngle.p, -89, 89), math.NormalizeAngle(newCamAngle.y), math.NormalizeAngle(newCamAngle.x)
    end

    local forward = newCamAngle:Forward()*FrameTime()
    forward.z = 0

    if input.IsKeyDown( KEY_W ) then
        newCamPos = newCamPos + forward*100
    elseif input.IsKeyDown( KEY_S ) then
        newCamPos = newCamPos + forward*-100
    end

    local right = newCamAngle:Right()*FrameTime()
    if input.IsKeyDown( KEY_A ) then
        newCamPos = newCamPos + right*-100
    elseif input.IsKeyDown( KEY_D ) then
        newCamPos = newCamPos + right*100
    end

    if input.IsKeyDown( KEY_LCONTROL ) then
        newCamPos = newCamPos + Vector( 0, 0, -0.4 )
    elseif input.IsKeyDown( KEY_SPACE ) then
        newCamPos = newCamPos + Vector( 0, 0, 0.4 )
    end

    if input.IsKeyDown( KEY_LSHIFT ) then
        newCamPos = newCamPos * 3
    end
    self:SetLookAng( newCamAngle )
    self:SetCamPos( self:GetCamPos() + newCamPos )

    self.LastX = x
    self.LastY = y
end
function FRAME:DrawModel( self )

	local curparent = self
	local leftx, topy = self:LocalToScreen( 0, 0 )
	local rightx, bottomy = self:LocalToScreen( self:GetWide(), self:GetTall() )
	while ( curparent:GetParent() != nil ) do
		curparent = curparent:GetParent()

		local x1, y1 = curparent:LocalToScreen( 0, 0 )
		local x2, y2 = curparent:LocalToScreen( curparent:GetWide(), curparent:GetTall() )

		leftx = math.max( leftx, x1 )
		topy = math.max( topy, y1 )
		rightx = math.min( rightx, x2 )
		bottomy = math.min( bottomy, y2 )
		previous = curparent
	end

	-- Causes issues with stencils, but only for some people?
	-- render.ClearDepth()

	render.SetScissorRect( leftx, topy, rightx, bottomy, true )

	local ret = self:PreDrawModel( self.Entity )
	if ( ret != false ) then
		-- self.Entity:DrawModel()
		self:PostDrawModel( self.Entity )
	end

	render.SetScissorRect( 0, 0, 0, 0, false )

end

function FRAME:Open()
    local F = vgui.Create('DFrame')
    local w, h = ScrW(), ScrH()
    F:SetSize( w, h )
    F:Center()
    F:MakePopup()
    

    local ENGINE = vgui.Create('DModelPanel', F )
    ENGINE:Dock( FILL )
    ENGINE:SetModel('models/props_c17/Lockers001a.mdl')
    ENGINE.LayoutEntity = function() return false end
    ENGINE:SetLookAng( Angle(20, 180, 0) )
    
    -- Handle CAMERA position
    function ENGINE:Think()
        FRAME:HandleMovement( self )
        PrintTable(self.Entity:GetPos():ToScreen())
    end 

    ENGINE.Entities = {}
    function ENGINE:DrawModel()
        FRAME:DrawModel( self )
    end
end
concommand.Add('OPEN_RTS', function()
    FRAME:Open()
end)