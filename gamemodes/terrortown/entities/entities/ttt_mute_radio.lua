if SERVER then
    AddCSLuaFile()
end

ENT.Base = "ttt_base_placeable"

if CLIENT then
    ENT.PrintName = "weapon_mute_radio_name"
    ENT.Icon = "vgui/ttt/icon_mute_radio"
end

ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.CanUseKey = true
ENT.pickupWeaponClass = "weapon_ttt_mute_radio"

if SERVER then
    local cvMuteRadius = CreateConVar("ttt_mute_radio_radius", "600", {FCVAR_NOTIFY, FCVAR_ARCHIVE})
    local cvChoppySound = CreateConVar("ttt_mute_radio_choppy_sound", "1", {FCVAR_NOTIFY, FCVAR_ARCHIVE})
    local cvMuteSameTeam = CreateConVar("ttt_mute_radio_mute_same_team", "0", {FCVAR_NOTIFY, FCVAR_ARCHIVE})

    ENT.ownerTeam = ""
    function ENT:Initialize()
        self:SetModel("models/props_lab/citizenradio.mdl")
        self:PhysicsInit( SOLID_VPHYSICS )
        self:SetMoveType( MOVETYPE_VPHYSICS )
        self:SetSolid( SOLID_VPHYSICS )
        self:SetModelScale(0.3)
        self.BaseClass.Initialize(self)
        self:SetHealth(100)
        self.ownerTeam = self:GetOriginator():GetTeam()

        local phys = self:GetPhysicsObject()
    
        if phys:IsValid() then
            phys:EnableMotion( true )
            phys:EnableGravity( true )
            phys:Wake()
        end
    
    end
    
    function ENT:SendMuteStatus(ply, bool)
        net.Start("ttt2SendMuteRadioInfo")
        net.WriteBool(bool)
        net.Send(ply)
    end

    function ENT:PlayerCanPickupWeapon(activator)
        return self:GetOriginator() == activator
    end

    function ENT:WasDestroyed(pos, dmgInfo)
        local originator = self:GetOriginator()
        local effectdata = EffectData()

        for _, ply in ipairs(player.GetAll()) do
            self:SendMuteStatus(ply, false)
            ply.hasMutedSound = false
        end

        effectdata:SetOrigin( pos )
        util.Effect( "ManhackSparks", effectdata )
        self:EmitSound("BaseGrenade.Explode")
        LANG.Msg(originator, "weapon_mute_radio_destroyed", nil, MSG_MSTACK_WARN)
    end

    local muteInterval = 0.25
    
    function ENT:Think( activator, caller )
        for _, ply in ipairs(player.GetAll()) do
            local posEntity = self:GetPos()
            local posPlayer = ply:GetPos()
            local distance = posEntity:Distance(posPlayer)
            local playerTeam = ply:GetTeam()
    
            if not ply:Alive() then
                continue
            end
    
            if ply.hasMutedSound == nil then
                ply.hasMutedSound = false
            end
    
            if distance <= cvMuteRadius:GetInt() and not ply.hasMutedSound then
                ply.hasMutedSound = true
                self:SendMuteStatus(ply, true)
            elseif distance > cvMuteRadius:GetInt() and ply.hasMutedSound then
                ply.hasMutedSound = false
                self:SendMuteStatus(ply, false)
            end
    
            if (not cvMuteSameTeam:GetBool() and playerTeam == self.ownerTeam) then
                continue
            end
    
            if ply.hasMutedSound then
                local percentage = 1
        
                if cvChoppySound:GetBool() then
                    percentage = math.ceil((1 - distance / cvMuteRadius:GetInt()) * 100) / 100
                end
        
                ply:ConCommand("soundfade 100 " .. (muteInterval * percentage * 1.1))
            end
        end
    
        self:NextThink( CurTime() + muteInterval)
        return true
    end
    
end

if CLIENT then 
    local TryT = LANG.TryTranslation
    local ParT = LANG.GetParamTranslation

    function ENT:Draw()
        self:DrawModel()
        self:CreateShadow()
    end
    
    hook.Add("TTTRenderEntityInfo", "TTT2MuteRadioRenderName", function(tData)
        local client = LocalPlayer()
        local ent = tData:GetEntity()

        if
            not client:IsTerror()
            or not IsValid(ent)
            or tData:GetEntityDistance() > 100
            or ent:GetClass() ~= "ttt_mute_radio"
            or client:GetTeam() ~= ent:GetOriginator():GetTeam()
        then
            return
        end

        tData:EnableText()
        tData:EnableOutline()
        tData:SetOutlineColor(client:GetRoleColor())
        tData:SetTitle(TryT(ent.PrintName))
        tData:SetKeyBinding("+use")

        if ent:GetOriginator() == client then
            tData:SetSubtitle("Press " .. Key("+use", "USE") .. " to pick back up")
        else
            tData:SetSubtitle("Press " .. Key("+use", "USE") .. "  to destroy")
        end
        return true
    end)
end