-- Benchmaxxed (passive)
-- Parody of models tuned to ace benchmarks and stumble in real use: in boss,
-- mini-boss, challenge and Boss Rush rooms ("the benchmark") damage is +1.5
-- per copy; everywhere else ("real-world use") damage is x0.9 per copy.
-- The damage cache is re-evaluated on every new room.

local Constants = include("scripts.constants")

local Bench = {}

Bench.BONUS, Bench.PENALTY = 1.5, 0.9

function Bench.OnBenchmark()
    local t = Game():GetRoom():GetType()
    return t == RoomType.ROOM_BOSS or t == RoomType.ROOM_MINIBOSS
        or t == RoomType.ROOM_CHALLENGE or t == RoomType.ROOM_BOSSRUSH
end

function Bench:Init(mod)
    mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player, flag)
        if flag ~= CacheFlag.CACHE_DAMAGE or not player:HasCollectible(Constants.Item.BENCHMAXXED) then return end
        local count = player:GetCollectibleNum(Constants.Item.BENCHMAXXED)
        if Bench.OnBenchmark() then
            player.Damage = player.Damage + Bench.BONUS * count
        else
            player.Damage = player.Damage * Bench.PENALTY ^ count
        end
    end)

    mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
        for i = 0, Game():GetNumPlayers() - 1 do
            local player = Isaac.GetPlayer(i)
            if player:HasCollectible(Constants.Item.BENCHMAXXED) then
                player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
                player:EvaluateItems()
            end
        end
    end)
end

return Bench
