-- Real Opus -> backlog -> character registration order and paid observers.
-- Parent-linked laser inputs are modeled; native ancestry/timing is unaccepted.
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
    local nativeInclude = include
    function include(name)
        if name == "scripts.hud_text" then return { Draw = function() end } end
        return nativeInclude(name)
    end
    function Isaac.GetPlayerTypeByName(name, tainted)
        if name == "Claude-chan" then return tainted and 43 or 41 end
        if name == "GPT-chan" then return tainted and 151 or 51 end
        return -1
    end
    EntityType.ENTITY_LASER = 7
    CacheFlag.CACHE_TEARCOLOR = 32
    CollectibleType.COLLECTIBLE_BIRTHRIGHT = 619
    ButtonAction, Input = { ACTION_DROP = 11 }, { IsActionPressed = function() return false end }
    function Color(r, g, b, a, ro, go, bo)
        return { R = r, G = g, B = b, A = a, RO = ro or 0, GO = go or 0, BO = bo or 0 }
    end
    local players = {}
    for index, kind in ipairs({ 41, 43, 151 }) do
        local p = env.player(index * 40)
        p.form, p.InitSeed, p.ControllerIndex, p.coins = kind, kind, index - 1, 5
        function p:GetPlayerType() return self.form end
        function p:AreControlsEnabled() return true end
        function p:SetPocketActiveItem() end
        function p:GetNumCoins() return self.coins end
        function p:AddCoins(n) self.coins = self.coins + n end
        players[index] = p
    end
    include("scripts.items.opus_mode"):Init(env.mod)
    env.load()
    for _, name in ipairs({ "claude_chan", "claude_chan_b", "gpt_reset" }) do
        include("scripts.characters." .. name):Init(env.mod, env.Risk)
    end
    env.fire("MC_POST_GAME_STARTED", nil, false)
    local state = { env.Risk.state.claudeUsage["0"], env.Risk.state.claudeAppeal["1"], env.Risk.state.gptReset["2"] }
    state[3].fullSend = true
    for _, p in ipairs(players) do env.give(p, "OPUS_MODE") end
    local serial = 0
    function env.laser(owner, parent)
        serial = serial + 1
        local data = {}
        local laser = { Type = EntityType.ENTITY_LASER, Variant = 1, hash = -serial,
            SpawnerEntity = owner, Parent = parent, FrameCount = 0, CollisionDamage = 6.25,
            Timeout = 24, Radius = 35, Size = 12, OneHit = false, DisableFollowParent = false,
            Position = Vector(30, 40), Velocity = Vector(2, 3), TearFlags = 17, alive = true }
        function laser:GetData() return data end
        function laser:ToPlayer() return nil end
        function laser:ToFamiliar() return nil end
        function laser:IsCircleLaser() return false end
        function laser:Exists() return self.alive end
        function laser:Remove() self.alive = false end
        return laser
    end
    return env, players, state
end
local function resources(s, usage, quota, credits)
    assert(s[1].value == usage, "unexpected Usage " .. s[1].value)
    assert(s[2].quota == quota, "unexpected Quota " .. s[2].quota)
    assert(s[3].credits == credits, "unexpected Credits " .. s[3].credits)
end
local function wallet(p, count, coins)
    assert((p:GetData().ccOpusTears or 0) == count, "unexpected Opus count")
    assert(p.coins == coins, "unexpected Opus wallet charge")
end
local function unchanged(laser, owner, parent)
    assert(laser.SpawnerEntity == owner and laser.Parent == parent and laser.Type == EntityType.ENTITY_LASER)
    assert(laser:Exists() and laser.Variant == 1 and laser.CollisionDamage == 6.25)
    assert(laser.Timeout == 24 and laser.Radius == 35 and laser.Size == 12 and laser.TearFlags == 17)
    assert(not laser.OneHit and not laser.DisableFollowParent)
    assert(laser.Position == Vector(30, 40) and laser.Velocity == Vector(2, 3), "native weapon fields changed")
end
local function init(env, laser, advance)
    env.frame = env.frame + (advance or 1)
    env.fire("MC_POST_LASER_INIT", nil, laser)
end

for index, label in ipairs({ "Claude Usage", "Tainted Claude Quota", "Tainted GPT Credits" }) do
    test(label .. " ignores later child starts but bills the next primary", function()
        local env, players, s = fresh()
        local p = players[index]
        local parent = env.laser(p)
        init(env, parent)
        local expected = { index == 1 and 4 or 0, index == 2 and 219 or 220, index == 3 and 79 or 80 }
        resources(s, table.unpack(expected)); wallet(p, 1, 5)
        for _, delay in ipairs({ 0, 1, 7 }) do
            local child = env.laser(p, parent)
            init(env, child, delay)
            resources(s, table.unpack(expected)); wallet(p, 1, 5)
            unchanged(child, p, parent)
        end
        init(env, env.laser(p))
        resources(s, index == 1 and 8 or 0, index == 2 and 218 or 220, index == 3 and 78 or 80)
        wallet(p, 2, 5)
        for other, partner in ipairs(players) do if other ~= index then wallet(partner, 0, 5) end end
    end)
end

test("children cannot trigger allowance thresholds; primary starts still do", function()
    local env, players, s = fresh()
    s[1].value, s[2].quota, s[3].credits = 96, 1, 1
    local damage, captions = {}, #env.captions
    for i, p in ipairs(players) do
        p:GetData().ccOpusTears = 9
        damage[i] = p.Damage
        local parent = env.laser(p)
        local child = env.laser(p, parent)
        init(env, child)
        unchanged(child, p, parent)
    end
    resources(s, 96, 1, 1)
    assert(s[1].limited == 0 and s[3].fullSend and #env.captions == captions)
    for i, p in ipairs(players) do near(p.Damage, damage[i]); wallet(p, 9, 5) end
    for _, p in ipairs(players) do init(env, env.laser(p)) end
    resources(s, 100, 0, 0)
    assert(s[1].limited == 150 and not s[3].fullSend and #env.captions == captions + 3)
    near(players[1].Damage, damage[1] * 0.4)
    near(players[2].Damage, damage[2] * 0.5 / 1.25)
    near(players[3].Damage, damage[3] / 1.5)
    for _, p in ipairs(players) do wallet(p, 0, 4) end
end)

test("Swarm primary surcharges remain once while children stay free", function()
    local env, players, s = fresh()
    for _, p in ipairs(players) do env.give(p, "SUBAGENT_SWARM") end
    for _, p in ipairs(players) do
        local parent = env.laser(p)
        init(env, parent)
        init(env, env.laser(p, parent))
    end
    resources(s, 8, 218, 79)
    for _, p in ipairs(players) do wallet(p, 1, 5); init(env, env.laser(p)) end
    resources(s, 16, 216, 78)
    for _, p in ipairs(players) do wallet(p, 2, 5) end
end)

test("non-laser parent stays paid; familiar and enemy sources stay free", function()
    local env, players, s = fresh()
    for _, p in ipairs(players) do
        local laser = env.laser(p, p)
        init(env, laser)
        unchanged(laser, p, p)
    end
    resources(s, 4, 219, 79)
    for _, p in ipairs(players) do
        init(env, env.laser(env.familiar(p)))
        init(env, env.laser(env.npc(400)))
        wallet(p, 1, 5)
    end
    resources(s, 4, 219, 79)
end)

test("held primary windows still pay and child updates remain free", function()
    local env, players, s = fresh()
    local parents, children = {}, {}
    for i, p in ipairs(players) do parents[i] = env.laser(p); init(env, parents[i]) end
    resources(s, 4, 219, 79)
    for i, p in ipairs(players) do
        children[i] = env.laser(p, parents[i])
        init(env, children[i])
    end
    resources(s, 4, 219, 79)
    for age = 6, 12, 6 do
        env.frame = env.frame + 6
        for i, p in ipairs(players) do
            local child, parent = children[i], parents[i]
            child.FrameCount, parent.FrameCount = age, age
            env.fire("MC_POST_LASER_UPDATE", nil, child)
            unchanged(child, p, parent)
            env.fire("MC_POST_LASER_UPDATE", nil, parent)
            env.fire("MC_POST_LASER_UPDATE", nil, parent)
            wallet(p, 1 + age / 6, 5)
        end
        resources(s, 4 * (1 + age / 6), 220 - (1 + age / 6), 80 - (1 + age / 6))
    end
end)

for index, label in ipairs({ "Claude Usage", "Tainted Claude Quota", "Tainted GPT Credits" }) do
    test("detached " .. label .. " stays free after init and leaves primary windows available", function()
        local env, players, s = fresh()
        local p = players[index]
        local function paid(count)
            resources(s, index == 1 and count * 4 or 0, index == 2 and 220 - count or 220,
                index == 3 and 80 - count or 80)
            wallet(p, count, 5)
        end
        local parent = env.laser(p)
        init(env, parent)
        local child = env.laser(p, parent)
        init(env, child)
        parent:Remove(); child.Parent, child.FrameCount = nil, 7
        env.frame = 20
        env.fire("MC_POST_LASER_UPDATE", nil, child)
        env.fire("MC_POST_LASER_UPDATE", nil, child)
        paid(1); unchanged(child, p, nil)
        local primary = env.laser(p, p)
        primary.FrameCount = 6
        env.fire("MC_POST_LASER_UPDATE", nil, primary)
        env.fire("MC_POST_LASER_UPDATE", nil, primary)
        paid(2)
        env.frame, primary.FrameCount = 26, 12
        env.fire("MC_POST_LASER_UPDATE", nil, primary)
        paid(3)
        for other, partner in ipairs(players) do if other ~= index then wallet(partner, 0, 5) end end
    end)
end

test("detached children observed only during early or paused updates retain classification", function()
    for _, mode in ipairs({ "early", "paused", "eligible" }) do
        local env, players, s = fresh()
        local nativeGame = Game
        function Game()
            local game = nativeGame()
            function game:IsPaused() return env.paused or false end
            return game
        end
        local parents, children = {}, {}
        for i, p in ipairs(players) do
            parents[i] = env.laser(p); init(env, parents[i])
            children[i] = env.laser(p, parents[i]) -- No child initialization callback.
            children[i].FrameCount = mode == "eligible" and 7 or 0
            env.paused = mode == "paused"
            env.fire("MC_POST_LASER_UPDATE", nil, children[i])
            env.paused = false
            children[i].Parent, children[i].FrameCount = nil, 7
        end
        env.frame = 30
        for i, p in ipairs(players) do
            env.fire("MC_POST_LASER_UPDATE", nil, children[i])
            unchanged(children[i], p, nil)
            wallet(p, 1, 5)
        end
        resources(s, 4, 219, 79)
        for i, parent in ipairs(parents) do
            parent.FrameCount = 6
            env.fire("MC_POST_LASER_UPDATE", nil, parent)
            wallet(players[i], 2, 5)
        end
        resources(s, 8, 218, 78)
    end
end)

test("detached classification lasts with the entity across resets but not reused pointer hashes", function()
    for _, reset in ipairs({ "room", "new-run", "continue" }) do
        local env, players = fresh()
        local children = {}
        for i, p in ipairs(players) do
            children[i] = env.laser(p, env.laser(p))
            init(env, children[i]); children[i].Parent = nil
        end
        if reset == "room" then env.fire("MC_POST_NEW_ROOM")
        else
            env.fire("MC_PRE_GAME_EXIT", nil, true)
            env.fire("MC_POST_GAME_STARTED", nil, reset == "continue")
        end
        local s = { env.Risk.state.claudeUsage["0"], env.Risk.state.claudeAppeal["1"], env.Risk.state.gptReset["2"] }
        s[3].fullSend = true
        resources(s, 0, 220, 80)
        env.frame = 30
        for i, p in ipairs(players) do
            children[i].FrameCount = 7
            env.fire("MC_POST_LASER_UPDATE", nil, children[i]); wallet(p, 0, 5)
        end
        resources(s, 0, 220, 80)
        for i, p in ipairs(players) do
            local primary = env.laser(p)
            primary.hash, primary.FrameCount = children[i].hash, 6 -- Fresh entity data at a reused address.
            env.fire("MC_POST_LASER_UPDATE", nil, primary); wallet(p, 1, 5)
        end
        resources(s, 4, 219, 79)
    end
end)

test("detached child classification predates Opus ownership and cannot spend the threshold coin", function()
    local env, players, s = fresh()
    local parents, children = {}, {}
    for i, p in ipairs(players) do
        p.items[env.Item.OPUS_MODE] = nil
        parents[i] = env.laser(p); init(env, parents[i])
        children[i] = env.laser(p, parents[i]); init(env, children[i])
        env.give(p, "OPUS_MODE")
        p:GetData().ccOpusTears = 9
        children[i].Parent, children[i].FrameCount = nil, 7
    end
    env.frame = 30
    for i, p in ipairs(players) do
        env.fire("MC_POST_LASER_UPDATE", nil, children[i]); wallet(p, 9, 5)
    end
    resources(s, 4, 219, 79)
    for i, parent in ipairs(parents) do
        parent.FrameCount = 6
        env.fire("MC_POST_LASER_UPDATE", nil, parent); wallet(players[i], 0, 4)
    end
    resources(s, 8, 218, 78)
end)

test("detached nested children do not become a co-op partner's paid attack", function()
    local env, players, s = fresh()
    local p, q = players[1], players[2]
    local parent = env.laser(p); init(env, parent)
    local child = env.laser(p, parent); init(env, child)
    local nested = env.laser(p, child); init(env, nested)
    child.Parent, nested.Parent = nil, nil
    child.SpawnerEntity, nested.SpawnerEntity = q, q
    child.FrameCount, nested.FrameCount = 7, 7
    env.frame = 30
    env.fire("MC_POST_LASER_UPDATE", nil, child)
    env.fire("MC_POST_LASER_UPDATE", nil, nested)
    resources(s, 4, 220, 80); wallet(p, 1, 5); wallet(q, 0, 5)
    unchanged(child, q, nil); unchanged(nested, q, nil)
    local primary = env.laser(q); primary.FrameCount = 6
    env.fire("MC_POST_LASER_UPDATE", nil, primary)
    resources(s, 4, 219, 80); wallet(q, 1, 5)
end)

for _, failure in ipairs(failures) do print("FAIL " .. failure) end
assert(#failures == 0, tostring(#failures) .. " child-laser groups failed")
print("PASS child-laser billing: " .. passed .. " callback groups")
