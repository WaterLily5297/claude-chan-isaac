-- F7: Opus Mode's partial ten-attack count survives Continue, and belongs to
-- the live player who built it. Risk.state is copied the way Risk:Load
-- rebuilds it; player entities and their data are recreated. Supplied
-- callbacks only; native save timing is not observed.
local root = arg[1]
local Env = dofile(root .. "/tests/lib/backlog_env.lua")

local function copy(t)
    if type(t) ~= "table" then return t end
    local out = {}
    for k, v in pairs(t) do out[k] = copy(v) end
    return out
end

local env = Env.New(root)
local function opusPlayer(x, seed)
    local p = env.player(x)
    p.InitSeed, p.coins = seed, 5
    function p:GetNumCoins() return self.coins end
    function p:AddCoins(n) self.coins = self.coins + n end
    return p
end
local p, q = opusPlayer(300, 1), opusPlayer(320, 2)
include("scripts.items.opus_mode"):Init(env.mod, env.Risk)
env.load(); env.newRoom()
env.give(p, "OPUS_MODE"); env.give(q, "OPUS_MODE")
for _ = 1, 7 do env.shoot(p) end
for _ = 1, 2 do env.shoot(q) end
assert(p:GetData().ccOpusTears == 7 and p.coins == 5, "positive control: seven attacks, no coin yet")
assert(env.Risk.state.opusTears["0"] == 7 and env.Risk.state.opusTears["1"] == 2, "counts are saved by slot")

-- Save, exit and Continue: new entities, rebuilt saved state.
local saved = copy(env.Risk.state)
env.fire("MC_PRE_GAME_EXIT", nil, true)
local p2, q2 = opusPlayer(300, 1), opusPlayer(320, 2)
env.players = { p2, q2 }
env.Risk.state = saved
env.fire("MC_POST_GAME_STARTED", nil, true)
env.give(p2, "OPUS_MODE"); env.give(q2, "OPUS_MODE")
for _ = 1, 3 do env.shoot(p2) end
assert(p2.coins == 4 and p2:GetData().ccOpusTears == 0, "the tenth attack after Continue pays the coin")
env.shoot(q2)
assert(q2.coins == 5 and q2:GetData().ccOpusTears == 3, "the partner resumes its own count")
print("PASS Opus Mode: partial bill survives Continue")

-- A replacement in the same slot does not inherit the count; a corrupt value is ignored.
env.shoot(p2) -- p2 at 1
local r = opusPlayer(340, 3)
env.players[#env.players] = nil
env.players[1] = r
env.give(r, "OPUS_MODE")
env.shoot(r)
assert(r:GetData().ccOpusTears == 1, "a replacement starts its own count")
env.Risk.state.opusTears["1"] = 42
q2:GetData().ccOpusTears = nil
env.shoot(q2)
assert(q2:GetData().ccOpusTears == 1, "a corrupt saved count restarts at zero")

-- A new run starts with no saved count.
env.fire("MC_PRE_GAME_EXIT", nil, false)
env.Risk.state = {}
env.fire("MC_POST_GAME_STARTED", nil, false)
r:GetData().ccOpusTears = nil
env.shoot(r)
assert(r:GetData().ccOpusTears == 1 and env.Risk.state.opusTears["0"] == 1, "new run starts from zero")
print("PASS Opus Mode: replacement, corrupt value and new run")
