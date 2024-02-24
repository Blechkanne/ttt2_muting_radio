include('shared.lua')
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
	
	if not hitEntity:IsValid() then return end
	if hitEntity.ClassName ~= "ttt_mute_radio" then return end

	local playerTeam = ply:GetTeam()
	local ownerTeam = hitEntity.Owner:GetTeam()

	if playerTeam == ownerTeam then
		local quality = 20
		cam.Start3D()
		render.SetMaterial(material)
		render.SetColorMaterial()
		render.DrawSphere( hitEntity:GetPos(), -MUTE_RADIO_CONVARS.muteRadius, quality, quality, mat_color)
		render.DrawSphere( hitEntity:GetPos(), MUTE_RADIO_CONVARS.muteRadius, quality, quality, mat_color)
		render.DrawWireframeSphere( hitEntity:GetPos(), MUTE_RADIO_CONVARS.muteRadius, quality, quality, mat_color, true)

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


cvars.AddChangeCallback("ttt_mute_radio_radius", function(convar, oldValue, newValue)
	muteRadius = tonumber(newValue)
end )