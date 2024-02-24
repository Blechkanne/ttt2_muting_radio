AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include("shared.lua")

ENT.ownerTeam = ""

function ENT:Initialize()
	self:SetModel("models/props/cs_office/radio.mdl")
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetModelScale(1)
	
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

		if distance <= MUTE_RADIO_CONVARS.muteRadius and not ply.hasMutedSound then
			ply.hasMutedSound = true
			self:SendMuteStatus(ply, true)
		elseif distance > MUTE_RADIO_CONVARS.muteRadius and ply.hasMutedSound then
			ply.hasMutedSound = false
			self:SendMuteStatus(ply, false)
		end

		if (not MUTE_RADIO_CONVARS.muteSameTeam and playerTeam == self.ownerTeam) then
			continue
		end

		if ply.hasMutedSound then
			local percentage = 1
	
			if MUTE_RADIO_CONVARS.choppySound then
				percentage = math.ceil((1 - distance / MUTE_RADIO_CONVARS.muteRadius) * 100) / 100
			end
	
			ply:ConCommand("soundfade 100 " .. (muteInterval * percentage * 1.1))
		end
	end

	self:NextThink( CurTime() + muteInterval)
	return true
end
