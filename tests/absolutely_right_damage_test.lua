-- Real charm and shield modules, with documented priority/short-circuit dispatch.
-- No health loss or native status-effect timing is simulated as acceptance.
local root, mode = arg[1], arg[2] or "all"
local Env = dofile(root .. "/tests/lib/backlog_env.lua")
local function wanted(group) return mode == "all" or mode == group end
local source = assert(io.open(root .. "/main.lua", "r"))
local main = source:read("*a"); source:close()
local constitution = assert(main:find('include("scripts.items.constitution"):Init', 1, true))
local charm = assert(main:find('include("scripts.items.absolutely_right"):Init', 1, true))
local backlog = assert(main:find('include("scripts.items.backlog.common")', 1, true))
assert(constitution < charm and charm < backlog, "fixture must match relative main.lua registration order")

for _, charmSetsFriendly in ipairs({false, true}) do
    local env = Env.New(root)
    CallbackPriority = { EARLY=-100, DEFAULT=0, LATE=100 }
    DamageFlag.DAMAGE_IV_BAG, DamageFlag.DAMAGE_RED_HEARTS = 1 << 18, 1 << 5
    local externalPriority, externalReturn
    function env.mod:AddPriorityCallback(id, priority, fn, filter)
        env.callbacks[#env.callbacks + 1] = { id=id, priority=priority, fn=fn,
            filter=filter, order=#env.callbacks + 1 }
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
    -- A supplied earlier veto and a later veto expose the observer's limits.
    for _, priority in ipairs({-100, 200}) do
        local at = priority
        env.mod:AddPriorityCallback("MC_ENTITY_TAKE_DMG", priority, function()
            if externalPriority == at then return externalReturn end
        end, EntityType.ENTITY_PLAYER)
    end
    local p, q = env.player(300), env.player(350)
    include("scripts.items.constitution"):Init(env.mod, env.Risk)
    include("scripts.items.absolutely_right"):Init(env.mod)
    env.load() -- Real common, Red Stamp and Sold Out, then GAME_STARTED.
    env.give(p, "ABSOLUTELY_RIGHT"); env.give(q, "ABSOLUTELY_RIGHT")
    local function enemy(opts)
        local npc = env.npc(310, opts)
        npc.charms = {}
        function npc:AddCharmed(ref, frames)
            self.charms[#self.charms + 1] = { owner=ref.Entity, frames=frames }
            -- Run both models; the cancelled-hit defect must not depend on
            -- guessing whether the native charm updates FLAG_FRIENDLY immediately.
            if charmSetsFriendly then self.flags = self.flags | EntityFlag.FLAG_FRIENDLY end
        end
        return npc
    end
    local function captions()
        local count = 0
        for _, title in ipairs(env.captions) do if title == "You're absolutely right!" then count=count+1 end end
        return count
    end
    local function charmed(npc, owner, label)
        assert(#npc.charms == 1 and npc.charms[1].owner == owner and npc.charms[1].frames == 150, label)
    end
    local function fresh()
        env.newRoom(); env.frame=0
        externalPriority, externalReturn = nil, nil
    end

    if wanted("shields") then
        fresh()
        local shooter = enemy()
        assert(env.use(env.Item.SOLD_OUT, p).Discharge and env.C.Guards(p) == 1)
        local bullet, before = env.bullet(305, 0, shooter), captions()
        assert(env.hitPlayer(p, bullet) == false and not bullet:Exists(), "Sold Out must still block/remove the bullet")
        assert(#shooter.charms == 0 and captions() == before, "a guarded bullet must not charm its shooter")
        assert(env.C.Guards(p) == 0, "the blocked bullet consumes exactly one guard")
        local nextBullet = env.bullet(305, 0, shooter)
        assert(env.hitPlayer(p, nextBullet) == nil and nextBullet:Exists())
        charmed(shooter, p, "next unguarded hit retains charm")

        fresh()
        local contact = enemy(); before = captions()
        assert(env.use(env.Item.RED_STAMP, q).Discharge)
        assert(env.hitPlayer(p, contact) == false and env.hitPlayer(q, contact) == false)
        assert(#contact.charms == 0 and captions() == before, "stamped contact must not charm for either holder")
        env.frame=121
        assert(env.hitPlayer(q, contact) == nil)
        charmed(contact, q, "expired stamp allows the normal reaction")

        fresh()
        local guarded, unguarded = enemy(), enemy()
        assert(env.use(env.Item.SOLD_OUT, p).Discharge)
        assert(env.hitPlayer(q, env.bullet(345, 0, unguarded)) == nil)
        charmed(unguarded, q, "another holder does not borrow the guard")
        assert(env.C.Guards(p) == 1)
        assert(env.hitPlayer(p, env.bullet(305, 0, guarded)) == false and #guarded.charms == 0)

        fresh()
        local protected = enemy(); before = captions()
        env.give(p, "CONSTITUTION")
        assert(env.use(env.Item.SOLD_OUT, p).Discharge)
        assert(env.hitPlayer(p, protected) == false and #protected.charms == 0)
        assert(env.C.Guards(p) == 1, "Constitution does not spend the bullet guard")
        assert(env.hitPlayer(p, env.bullet(305, 0, protected)) == false and #protected.charms == 0)
        assert(env.C.Guards(p) == 0 and captions() == before)
        assert(env.hitPlayer(p, protected) == nil)
        charmed(protected, p, "ordinary hit after both shields still reacts")
        p.items[env.Item.CONSTITUTION] = nil
    end

    if wanted("ordinary") then
        fresh()
        for _, projectile in ipairs({false, true}) do
            local attacker, before = enemy(), captions()
            assert(env.hitPlayer(p, projectile and env.bullet(305, 0, attacker) or attacker) == nil)
            charmed(attacker, p, "eligible contact/projectile preserves source, duration and owner")
            assert(captions() == before + 1, "one reaction caption")
        end
        for _, opts in ipairs({{boss=true}, {friendly=true}}) do
            local ineligible, before = enemy(opts), captions()
            assert(env.hitPlayer(p, ineligible) == nil)
            assert(#ineligible.charms == 0 and captions() == before, "boss/friendly exclusion remains")
        end
        local nonholder, before = enemy(), captions()
        q.items[env.Item.ABSOLUTELY_RIGHT] = nil
        assert(env.hitPlayer(q, nonholder) == nil and #nonholder.charms == 0)
        env.give(q, "ABSOLUTELY_RIGHT")
        assert(env.hitPlayer(p, nil) == nil and env.hitPlayer(p, env.bullet(305, 0, nil)) == nil)
        assert(captions() == before, "missing source/non-holder produces no caption")
    end

    if wanted("flags") then
        fresh()
        -- Preserve existing beneficial-proc semantics; this priority fix does
        -- not turn damage-penalty exclusions into new charm eligibility rules.
        for _, flags in ipairs({DamageFlag.DAMAGE_FAKE, DamageFlag.DAMAGE_NO_PENALTIES,
                DamageFlag.DAMAGE_FAKE | DamageFlag.DAMAGE_NO_PENALTIES,
                DamageFlag.DAMAGE_IV_BAG, DamageFlag.DAMAGE_RED_HEARTS}) do
            local attacker = enemy()
            assert(env.hitPlayer(p, attacker, flags) == nil)
            charmed(attacker, p, "supplied eligible enemy source keeps the existing flag behavior")
        end
    end

    if wanted("limits") then
        fresh()
        local earlier, before = enemy(), captions()
        externalPriority, externalReturn = -100, false
        assert(env.hitPlayer(p, earlier) == false and #earlier.charms == 0 and captions() == before)
        externalReturn = true
        assert(env.hitPlayer(p, earlier) == true and #earlier.charms == 0,
            "an earlier non-nil allow result also stops later callbacks")
        externalPriority, externalReturn = 200, false
        local later = enemy()
        assert(env.hitPlayer(p, later) == false)
        charmed(later, p, "a veto after LATE is still beyond this pre-damage observer")
    end
end
print("OK: charm follows ordinary shields; source/owner/duration/flags retained; later-veto limits explicit (" .. mode .. ")")
