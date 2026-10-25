-- Real Peak, paid-observer, Opus and backlog callbacks in main's order.
-- Explicit ancestry and callback timing are fixtures, not engine evidence.
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
    local nativeInclude, nativeGame = include, Game
    function include(name)
        if name == "scripts.hud_text" then return { Draw = function() end } end
        return nativeInclude(name)
    end
    function Game()
        local game = nativeGame()
        function game:IsPaused() return env.paused or false end
        return game
    end
    function Isaac.GetPlayerTypeByName(name, tainted)
        if name == "DeepSeek-chan" then return tainted and 142 or 42 end
        return -1
    end
    EntityType.ENTITY_LASER, EntityType.ENTITY_KNIFE, EntityType.ENTITY_BOMB = 7, 8, 4
    CollectibleType.COLLECTIBLE_BIRTHRIGHT = 619
    ButtonAction, Input = { ACTION_DROP = 11 }, { IsActionPressed = function() return false end }
    env.clear = true
    local p, q = env.player(0), env.player(20)
    for i, player in ipairs({ p, q }) do
        player.form, player.InitSeed, player.ControllerIndex, player.coins = 142, 100 + i, i - 1, 5
        function player:GetPlayerType() return self.form end
        function player:AreControlsEnabled() return true end
        function player:GetNumCoins() return self.coins end
        function player:AddCoins(n) self.coins = self.coins + n end
    end
    include("scripts.items.opus_mode"):Init(env.mod)
    env.load()
    include("scripts.characters.deepseek_peak"):Init(env.mod, env.Risk)
    env.fire("MC_POST_GAME_STARTED", nil, false)
    function env.state(i) return env.Risk.state.deepseekPeak[tostring(i or 0)] end
    local serial = 0
    function env.laser(spawner, parent, oneHit)
        serial = serial + 1
        local laser = { hash = -serial, Type = 7, FrameCount = 0, SpawnerEntity = spawner, Parent = parent,
            OneHit = oneHit or false, CollisionDamage = 10, Timeout = 40, Radius = 35, TearFlags = 17,
            Position = Vector(10, 15), Velocity = Vector(2, 3), data = {}, alive = true }
        function laser:GetData() return self.data end
        function laser:ToPlayer() end
        function laser:ToNPC() end
        function laser:ToFamiliar() end
        function laser:IsCircleLaser() return self.circle or false end
        function laser:Exists() return self.alive end
        function laser:Remove() self.alive = false end
        return laser
    end
    function env.init(laser, at)
        env.frame = at or env.frame
        env.fire("MC_POST_LASER_INIT", nil, laser)
    end
    function env.observe(laser, at, age)
        env.frame, laser.FrameCount = at or env.frame, age or laser.FrameCount
        env.fire("MC_POST_LASER_UPDATE", nil, laser)
    end
    local enemy = env.npc(80, { hp = 10000 })
    function env.hit(laser)
        local before = #enemy.damage
        enemy:TakeDamage(laser.CollisionDamage, 0, EntityRef(laser))
        assert(#enemy.damage == before + 1, "one native hit must apply damage exactly once")
        return enemy.damage[#enemy.damage]
    end
    return env, p, q
end
local function native(laser, spawner, parent)
    assert(laser:Exists() and laser.SpawnerEntity == spawner and laser.Parent == parent)
    assert(laser.Type == 7 and laser.CollisionDamage == 10 and laser.Timeout == 40 and laser.Radius == 35)
    assert(laser.TearFlags == 17 and laser.Position == Vector(10, 15) and laser.Velocity == Vector(2, 3))
end

test("delayed child starts share Valley and Peak payments while independent primaries pay", function()
    for phase, cost in pairs({ valley = 2, peak = 4 }) do
        local env, p = fresh()
        env.state().phase = phase
        local parent = env.laser(p, nil, true)
        env.init(parent, 1)
        assert(env.state().compute == 12 - cost)
        for _, frame in ipairs({ 1, 2, 9 }) do
            local child = env.laser(p, parent, true)
            env.init(child, frame); env.init(child)
            near(env.hit(child), 13)
            assert(env.state().compute == 12 - cost, "child charged Compute")
            native(child, p, parent)
        end
        local primary = env.laser(p, p, true)
        env.init(primary, 10)
        assert(env.state().compute == 12 - 2 * cost, "a non-laser Parent must remain a paid primary")
        near(env.hit(primary), 13)
    end
end)

test("a child inherits the resolved decision instead of current mode or affordability", function()
    for _, refused in ipairs({ "saving", "poor", "paid" }) do
        local env, p = fresh()
        env.state().saving = refused == "saving"
        if refused == "poor" then env.state().compute = 1 end
        local parent = env.laser(p, nil, true)
        env.init(parent, 1)
        env.state().saving = refused == "paid"
        env.state().phase, env.state().compute = "peak", 12
        local child = env.laser(p, parent, true)
        env.init(child, 2)
        near(env.hit(child), refused == "paid" and 13 or 10)
        assert(env.state().compute == 12, "a child cannot buy its own boost")
    end
end)

test("held children share expiry and subsequent paid or unpaid parent windows", function()
    local env, p = fresh()
    local parent = env.laser(p)
    env.init(parent, 10)
    local child = env.laser(p, parent, true) -- Its own OneHit flag cannot extend the paid window.
    env.init(child, 15)
    near(env.hit(child), 13)
    env.frame = 16; near(env.hit(child), 13)
    env.frame = 17; near(env.hit(child), 10)
    assert(env.state().compute == 10)
    env.observe(parent, 17, 7)
    assert(env.state().compute == 8); near(env.hit(child), 13)
    env.state().saving = true
    env.observe(parent, 23, 13) -- An unpaid window cancels even the inclusive old deadline.
    assert(env.state().compute == 8); near(env.hit(parent), 10); near(env.hit(child), 10)
    env.state().saving = false
    env.observe(parent, 29, 19)
    assert(env.state().compute == 6); near(env.hit(child), 13)
    native(child, p, parent)
end)

test("child-first nested callbacks resolve later without synthesizing parent payment", function()
    local env, p = fresh()
    local parent = env.laser(p, nil, true)
    local child = env.laser(parent, parent)
    local grandchild = env.laser(child, child)
    env.init(grandchild, 1); env.init(child, 2)
    near(env.hit(grandchild), 10); assert(env.state().compute == 12)
    env.init(parent, 3)
    near(env.hit(grandchild), 13) -- Resolve on damage before another child update.
    assert(env.state().compute == 10)
    parent:Remove(); child:Remove(); grandchild.Parent = nil
    near(env.hit(grandchild), 13)
    native(grandchild, child, nil)
end)

test("detached children keep paid damage but never steal the next primary window", function()
    local env, p = fresh()
    local parent = env.laser(p)
    local child = env.laser(p, parent)
    env.init(child, 1); env.init(parent, 2)
    env.observe(child, 3, 1) -- Cache the parent's decision before its removal.
    parent:Remove(); child.Parent = nil
    env.frame = 4; near(env.hit(child), 13)
    env.observe(child, 9, 7)
    near(env.hit(child), 10)
    assert(env.state().compute == 10, "a known detached child cannot pay")
    local primary = env.laser(p)
    env.observe(primary, 9, 7)
    assert(env.state().compute == 8, "ignored child must not consume the observer's window")
    near(env.hit(primary), 13)
end)

test("removed parent references do not require surviving parent GetData", function()
    for _, laserSpawner in ipairs({ true, false }) do
        local env, p = fresh()
        local parent = env.laser(p, nil, true)
        env.init(parent, 1)
        local child = env.laser(laserSpawner and parent or p, parent)
        env.init(child, 2)
        parent:Remove()
        function parent:GetData() error("removed parent data must not be accessed") end
        env.observe(child, 3, 2); near(env.hit(child), 13)
        child.Parent = nil
        env.observe(child, 4, 3); near(env.hit(child), 13)
        assert(env.state().compute == 10)
    end
end)

test("explicit foreign, familiar and unknown sources cannot borrow a parent boost", function()
    local env, p, q = fresh()
    local parent = env.laser(p, nil, true)
    env.init(parent, 1)
    local unknown = env.npc(400)
    local familiar = env.familiar(p)
    for _, source in ipairs({ q, familiar, unknown, env.laser(p) }) do
        local child = env.laser(source, parent, true)
        env.init(child, env.frame + 1)
        near(env.hit(child), 10)
        native(child, source, parent)
    end
    local child = env.laser(nil, parent)
    env.init(child, 6); near(env.hit(child), 13)
    child.SpawnerEntity = q
    near(env.hit(child), 10)
    child.SpawnerEntity = p; parent.SpawnerEntity = q
    near(env.hit(child), 10)
    assert(env.state().compute == 10 and env.state(1).compute == 12)
    local own = env.laser(q, nil, true)
    env.init(own, 7); near(env.hit(own), 13); assert(env.state(1).compute == 10)
end)

test("surviving former laser spawners are revalidated after Parent is cleared", function()
    local env, p, q = fresh()
    local parent = env.laser(p, nil, true)
    env.init(parent, 1)
    local child = env.laser(parent, parent)
    env.init(child, 2); child.Parent = nil
    near(env.hit(child), 13)
    parent.SpawnerEntity = q
    near(env.hit(child), 10)
    assert(env.state().compute == 10 and env.state(1).compute == 12)
end)

test("unobserved parents and cycles stay unpaid and unboosted", function()
    local env, p = fresh()
    local parent = env.laser(p)
    local child = env.laser(p, parent)
    env.init(child, 1); env.observe(child, 10, 9)
    near(env.hit(child), 10)
    local a, b = env.laser(p), env.laser(p)
    a.Parent, b.Parent = b, a
    env.init(a, 11); env.init(b, 12)
    near(env.hit(a), 10); near(env.hit(b), 10)
    assert(env.state().compute == 12)
    env.init(env.laser(p, nil, true), 13)
    assert(env.state().compute == 10)
end)

test("room and run boundaries invalidate transient child decisions", function()
    for _, reset in ipairs({ "room", "continue", "new-run" }) do
        local env, p = fresh()
        local parent = env.laser(p, nil, true)
        local child = env.laser(p, parent)
        env.init(parent, 1); env.init(child, 2)
        parent:Remove(); child.Parent = nil
        if reset == "room" then env.newRoom({ clear = true, keep = true })
        else
            env.fire("MC_PRE_GAME_EXIT", nil, true)
            near(env.hit(child), 10)
            env.frame = 0
            env.fire("MC_POST_GAME_STARTED", nil, reset == "continue")
        end
        local before = env.state().compute
        env.observe(child, 3, 10)
        near(env.hit(child), 10); assert(env.state().compute == before)
        local primary = env.laser(p, nil, true)
        env.init(primary, 4); near(env.hit(primary), 13)
        assert(env.state().compute == before - 2)
        for _, value in pairs(env.state()) do assert(type(value) ~= "table", "transient leases entered saved state") end
    end
end)

test("slot identity and form changes cannot retain another binding's boost", function()
    for _, change in ipairs({ "seed", "form", "removed" }) do
        local env, p = fresh()
        local parent = env.laser(p, nil, true)
        env.init(parent, 1)
        local child = env.laser(nil, parent)
        env.init(child, 2); parent:Remove(); child.Parent = nil
        if change == "seed" then p.InitSeed = p.InitSeed + 100
        elseif change == "form" then p.form = 42
        else table.remove(env.players, 1) end
        env.update()
        near(env.hit(child), 10)
    end
end)

test("backlog primes and Peak compose once while Opus and next primes stay unchanged", function()
    local env, p = fresh()
    env.give(p, "OPUS_MODE")
    env.C.Prime(p, "parent", 2)
    local parent = env.laser(p, nil, true)
    env.init(parent, 1); env.observe(parent, 1, 1)
    near(env.hit(parent), 26)
    env.C.Prime(p, "next", 3)
    local child = env.laser(p, parent, true)
    env.init(child, 2); env.observe(child, 2, 1)
    near(env.hit(child), 26)
    assert(env.state().compute == 10 and env.C.Primed(p, "next"))
    assert(p:GetData().ccOpusTears == 1 and p.coins == 5)
    local primary = env.laser(p, nil, true)
    env.init(primary, 3); env.observe(primary, 3, 1)
    near(env.hit(primary), 39)
    assert(env.state().compute == 8 and not env.C.Primed(p, "next"))
    assert(p:GetData().ccOpusTears == 2 and p.coins == 5)
    assert(env.hitPlayer(p, child) ~= false, "Peak must not boost damage against a player")
    native(child, p, parent)
end)

for _, failure in ipairs(failures) do print("FAIL " .. failure) end
assert(#failures == 0, tostring(#failures) .. " Peak child-laser groups failed")
print("PASS Peak child-laser inheritance: " .. passed .. " callback groups")
