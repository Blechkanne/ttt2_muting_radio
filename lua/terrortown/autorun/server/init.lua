util.AddNetworkString("ttt2SendMuteRadioInfo")


hook.Add("TTTPrepareRound", "TTT2MuteRadioClearup", function()
    for _, ply in ipairs(player.GetAll()) do
        ply.hasMutedSound = false
    end
end )