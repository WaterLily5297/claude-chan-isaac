-- Reproduce an outage leaking across runs when the frame counter resets.
local root = arg[1]
local callbacks, frame, roomFrame, hasTrinket = {}, 5000, 599, true
local freezes = 0
ModCallbacks = setmetatable({}, { __index = function(_, key) return key end })
EntityFlag = { FLAG_FRIENDLY = 1 }
function include() return { Trinket = { OVERLOADED = 190 } } end
function EntityRef(entity) return entity end
local player = {
    HasTrinket = function() return hasTrinket end,
    ToPlayer = function(self) return self end,
}
local enemy = {
    ToNPC = function(self) return self end,
    IsVulnerableEnemy = function() return true end,
    HasEntityFlags = function() return false end,
    AddFreeze = function(_, _, duration) assert(duration == 60); freezes = freezes + 1 end,
}
Isaac = {
    GetPlayer = function() return player end,
    GetRoomEntities = function() return { enemy } end,
}
function Game() return {
    GetFrameCount = function() return frame end,
    GetNumPlayers = function() return 1 end,
    GetRoom = function() return {
        IsClear = function() return false end,
        GetFrameCount = function() return roomFrame end,
    } end,
    GetHUD = function() return { ShowItemText = function() end } end,
} end
local mod = { AddCallback = function(_, id, fn) callbacks[id] = fn end }
dofile(root .. "/scripts/items/overloaded.lua"):Init(mod)
local function fire(id, ...)
    if callbacks[id] then callbacks[id](mod, ...) end
end
local function damage()
    local tear = { SpawnerEntity = player, CollisionDamage = 4 }
    fire("MC_POST_FIRE_TEAR", tear)
    return tear.CollisionDamage
end
fire("MC_POST_GAME_STARTED", false)
fire("MC_POST_UPDATE")
assert(freezes == 1 and damage() == 2, "an outage freezes enemies and halves tears")
hasTrinket = false
assert(damage() == 4, "dropping the trinket removes its penalty")
hasTrinket = true
frame = 5060
assert(damage() == 4, "the penalty ends after exactly 60 frames")

frame = 6000; fire("MC_POST_UPDATE")
assert(damage() == 2)
fire("MC_PRE_GAME_EXIT", false)
frame, roomFrame = 0, 0
fire("MC_POST_GAME_STARTED", false)
assert(damage() == 4, "a new run must not inherit an old run's outage deadline")

frame, roomFrame = 7000, 599; fire("MC_POST_UPDATE")
assert(damage() == 2)
fire("MC_PRE_GAME_EXIT", true)
frame, roomFrame = 100, 0
fire("MC_POST_GAME_STARTED", true)
assert(damage() == 4, "continue must not retain a stale module-local deadline")
print("OK: Overloaded outage duration, trinket removal, new run and continue")
