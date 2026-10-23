-- Exercise real character and Swarm callbacks in the entry point's registration order.
local root = arg[1]
function include(name) return dofile(root .. "/" .. name:gsub("%.", "/") .. ".lua") end
ModCallbacks = setmetatable({}, { __index = function(_, key) return key end })
CallbackPriority = { DEFAULT = 0, LATE = 1000 }
CacheFlag = {}
ActiveSlot = { SLOT_POCKET = 2 }
EntityType = { ENTITY_TEAR = 2 }
function Color(...) return {...} end

local callbacks = {}
local mod = {}
function mod:AddPriorityCallback(id, priority, fn, param)
    callbacks[#callbacks + 1] = {id = id, priority = priority, fn = fn, param = param, order = #callbacks + 1}
end
function mod:AddCallback(id, fn, param) self:AddPriorityCallback(id, 0, fn, param) end
local function fire(id, ...)
    local selected = {}
    for _, cb in ipairs(callbacks) do if cb.id == id then selected[#selected + 1] = cb end end
    table.sort(selected, function(a, b)
        if a.priority == b.priority then return a.order < b.order end
        return a.priority < b.priority
    end)
    for _, cb in ipairs(selected) do cb.fn(mod, ...) end
end

local frame, roll, enemies = 0, 0.99, 0
local spawned = {}
local function player(kind, swarm)
    local p = {kind = kind, swarm = swarm, data = {}}
    function p:ToPlayer() return self end
    function p:GetPlayerType() return self.kind end
    function p:GetData() return self.data end
    function p:HasCollectible(id) return id == 745 and self.swarm end
    function p:SetPocketActiveItem() end
    return p
end
local deepseek, claude = player(42, true), player(41, true)
Isaac = {
    GetItemIdByName = function(name)
        return ({["Subagent Swarm"] = 745, ["Lunch Break"] = 749, ["Ban Hammer"] = 733})[name] or -1
    end,
    GetPlayerTypeByName = function(name, tainted)
        return (name == "DeepSeek-chan" and 42 or 41) + (tainted and 100 or 0)
    end,
    GetTrinketIdByName = function() return -1 end,
    GetPillEffectByName = function() return -1 end,
    GetPlayer = function(i) return i == 0 and deepseek or claude end,
    CountEnemies = function() return enemies end,
    Spawn = function(_, _, _, _, velocity, owner)
        local t = {Velocity = velocity, SpawnerEntity = owner, TearFlags=0,
            Scale=1, Height=-10, FallingSpeed=0, FallingAcceleration=0.5,
            HomingFriction=0, KnockbackMultiplier=1}
        function t:ToTear() return self end
        function t:ResetSpriteScale() self.spriteScale=self.Scale end
        spawned[#spawned + 1] = t
        return t
    end,
}
function RNG() return {SetSeed = function() end, RandomFloat = function() return roll end} end
function Game() return {
    GetFrameCount = function() return frame end,
    GetNumPlayers = function() return 2 end,
    GetSeeds = function() return {GetStartSeed = function() return 123 end} end,
    GetHUD = function() return {ShowItemText = function() end} end,
} end
local risk = {state = {}}
function risk:IsSuspended() return false end
include("scripts.items.subagent_swarm"):Init(mod)
include("scripts.characters.claude_chan"):Init(mod, risk)
include("scripts.characters.claude_chan_b"):Init(mod, risk)
include("scripts.characters.deepseek_chan"):Init(mod, risk)
fire("MC_POST_GAME_STARTED", false)

local function shot(owner)
    spawned = {}
    local t = {SpawnerEntity = owner, CollisionDamage = 4, Color = "natural", Scale = 1,
        TearFlags=0, Height=-10, FallingSpeed=0, FallingAcceleration=0.5,
        HomingFriction=0, KnockbackMultiplier=1,
        Variant = 0, Position = {}, Velocity = {Rotated = function(_, angle) return angle end}}
    function t:Remove() self.removed = true end
    function t:Exists() return not self.removed end
    fire("MC_POST_FIRE_TEAR", t)
    return t
end

-- Baseline spawns two Swarm tears before DeepSeek removes the natural tear.
enemies, roll = 10, 0.1
local cancelled = shot(deepseek)
assert(cancelled.removed, "the busy roll must cancel the natural tear")
assert(#spawned == 0, "a busy shot must not leave Subagent Swarm tears behind")
deepseek.kind = 142
shot(deepseek)
assert(#spawned == 0, "a busy tainted shot must cancel both character forks and Swarm")
deepseek.kind = 42

enemies, roll, frame = 0, 0.99, 150
local thought = shot(deepseek)
assert(thought.CollisionDamage == 8, "Deep Think must resolve before inspecting child damage")
assert(#spawned == 2 and spawned[1].CollisionDamage == 4 and spawned[2].CollisionDamage == 4,
    "Swarm tears must deal half the resolved Deep Think damage")
assert(spawned[1].Velocity == -15 and spawned[2].Velocity == 15, "keep the two-shot fan")
assert(spawned[1].SpawnerEntity == deepseek, "keep the owner")
deepseek.kind = 142
shot(deepseek)
assert(#spawned == 4, "tainted forks and Swarm add two each without recursive growth")
deepseek.kind = 42

claude.data.ccUsage = {value = 100, limited = 90}
local limited = shot(claude)
assert(limited.CollisionDamage == 1.6)
assert(#spawned == 2 and spawned[1].CollisionDamage == 0.8,
    "Swarm tears must not bypass Claude's limited damage")
assert(spawned[1].Color == limited.Color, "children use the resolved parent color")
assert(claude.data.ccUsage.limited == 90, "Swarm must not restart an active limit")
claude.kind = 141
risk.state.weeklyUsed = 220
local weekly = shot(claude)
assert(weekly.CollisionDamage == 1 and spawned[1].CollisionDamage == 0.5,
    "Swarm tears must respect the tainted weekly limit")
assert(risk.state.weeklyUsed == 220, "generated tears must not consume another weekly shot")

claude.kind = 41
claude.data.ccUsage = {value = 0, limited = 0}
local ordinary = shot(claude)
assert(ordinary.CollisionDamage == 4 and spawned[1].CollisionDamage == 2)
assert(claude.data.ccUsage.value == 8, "keep the existing double-usage accounting")
deepseek.swarm = false
shot(deepseek)
assert(#spawned == 0, "another player's Swarm must not leak to a non-holder")
shot({ToPlayer = function() return nil end})
assert(#spawned == 0, "ignore a non-player spawner")

-- Engine item effects are already present on the natural tear. Use unusual
-- flight values and a high-bit flag so defaults or a truncated mask cannot pass.
local function effectShot(owner)
    spawned={}
    local original={SpawnerEntity=owner, Variant=7, Position={},
        Velocity={Rotated=function(_,a) return a end}, CollisionDamage=10, Color='modified',
        TearFlags=(1 << 1) | (1 << 3) | (1 << 4) | (1 << 52),
        Scale=1.7, Height=-27, FallingSpeed=-4.5, FallingAcceleration=0.17,
        HomingFriction=0.08, KnockbackMultiplier=1.4}
    function original:Exists() return not self.removed end
    function original:Remove() self.removed=true end
    fire('MC_POST_FIRE_TEAR',original)
    return original
end
local function inherited(original, count)
    assert(#spawned==count, 'inheritance must not change the fan size')
    for _,child in ipairs(spawned) do
        assert(child.TearFlags==original.TearFlags, 'fork loses native tear effects')
        assert(child.Scale==original.Scale and child.spriteScale==original.Scale,
            'fork must display the resolved parent size')
        assert(child.Height==original.Height and child.FallingSpeed==original.FallingSpeed
            and child.FallingAcceleration==original.FallingAcceleration, 'fork loses the flight arc')
        assert(child.HomingFriction==original.HomingFriction
            and child.KnockbackMultiplier==original.KnockbackMultiplier, 'fork loses effect parameters')
        assert(child.CollisionDamage==original.CollisionDamage*0.5 and child.Color==original.Color)
        assert(child.SpawnerEntity==original.SpawnerEntity, 'fork owner must remain unchanged')
    end
end
claude.kind=0; claude.swarm=true
local vanilla=effectShot(claude); inherited(vanilla,2)
assert(vanilla.Scale==1.7 and vanilla.CollisionDamage==10, 'fork must not mutate its parent')
deepseek.kind=142; deepseek.swarm=false
inherited(effectShot(deepseek),2)
deepseek.swarm=true; inherited(effectShot(deepseek),4)
deepseek.kind=42; frame=300
local boosted=effectShot(deepseek); assert(boosted.Scale==2.55); inherited(boosted,2)
enemies,roll=10,0.1
local blocked=effectShot(deepseek); assert(blocked.removed and #spawned==0)
print("OK: Swarm shot resolution, player isolation and resolved fork effects/flight")
