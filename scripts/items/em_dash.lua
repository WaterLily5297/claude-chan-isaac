-- Em Dash (passive)
-- Parody of the "AI writing always uses em dashes" meme: tears go straight
-- through enemies — like the sentence never ends. Native piercing plus +0.16
-- shot speed per copy. Pure cache changes, so every weapon and vanilla item
-- keeps working on top of it.

local Constants = include("scripts.constants")

local EmDash = {}

EmDash.SHOT_SPEED = 0.16

function EmDash:Init(mod)
    mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player, flag)
        if not player:HasCollectible(Constants.Item.EM_DASH) then return end
        if flag == CacheFlag.CACHE_SHOTSPEED then
            player.ShotSpeed = player.ShotSpeed + EmDash.SHOT_SPEED * player:GetCollectibleNum(Constants.Item.EM_DASH)
        elseif flag == CacheFlag.CACHE_TEARFLAG then
            player.TearFlags = player.TearFlags | TearFlags.TEAR_PIERCING
        end
    end)
end

return EmDash
