-- Damage cache must use the current wallet, even before the next player update.
local root = arg[1]
local callbacks = {}
ModCallbacks = setmetatable({}, { __index = function(_, key) return key end })
CacheFlag = { CACHE_DAMAGE = 1, CACHE_SPEED = 2 }
local paid
function include(name)
    if name == "scripts.characters.paid_attacks" then return { Observe = function(_, fn) paid = fn end } end
    return { Item = { OPUS_MODE = 747 } }
end
EntityType = { ENTITY_LASER = 7 }
local mod = { AddCallback = function(_, id, fn) callbacks[id] = fn end }
dofile(root .. "/scripts/items/opus_mode.lua"):Init(mod)

local function player(coins, data, owned)
    return {
        Damage = 10,
        GetNumCoins = function() return coins end,
        GetData = function() return data end,
        HasCollectible = function(_, id) assert(id == 747); return owned ~= false end,
    }
end
local function damage(p, flag)
    callbacks.MC_EVALUATE_CACHE(mod, p, flag or CacheFlag.CACHE_DAMAGE)
    return p.Damage
end

assert(damage(player(0, {})) == 6,
    "acquiring Opus with an empty wallet must use fallback before the first update")
assert(damage(player(1, {})) == 18, "funded players receive the Opus multiplier")
assert(damage(player(0, { ccOpusBroke = false })) == 6,
    "spending the last coin must affect a cache evaluation before the next update")
assert(damage(player(1, { ccOpusBroke = true })) == 18,
    "a coin pickup must affect a cache evaluation even if the notification flag is stale")
assert(damage(player(0, { ccOpusBroke = true }, false)) == 10,
    "rerolling away Opus must remove both multipliers")
assert(damage(player(1, { ccOpusBroke = true })) == 18,
    "reacquiring Opus must not reuse a stale empty-wallet multiplier")
assert(damage(player(0, {})) == 6 and damage(player(2, {})) == 18,
    "each player's cache reads that player's own wallet")
assert(damage(player(0, {}), CacheFlag.CACHE_SPEED) == 10,
    "unrelated cache flags must not alter damage")
-- Every weapon pays: tears, laser starts, Dr. Fetus bombs and observed attacks.
local spent, data = 0, {}
local owner = player(5, data)
owner.AddCoins = function(_, n) spent = spent - n end
local function shooter(e)
    local entityData = {}
    e.SpawnerEntity = { ToPlayer = function() return owner end }
    function e:GetData() return entityData end
    return e
end
for _ = 1, 3 do callbacks.MC_POST_FIRE_TEAR(mod, shooter({})) end
for _ = 1, 3 do callbacks.MC_POST_LASER_INIT(mod, shooter({})) end
callbacks.MC_POST_LASER_INIT(mod, shooter({ Parent = { Type = 7 } })) -- child beam: free
callbacks.MC_POST_BOMB_INIT(mod, shooter({ IsFetus = true }))
callbacks.MC_POST_BOMB_INIT(mod, shooter({ IsFetus = false })) -- placed bomb: free
assert(data.ccOpusTears == 7 and spent == 0, "seven billed attacks so far")
for _ = 1, 3 do paid(owner) end
assert(spent == 1 and data.ccOpusTears == 0, "the tenth attack of any weapon costs a coin")
print("PASS Opus Mode: every weapon is billed")
print("OK: Opus immediate wallet damage, stale notification state, ownership and player isolation")
