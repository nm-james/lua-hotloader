
SWEP.Base                  = "falcon_weapon_base"

SWEP.PrintName          = "DC-15X"
SWEP.Slot               = 2
SWEP.SlotPos            = 1
SWEP.Category           = "Falcon's SWEPs"
SWEP.Spawnable = true

SWEP.Primary = {}
SWEP.Primary.Damage = {}
SWEP.Primary.Damage.min = 23
SWEP.Primary.Damage.max = 60

SWEP.ViewModel = "models/jajoff/sps/cgiweapons/tc13j/dc15x.mdl"
SWEP.Primary.Tracer = "lfs_laser_blue"
SWEP.Primary.Recoil = 0.85
SWEP.Primary.NumberofShots = 1 
SWEP.Primary.Spread = 0.15
SWEP.Primary.ClipSize = 6 
SWEP.Primary.DefaultClip = 6
SWEP.Primary.Automatic = false
SWEP.Primary.Delay = 1
SWEP.Primary.Force = 1
SWEP.Primary.Ammo = "AR2"


-- audio stuff
SWEP.Sounds = {}
SWEP.Sounds.Init = "weapons/"
SWEP.Sounds.FirePath = 'weapons/dc15x/'
SWEP.Sounds.Fire = 5
SWEP.Sounds.Deploy = "weapons/"
SWEP.Sounds.Reserve = "weapons/"

-- positioniing stuff
SWEP.StandardSightPos = function( ang )
   return (ang:Forward()*0) - (ang:Up()*14 ) + (ang:Right() * 4.675)
end
SWEP.IronSightsPos  = function( ang )
   return -ang:Forward() * 10 + ang:Up() * 9.25 - ang:Right()*5.75
end

SWEP.WorldOffsetPos = Vector(-6, -2.25, -0.6)
SWEP.WorldOffsetAng = Angle(174, 181, -3)

-- DO NOT TOUCH
SWEP.WorldModel = SWEP.ViewModel
