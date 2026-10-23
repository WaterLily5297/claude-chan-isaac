-- Boundary tests for selection and native-shot handoff, not engine rendering.
local root = arg[1]
function include(name) return dofile(root .. "/" .. name:gsub("%.", "/") .. ".lua") end
Isaac = {
    GetItemIdByName = function(name) return name == "Summary Stapler" and 850 or 800 end,
    GetTrinketIdByName = function() return 190 end,
    GetPillEffectByName = function() return 50 end,
    GetPlayerTypeByName = function() return 41 end,
}
ModCallbacks = { MC_USE_ITEM = 1 }
UseFlag = { USE_CARBATTERY = 32 }
EntityFlag = { FLAG_FRIENDLY = 1 }
Direction = { LEFT = 0, UP = 1, RIGHT = 2, DOWN = 3 }
local vector = {}
vector.__index = vector
function Vector(x, y) return setmetatable({ X = x, Y = y }, vector) end
function vector.__sub(a, b) return Vector(a.X - b.X, a.Y - b.Y) end
function vector:LengthSquared() return self.X * self.X + self.Y * self.Y end
function vector:Resized(n)
    local length = math.sqrt(self:LengthSquared())
    return Vector(self.X * n / length, self.Y * n / length)
end
local entities, shots, scans = {}, {}, 0
function Isaac.GetRoomEntities() scans = scans + 1; return entities end
local callback
local mod = { AddCallback = function(_, id, fn, item)
    assert(id == ModCallbacks.MC_USE_ITEM and item == 850)
    assert(not callback, "Item must not install a recurring scan")
    callback = fn
end }
include("scripts.items.summary_stapler"):Init(mod)

local function player(x)
    return { Position = Vector(x or 0, 0), aim = Vector(0, 0), head = Direction.UP,
        GetShootingInput = function(p) return p.aim end,
        GetHeadDirection = function(p) return p.head end,
        FireTear = function(p, position, velocity, eye, tractor, streak, source, multiplier)
            assert(position == p.Position and source == p)
            assert(eye == false and tractor == false and streak == false)
            shots[#shots + 1] = { owner = p, velocity = velocity, multiplier = multiplier }
            -- A native callback may cancel the shot. The item must not dereference
            -- or reconstruct the returned tear, nor undo the defensive absorption.
            return nil
        end,
    }
end
local p, other = player(), player(200)
local function bullet(x, seed, flags, friendly)
    local b = { Position = Vector(x, 0), Variant = 0, SubType = 0,
        InitSeed = seed or x, Index = seed or x, ProjectileFlags = flags or 0, ChangeFlags = 0 }
    function b:ToProjectile() return self end
    function b:Exists() return not self.removed end
    function b:IsDead() return self.dead or false end
    function b:HasEntityFlags() return self.friendly or false end
    function b:Remove() self.removed = true end
    b.SpawnerEntity = { ToNPC = function() return {
        HasEntityFlags = function() return friendly or false end,
    } end }
    return b
end
local function use(who, flags) return callback(mod, 850, nil, who or p, flags or 0) end
assert(not use().Discharge and #shots == 0)
local scanBefore = scans
entities = { bullet(2) }
assert(not use(p, 32).Discharge and scans == scanBefore and not entities[1].removed)
local outside, boundary = bullet(120.01), bullet(120)
entities = { outside, boundary }
assert(use().Discharge and boundary.removed and not outside.removed)
assert(#shots == 1 and shots[1].multiplier == 1.25)
assert(shots[1].velocity.X == 0 and shots[1].velocity.Y == -6)
assert(not use().Discharge, "Removed projectiles must not be counted twice")

-- Keep 12 nearest, independent of room enumeration; equal distance uses seed,
-- and equal seed uses entity index. The room's table itself must not be sorted.
entities, shots = {}, {}
for i = 20, 1, -1 do entities[#entities + 1] = bullet(i) end
local first = entities[1]
p.aim = Vector(3, 4)
assert(use().Discharge and entities[1] == first)
for _, b in ipairs(entities) do assert((b.removed or false) == (b.Position.X <= 12)) end
assert(#shots == 1 and shots[1].multiplier == 4)
assert(math.abs(shots[1].velocity.X - 3.6) < 0.0001 and math.abs(shots[1].velocity.Y - 4.8) < 0.0001)
entities, shots = {}, {}
for i = 14, 1, -1 do entities[#entities + 1] = bullet(10, i) end
use()
for _, b in ipairs(entities) do assert((b.removed or false) == (b.InitSeed <= 12)) end
entities, shots = {}, {}
for i = 14, 1, -1 do
    local b = bullet(10, 1); b.Index = i; entities[#entities + 1] = b
end
use()
for _, b in ipairs(entities) do assert((b.removed or false) == (b.Index <= 12)) end

-- Preserve special bullets, friendly/charmed sources, player/familiar shots,
-- dead entities, non-projectiles and unknown sources.
entities, shots = {}, {}
for i = 1, 10 do entities[i] = bullet(1, i) end
entities[1].Variant = 1
entities[2].SubType = 1
entities[3].ProjectileFlags = 4
entities[4].ChangeFlags = 8
entities[5].SpawnerEntity = nil
entities[6].SpawnerEntity = { ToNPC = function() return nil end }
entities[7] = bullet(1, 7, 0, true)
entities[8].friendly = true
entities[9].dead = true
entities[10].ToProjectile = function() return nil end
assert(not use().Discharge and #shots == 0)
for _, b in ipairs(entities) do assert(not b.removed) end

-- Both players use their own position/aim; no global cooldown or saved meter.
local nearP, nearOther = bullet(1), bullet(201)
entities = { nearP, nearOther }
p.aim, p.head = Vector(0, 0), Direction.LEFT
assert(use(p).Discharge and nearP.removed and not nearOther.removed)
other.aim = Vector(0, 1)
assert(use(other).Discharge and nearOther.removed)
assert(shots[#shots - 1].owner == p and shots[#shots - 1].velocity.X == -6)
assert(shots[#shots].owner == other and shots[#shots].velocity.Y == 6)
entities = { bullet(1) }; p.head = -1
use(p)
assert(shots[#shots].velocity.Y == 6, "Unspecified aim falls back down")
print("PASS Summary Stapler: bounds, ownership, special exclusions, nearest order, charge and native-shot handoff")
