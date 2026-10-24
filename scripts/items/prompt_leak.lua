-- System Prompt Leak (trinket)
-- Parody of leaked hidden instructions: the first room a holder enters on
-- each floor reveals the special rooms with the native compass effect.

local Constants = include("scripts.constants")
local MemeState = include("scripts.items.meme_state")

local Leak = {}

function Leak:Init(mod, Risk)
    mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
        local holders = MemeState.Holders(Constants.Trinket.PROMPT_LEAK)
        if #holders == 0 then return end
        local s = MemeState.For(Risk, holders[1])
        if not s or s.leakedFloor == s.floor then return end
        s.leakedFloor = s.floor
        Game():GetLevel():ApplyCompassEffect(true)
        Game():GetHUD():ShowItemText("System prompt leaked", "Special rooms: revealed")
    end)
end

return Leak
