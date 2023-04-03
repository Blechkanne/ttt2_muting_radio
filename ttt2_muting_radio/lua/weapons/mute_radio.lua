SWEP.PrintName = "Mute Radio"
SWEP.Author = "Blechkanne"
SWEP.Instructions = "Leftclick to throw out a mute radio (WARNING: Slippery)"
SWEP.Spawnable = true
SWEP.AdminOnly = true
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = true
SWEP.ViewModel = "models/props/cs_office/radio.mdl"
SWEP.WorldModel = "models/props/cs_office/radio.mdl"
SWEP.AutoSwitchTo = true

-- TTT Customisation
if (engine.ActiveGamemode() == "terrortown") then
	SWEP.Base = "weapon_tttbase"
	SWEP.Kind = WEAPON_EQUIP1
	SWEP.AutoSpawnable = false
	SWEP.CanBuy = { ROLE_TRAITOR, ROLE_JACKAL, ROLE_DETECTIVE }
	SWEP.LimitedStock = true
	SWEP.Slot = 7
	SWEP.Icon = "VGUI/icon_mute_radio"
	SWEP.ViewModelFlip = true
	SWEP.EquipMenuData = {
		type = "item_weapon",
		name = "Mute Radio",
		desc = [[Muted all Voicechat Communication in a given radius]]
	}
end

function SWEP:Initialize()
	self:SetHoldType("melee2")

	self.m_bInitialized = true
end

function SWEP:Think()
	if not self.m_bInitialized then
		self:Initialize()
	end
end

function SWEP:GetViewModelPosition(pos, ang)
	return pos + ang:Forward() * 20 + ang:Right() * 6 - ang:Up() * 8, ang
end

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire( CurTime() )

	if CLIENT then return end
	local owner = self:GetOwner()

	local ent = ents.Create("ttt_mute_radio")
	local aimvec = owner:GetAimVector()
	local pos = aimvec * 10
	pos:Add( owner:EyePos() )
	ent:SetPos( pos )
	ent:SetAngles( owner:EyeAngles() )
	ent:Spawn()

	local phys = ent:GetPhysicsObject()
	phys:ApplyForceCenter(Vector(aimvec.x, aimvec.y, aimvec.z) * 5000)

	ent:SetOwner(owner)
	ent.ownerTeam = owner:GetTeam()
	ent.fingerprints = self.fingerprints
	self:Remove()

	cleanup.Add( owner, "props", ent )
	undo.Create( "Mute Radio" )
		undo.AddEntity( ent )
		undo.SetPlayer( owner )
	undo.Finish()
end

function SWEP:SecondaryAttack()
end

if SERVER then
	resource.AddFile("materials/VGUI/icon_mute_radio.vmt")
	resource.AddFile("materials/VGUI/icon_mute_radio.vtf")
end