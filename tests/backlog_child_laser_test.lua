-- Real backlog listeners and damage callbacks with explicit laser ancestry.
-- Callback order and entity fields are stub inputs, not native engine evidence.
local root = assert(arg[1])
local Env = dofile(root .. "/tests/lib/backlog_env.lua")
local passed, failures = 0, {}
local function test(name, fn)
    if arg[2] and not name:find(arg[2], 1, true) then return end
    local ok, err = pcall(fn)
    if ok then passed = passed + 1 else failures[#failures + 1] = name .. ": " .. tostring(err) end
end
local function near(a, b) assert(math.abs(a - b) < 1e-8, tostring(a) .. " != " .. tostring(b)) end
local function fresh()
    local env = Env.New(root)
    EntityType.ENTITY_LASER = 7
    local p, q = env.player(0), env.player(20)
    env.load()
    env.attacks, env.hits = {}, {}
    env.C.On("attack", function(owner, kind, entity, id)
        env.attacks[#env.attacks + 1] = { owner = owner, kind = kind, entity = entity, id = id }
    end)
    env.C.On("hit", function(_, owner, kind, id, amount)
        env.hits[#env.hits + 1] = { owner = owner, kind = kind, id = id, amount = amount }
    end)
    local serial = 0
    function env.laser(spawner, parent)
        serial = serial + 1
        local laser = { hash = -serial, Type = EntityType.ENTITY_LASER, FrameCount = 1,
            SpawnerEntity = spawner, Parent = parent, data = {}, alive = true,
            CollisionDamage = 2, Timeout = 40, Radius = 30, TearFlags = 17,
            Position = Vector(10, 15), Velocity = Vector(2, 3) }
        function laser:ToPlayer() end
        function laser:ToFamiliar() end
        function laser:ToNPC() end
        function laser:GetData() return self.data end
        function laser:Exists() return self.alive end
        function laser:Remove() self.alive = false end
        return laser
    end
    function env.observe(laser, advance)
        env.frame = env.frame + (advance or 1)
        env.fire("MC_POST_LASER_UPDATE", nil, laser)
    end
    function env.hit(target, laser)
        target:TakeDamage(laser.CollisionDamage, 0, EntityRef(laser))
        return target.damage[#target.damage], env.hits[#env.hits]
    end
    return env, p, q
end
local function native(laser, spawner, parent)
    assert(laser:Exists() and laser.Type == EntityType.ENTITY_LASER)
    assert(laser.SpawnerEntity == spawner and laser.Parent == parent)
    assert(laser.CollisionDamage == 2 and laser.Timeout == 40 and laser.Radius == 30 and laser.TearFlags == 17)
    assert(laser.Position == Vector(10, 15) and laser.Velocity == Vector(2, 3), "native laser fields changed")
end

test("children share the resolved multiplier without consuming primes or Finger events", function()
    local env, p = fresh()
    local target = env.npc(60, { hp = 1000 })
    env.give(p, "ONE_MORE_FINGER")
    for _ = 1, 3 do env.observe(env.laser(p)) end
    env.C.Prime(p, "parent", 2)
    local parent = env.laser(p)
    env.observe(parent)
    local parentFrame, id = env.frame, env.attacks[4].id
    near(env.hit(target, parent), 4)
    env.C.Prime(p, "next", 3)
    for _, delay in ipairs({ 0, 5 }) do
        local child = env.laser(p, parent)
        env.observe(child, delay)
        local amount, hit = env.hit(target, child)
        near(amount, 4)
        assert(hit.id == id and hit.kind == "laser" and hit.owner == p)
        assert(env.C.Primed(p, "next") and #env.attacks == 4 and env.C.Data(p).fingers == 4)
        assert(env.C.LastAttack(p) == parentFrame, "child must not start a new attack clock")
        native(child, p, parent)
    end
    env.update()
    assert(#p.fired == 0, "children must not schedule Finger's fifth-shot helper")
    local primary = env.laser(p)
    env.observe(primary)
    near(env.hit(target, primary), 6)
    assert(not env.C.Primed(p, "next") and #env.attacks == 5 and env.C.Data(p).fingers == 0)
    env.update()
    assert(#p.fired == 1 and p.fired[1].mult == 0.3, "next independent primary still schedules Finger")
end)

test("parent and delayed child hits share Sanity and Community Note progress", function()
    local env, p = fresh()
    local target = env.npc(60, { hp = 1000 })
    env.give(p, "COMMUNITY_NOTE")
    assert(env.use(env.Item.SANITY_TEST, p).Discharge)
    local parents = {}
    for attack = 1, 2 do
        local parent = env.laser(p)
        parents[attack] = parent
        env.observe(parent)
        near(env.hit(target, parent), 2)
        for _ = 1, 2 do
            local child = env.laser(p, parent)
            env.observe(child)
            near(env.hit(target, child), 2)
            assert(env.C.Data(p).room.sanity.count == attack, "children are not distinct Sanity hits")
        end
    end
    local oldChild = env.laser(p, parents[1])
    env.observe(oldChild)
    near(env.hit(target, oldChild), 2) -- Two parent identities cannot expose the target.
    local third = env.laser(p)
    env.observe(third)
    near(env.hit(target, third), 2)
    assert(env.C.Data(p).room.sanity == nil, "third independent primary must complete Sanity")
    near(env.hit(target, oldChild), 2.3) -- Community Note now exposes it.
    local before = #target.damage
    env.update()
    assert(#target.damage == before + 1, "Sanity schedules exactly one pulse")
    near(target.damage[#target.damage], p.Damage * 3)
    assert(#env.attacks == 3)
end)

test("delayed children retain the original inclusive lease expiry", function()
    local env, p = fresh()
    local target = env.npc(60, { hp = 1000 })
    env.frame = 10
    env.C.Prime(p, "parent", 2)
    local parent = env.laser(p)
    env.observe(parent, 0)
    env.C.Prime(p, "next", 3)
    env.frame = 129
    local child = env.laser(p, parent)
    env.observe(child, 0)
    near(env.hit(target, child), 4)
    env.frame = 130
    near(env.hit(target, child), 4)
    env.frame = 131
    local amount, hit = env.hit(target, child)
    near(amount, 2); assert(hit.id == nil and hit.kind == "other")
    local lateChild = env.laser(p, parent)
    env.observe(lateChild, 0)
    near(env.hit(target, lateChild), 2)
    assert(#env.attacks == 1 and env.C.Primed(p, "next"), "expired parent cannot create or renew a lease")
    local nextPrimary = env.laser(p)
    env.observe(nextPrimary)
    near(env.hit(target, nextPrimary), 6)
    assert(#env.attacks == 2 and not env.C.Primed(p, "next"))
end)

test("child-first nested lasers resolve only after the parent attack exists", function()
    local env, p = fresh()
    local target = env.npc(60, { hp = 1000 })
    local parent = env.laser(p)
    local child = env.laser(parent, parent)
    local grandchild = env.laser(child, child)
    env.C.Prime(p, "parent", 2)
    env.observe(grandchild)
    env.observe(child)
    near(env.hit(target, grandchild), 2)
    assert(#env.attacks == 0 and env.C.Primed(p, "parent"), "child-first updates must not synthesize the parent")
    env.observe(parent)
    env.C.Prime(p, "next", 3)
    local amount, hit = env.hit(target, grandchild) -- No second child update.
    near(amount, 4)
    assert(hit.owner == p and hit.kind == "laser" and hit.id == env.attacks[1].id)
    near(env.hit(target, child), 4)
    assert(#env.attacks == 1 and env.C.Primed(p, "next"))
    native(child, parent, parent); native(grandchild, child, child)
end)

test("resolved child survives parent removal but room and run resets clear leases", function()
    for _, reset in ipairs({ "room", "run" }) do
        local env, p = fresh()
        local target = env.npc(60, { hp = 1000 })
        env.C.Prime(p, "parent", 2)
        local parent = env.laser(p)
        env.observe(parent)
        local child = env.laser(p, parent)
        env.observe(child)
        parent:Remove()
        child.Parent = nil
        near(env.hit(target, child), 4)
        if reset == "room" then env.newRoom({ keep = true })
        else env.fire("MC_POST_GAME_STARTED", nil, false) end
        env.C.Prime(p, "next", 3)
        env.observe(child)
        local amount, hit = env.hit(target, child)
        near(amount, 2); assert(hit.id == nil)
        assert(env.C.Primed(p, "next"), reset .. " cleanup must not pay for the old child")
    end
end)

test("detached children preserve the resolved owner without lending bonuses to another player", function()
    for _, playerSpawner in ipairs({ true, false }) do
        local env, p, q = fresh()
        local target = env.npc(60, { hp = 1000 })
        env.C.Prime(p, "parent", 2)
        local parent = env.laser(p)
        env.observe(parent)
        local child = env.laser(playerSpawner and p or parent, parent)
        env.observe(child)
        local id = env.attacks[1].id
        parent:Remove(); child.Parent = nil
        env.C.Prime(p, "next", 4); env.C.Prime(q, "next", 3)
        env.observe(child)
        local amount, hit = env.hit(target, child)
        near(amount, 4)
        assert(hit.owner == p and hit.id == id and hit.kind == "laser")
        child.SpawnerEntity = q
        env.observe(child)
        amount, hit = env.hit(target, child)
        near(amount, 2)
        assert(hit.owner == q and hit.id == nil and hit.kind == "other")
        child.SpawnerEntity = env.familiar(q)
        amount, hit = env.hit(target, child)
        near(amount, 2); assert(hit.owner == q and hit.id == nil and hit.kind == "familiar")
        assert(#env.attacks == 1 and env.C.Primed(p, "next") and env.C.Primed(q, "next"))
    end
end)

test("missing spawners can use explicit parents but unrelated sources cannot borrow a lease", function()
    local env, p = fresh()
    local target = env.npc(60, { hp = 1000 })
    env.C.Prime(p, "parent", 2)
    local parent = env.laser(p)
    env.observe(parent)
    env.C.Prime(p, "next", 3)
    local child = env.laser(nil, parent)
    env.observe(child)
    local amount, hit = env.hit(target, child)
    near(amount, 4); assert(hit.owner == p and hit.id == env.attacks[1].id)
    local unknown = env.npc(400)
    local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, 0, 0, Vector.Zero, Vector.Zero, p)
    for _, source in ipairs({ unknown, effect, env.laser(p) }) do
        local rejected = env.laser(source, parent)
        env.observe(rejected)
        local before = #env.hits
        near(env.hit(target, rejected), 2)
        assert(#env.hits == before, "unrelated sources must not borrow parent ownership")
        native(rejected, source, parent)
    end
    assert(#env.attacks == 1 and env.C.Primed(p, "next"))
end)

test("a child can deliver the first parent hit while retaining the laser source category", function()
    local env, p = fresh()
    local target = env.npc(60, { hp = 1000 })
    env.give(p, "CONSENSUS_COIN")
    assert(env.use(env.Item.SANITY_TEST, p).Discharge)
    local parent = env.laser(p)
    env.observe(parent)
    local child = env.laser(parent, parent)
    env.observe(child)
    near(env.hit(target, child), 2)
    assert(env.C.Data(p).room.sanity.count == 1)
    near(env.hit(target, parent), 2)
    assert(env.C.Data(p).room.sanity.count == 1)
    local before = #target.damage
    env.update()
    assert(#target.damage == before, "parent and child lasers are only one Consensus category")
    env.frame = env.frame + 1
    local tear = env.tear(p)
    env.fire("MC_POST_FIRE_TEAR", nil, tear)
    target:TakeDamage(2, 0, EntityRef(tear))
    before = #target.damage
    env.update()
    assert(#target.damage == before + 1, "an independent tear combines with the inherited laser")
    near(target.damage[#target.damage], p.Damage * 0.5)
end)

test("foreign player and familiar ancestry cannot borrow the parent's lease", function()
    local env, p, q = fresh()
    local target = env.npc(60, { hp = 1000 })
    env.C.Prime(p, "parent", 2)
    local parent = env.laser(p)
    env.observe(parent)
    env.C.Prime(p, "next", 4); env.C.Prime(q, "next", 3)
    local foreign = env.laser(q, parent)
    env.observe(foreign)
    local amount, hit = env.hit(target, foreign)
    near(amount, 2); assert(hit.owner == q and hit.id == nil and hit.kind == "other")
    local familiar = env.familiar(p)
    local familiarChild = env.laser(familiar, parent)
    env.observe(familiarChild)
    amount, hit = env.hit(target, familiarChild)
    near(amount, 2); assert(hit.owner == p and hit.id == nil and hit.kind == "familiar")
    local nested = env.laser(foreign, foreign)
    env.observe(nested)
    near(env.hit(target, nested), 2)
    assert(#env.attacks == 1 and env.C.Primed(p, "next") and env.C.Primed(q, "next"))
    local ownPrimary = env.laser(q)
    env.observe(ownPrimary)
    near(env.hit(target, ownPrimary), 6)
    assert(#env.attacks == 2 and env.C.Primed(p, "next") and not env.C.Primed(q, "next"))
    native(foreign, q, parent); native(familiarChild, familiar, parent)
end)

test("unobserved parents and ancestry cycles remain unleased without paying", function()
    local env, p = fresh()
    local target = env.npc(60, { hp = 1000 })
    env.C.Prime(p, "next", 3)
    local unknown = env.laser(p)
    local child = env.laser(p, unknown)
    env.observe(child)
    local amount, hit = env.hit(target, child)
    near(amount, 2); assert(hit.id == nil and hit.kind == "other")
    local a = env.laser(p)
    local b = env.laser(p, a)
    a.Parent = b
    env.observe(a); env.observe(b)
    near(env.hit(target, a), 2); near(env.hit(target, b), 2)
    assert(#env.attacks == 0 and env.C.LastAttack(p) == nil and env.C.Primed(p, "next"))
    native(a, p, b); native(b, p, a)
end)

for _, failure in ipairs(failures) do print("FAIL " .. failure) end
assert(#failures == 0, tostring(#failures) .. " backlog child-laser groups failed")
print("PASS backlog child-laser leases: " .. passed .. " callback groups")
