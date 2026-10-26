-- Real item callbacks in main.lua's relative order, using supplied ordinary tears.
-- Cache inheritance and callback dispatch are fixtures, not engine observations.
local root = arg[1]
local C = { Item = { MILLION_CONTEXT = 1, PIZZA_GLUE = 2, STRAWBERRY = 3,
    GOLDEN_GATE = 4, BLUEBERRY = 5 }, Trinket = { HARDCODED_OUTPUT = 6 } }
local modules = {}
function include(name)
    if name == "scripts.constants" then return C end
    if not modules[name] then modules[name] = dofile(root .. "/" .. name:gsub("%.", "/") .. ".lua") end
    return modules[name]
end
function Color(r, g, b, a, ro, go, bo) return { R=r, G=g, B=b, A=a, RO=ro, GO=go, BO=bo } end
ModCallbacks = { MC_EVALUATE_CACHE = "cache", MC_POST_FIRE_TEAR = "fire",
    MC_POST_TEAR_UPDATE = "update", MC_POST_NEW_ROOM = "room" }
CacheFlag = { CACHE_RANGE = 1, CACHE_SHOTSPEED = 2, CACHE_TEARFLAG = 3, CACHE_TEARCOLOR = 4 }
TearFlags = { TEAR_HOMING = 1, TEAR_PIERCING = 2, TEAR_SLOW = 4,
    TEAR_QUADSPLIT = 8, TEAR_SPECTRAL = 16, TEAR_LUDOVICO = 32 }
local callbacks = {}
local mod = {}
function mod:AddCallback(id, fn, filter)
    assert(filter == nil, "selected callbacks currently have no optional filter")
    callbacks[#callbacks + 1] = { id=id, fn=fn }
end
local selected = { million_context=true, hardcoded_output=true, pizza_glue=true,
    strawberry=true, golden_gate=true, blueberry=true }
local seen, initialized = {}, 0
local file = assert(io.open(root .. "/main.lua", "r"))
local main = file:read("*a"); file:close()
for line in main:gmatch("[^\r\n]+") do
    local name = line:match('^%s*include%("scripts%.items%.([%w_]+)"%):Init%(')
    if selected[name] then
        assert(not seen[name], "duplicate selected module: " .. name)
        seen[name], initialized = true, initialized + 1
        include("scripts.items." .. name):Init(mod)
    end
end
assert(initialized == 6, "all six selected modules must be registered directly in main.lua")
local function dispatch(id, ...)
    for _, callback in ipairs(callbacks) do
        if callback.id == id then callback.fn(mod, ...) end
    end
end
local function near(actual, expected, label)
    assert(math.abs(actual - expected) < 1e-8, label .. ": " .. tostring(actual) .. " ~= " .. expected)
end
local function sameColor(actual, expected, label)
    for _, key in ipairs({ "R", "G", "B", "A", "RO", "GO", "BO" }) do
        near(actual[key], expected[key], label .. "." .. key)
    end
end
local function copyColor(c) return Color(c.R, c.G, c.B, c.A, c.RO, c.GO, c.BO) end
local nativeColor = Color(0.2, 0.7, 0.9, 0.6, 0.11, 0.22, 0.33)
local nativeFlags = TearFlags.TEAR_HOMING | TearFlags.TEAR_PIERCING
local rolls = { 0.1, 0.9, 0.15, 0.85, 0.2, 0.8 }
local function player(mask, damage)
    local p = { inventory={}, data={}, Damage=damage, Luck=0, draws=0 }
    for id = 1, 6 do p.inventory[id] = mask & (1 << (id - 1)) ~= 0 end
    function p:ToPlayer() return self end
    function p:HasCollectible(id) return self.inventory[id] end
    function p:HasTrinket(id) return self.inventory[id] end
    function p:GetCollectibleNum(id) return self.inventory[id] and 1 or 0 end
    function p:GetData() return self.data end
    function p:GetCollectibleRNG(id)
        assert(id == C.Item.PIZZA_GLUE, "only the supplied Pizza Glue roll is expected")
        return { RandomFloat = function()
            self.draws = self.draws + 1
            return assert(rolls[self.draws], "unexpected extra RNG draw")
        end }
    end
    return p
end
local function cache(p)
    p.TearRange, p.ShotSpeed = 100, 1.3
    p.TearColor, p.TearFlags = copyColor(nativeColor), nativeFlags
    for _, flag in ipairs({ CacheFlag.CACHE_RANGE, CacheFlag.CACHE_SHOTSPEED,
            CacheFlag.CACHE_TEARFLAG, CacheFlag.CACHE_TEARCOLOR }) do
        dispatch("cache", p, flag)
    end
    near(p.TearRange, 100 + (p.inventory[1] and 200 or 0) + (p.inventory[4] and 60 or 0), "range")
    near(p.ShotSpeed, p.inventory[2] and 1.2 or 1.3, "shot speed")
end
local function tear(owner, damage, flags)
    local t = { SpawnerEntity=owner, CollisionDamage=damage, Scale=1.7, FrameCount=0,
        Color=copyColor(owner and owner.TearColor or nativeColor),
        TearFlags=flags or (owner and owner.TearFlags or nativeFlags), data={} }
    function t:GetData() return self.data end
    function t:HasTearFlags(flag) return self.TearFlags & flag ~= 0 end
    function t:AddTearFlags(flag) self.TearFlags = self.TearFlags | flag end
    return t
end
local function expected(p, number, alreadySlow)
    local third = number % 3 == 0
    local glue = p.inventory[2] and not alreadySlow and rolls[number] < 0.25
    local red, blue, gold = p.inventory[3] and third, p.inventory[5] and third, p.inventory[4]
    local damage = (p.inventory[6] and 3.5 or p.Damage) * (red and 2 or 1)
    -- Expected combined channels, independently of the callbacks' intermediate objects.
    local color = Color(nativeColor.R * (blue and 0.45 or 1),
        nativeColor.G * (gold and 0.9 or 1) * (red and 0.35 or 1) * (blue and 0.55 or 1),
        nativeColor.B * (gold and 0.5 or 1) * (glue and 0.85 or 1) * (red and 0.35 or 1),
        nativeColor.A, nativeColor.RO + (gold and 0.25 or 0) + (glue and 0.25 or 0) + (red and 0.3 or 0),
        nativeColor.GO + (gold and 0.18 or 0) + (glue and 0.22 or 0),
        nativeColor.BO + (glue and 0.12 or 0) + (blue and 0.25 or 0))
    local flags = nativeFlags | ((glue or alreadySlow) and TearFlags.TEAR_SLOW or 0)
        | (gold and TearFlags.TEAR_SPECTRAL or 0) | (blue and TearFlags.TEAR_QUADSPLIT or 0)
    return damage, red and 2.04 or 1.7, color, flags
end
local function fireAndAge(p, number, firstFrame, alreadySlow)
    local t = tear(p, p.Damage, alreadySlow and (p.TearFlags | TearFlags.TEAR_SLOW) or nil)
    local inheritedColor = t.Color
    local damage, scale, color, flags = expected(p, number, alreadySlow)
    dispatch("fire", t)
    near(t.CollisionDamage, damage, "damage after all fire callbacks")
    sameColor(inheritedColor, p.TearColor, "fire must not mutate inherited color object")
    local draws = p.draws
    for _, frame in ipairs({ firstFrame or 0, 30, 62, 63, 90, 180 }) do
        t.FrameCount = frame
        for _ = 1, 2 do
            dispatch("update", t)
            -- Fractions explicitly mark the existing floor at frame 63, not frame 90.
            local factors = { [0]=1, [1]=89/90, [30]=2/3, [62]=28/90, [63]=0.3, [90]=0.3, [180]=0.3 }
            near(t.CollisionDamage, damage * (p.inventory[1] and factors[frame] or 1), "age damage")
            near(t.Scale, scale, "inherited scale and Strawberry growth")
            sameColor(t.Color, color, "combined tint")
            assert(t.TearFlags == flags, "native and added flags survive updates")
        end
    end
    assert(p.draws == draws, "updates must not roll Pizza Glue again")
    if p.inventory[1] then near(t.data.ccBaseDamage, damage, "snapshot includes all fire modifiers")
    else assert(t.data.ccBaseDamage == nil, "non-holder gets no Context snapshot") end
    return t
end

-- All 64 subsets; separate players fire interleaved rather than sharing counters.
for mask = 0, 63 do
    local a, b = player(mask, 12), player(mask, 5.25)
    cache(a); cache(a); cache(b)
    for number = 1, 6 do
        fireAndAge(a, number, number % 2)
        if number % 2 == 0 then
            fireAndAge(b, number - 1, 1)
            fireAndAge(b, number, 0)
        end
    end
    for _, p in ipairs({a, b}) do
        assert(p.draws == (p.inventory[2] and 6 or 0), "one roll per eligible primary tear")
        assert(p.data.ccStrawberry == (p.inventory[3] and 0 or nil), "separate red counter")
        assert(p.data.ccBlueberry == (p.inventory[5] and 0 or nil), "separate blue counter")
    end
end

-- Already-slow tears skip the Glue roll/tint without skipping the berry counters.
local slow = player(63, 12); cache(slow)
for number = 1, 3 do fireAndAge(slow, number, 0, true) end
assert(slow.draws == 0, "an existing slow flag consumes no Pizza Glue RNG")

-- A late first update still snapshots the fire result rather than pre-decaying it twice.
local late = player(63, 12); cache(late)
for number = 1, 3 do fireAndAge(late, number, 30) end

-- Ludovico is outside Context rot; this control does not model controlled-shot payment.
local ludoOwner = player(1, 12); cache(ludoOwner)
local ludo = tear(ludoOwner, 12, nativeFlags | TearFlags.TEAR_LUDOVICO)
dispatch("fire", ludo); ludo.FrameCount = 180; dispatch("update", ludo)
near(ludo.CollisionDamage, 12, "Ludovico exclusion")
assert(ludo.data.ccBaseDamage == nil)

-- No player owner: these six modules must leave supplied familiar/orphan tears alone.
for _, owner in ipairs({ false, { ToPlayer=function() return nil end } }) do
    local t = tear(nil, 9); t.SpawnerEntity = owner or nil
    dispatch("fire", t); t.FrameCount=180; dispatch("update", t)
    near(t.CollisionDamage, 9, "unowned damage"); near(t.Scale, 1.7, "unowned scale")
    sameColor(t.Color, nativeColor, "unowned color")
    assert(t.TearFlags == nativeFlags and next(t.data) == nil)
end
sameColor(nativeColor, Color(0.2, 0.7, 0.9, 0.6, 0.11, 0.22, 0.33), "shared native color")
print("OK: 64 real-module primary-tear loadouts, interleaved owners, age/tint/flag composition and controls")
