MUTE_RADIO_CONVARS = {}

CreateConVar("ttt_mute_radio_radius", "600", {FCVAR_NOTIFY, FCVAR_ARCHIVE, FCVAR_REPLICATED})
CreateConVar("ttt_mute_radio_choppy_sound", "1", {FCVAR_NOTIFY, FCVAR_ARCHIVE, FCVAR_REPLICATED})
CreateConVar("ttt_mute_radio_mute_same_team", "0", {FCVAR_NOTIFY, FCVAR_ARCHIVE, FCVAR_REPLICATED})
CreateConVar("ttt_mute_radio_show_mute_info", "1", {FCVAR_NOTIFY, FCVAR_ARCHIVE, FCVAR_REPLICATED})

local muteRadiusConvar = GetConVar("ttt_mute_radio_radius")
MUTE_RADIO_CONVARS.muteRadius = 600
if muteRadiusConvar ~= nil then
    MUTE_RADIO_CONVARS.muteRadius = muteRadiusConvar:GetInt()
end

local choppySoundConvar = GetConVar("ttt_mute_radio_choppy_sound")
MUTE_RADIO_CONVARS.choppySound = true
if choppySoundConvar ~= nil then
    MUTE_RADIO_CONVARS.choppySound = choppySoundConvar:GetBool()
end

local muteSameTeamConvar = GetConVar("ttt_mute_radio_mute_same_team")
MUTE_RADIO_CONVARS.muteSameTeam = false
if muteSameTeamConvar ~= nil then
    MUTE_RADIO_CONVARS.muteSameTeam = muteSameTeamConvar:GetBool()
end

local showTextConvar = GetConVar("ttt_mute_radio_show_mute_info")
MUTE_RADIO_CONVARS.showText = true
if showText ~= nil then
    MUTE_RADIO_CONVARS.showText = showTextConvar:GetBool()
end


cvars.AddChangeCallback("ttt_mute_radio_radius", function(convar, oldValue, newValue)
	MUTE_RADIO_CONVARS.muteRadius = tonumber(newValue)
end )

cvars.AddChangeCallback("ttt_mute_radio_choppy_sound", function(convar, oldValue, newValue)
	MUTE_RADIO_CONVARS.choppySound = tobool(newValue)
end )

cvars.AddChangeCallback("ttt_mute_radio_mute_same_team", function(convar, oldValue, newValue)
	MUTE_RADIO_CONVARS.muteSameTeam = tobool(newValue)
end )

cvars.AddChangeCallback("ttt_mute_radio_show_mute_info", function(convar, oldValue, newValue)
	MUTE_RADIO_CONVARS.showText = tobool(newValue)
end )