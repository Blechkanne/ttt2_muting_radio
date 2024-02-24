if SERVER then
    AddCSLuaFile()
    resource.AddFile("materials/vgui/ttt/.vmt")
end

SWEP.HoldType = "grenade"

if CLIENT then
    SWEP.PrintName = "weapon_mute_radio_name"
    SWEP.Slot = 7

    SWEP.ViewModelFlip = false
    SWEP.ViewModelFOV = 64

    SWEP.UseHands = true
    SWEP.ShowDefaultViewModel = false
    SWEP.ShowDefaultWorldModel = false

    SWEP.EquipMenuData = {
        type = "item_weapon",
        name = "weapon_mute_radio_name",
        desc = "weapon_mute_radio_desc",
    }

	SWEP.Icon = "vgui/ttt/icon_mute_radio"
end
SWEP.Base = "weapon_tttbase"
SWEP.ViewModel = "models/weapons/cstrike/c_eq_flashbang.mdl"
SWEP.WorldModel = "models/props_lab/citizenradio.mdl"

SWEP.Author = "Blechkanne"

SWEP.Kind = WEAPON_EQUIP1
SWEP.CanBuy = { ROLE_TRAITOR, ROLE_DETECTIVE }
SWEP.LimitedStock = true
SWEP.Spawnable = false
SWEP.AdminSpawnable = false

SWEP.Primary.Delay = 0.9
SWEP.Primary.ClipSize = 1
SWEP.Primary.DefaultClip = 1
SWEP.Primary.NumShots = 1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )

	if CLIENT then return end
	if not self:CanPrimaryAttack() then return end

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
end

function SWEP:SecondaryAttack() end

if CLIENT then
    function SWEP:Initialize()
        self:AddTTT2HUDHelp("mute_radio_help_pri")

        self.BaseClass.Initialize(self)
    end

    function SWEP:InitializeCustomModels()
        self:AddCustomViewModel("vmodel", {
            type = "Model",
            model = "models/props_lab/citizenradio.mdl",
            bone = "ValveBiped.Bip01_R_Finger02",
            rel = "",
            pos = Vector(0, 0, 5),
            angle = Angle(160, 0, 0),
            size = Vector(0.3, 0.3, 0.3),
            color = Color(255, 255, 255, 255),
            surpresslightning = false,
            material = "",
            skin = 0,
            bodygroup = {},
        })

        self:AddCustomWorldModel("wmodel", {
            type = "Model",
            model = "models/props_lab/citizenradio.mdl",
            bone = "ValveBiped.Bip01_R_Hand",
            rel = "",
            pos = Vector(4, 2.5, 0),
            angle = Angle(110, -20, 0),
            size = Vector(0.3, 0.3, 0.3),
            color = Color(255, 255, 255, 255),
            surpresslightning = false,
            material = "",
            skin = 0,
            bodygroup = {},
        })
    end

    function SWEP:AddToSettingsMenu(parent)
		local form = vgui.CreateTTT2Form(parent, "mute_radio_addon_header")

		form:MakeHelp({
			label = "mute_radio_addon_help_menu"
		})
	
		form:MakeCheckBox({
			label = "mute_radio_choppy_sound",
			serverConvar = "ttt_mute_radio_choppy_sound"
		})
		
		form:MakeCheckBox({
			label = "mute_radio_mute_same_team",
			serverConvar = "ttt_mute_radio_mute_same_team"
		})
	
		form:MakeCheckBox({
			label = "mute_radio_show_mute_info",
			serverConvar = "ttt_mute_radio_show_mute_info"
		})
	
		form:MakeSlider({
			label = "mute_radio_radius",
			serverConvar = "ttt_mute_radio_radius",
			min = 10,
			max = 2000,
			decimal = 0
		})
    end
end

if SERVER then
	resource.AddFile("materials/vgui/ttt/icon_mute_radio.vmt")
	resource.AddFile("materials/vgui/ttt/icon_mute_radio.vtf")
end