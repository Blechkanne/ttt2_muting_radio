local muteStatus = false

net.Receive("ttt2SendMuteRadioInfo", function(len, ply)
    muteStatus = net.ReadBool()
end )


hook.Add("PostDrawHUD", "TTT2MuteRadioRenderInfo", function()
    local cvShowText = CreateConVar("ttt_mute_radio_show_mute_info", "1", {FCVAR_NOTIFY, FCVAR_ARCHIVE})
    if not muteStatus or not cvShowText:GetBool() then return end

    surface.SetFont("DermaDefault")
    surface.SetTextColor(255, 0, 0)
    surface.SetTextPos(ScrW() / 2 + 22, ScrH() / 2 - 10)
    surface.DrawText("You are in range of a mute Radio")
end )

hook.Add("TTTPrepareRound", "TTT2MuteRadioClearup", function()
    muteStatus = false
end )
