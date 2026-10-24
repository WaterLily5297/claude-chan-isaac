-- Real Summary Stapler, Opus and backlog registration order from main.lua.
-- Synchronous FireTear dispatch is modeled; native weapon behavior is separate.
local root = assert(arg[1])
local Env = dofile(root .. "/tests/lib/backlog_env.lua")
local passed, failures = 0, {}
local function test(name, fn)
    if arg[2] and not name:find(arg[2], 1, true) then return end
    local ok, err = pcall(fn)
    if ok then passed = passed + 1
    else failures[#failures + 1] = name .. ": " .. tostring(err) end
end
local function fresh()
    local env = Env.New(root)
    local players = {}
    for i = 1, 3 do
        local p = env.player(300 + i * 20)
        p.coins = 5
        function p:GetNumCoins() return self.coins end
        function p:AddCoins(n) self.coins = self.coins + n end
        players[i] = p
    end
    include("scripts.items.summary_stapler"):Init(env.mod)
    include("scripts.items.opus_mode"):Init(env.mod)
    env.load()
    env.give(players[1], "OPUS_MODE")
    env.give(players[2], "OPUS_MODE")
    return env, players[1], players[2], players[3]
end
local function balance(player, count, coins)
    assert((player:GetData().ccOpusTears or 0) == count,
        "expected Opus count " .. count .. ", got " .. tostring(player:GetData().ccOpusTears))
    assert(player.coins == coins, "expected " .. coins .. " coins, got " .. player.coins)
end
local function primary(env, player)
    env.frame = env.frame + 1
    return env.shoot(player)
end

test("direct helper preserves wallet, prime and native shot multiplier", function()
    local env, p = fresh()
    p:GetData().ccOpusTears = 9
    env.C.Prime(p, "test", 2)
    local tear = env.C.FireDerived(p, Vector(10, 0), 0.6)
    assert(tear == p.fired[1] and tear.mult == 0.6)
    assert(tear:GetData().ccThoughtDerived and env.C.Primed(p, "test"))
    balance(p, 9, 5)
    primary(env, p)
    balance(p, 0, 4)
    assert(not env.C.Primed(p, "test"), "the next normal shot still uses its prime")
end)

test("Please Retry's three scheduled helpers do not charge Opus", function()
    local env, p = fresh()
    p:GetData().ccOpusTears = 9
    env.C.Prime(p, "test", 2)
    assert(env.use(env.Item.PLEASE_RETRY, p).Discharge)
    env.update(31)
    assert(#p.fired == 3 and env.C.Primed(p, "test"))
    for _, tear in ipairs(p.fired) do assert(tear.mult == 0.6 and tear:GetData().ccThoughtDerived) end
    balance(p, 9, 5)
    primary(env, p)
    balance(p, 0, 4)
end)

test("One More Finger bills its five primary shots but not the helper", function()
    local env, p = fresh()
    env.give(p, "ONE_MORE_FINGER")
    p:GetData().ccOpusTears = 4
    for _ = 1, 5 do primary(env, p) end
    balance(p, 9, 5)
    env.update()
    assert(#p.fired == 1 and p.fired[1].mult == 0.3 and p.fired[1]:GetData().ccThoughtDerived)
    balance(p, 9, 5)
    primary(env, p)
    balance(p, 0, 4)
end)

test("Summary Stapler retains its documented normal-shot billing", function()
    local env, p = fresh()
    p:GetData().ccOpusTears = 9
    env.C.Prime(p, "test", 2)
    local bullet = env.bullet(p.Position.X + 10, 0, env.npc(500))
    assert(env.use(env.Item.SUMMARY_STAPLER, p).Discharge)
    assert(not bullet.alive and #p.fired == 1 and p.fired[1].mult == 1.25)
    assert(not p.fired[1]:GetData().ccThoughtDerived and not env.C.Primed(p, "test"))
    balance(p, 0, 4)
    assert(not env.use(env.Item.SUMMARY_STAPLER, p).Discharge)
    balance(p, 0, 4)
end)

test("nested same-player helpers stay free until the outer scope ends", function()
    local env, p = fresh()
    p:GetData().ccOpusTears = 9
    env.C.Prime(p, "test", 2)
    local nativeFire, nested = p.FireTear, false
    function p:FireTear(...)
        if not nested then
            nested = true
            env.C.FireDerived(self, Vector(0, 10), 0.3)
        end
        return nativeFire(self, ...)
    end
    env.C.FireDerived(p, Vector(10, 0), 0.6)
    assert(#p.fired == 2 and env.C.Primed(p, "test"))
    for _, tear in ipairs(p.fired) do assert(tear:GetData().ccThoughtDerived) end
    balance(p, 9, 5)
    p.FireTear = nativeFire
    primary(env, p)
    balance(p, 0, 4)
end)

test("another player's normal shot remains paid during a helper spawn", function()
    local env, p, q, unowned = fresh()
    p:GetData().ccOpusTears, q:GetData().ccOpusTears = 9, 9
    env.C.Prime(p, "test", 2); env.C.Prime(q, "test", 2)
    local nativeFire, otherShot = p.FireTear
    function p:FireTear(...)
        otherShot = env.shoot(q)
        env.shoot(unowned)
        return nativeFire(self, ...)
    end
    env.C.FireDerived(p, Vector(10, 0), 0.6)
    balance(p, 9, 5); balance(q, 0, 4); balance(unowned, 0, 5)
    assert(not otherShot:GetData().ccThoughtDerived and not env.C.Primed(q, "test"))
    assert(env.C.Primed(p, "test"), "only the helper owner's prime is retained")
    p.FireTear = nativeFire
    primary(env, p)
    balance(p, 0, 4)
end)

test("nil and error returns do not leave later shots exempt", function()
    for _, mode in ipairs({ "nil", "error" }) do
        local env, p = fresh()
        p:GetData().ccOpusTears = 9
        env.C.Prime(p, "test", 2)
        local nativeFire = p.FireTear
        function p:FireTear()
            if mode == "error" then error("injected native shot failure") end
        end
        local ok, result = pcall(env.C.FireDerived, p, Vector(10, 0), 0.6)
        if mode == "error" then
            assert(not ok and tostring(result):find("injected native shot failure", 1, true))
        else
            assert(ok and result == nil)
        end
        balance(p, 9, 5)
        p.FireTear = nativeFire
        local tear = primary(env, p)
        balance(p, 0, 4)
        assert(not tear:GetData().ccThoughtDerived and not env.C.Primed(p, "test"),
            "a failed helper must not suppress the next real attack")
    end
end)

test("premarked derived tears and familiar tears stay free", function()
    local env, p = fresh()
    p:GetData().ccOpusTears = 9
    env.C.Prime(p, "test", 2)
    local derived = env.tear(p)
    derived:GetData().ccThoughtDerived = true
    env.fire("MC_POST_FIRE_TEAR", nil, derived)
    env.fire("MC_POST_FIRE_TEAR", nil, env.tear(env.familiar(p)))
    balance(p, 9, 5)
    assert(env.C.Primed(p, "test"), "premarked helpers and familiar shots retain player primes")
    primary(env, p)
    balance(p, 0, 4)
    assert(not env.C.Primed(p, "test"), "a later primary shot still uses its prime")
end)

for _, failure in ipairs(failures) do print("FAIL " .. failure) end
assert(#failures == 0, tostring(#failures) .. " Opus helper groups failed")
print("PASS Opus helper billing: " .. passed .. " callback groups")
