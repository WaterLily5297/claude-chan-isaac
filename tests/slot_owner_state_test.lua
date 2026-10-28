-- Saved per-slot item state (backlog and meme extras) must stay with the live
-- player who earned it: a replacement entity in the same slot starts fresh,
-- reordered players keep their own values, a removed player's values cannot
-- reach a later join, and Continue restores slots to the recreated players.
-- Supplied pointer/seed identities only; native revival, co-op join and
-- Tainted Lazarus ordering are not observed here.
local root = arg[1]
local Env = dofile(root .. "/tests/lib/backlog_env.lua")

local function near(a, b, label) assert(math.abs(a - b) < 1e-6, label .. ": expected " .. b .. ", got " .. a) end

local function setup()
    local env = Env.New(root)
    local p, q = env.player(300), env.player(320)
    p.InitSeed, q.InitSeed = 11, 22
    env.load(); env.newRoom(); env.frame = 1000
    include("scripts.items.decimal_pill"):Init(env.mod, env.Risk)
    env.give(p, "ANNIVERSARY_CAKE")
    env.update(15); env.newFloor()
    env.fire("MC_USE_PILL", 50, 50, p, 0)
    p:EvaluateItems()
    near(p.Damage, 3.5 + 0.15 + 0.11, "positive control: cake and 9.11 bonus belong to p")
    q:EvaluateItems(); near(q.Damage, 3.5, "positive control: q has no bonus")
    return env, p, q
end

local function newcomer(env, seed)
    local r = env.player(340)
    env.players[#env.players] = nil
    r.InitSeed = seed
    return r
end

-- A new entity in the same slot does not inherit the old owner's values.
do
    local env, p = setup()
    local r = newcomer(env, 33)
    env.players[1] = r
    env.give(r, "ANNIVERSARY_CAKE")
    near(r.Damage, 3.5, "replacement must not inherit cake or 9.11 bonus")
    -- The original entity returning to the slot gets its own values back.
    env.players[1] = p
    env.update()
    p:EvaluateItems()
    near(p.Damage, 3.76, "returning owner keeps its own values within the session")
    -- The same pointer with a new seed is also a different owner.
    local _, p2 = setup()
    p2.InitSeed = 99
    p2:EvaluateItems()
    near(p2.Damage, 3.5, "reused pointer with a new seed must start fresh")
    print("PASS slot owners: replacement, reused pointer and returning owner")
end

-- Reordered slots keep each player's values, and both caches are refreshed.
do
    local env, p, q = setup()
    env.players[1], env.players[2] = q, p
    p.Damage, q.Damage = 0, 0
    env.update()
    near(p.Damage, 3.76, "moved player keeps and re-evaluates its own values")
    near(q.Damage, 3.5, "the other player does not take them")
    assert(env.Risk.state.backlog.players["1"].cake == 0.15
        and env.Risk.state.memeExtras.players["1"].decimal == 0.11, "saved tables follow the player")
    print("PASS slot owners: reorder moves saved tables and refreshes caches")
end

-- A removed player's values are gone before a save, and cannot reach a later join.
do
    local env, p, q = setup()
    env.players = { q }
    env.update()
    assert(env.Risk.state.backlog.players["1"] == nil and env.Risk.state.memeExtras.players["1"] == nil,
        "removed slot must not be saved")
    q:EvaluateItems(); near(q.Damage, 3.5, "remaining player keeps its own values")
    local joined = newcomer(env, 44)
    env.players[2] = joined
    env.give(joined, "ANNIVERSARY_CAKE")
    env.update()
    near(joined.Damage, 3.5, "later join must start fresh")
    print("PASS slot owners: removal and later join")
end

-- Continue binds saved slots to recreated players with new pointers.
-- Risk:Load always replaces Risk.state on Continue, as modelled here.
do
    local env, p, q = setup()
    local saved = env.Risk.state
    local function copy(t)
        if type(t) ~= "table" then return t end
        local out = {}
        for k, v in pairs(t) do out[k] = copy(v) end
        return out
    end
    env.fire("MC_PRE_GAME_EXIT", nil, true)
    local p2, q2 = newcomer(env, 55), newcomer(env, 66)
    env.players = { p2, q2 }
    env.Risk.state = copy(saved)
    env.fire("MC_POST_GAME_STARTED", nil, true)
    env.give(p2, "ANNIVERSARY_CAKE")
    near(p2.Damage, 3.76, "Continue restores slot 0 to its recreated player")
    q2:EvaluateItems(); near(q2.Damage, 3.5, "Continue keeps slot 1 fresh")
    print("PASS slot owners: Continue rebinding")
end
