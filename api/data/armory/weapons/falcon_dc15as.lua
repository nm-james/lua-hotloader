
SWEP.Base                  = "falcon_weapon_base"

SWEP.PrintName          = "DC-15A Shotgun"
SWEP.Slot               = 2
SWEP.SlotPos            = 1
SWEP.Category           = "Falcon's SWEPs"
SWEP.Spawnable = true

SWEP.Primary = {}
SWEP.Primary.Damage = {}
SWEP.Primary.Damage.min = 3
SWEP.Primary.Damage.max = 8

SWEP.ViewModel = "models/jajoff/sps/cgiweapons/tc13j/dc15ashotgun.mdl"
SWEP.Primary.Tracer = "lfs_laser_blue"
SWEP.Primary.Recoil = 1
SWEP.Primary.NumberofShots = 6
SWEP.Primary.Spread = 2
SWEP.Primary.ClipSize = 12 
SWEP.Primary.DefaultClip = 12
SWEP.Primary.Automatic = false
SWEP.Primary.Delay = 0.8
SWEP.Primary.Force = 1
SWEP.Primary.Ammo = "AR2"


-- audio stuff
SWEP.Sounds = {}
SWEP.Sounds.Init = "weapons/"
SWEP.Sounds.FirePath = 'weapons/dc15a/'
SWEP.Sounds.Fire = 9
SWEP.Sounds.Deploy = "weapons/"
SWEP.Sounds.Reserve = "weapons/"

-- positioniing stuff
SWEP.StandardSightPos = function( ang )
   return (ang:Forward()*0) - (ang:Up()*14 ) + (ang:Right() * 4.675)
end
SWEP.IronSightsPos  = function( ang )
   return -ang:Forward() * 15 + ang:Up() * 7.25 - ang:Right()*6
end

SWEP.WorldOffsetPos = Vector(-6, -2.25, -0.6)
SWEP.WorldOffsetAng = Angle(174, 181, -3)


-- DO NOT TOUCH
SWEP.WorldModel = SWEP.ViewModel
