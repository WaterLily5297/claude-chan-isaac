-- Boundary tests for backlog rows 02-24 (Claude, DeepSeek, GPT, Gemini, Grok,
-- Qwen) plus the shared service. Callback inputs only, no native AI.
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

-- A fresh run with one player in a hostile room.
local function fresh(...)
    local env = Env.New(root)
    local p = env.player(300)
    p.Position = Vector(300, 200)
    env.load()
    env.newRoom()
    for _, key in ipairs({ ... }) do env.give(p, key) end
    return env, p, env.Item
end

T("every active registers a use callback and ignores Car Battery", function()
    local env, p, Item = fresh()
    local actives = { "RED_STAMP", "RICE_COOKER", "WENGU_CLOCK", "SANITY_TEST", "TIBO_RESET", "NANO_BANANA",
        "UNDO_BRUSH", "UNCHANGED_PREVIEW", "IS_THIS_TRUE", "ANOTHER_ADAPTER", "OPEN_WEIGHTS", "RELEASE_SOON",
        "EMERGENCY_BAGUETTE", "LARGE_KITTEN", "INSTANT_APOLOGY", "CONFIDENT_ANSWER", "SLIDE_DEADLINE",
        "STANDUP_MEETING", "SOLD_OUT", "PLEASE_RETRY", "TOKEN_RECALL", "CHECKPOINT_PIN" }
    env.npc(350, { y = 200 }); env.bullet(310, 200, env.npc(400, { y = 200 }))
    for _, key in ipairs(actives) do
        local id = assert(Item[key], key)
        local found = false
        for _, cb in ipairs(env.callbacks) do if cb.id == "MC_USE_ITEM" and cb.filter == id then found = true end end
        assert(found, key .. " has no use callback")
        local r = env.use(id, p, UseFlag.USE_CARBATTERY | UseFlag.USE_OWNED)
        assert(r and r.Discharge == false, key .. " must ignore Car Battery")
    end
    assert(#env.spawned == 0 and p.flies == 0, "Car Battery uses changed the room")
end)

T("targeted actives keep their charge without a target", function()
    local env, p, Item = fresh()
    for _, key in ipairs({ "RED_STAMP", "SANITY_TEST", "NANO_BANANA", "IS_THIS_TRUE", "SLIDE_DEADLINE",
            "UNDO_BRUSH", "INSTANT_APOLOGY", "TOKEN_RECALL", "STANDUP_MEETING" }) do
        assert(env.use(Item[key], p).Discharge == false, key)
    end
    env.npc(900, { y = 200 }) -- out of every range
    assert(env.use(Item.RED_STAMP, p).Discharge == false)
end)

T("02 Rejection Letter clears three nearest bullets once per room", function()
    local env, p = fresh("REJECTION_LETTER")
    local shooter = env.npc(500, { y = 200 })
    local b = {}
    for i = 1, 4 do b[i] = env.bullet(300 + i * 20, 200, shooter) end
    local far = env.bullet(300, 400, shooter)
    env.hitPlayer(p, shooter, DamageFlag.DAMAGE_FAKE)
    assert(b[1].alive, "fake damage must not count")
    assert(env.hitPlayer(p, shooter) == nil, "the hit itself stays")
    assert(not b[1].alive and not b[2].alive and not b[3].alive and b[4].alive and far.alive)
    env.hitPlayer(p, shooter)
    assert(b[4].alive, "once per room")
end)

T("03 Red Stamp blocks contact before hit events, bosses only slow", function()
    local env, p, Item = fresh("REJECTION_LETTER", "ANNIVERSARY_CAKE")
    local npc = env.npc(350, { y = 200 })
    local shooter = env.npc(600, { y = 0 })
    local bullet = env.bullet(310, 200, shooter)
    assert(env.use(Item.RED_STAMP, p).Discharge == true)
    assert(npc.slowed == 120)
    assert(env.hitPlayer(p, npc) == false, "stamped contact is cancelled")
    assert(bullet.alive and not env.C.HitThisRoom(p), "a cancelled hit must not emit hit events")
    env.update(121)
    assert(env.hitPlayer(p, npc) == nil, "stamp expired")
    env.newRoom()
    local boss = env.npc(350, { y = 200, boss = true })
    env.use(Item.RED_STAMP, p)
    assert(boss.slowed == 120 and env.hitPlayer(p, boss) == nil, "bosses are only slowed")
end)

T("04 Anniversary Cake grows per clean floor, resets on a spoiled one, caps", function()
    local env, p = fresh("ANNIVERSARY_CAKE")
    local function floor(hit)
        env.update(15)
        if hit then env.hitPlayer(p, env.npc(320, { y = 200 })) end
        env.newFloor()
    end
    floor(); near(p.Damage, 3.65)
    floor(true); near(p.Damage, 3.5, "spoiled")
    for _ = 1, 6 do floor() end
    near(p.Damage, 4.1, "cap")
    env.Risk.suspended = true
    floor(); near(p.Damage, 3.5, "suspension spoils")
end)

T("05 Rice Cooker: meal then one 2x attack; busy keeps the charge", function()
    local env, p, Item = fresh()
    local npc = env.npc(400, { y = 200 })
    assert(env.use(Item.RICE_COOKER, p).Discharge == true)
    assert(env.use(Item.RICE_COOKER, p).Discharge == false, "already eating")
    env.update(91)
    env.shoot(p, npc); near(last(npc), 7)
    env.update(); env.shoot(p, npc); near(last(npc), 3.5, "one attack only")
    assert(env.use(Item.RICE_COOKER, p).Discharge == true)
    env.update(91 + 211)
    env.shoot(p, npc); near(last(npc), 3.5, "window expired")
end)

T("06 One Bowl Only: confirmed red heart grants one guard per room", function()
    local env, p = fresh("ONE_BOWL")
    local function eat(gain)
        env.fire("MC_PRE_PICKUP_COLLISION", nil, { Variant = PickupVariant.PICKUP_HEART, SubType = HeartSubType.HEART_FULL }, p)
        if gain then p.hearts = p.hearts + 2 end
        env.update()
    end
    eat(false); assert(env.C.Guards(p) == 0, "unconsumed heart")
    env.fire("MC_PRE_PICKUP_COLLISION", nil, { Variant = PickupVariant.PICKUP_HEART, SubType = HeartSubType.HEART_SOUL }, p)
    p.hearts = p.hearts + 2; env.update(); assert(env.C.Guards(p) == 0, "a soul heart never counts")
    eat(true); assert(env.C.Guards(p, "bowl") == 1)
    eat(true); assert(env.C.Guards(p, "bowl") == 1, "once per room")
    for _ = 1, 3 do
        env.newRoom()
        assert(env.hitPlayer(p, env.bullet(300, 200, env.npc(500, { y = 200 }))) == false)
        eat(true)
    end
    assert(env.C.State(p).floor.bowls == 3 and env.C.Guards(p) == 0, "three grants per floor")
    env.newFloor(); eat(true); assert(env.C.Guards(p, "bowl") == 1, "a new floor resets the grants")
end)

T("guards consume only ordinary bullets and real hits", function()
    local env, p, Item = fresh()
    local shooter = env.npc(500, { y = 200 })
    env.use(Item.SOLD_OUT, p)
    near(p.MoveSpeed, 1.15)
    assert(env.use(Item.SOLD_OUT, p).Discharge == false, "no stacking")
    local special = env.bullet(300, 200, shooter); special.Variant = 1
    assert(env.hitPlayer(p, special) == nil and env.C.Guards(p) == 1, "special bullets pass")
    assert(env.hitPlayer(p, env.bullet(300, 200, shooter), DamageFlag.DAMAGE_FAKE) == nil, "fake hits pass")
    local bullet = env.bullet(300, 200, shooter)
    assert(env.hitPlayer(p, bullet) == false and not bullet.alive)
    assert(env.C.Guards(p) == 0)
    near(p.MoveSpeed, 1, "speed ends with the guard")
    assert(env.hitPlayer(p, shooter) == nil, "contact is never guarded")
end)

T("07 Wengu Clock primes after two idle seconds, never extends", function()
    local env, p, Item = fresh()
    local npc = env.npc(400, { y = 200 })
    env.use(Item.WENGU_CLOCK, p)
    assert(env.use(Item.WENGU_CLOCK, p).Discharge == false)
    env.update(30); env.shoot(p, npc)
    env.update(59); assert(not env.C.Primed(p, "wengu"), "idle restarted by the attack")
    env.update(1); assert(env.C.Primed(p, "wengu"))
    env.shoot(p, npc); near(last(npc), 4.55)
    env.update(200); env.shoot(p, npc); near(last(npc), 3.5)
end)

T("08 Seven-Second Memory: a different attack pulses 0.5x once", function()
    local env, p = fresh("SEVEN_SECOND_MEMORY")
    local npc = env.npc(400, { y = 200 })
    env.shoot(p, npc, npc)
    env.update(); assert(#npc.damage == 2, "same attack never pulses")
    env.shoot(p, npc); env.update()
    near(npc.damage[4], 1.75)
    env.update(); env.shoot(p, npc); env.update(); env.shoot(p, npc); env.update()
    assert(#npc.damage == 6, "cooldown")
end)

T("09 Sanity Test: three distinct attacks give one 3x pulse", function()
    local env, p, Item = fresh()
    local npc = env.npc(400, { y = 200 })
    env.use(Item.SANITY_TEST, p)
    env.shoot(p, npc, npc); env.update()
    env.shoot(p, npc); env.update()
    assert(#npc.damage == 3)
    env.shoot(p, npc); env.update()
    near(npc.damage[5], 10.5)
    env.shoot(p, npc); env.update(); assert(#npc.damage == 6, "single pulse")
end)

T("10 Routing Receipt banks after three unique clears", function()
    local env, p = fresh("ROUTING_RECEIPT")
    env.clearRoom(); env.clearRoom(); env.clearRoom()
    assert(not env.C.State(p).routingBanked, "re-clear never counts")
    for _ = 1, 2 do env.newRoom(); env.clearRoom() end
    env.newRoom({ clear = true }); near(p.Damage, 3.5, "cleared rooms do not spend it")
    env.newRoom(); near(p.Damage, 4.2)
    env.newRoom(); near(p.Damage, 3.5)
end)

T("11 Tibo Reset: once per floor, two new combat rooms", function()
    local env, p, Item = fresh()
    assert(env.use(Item.TIBO_RESET, p).Discharge == true)
    assert(env.use(Item.TIBO_RESET, p).Discharge == false)
    env.newRoom({ first = false }); near(p.Damage, 3.5, "revisits never count")
    env.newRoom(); near(p.Damage, 4.2)
    env.newRoom(); near(p.Damage, 4.2)
    env.newRoom(); near(p.Damage, 3.5)
    env.newFloor()
    assert(env.use(Item.TIBO_RESET, p).Discharge == true)
end)

T("12 Same Model Badge phases", function()
    local env, p = fresh("SAME_MODEL_BADGE")
    env.newRoom(); near(p.Damage, 4.375)
    env.update(60); near(p.Damage, 3.15)
    env.update(120); near(p.Damage, 3.5)
    env.newRoom({ clear = true }); near(p.Damage, 3.5, "cleared rooms never start it")
end)

T("13 Nano Banana: a painted kill leaves a slowing peel", function()
    local env, p, Item = fresh()
    local a, b = env.npc(350, { y = 200 }), env.npc(360, { y = 210 })
    env.use(Item.NANO_BANANA, p)
    env.kill(a)
    env.update(10)
    assert(b.slowed == 15)
    env.newRoom(); env.update(10)
end)

T("14 One More Finger: every fifth attack adds one 0.3x tear, no recursion", function()
    local env, p = fresh("ONE_MORE_FINGER")
    for _ = 1, 5 do env.shoot(p); env.update() end
    assert(#p.fired == 1 and near(p.fired[1].mult, 0.3) == nil)
    env.update()
    for _ = 1, 4 do env.shoot(p); env.update(5) end
    assert(#p.fired == 1, "the derived tear is not an attack")
    env.shoot(p); env.update(); assert(#p.fired == 2)
end)

T("15 Undo Brush: speed per erased bullet for four seconds", function()
    local env, p, Item = fresh()
    local shooter = env.npc(600, { y = 0 })
    env.bullet(320, 200, shooter); env.bullet(330, 200, shooter)
    env.use(Item.UNDO_BRUSH, p)
    near(p.MoveSpeed, 1.04)
    env.update(121); near(p.MoveSpeed, 1)
end)

T("16 Unchanged Preview and 40 Stand-Up Meeting share helpers", function()
    local env, p, Item = fresh()
    local npc = env.npc(230, { y = 200 })
    env.use(Item.UNCHANGED_PREVIEW, p)
    local first = { env.spawned[1], env.spawned[2] }
    env.use(Item.UNCHANGED_PREVIEW, p)
    assert(not first[1].alive and not first[2].alive, "reuse replaces")
    env.update(5)
    assert(npc.Target == env.spawned[3], "pointed at the nearest decoy")
    local fly = env.familiar(p)
    assert(env.use(Item.STANDUP_MEETING, p).Discharge == true)
    near(last(npc), 7)
    assert(not env.spawned[3].alive and fly.alive, "vanilla familiars untouched")
    assert(env.use(Item.STANDUP_MEETING, p).Discharge == false)
end)

T("17 Is This True?: +35% target, -15% others, kill refunds", function()
    local env, p, Item = fresh()
    local a, b = env.npc(320, { y = 200 }), env.npc(500, { y = 200 })
    p.active[0], p.charge[0] = Item.IS_THIS_TRUE, 0
    env.use(Item.IS_THIS_TRUE, p, UseFlag.USE_OWNED)
    env.shoot(p, a, b)
    near(a.damage[1], 3.5 * 1.35); near(b.damage[1], 3.5 * 0.85)
    env.kill(a); assert(p.charge[0] == 1)
end)

T("18 Live Wire follows nearby ordinary bullets", function()
    local env, p = fresh("LIVE_WIRE")
    local bullet = env.bullet(350, 200, env.npc(600, { y = 0 }))
    env.update(5); near(p.MoveSpeed, 1.15)
    bullet:Remove(); env.update(5); near(p.MoveSpeed, 1)
end)

T("19 Quote Retort and 34 Next Time Again prime after real damage", function()
    local env, p = fresh("QUOTE_RETORT", "NEXT_TIME_AGAIN")
    local npc = env.npc(400, { y = 200 })
    env.hitPlayer(p, npc, DamageFlag.DAMAGE_NO_PENALTIES)
    env.shoot(p, npc); near(last(npc), 3.5)
    env.update(); env.hitPlayer(p, npc)
    env.shoot(p, npc); near(last(npc), 3.5 * 1.5 * 1.5)
    env.update(); env.hitPlayer(p, npc)
    env.shoot(p, npc); near(last(npc), 5.25, "Next Time Again is once per room")
end)

T("20 Community Note exposes after three distinct attacks", function()
    local env, p = fresh("COMMUNITY_NOTE")
    local npc = env.npc(400, { y = 200 })
    env.shoot(p, npc, npc); env.update()
    env.shoot(p, npc); env.update()
    env.shoot(p, npc); near(last(npc), 3.5, "one volley counts once")
    env.update(); env.shoot(p, npc); near(last(npc), 4.025)
    env.update(91); env.shoot(p, npc); near(last(npc), 3.5)
end)

T("21 Base Model primes once per room on charged use only", function()
    local env, p, Item = fresh("BASE_MODEL")
    local npc = env.npc(400, { y = 200 })
    env.config[999] = { MaxCharges = 4, ChargeType = 0 }
    p.active[0], p.charge[0] = 999, 4
    env.fire("MC_PRE_USE_ITEM", nil, 999, nil, p, 0, 0) -- not an owned use (e.g. a wisp or Void)
    p.charge[0] = 0; env.update()
    env.shoot(p, npc); near(last(npc), 3.5, "unowned uses never count")
    env.update()
    env.chargedUse(p, 999)
    env.shoot(p, npc); near(last(npc), 4.55)
    env.update(); env.chargedUse(p, 999)
    env.shoot(p, npc); near(last(npc), 3.5)
end)

T("22 Another Adapter cycles and ends with the room", function()
    local env, p, Item = fresh()
    env.use(Item.ANOTHER_ADAPTER, p); near(p.TearRange, 320)
    env.use(Item.ANOTHER_ADAPTER, p); near(p.TearRange, 260); near(p.MoveSpeed, 1.15)
    env.use(Item.ANOTHER_ADAPTER, p); near(p.Damage, 4.025)
    env.newRoom(); near(p.Damage, 3.5)
    env.use(Item.ANOTHER_ADAPTER, p); near(p.TearRange, 320, "choice is saved")
end)

T("23 Final Final Weights banks two flawless clears; a hit resets", function()
    local env, p = fresh("FINAL_WEIGHTS")
    env.clearRoom(); env.newRoom()
    env.hitPlayer(p, env.npc(320, { y = 200 }))
    env.clearRoom(); env.newRoom()
    assert(not env.C.State(p).weightsBanked)
    env.clearRoom(); env.newRoom(); env.clearRoom()
    env.newRoom(); near(p.Damage, 4.2)
    env.newRoom(); near(p.Damage, 3.5)
end)

T("24 Tiny Variant changes cache stats only", function()
    local env, p = fresh("TINY_VARIANT")
    near(p.MoveSpeed, 1.15); near(p.Damage, 3.15)
end)

T("players without backlog items get no saved state", function()
    local env, p = fresh()
    for _ = 1, 3 do env.clearRoom(); env.newRoom(); env.hitPlayer(p, env.npc(320, { y = 200 })) end
    env.newFloor(); env.update(30)
    assert(env.Risk.state.backlog == nil)
end)

T("saved state is versioned and holds no engine entities", function()
    local env, p, Item = fresh("ANNIVERSARY_CAKE", "ROUTING_RECEIPT", "QUEUE_TICKET")
    env.use(Item.TIBO_RESET, p); env.clearRoom(); env.update(15); env.newFloor()
    local function walk(t, depth)
        assert(depth < 8)
        for k, v in pairs(t) do
            assert(type(k) == "string" or type(k) == "number")
            assert(type(v) ~= "function" and type(v) ~= "userdata")
            if type(v) == "table" then assert(v.hash == nil, "entity saved"); walk(v, depth + 1) end
        end
    end
    walk(env.Risk.state, 0)
    env.Risk.state.backlog = { version = 99, players = { ["0"] = { cake = 0.6 } } }
    assert(env.C.Peek(p) == nil and env.C.State(p).cake == nil, "other versions are discarded")
    p:EvaluateItems(); local clean = p.Damage
    env.Risk.state.backlog.players["0"].cake = "bad"
    p:EvaluateItems(); near(p.Damage, clean, "malformed numbers are ignored")
    env.Risk.state.backlog.players["0"].cake = 99
    p:EvaluateItems(); near(p.Damage, clean, "out-of-range numbers are ignored")
end)

print(string.format("backlog items 02-24: %d tests passed", passed))
