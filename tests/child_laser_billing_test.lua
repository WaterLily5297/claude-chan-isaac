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

for _, failure in ipairs(failures) do print("FAIL " .. failure) end
assert(#failures == 0, tostring(#failures) .. " child-laser groups failed")
print("PASS child-laser billing: " .. passed .. " callback groups")
