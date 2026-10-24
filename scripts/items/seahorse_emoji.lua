-- Seahorse Emoji (active, 3 charges)
-- Parody of models spiralling over a seahorse emoji that does not exist:
-- summon a native Book of Virtues wisp of a random vanilla active ("here it
-- is!"), which disappears when you leave the room ("no wait"). One per
-- player; using again replaces it. Car Battery does not add a second.

local Constants = include("scripts.constants")

local Seahorse = {}

local NAMES = { "COLLECTIBLE_BOOK_OF_BELIAL", "COLLECTIBLE_NECRONOMICON", "COLLECTIBLE_YUM_HEART",
    "COLLECTIBLE_TAMMYS_HEAD", "COLLECTIBLE_SHOOP_DA_WHOOP", "COLLECTIBLE_MONSTROS_TOOTH",
    "COLLECTIBLE_THE_NAIL" }

function Seahorse:Init(mod)
    local wisps = {}

    local function clear(key)
        local w = wisps[key]
        if w and w:Exists() then w:Remove() end
        wisps[key] = nil
    end

    mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, _, rng, player, flags)
        if (flags & UseFlag.USE_CARBATTERY) ~= 0 then
            return { Discharge = false, Remove = false, ShowAnim = false }
        end
        local key = GetPtrHash(player)
        clear(key)
        local pool = {}
        for _, name in ipairs(NAMES) do
            if CollectibleType[name] then pool[#pool + 1] = CollectibleType[name] end
        end
        local pick = pool[rng:RandomInt(#pool) + 1]
        wisps[key] = player:AddWisp(pick, player.Position)
        Game():GetHUD():ShowItemText("Here is the seahorse emoji!", "No wait, that's a different one")
        return { Discharge = true, Remove = false, ShowAnim = true }
    end, Constants.Item.SEAHORSE_EMOJI)

    mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
        for key in pairs(wisps) do clear(key) end
    end)
    mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, function()
        for key in pairs(wisps) do clear(key) end
    end)
end

return Seahorse
