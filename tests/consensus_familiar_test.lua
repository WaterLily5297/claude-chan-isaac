-- Real backlog callbacks with direct familiar/weapon relationships. This fixture
-- does not establish which relationship native familiars populate in the engine.
local root = assert(arg[1])
local Env = dofile(root .. "/tests/lib/backlog_env.lua")
local passed = 0
local function test(name, fn)
    local ok, err = pcall(fn)
    assert(ok, name .. ": " .. tostring(err))
    passed = passed + 1
end
local function near(a, b)
    assert(type(a) == "number" and math.abs(a - b) < 1e-8, tostring(a) .. " ~= " .. b)
end
local function fresh()
    local env = Env.New(root)
    local p, q = env.player(), env.player()
    env.load()
    env.give(p, "CONSENSUS_COIN")
    env.give(q, "CONSENSUS_COIN")
    return env, p, q
end
local callbacks = { tear = "MC_POST_FIRE_TEAR", laser = "MC_POST_LASER_UPDATE",
    knife = "MC_POST_KNIFE_UPDATE", bomb = "MC_POST_BOMB_UPDATE" }
local types = { tear = 2, laser = 7, knife = 8, bomb = 4 }
local serial = 10000
local function weapon(env, kind, owner, relation)
    serial = serial + 1
    local e = { hash = serial, Type = types[kind], FrameCount = 1, data = {}, IsFetus = kind == "bomb" }
    e[relation or "SpawnerEntity"] = owner
    function e:ToPlayer() end
    function e:ToFamiliar() end
    function e:ToNPC() end
    function e:GetData() return self.data end
    function e:IsFlying() return true end
    function e:Exists() return true end
    env.fire(callbacks[kind], nil, e)
    return e
end

test("familiar weapons count without consuming player primes or attack leases", function()
    for _, kind in ipairs({ "tear", "laser", "knife", "bomb" }) do
        for _, relation in ipairs({ "SpawnerEntity", "Parent" }) do
            local env, p = fresh()
            local target = env.npc(50)
            local familiar = env.familiar(p)
            local attacks, hits = 0, {}
            env.C.On("attack", function() attacks = attacks + 1 end)
            env.C.On("hit", function(_, owner, hitKind, id)
                hits[#hits + 1] = { owner = owner, kind = hitKind, id = id }
            end)
            env.C.Prime(p, "audit", 2)
            local source = weapon(env, kind, familiar, relation)
            target:TakeDamage(2, 0, EntityRef(source))
            env.update()
            assert(#hits == 1 and hits[1].owner == p and hits[1].kind == "familiar"
                and hits[1].id == nil, kind .. " / " .. relation .. " must be familiar damage without a lease")
            assert(attacks == 0 and env.C.LastAttack(p) == nil and env.C.Primed(p, "audit"),
                "familiar weapons must not spend or begin the player's attack")
            near(target.damage[1], 2)
            env.shoot(p, target)
            env.update()
            assert(attacks == 1 and not env.C.Primed(p, "audit"))
            near(target.damage[2], 7)
            near(target.damage[3], 1.75)
            target:TakeDamage(2, 0, EntityRef(source))
            env.shoot(p, target)
            env.update()
            assert(#target.damage == 5, "Consensus must pulse only once per target")
        end
    end
end)

test("all familiar contact and weapon shapes are one source category", function()
    local env, p = fresh()
    local target = env.npc(50)
    target:TakeDamage(2, 0, EntityRef(env.familiar(p)))
    for _, kind in ipairs({ "tear", "laser", "knife", "bomb" }) do
        local familiar = env.familiar(p)
        for _, relation in ipairs({ "SpawnerEntity", "Parent" }) do
            target:TakeDamage(2, 0, EntityRef(weapon(env, kind, familiar, relation)))
            env.update()
        end
    end
    assert(#target.damage == 9, "two different familiars or weapons must not fabricate mixed sources")
    env.shoot(p, target)
    env.update()
    near(target.damage[11], 1.75)
end)

test("mixed-source history is isolated by owner and target", function()
    local env, p, q = fresh()
    local a, b = env.npc(50), env.npc(70)
    env.shoot(p, a)
    a:TakeDamage(2, 0, EntityRef(weapon(env, "tear", env.familiar(q))))
    env.update()
    assert(#a.damage == 2, "another owner's familiar cannot complete p's history")
    b:TakeDamage(2, 0, EntityRef(weapon(env, "tear", env.familiar(p))))
    env.update()
    assert(#b.damage == 1, "another target cannot complete a's history")
    a:TakeDamage(2, 0, EntityRef(weapon(env, "laser", env.familiar(p))))
    env.update()
    near(a.damage[4], 1.75)
    env.shoot(q, a)
    env.update()
    near(a.damage[6], 1.75)
    env.shoot(p, b)
    env.update()
    near(b.damage[3], 1.75)
end)

test("direct owner precedence stays bounded to one relationship", function()
    local env, p, q = fresh()
    local familiar = env.familiar(p)
    familiar.Parent = q
    local owner, fromFamiliar = env.C.Owner(familiar)
    assert(owner == p and fromFamiliar, "the familiar's own player wins")
    local source = weapon(env, "tear", familiar)
    source.Parent = q
    owner, fromFamiliar = env.C.Owner(source)
    assert(owner == p and fromFamiliar, "a familiar spawner wins over a player parent")
    local direct = weapon(env, "tear", q)
    direct.Parent = familiar
    owner, fromFamiliar = env.C.Owner(direct)
    assert(owner == q and not fromFamiliar, "a player spawner wins over a familiar parent")
    local orphan = env.familiar(nil)
    orphan.Parent = p
    assert(env.C.Owner(orphan) == nil, "unowned familiar contact must not borrow its parent")
    local orphanShot = weapon(env, "tear", orphan)
    orphanShot.Parent = p
    assert(env.C.Owner(orphanShot) == nil, "unowned familiar shots must not borrow their parent")
    local parentOnly = weapon(env, "tear", familiar, "Parent")
    parentOnly.SpawnerEntity = weapon(env, "tear", nil)
    owner, fromFamiliar = env.C.Owner(parentOnly)
    assert(owner == p and fromFamiliar, "unknown spawners retain direct-parent fallback")
    local indirect = weapon(env, "tear", source, "Parent")
    assert(env.C.Owner(indirect) == nil, "do not recursively guess ownership through weapons")
end)

test("unknown, contact and derived hits do not complete Consensus", function()
    local env, p = fresh()
    local target = env.npc(50)
    target:TakeDamage(2, 0, EntityRef(env.familiar(p)))
    target:TakeDamage(2, 0, EntityRef(weapon(env, "tear", nil)))
    target:TakeDamage(2, 0, EntityRef(p))
    local unknown = weapon(env, "tear", nil)
    unknown.Parent = p -- Identifiable owner, but no observed player attack lease.
    target:TakeDamage(2, 0, EntityRef(unknown))
    env.C.Prime(p, "audit", 2)
    local derived = env.C.FireDerived(p, Vector(1, 0), 1)
    target:TakeDamage(2, 0, EntityRef(derived))
    env.update()
    assert(#target.damage == 5 and env.C.Primed(p, "audit"), "excluded hits must not pulse or spend primes")
    env.shoot(p, target)
    env.update()
    near(target.damage[6], 7)
    near(target.damage[7], 1.75)
end)

test("native player weapon leases keep their source categories and bonuses", function()
    for _, kind in ipairs({ "tear", "laser", "knife", "bomb" }) do
        local env, p = fresh()
        local target = env.npc(50)
        local observed
        env.C.On("hit", function(_, _, hitKind) observed = hitKind end)
        env.C.Prime(p, "audit", 2)
        target:TakeDamage(2, 0, EntityRef(weapon(env, kind, p)))
        assert(observed == kind and not env.C.Primed(p, "audit"))
        near(target.damage[1], 4)
        target:TakeDamage(2, 0, EntityRef(env.familiar(p)))
        env.update()
        near(target.damage[3], 1.75)
    end
end)

print("PASS Consensus familiar sources: " .. passed .. " callback groups")
