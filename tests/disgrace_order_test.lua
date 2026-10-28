-- Disgrace Loop must react only to a hit that ordinary shields let through,
-- like You're Absolutely Right! (docs/CHARM_DAMAGE_ORDER.md). Real Disgrace
-- Loop, Constitution, backlog common, Sold Out and Red Stamp modules, with
-- priority/short-circuit dispatch. No native health or freeze timing.
local root = arg[1]
local Env = dofile(root .. "/tests/lib/backlog_env.lua")
local source = assert(io.open(root .. "/main.lua", "r"))
local main = source:read("*a"); source:close()
local constitution = assert(main:find('include("scripts.items.constitution"):Init', 1, true))
local disgrace = assert(main:find('include("scripts.items.disgrace_loop"):Init', 1, true))
local backlog = assert(main:find('include("scripts.items.backlog.common")', 1, true))
assert(constitution < disgrace and disgrace < backlog, "fixture must match relative main.lua registration order")

local env = Env.New(root)
CallbackPriority = { EARLY = -100, DEFAULT = 0, LATE = 100 }
DamageFlag.DAMAGE_IV_BAG, DamageFlag.DAMAGE_RED_HEARTS = 1 << 18, 1 << 5
function env.mod:AddPriorityCallback(id, priority, fn, filter)
    env.callbacks[#env.callbacks + 1] = { id = id, priority = priority, fn = fn, filter = filter, order = #env.callbacks + 1 }
end
function env.mod:AddCallback(id, fn, filter) self:AddPriorityCallback(id, 0, fn, filter) end
function env.fire(id, filter, ...)
    local selected = {}
    for _, cb in ipairs(env.callbacks) do
        if cb.id == id and (cb.filter == nil or cb.filter == filter) then selected[#selected + 1] = cb end
    end
    table.sort(selected, function(a, b)
        if a.priority == b.priority then return a.order < b.order end
        return a.priority < b.priority
    end)
    local result
    for _, cb in ipairs(selected) do
        local value = cb.fn(env.mod, ...)
        if value ~= nil then
            result = value
            if id == "MC_ENTITY_TAKE_DMG" then return value end
        end
    end
    return result
end

local p, q = env.player(300), env.player(350)
local TRINKET = 190
for _, player in ipairs({ p, q }) do
    player.trinkets = { [TRINKET] = true }
    function player:HasTrinket(id) return self.trinkets[id] == true end
end
include("scripts.items.constitution"):Init(env.mod, env.Risk)
include("scripts.items.disgrace_loop"):Init(env.mod)
env.load() -- Real common, Red Stamp and Sold Out, then GAME_STARTED.

local function captions()
    local count = 0
    for _, title in ipairs(env.captions) do if title == "I am a disgrace" then count = count + 1 end end
    return count
end

-- Sold Out blocks a bullet: no freeze, and the room's reaction is not spent.
env.newRoom()
local shooter = env.npc(310)
assert(env.use(env.Item.SOLD_OUT, p).Discharge and env.C.Guards(p) == 1)
local before = captions()
assert(env.hitPlayer(p, env.bullet(305, 0, shooter)) == false, "Sold Out must still block the bullet")
assert(shooter.frozen == nil and captions() == before, "a blocked bullet must not freeze enemies")
assert(env.hitPlayer(p, env.bullet(305, 0, shooter)) == nil)
assert(shooter.frozen == 45 and captions() == before + 1, "the next real hit in the room still reacts once")

-- Red Stamp blocks contact for its holder: no freeze, reaction not spent.
env.newRoom()
local contact = env.npc(310)
assert(env.use(env.Item.RED_STAMP, q).Discharge)
assert(env.hitPlayer(q, contact) == false and contact.frozen == nil, "stamped contact must not freeze enemies")
env.frame = 121
assert(env.hitPlayer(q, contact) == nil and contact.frozen == 45, "expired stamp allows the reaction")

-- Ordinary controls: once per room per player, flag filter unchanged.
env.newRoom()
local watcher = env.npc(310)
assert(env.hitPlayer(p, watcher, DamageFlag.DAMAGE_NO_PENALTIES) == nil and watcher.frozen == nil)
assert(env.hitPlayer(p, watcher) == nil and watcher.frozen == 45)
watcher.frozen = nil
assert(env.hitPlayer(p, watcher) == nil and watcher.frozen == nil, "once per room for the same player")
assert(env.hitPlayer(q, watcher) == nil and watcher.frozen == 45, "the other holder reacts separately")

-- A new run clears the room set even if no room callback arrives first.
watcher.frozen = nil
env.fire("MC_PRE_GAME_EXIT", nil, true)
env.fire("MC_POST_GAME_STARTED", nil, true)
assert(env.hitPlayer(p, watcher) == nil and watcher.frozen == 45, "restart must not keep the previous room's reaction")
print("OK: Disgrace Loop follows ordinary shields; once per room/player, flag filter and run reset")
