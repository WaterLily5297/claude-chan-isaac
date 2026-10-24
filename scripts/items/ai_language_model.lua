-- As an AI Language Model (trinket)
-- The classic refusal: "As an AI language model, I can't help with that."
-- The first time a holder enters a room on a cursed floor, one curse is
-- refused and removed with the native curse API, once per floor. Curse of
-- the Labyrinth is never removed, because the floor is already built.

local Constants = include("scripts.constants")
local MemeState = include("scripts.items.meme_state")

local Refusal = {}

local LABYRINTH, MAX_BIT = 2, 1 << 12

-- Lowest curse bit other than the Labyrinth, or nil.
function Refusal.Pick(curses)
    local bit = 1
    while bit <= MAX_BIT do
        if bit ~= LABYRINTH and (curses & bit) ~= 0 then return bit end
        bit = bit << 1
    end
end

function Refusal:Init(mod, Risk)
    mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
        local holders = MemeState.Holders(Constants.Trinket.AI_LANGUAGE_MODEL)
        if #holders == 0 then return end
        local s = MemeState.For(Risk, holders[1])
        if not s or s.refusedFloor == s.floor then return end
        local level = Game():GetLevel()
        local curse = Refusal.Pick(level:GetCurses())
        if not curse then return end
        s.refusedFloor = s.floor
        level:RemoveCurses(curse)
        Game():GetHUD():ShowItemText("As an AI language model", "I can't help with that curse")
    end)
end

return Refusal
