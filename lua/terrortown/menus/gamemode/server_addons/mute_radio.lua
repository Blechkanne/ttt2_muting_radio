CLGAMEMODESUBMENU.base = "base_gamemodesubmenu"
CLGAMEMODESUBMENU.title = "mute_radio_addon_info"

function CLGAMEMODESUBMENU:Populate(parent)
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
