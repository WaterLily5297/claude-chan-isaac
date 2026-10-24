-- Tungsten Cube (passive)
-- Project Vend parody: the shopkeeping assistant stocked specialty metal cubes
-- and sold them at a loss. Heavy: +0.8 damage and -0.15 speed per copy, and
-- tears gain native knockback. Pure cache changes, so every weapon and
-- vanilla stat item keeps working on top of it.

local Constants = include("scripts.constants")

local Cube = {}

local DAMAGE, SPEED, MIN_SPEED = 0.8, 0.15, 0.1

function Cube:Init(mod)
    mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player, flag)
        if not player:HasCollectible(Constants.Item.TUNGSTEN_CUBE) then return end
        local count = player:GetCollectibleNum(Constants.Item.TUNGSTEN_CUBE)
        if flag == CacheFlag.CACHE_DAMAGE then
            player.Damage = player.Damage + DAMAGE * count
        elseif flag == CacheFlag.CACHE_SPEED then
            -- Never push speed below the floor, but never raise a lower value
            -- that another item already set.
            local speed = player.MoveSpeed - SPEED * count
            if speed < MIN_SPEED then speed = math.min(player.MoveSpeed, MIN_SPEED) end
            player.MoveSpeed = speed
        elseif flag == CacheFlag.CACHE_TEARFLAG then
            player.TearFlags = player.TearFlags | TearFlags.TEAR_KNOCKBACK
        end
    end)
end

return Cube
