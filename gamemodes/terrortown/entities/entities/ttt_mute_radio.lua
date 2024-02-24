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
    
    function ENT:Use( activator, caller )
        if not activator:IsPlayer() then return end
        local playerTeam = activator:GetTeam()
    
        for _, ply in ipairs(player.GetAll()) do
            self:SendMuteStatus(ply, false)
            ply.hasMutedSound = false
        end
    
        if playerTeam == self.ownerTeam then
            activator:Give("mute_radio")
            self:Remove()
        else
            local effectdata = EffectData()
            effectdata:SetOrigin( self:GetPos() )
            util.Effect( "ManhackSparks", effectdata )
            self:EmitSound("BaseGrenade.Explode")
            self:Remove()
        end
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
    local material = Material("vgui/white")
    local mat_color = Color(0, 255, 0, 30)
    
    function ENT:Draw()
        self:DrawModel()
        self:CreateShadow()
    end
    
    hook.Add( "PostDrawTranslucentRenderables", "TTT2MuteRadioRenderRadius", function()
        local ply = LocalPlayer()
        local eyeTrace = ply:GetEyeTrace()
        local hitEntity = eyeTrace.Entity
        local cvMuteRadius = CreateConVar("ttt_mute_radio_radius", "600", {FCVAR_NOTIFY, FCVAR_ARCHIVE})
    
        
        if not hitEntity:IsValid() then return end
        if hitEntity.ClassName ~= "ttt_base_placeable" then return end
    
        local playerTeam = ply:GetTeam()
        local ownerTeam = hitEntity.Owner:GetTeam()
    
        if playerTeam == ownerTeam then
            local quality = 20
            cam.Start3D()
            render.SetMaterial(material)
            render.SetColorMaterial()
            render.DrawSphere( hitEntity:GetPos(), -cvMuteRadius:GetInt(), quality, quality, mat_color)
            render.DrawSphere( hitEntity:GetPos(), cvMuteRadius:GetInt(), quality, quality, mat_color)
            render.DrawWireframeSphere( hitEntity:GetPos(), cvMuteRadius:GetInt(), quality, quality, mat_color, true)
    
            cam.End3D()
        end
    
    end )
    
    local color_orange = Color(255, 128, 0);
    
    hook.Add("TTTRenderEntityInfo", "TTT2MuteRadioRenderName", function(tData)
        local ent = tData:GetEntity()
        if not IsValid(ent) then return end
        if ent.ClassName ~= "ttt_mute_radio" then return end
    
        local ply = LocalPlayer()
        local entityPos = ent:GetPos()
        local plyPos = ply:GetPos()
        local distance = entityPos:Distance(plyPos)
    
        if distance > 100 then return end
    
        local playerTeam = ply:GetTeam()
        local ownerTeam = ent.Owner:GetTeam()
    
        if playerTeam == ownerTeam  then
            tData:SetTitle("Mute Radio", color_orange)
            tData:EnableText(true)
            tData:EnableOutline(true)
            tData:AddDescriptionLine("Press E to pick back up", color_white, {})
        else
            tData:SetTitle("Mute Radio", color_orange)
            tData:EnableText(true)
            tData:EnableOutline(true)
            tData:AddDescriptionLine("Press E to destroy", color_white, {})
        end
    
        return true
    end)
end