-- Fire-rate multipliers must raise tears per second for every MaxFireDelay
-- vanilla can produce, including the -0.75..0 band reached with Soy Milk,
-- Almond Milk or stacked tears items. Stubs cache callbacks only.
local root = arg[1]
function include(name) return dofile(root .. "/" .. name:gsub("%.", "/") .. ".lua") end
Isaac = {
    GetItemIdByName = function() return 800 end,
    GetTrinketIdByName = function() return 190 end,
    GetPillEffectByName = function(n) return ({ ["Cat-girl Mode"] = 60, ["Rolled Back"] = 61 })[n] or 50 end,
    GetPlayerTypeByName = function() return 41 end,
}
ModCallbacks = setmetatable({}, { __index = function(_, k) return k end })
CacheFlag = { CACHE_DAMAGE = 1, CACHE_FIREDELAY = 2, CACHE_SHOTSPEED = 4, CACHE_RANGE = 8,
    CACHE_SPEED = 16, CACHE_FLYING = 32, CACHE_LUCK = 1024 }

local FireRate = include("scripts.fire_rate")
local function tears(delay) return 30 / (delay + 1) end
local function near(a, b) return math.abs(a - b) < 1e-9 end

-- The helper itself ----------------------------------------------------------------------------
assert(near(FireRate.ScaleInterval(9, 0.5), 4), "half interval doubles tears")
assert(near(tears(FireRate.ScaleInterval(-0.5, 0.5)), 2 * tears(-0.5)), "doubles in the negative band")
assert(near(FireRate.ScaleInterval(9, 1.2), 11), "slower interval")
assert(FireRate.ScaleInterval(-0.7, 0.5) == FireRate.MIN_DELAY, "clamped at the floor")
print("PASS fire_rate: interval scaling, negative band, clamp")

-- Every module that speeds fire up -------------------------------------------------------------
local callbacks = {}
local mod = {}
function mod:AddCallback(id, fn, param) callbacks[#callbacks + 1] = { id = id, fn = fn } end
local function cache(player, flag)
    for _, c in ipairs(callbacks) do if c.id == "MC_EVALUATE_CACHE" then c.fn(nil, player, flag) end end
end

include("scripts.transformation"):Init(mod)
include("scripts.pills"):Init(mod, { Start = function() return true end })
include("scripts.items.rolled_back"):Init(mod)

local cases = {
    { "Agentic", function(d) d.ccAgentic = true end, 0.8 },
    { "Cat-girl Mode", function(d) d.ccCatGirl = true end, 0.5 },
    { "Rolled Back", function(d) d.ccRolledBack = 1 end, 0.8 },
    { "Rolled Back (horse)", function(d) d.ccRolledBack = 2 end, 0.64 },
}
for _, case in ipairs(cases) do
    for _, base in ipairs({ 10, 2, 0.2, 0, -0.5 }) do
        local data = {}
        case[2](data)
        local p = { MaxFireDelay = base }
        function p:GetData() return data end
        cache(p, CacheFlag.CACHE_FIREDELAY)
        assert(tears(p.MaxFireDelay) > tears(base),
            string.format("%s must raise tears at delay %.2f (got %.3f)", case[1], base, p.MaxFireDelay))
        assert(near(p.MaxFireDelay, math.max(FireRate.MIN_DELAY, (base + 1) * case[3] - 1)),
            string.format("%s scales the whole interval at %.2f", case[1], base))
    end
end
print("PASS fire_rate: Agentic, Cat-girl Mode and Rolled Back speed up every native delay")
