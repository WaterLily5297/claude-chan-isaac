-- Boundary tests for backlog rows 25-50 (Llama, Mistral, Doubao, Kimi, GLM
-- and shared items). Callback inputs only, no native AI.
local root = arg[1]
local Env = dofile(root .. "/tests/lib/backlog_env.lua")

local passed = 0
local function T(name, fn)
    local ok, err = pcall(fn)
    if not ok then error(name .. ": " .. tostring(err), 0) end
    passed = passed + 1
end
local function near(a, b, msg) assert(math.abs(a - b) < 1e-6, (msg or "") .. " expected " .. b .. ", got " .. a) end
local function last(n) return n.damage[#n.damage] end

local function fresh(...)
    local env = Env.New(root)
    local p = env.player(300)
    p.Position = Vector(300, 200)
    env.load()
    env.newRoom()
    for _, key in ipairs({ ... }) do env.give(p, key) end
    return env, p, env.Item
end
-- A room-charged primary active with no charge.
local function active(env, p, max, chargeType)
    env.config[999] = { MaxCharges = max or 4, ChargeType = chargeType or 0 }
    p.active[0], p.charge[0] = 999, 0
end
local function clears(env, n)
    for _ = 1, n do env.newRoom(); env.clearRoom() end
end

T("25 Open Weights: four flies solo, two each in co-op", function()
    local env, p, Item = fresh()
    env.use(Item.OPEN_WEIGHTS, p); assert(p.flies == 4)
    local q = env.player(100)
    env.use(Item.OPEN_WEIGHTS, p); assert(p.flies == 6 and q.flies == 2)
    function q:IsCoopGhost() return true end
    env.use(Item.OPEN_WEIGHTS, p); assert(p.flies == 10 and q.flies == 2, "a co-op ghost gets none; the solo share applies")
end)

T("26 Herd Bell: every third clear without flies grants one", function()
    local env, p = fresh("HERD_BELL")
    clears(env, 3); assert(p.flies == 1)
    env.familiar(p)
    for _ = 1, 3 do env.newRoom({ keep = true }); env.clearRoom() end
    assert(p.flies == 1, "no progress while a fly exists")
end)

T("27 Please Come Back: three clears without charged use add one charge", function()
    local env, p = fresh("PLEASE_COME_BACK")
    active(env, p)
    clears(env, 2); env.chargedUse(p, 999); p.active[0], p.charge[0] = 999, 0
    clears(env, 2); assert(p.charge[0] == 0, "a charged use resets progress")
    clears(env, 1); assert(p.charge[0] == 1)
    active(env, p, 4, 1)
    clears(env, 3); assert(p.charge[0] == 0, "timed actives never benefit")
end)

T("28 Release Soon: three guards after two seconds, cancelled by leaving", function()
    local env, p, Item = fresh()
    env.use(Item.RELEASE_SOON, p)
    env.update(59); assert(env.C.Guards(p) == 0)
    env.update(1); assert(env.C.Guards(p, "release") == 3)
    env.update(181); assert(env.C.Guards(p) == 0, "guards expire")
    env.use(Item.RELEASE_SOON, p); env.newRoom(); env.update(61)
    assert(env.C.Guards(p) == 0, "room exit cancels")
end)

T("29 Emergency Baguette strikes the line and stops at walls", function()
    local env, p, Item = fresh()
    local on, off, far = env.npc(400, { y = 200 }), env.npc(400, { y = 300 }), env.npc(560, { y = 200 })
    env.use(Item.EMERGENCY_BAGUETTE, p)
    near(last(on), 10.5); assert(#off.damage == 0 and #far.damage == 0)
    env.lineBlockedAt = 60
    env.use(Item.EMERGENCY_BAGUETTE, p)
    assert(#on.damage == 1, "an obstacle stops the line")
end)

T("30 Slipstream Boots after two seconds of movement", function()
    local env, p = fresh("SLIPSTREAM_BOOTS")
    local npc = env.npc(320, { y = 200 })
    p.Velocity = Vector(5, 0)
    env.update(60); near(p.MoveSpeed, 1)
    env.update(1); near(p.MoveSpeed, 1.15)
    p.Velocity = Vector(-5, 0); env.update()
    assert(npc.slowed == 30, "sharp turn gust")
    npc.slowed = nil; p.Velocity = Vector(5, 0); env.update()
    assert(npc.slowed == nil, "gust cooldown")
    p.Velocity = Vector(0, 0); env.update(); near(p.MoveSpeed, 1)
end)

T("31 Very Large Kitten pushes nearby ordinary bullets away", function()
    local env, p, Item = fresh()
    local b = env.bullet(350, 200, env.npc(600, { y = 0 })); b.Velocity = Vector(-3, 0)
    env.use(Item.LARGE_KITTEN, p)
    env.update(15)
    assert(b.Velocity.X > 0 and math.abs(b.Velocity:Length() - 6) < 1e-6)
end)

T("32 Edge Compass near the outer walls", function()
    local env, p = fresh("EDGE_COMPASS")
    env.update(5); near(p.ShotSpeed, 1)
    p.Position = Vector(20, 200); env.update(5); near(p.ShotSpeed, 1.25)
end)

T("33 Instant Apology slows and erases at most four bullets", function()
    local env, p, Item = fresh()
    local npc = env.npc(350, { y = 200 })
    local bullets = {}
    for i = 1, 5 do bullets[i] = env.bullet(300 + i * 10, 200, npc) end
    env.use(Item.INSTANT_APOLOGY, p)
    assert(npc.slowed == 60 and bullets[5].alive and not bullets[4].alive)
end)

T("35 Confident Answer cycle never overlaps", function()
    local env, p, Item = fresh()
    env.use(Item.CONFIDENT_ANSWER, p); near(p.Damage, 4.375)
    assert(env.use(Item.CONFIDENT_ANSWER, p).Discharge == false)
    env.update(180); near(p.Damage, 3.15)
    env.update(120); near(p.Damage, 3.5)
    assert(env.use(Item.CONFIDENT_ANSWER, p).Discharge == true)
end)

T("36 Smiling Correction waits for a flawless clear", function()
    local env, p = fresh("SMILING_CORRECTION")
    env.hitPlayer(p, env.npc(320, { y = 200 }))
    env.clearRoom(); assert(p.flies == 0, "not flawless")
    clears(env, 1); assert(p.flies == 2)
    clears(env, 1); assert(p.flies == 2, "one correction only")
end)

T("37 Slide Deadline rewards killing every marked enemy in time", function()
    local env, p, Item = fresh()
    local a, b = env.npc(320, { y = 200 }), env.npc(340, { y = 200 })
    env.use(Item.SLIDE_DEADLINE, p)
    assert(env.use(Item.SLIDE_DEADLINE, p).Discharge == false, "one batch")
    env.kill(a); near(p.Damage, 3.5)
    env.kill(b); near(p.Damage, 4.025)
    env.newRoom(); near(p.Damage, 3.5)
    local c = env.npc(320, { y = 200 })
    env.use(Item.SLIDE_DEADLINE, p); env.update(241); env.kill(c)
    near(p.Damage, 3.5, "late")
end)

T("38 Citation Thread boosts the first reference", function()
    local env, p = fresh("CITATION_THREAD")
    local a, b = env.npc(400, { y = 200 }), env.npc(420, { y = 200 })
    env.shoot(p, a); env.update(); env.shoot(p, b); env.update()
    env.shoot(p, a); near(last(a), 3.85)
    env.update(91); env.shoot(p, a); near(last(a), 3.5)
end)

T("39 Overtime Slides slows the next hostile room after three clears", function()
    local env, p = fresh("OVERTIME_SLIDES")
    clears(env, 3)
    env.newRoom({ clear = true })
    env.newRoom()
    local npc = env.npc(400, { y = 200 })
    env.update(); assert(npc.slowed == 60)
end)

T("41 Queue Ticket: every fourth unique clear adds a charge", function()
    local env, p = fresh("QUEUE_TICKET")
    active(env, p)
    env.clearRoom(); env.clearRoom(); clears(env, 2)
    assert(p.charge[0] == 0)
    clears(env, 1); assert(p.charge[0] == 1)
    p.charge[0] = 4; clears(env, 4); assert(p.charge[0] == 4, "full charge is untouched")
    active(env, p, 0); clears(env, 4); assert(p.charge[0] == 0, "zero-charge actives never benefit")
end)

T("43 Please Retry fires three derived 0.6x tears, cancelled by leaving", function()
    local env, p, Item = fresh()
    env.use(Item.PLEASE_RETRY, p)
    env.update(31); assert(#p.fired == 3 and p.fired[1].mult == 0.6)
    env.use(Item.PLEASE_RETRY, p); env.update(1); env.newRoom(); env.update(40)
    assert(#p.fired == 4)
end)

T("44 Access Pass: first charged use per floor, pending from cleared rooms", function()
    local env, p = fresh("ACCESS_PASS")
    env.chargedUse(p, 999); near(p.Damage, 4.025)
    env.chargedUse(p, 999); env.newRoom(); near(p.Damage, 3.5, "once per floor")
    env.newFloor(); env.clear = true
    env.chargedUse(p, 999); near(p.Damage, 3.5)
    env.newRoom(); near(p.Damage, 4.025, "delivered to the next hostile room")
end)

T("45 Cache Cartridge only in revisited cleared rooms", function()
    local env, p = fresh("CACHE_CARTRIDGE")
    env.newRoom({ clear = true }); near(p.MoveSpeed, 1)
    env.newRoom({ clear = true, first = false }); near(p.MoveSpeed, 1.15)
    env.newRoom(); near(p.MoveSpeed, 1)
end)

T("46 Token Recall takes back only the owner's ordinary tears", function()
    local env, p, Item = fresh()
    local q = env.player(100)
    local mine, other, special = env.tear(p), env.tear(q), env.tear(p)
    special.Variant = 5
    env.use(Item.TOKEN_RECALL, p)
    assert(not mine.alive and other.alive and special.alive and env.C.Guards(p, "recall") == 1)
end)

T("47 Checkpoint Pin returns within five seconds", function()
    local env, p, Item = fresh()
    assert(env.use(Item.CHECKPOINT_PIN, p).Discharge == false)
    p.Position = Vector(100, 100)
    assert(env.use(Item.CHECKPOINT_PIN, p).Discharge == true)
    assert(p.Position == Vector(300, 200))
    env.use(Item.CHECKPOINT_PIN, p); env.update(151); p.Position = Vector(50, 50)
    assert(env.use(Item.CHECKPOINT_PIN, p).Discharge == false and p.Position == Vector(50, 50), "expired pin")
end)

T("48 Rate-Limit Valve primes after two idle seconds", function()
    local env, p = fresh("RATE_LIMIT_VALVE")
    local a, b = env.npc(400, { y = 200 }), env.npc(420, { y = 200 })
    env.update(60)
    env.shoot(p, a, b); near(a.damage[1], 4.55); near(b.damage[1], 4.55)
    env.update(); env.shoot(p, a); near(last(a), 3.5)
end)

T("49 Consensus Coin: two sources on one target pulse once", function()
    local env, p = fresh("CONSENSUS_COIN")
    local npc = env.npc(400, { y = 200 })
    local fly = env.familiar(p)
    env.shoot(p, npc); env.update()
    npc:TakeDamage(2, 0, EntityRef(fly)); env.update()
    near(npc.damage[3], 1.75)
    env.shoot(p, npc); npc:TakeDamage(2, 0, EntityRef(fly)); env.update()
    assert(#npc.damage == 5, "one pulse per target")
end)

T("50 Error Budget: first real hit per floor", function()
    local env, p = fresh("ERROR_BUDGET")
    local npc = env.npc(320, { y = 200 })
    env.hitPlayer(p, npc); near(p.MoveSpeed, 1.2)
    env.newRoom(); env.hitPlayer(p, env.npc(320, { y = 200 })); near(p.MoveSpeed, 1)
    env.newFloor(); env.hitPlayer(p, env.npc(320, { y = 200 })); near(p.MoveSpeed, 1.2)
end)

T("primed bonuses reach every tear of a volley but no later attack", function()
    local env, p = fresh()
    local npc = env.npc(400, { y = 200 })
    env.C.Prime(p, "a", 2); env.C.Prime(p, "b", 1.5)
    local t1 = env.shoot(p); local t2 = env.shoot(p)
    npc:TakeDamage(3.5, 0, EntityRef(t1)); npc:TakeDamage(3.5, 0, EntityRef(t2))
    near(npc.damage[1], 10.5); near(npc.damage[2], 10.5)
    env.update(121); npc:TakeDamage(3.5, 0, EntityRef(t1)); near(last(npc), 3.5, "lease expired")
end)

print(string.format("backlog items 25-50: %d tests passed", passed))
