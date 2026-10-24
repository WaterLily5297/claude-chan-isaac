-- Claudius's Discount (trinket)
-- Project Vend parody: the shopkeeping assistant handed out discounts and
-- ran the shop at a loss. Each paid purchase of 2+ coins refunds 1 coin, but
-- every new floor costs the holder 1 coin if they have any. Native prices are
-- never rewritten: a purchase is confirmed by the coin count actually
-- dropping by the price within two updates of touching the pickup.

local Constants = include("scripts.constants")
local MemeState = include("scripts.items.meme_state")

local Discount = {}

local CONFIRM_FRAMES = 2

function Discount:Init(mod, Risk)
    local pending, started = {}, false

    mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function()
        pending, started = {}, true
    end)
    mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, function()
        pending, started = {}, false
    end)

    mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, function(_, pickup, collider)
        local player = collider and collider:ToPlayer()
        if not player or not player:HasTrinket(Constants.Trinket.CLAUDIUS_DISCOUNT) then return end
        local price, coins = pickup.Price, player:GetNumCoins()
        if price >= 2 and coins >= price then
            pending[GetPtrHash(player)] = { player = player, coins = coins, price = price,
                frame = Game():GetFrameCount() }
        end
    end)

    mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
        local now = Game():GetFrameCount()
        for hash, p in pairs(pending) do
            if p.player:GetNumCoins() == p.coins - p.price then
                p.player:AddCoins(1)
                Game():GetHUD():ShowItemText("Discount applied", "Margins are a later problem")
                pending[hash] = nil
            elseif now - p.frame > CONFIRM_FRAMES then
                pending[hash] = nil
            end
        end
    end)

    -- POST_NEW_LEVEL also fires before a new run starts; the floor key in
    -- saved state stops a duplicate charge on continue or repeated callbacks.
    mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, function()
        if not started then return end
        for _, player in ipairs(MemeState.Holders(Constants.Trinket.CLAUDIUS_DISCOUNT)) do
            local s = MemeState.For(Risk, player)
            if s and s.claudiusFloor ~= s.floor then
                s.claudiusFloor = s.floor
                if player:GetNumCoins() > 0 then
                    player:AddCoins(-1)
                    Game():GetHUD():ShowItemText("The shop ran at a loss", "-1 coin")
                end
            end
        end
    end)
end

return Discount
