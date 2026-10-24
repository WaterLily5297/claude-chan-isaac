-- Real backlog helpers and all four resource-owning forms in registration order.
-- FireTear callbacks are synchronous in this fixture; engine acceptance is separate.
local root = arg[1]
local Env = dofile(root .. "/tests/lib/backlog_env.lua")
local env = Env.New(root)
local nativeInclude = include
function include(name)
    if name == "scripts.hud_text" then return {Draw=function() end} end
    return nativeInclude(name)
end
function Isaac.GetPlayerTypeByName(name, tainted)
    if name == "Claude-chan" then return tainted and 43 or 41 end
    if name == "DeepSeek-chan" then return tainted and 44 or 42 end
    return -1
end
CacheFlag.CACHE_TEARCOLOR = 32
ActiveSlot.SLOT_POCKET = 2
CollectibleType.COLLECTIBLE_BIRTHRIGHT = 619
ButtonAction = {ACTION_DROP=11}
Input = {IsActionPressed=function() return false end}
TearFlags = {TEAR_LUDOVICO=1<<10}
function Color(r,g,b,a,ro,go,bo)
    return {R=r,G=g,B=b,A=a,RO=ro or 0,GO=go or 0,BO=bo or 0}
end
local function color() return Color(1,1,1,1) end
getmetatable(Vector(0,0)).Rotated = function(v, angle)
    local a = math.rad(angle)
    return Vector(v.X*math.cos(a)-v.Y*math.sin(a), v.X*math.sin(a)+v.Y*math.cos(a))
end
local originalTear = env.tear
function env.tear(owner)
    local t = originalTear(owner)
    t.CollisionDamage, t.Color = owner.Damage, color()
    function t:HasTearFlags() return false end
    return t
end
local forms = {}
for _, kind in ipairs({41,43,42,44}) do
    local p = env.player(300)
    p.formType, p.InitSeed, p.ControllerIndex, p.MaxFireDelay = kind, kind, #forms, 0
    p.TearColor = color()
    function p:GetPlayerType() return self.formType end
    function p:AreControlsEnabled() return true end
    function p:SetPocketActiveItem() end
    function p:FireTear(pos,vel,_,_,_,_,mult)
        local t = env.tear(self)
        t.Position, t.Velocity, t.CollisionDamage = pos, vel, self.Damage*mult
        self.fired[#self.fired+1] = t
        env.fire("MC_POST_FIRE_TEAR", nil, t)
        return t
    end
    forms[#forms+1] = p
end
env.load()
for _, module in ipairs({"claude_chan","claude_chan_b","deepseek_rice","deepseek_peak"}) do
    include("scripts.characters."..module):Init(env.mod, env.Risk, env.Meal)
end
env.fire("MC_POST_GAME_STARTED", nil, false)
env.Risk.state.deepseekRice["2"].thought = 150
local function balances()
    local s = env.Risk.state
    return {s.claudeUsage["0"].value, s.claudeAppeal["1"].quota,
        s.deepseekRice["2"].thought, s.deepseekPeak["3"].compute}
end
local function same(actual, expected, label)
    for i=1,4 do assert(actual[i] == expected[i], label.." form "..i..": "..actual[i].." ~= "..expected[i]) end
end
local initial = balances()
local helpers = {}
for i,p in ipairs(forms) do
    env.frame = env.frame + 1
    env.C.Prime(p, "regression", 2)
    local tear = env.C.FireDerived(p, Vector(10,0), 0.6)
    helpers[i] = tear
    assert(tear and env.C.Primed(p,"regression"), "derived helpers must preserve primed bonuses")
end
same(balances(), initial, "helper must not bill (all balances "..table.concat(balances(),",")..")")
for i,p in ipairs(forms) do assert(helpers[i].CollisionDamage == p.Damage*0.6, "Thought must not be spent on a helper") end
-- A real shot on the very next frame still pays; the helper's scope must end.
env.frame = env.frame + 1
-- Avoid testing raw fork graphics in this billing fixture; tainted DeepSeek's
-- payment occurs before its optional Spawn result is converted to a tear.
for _,p in ipairs(forms) do env.shoot(p) end
same(balances(), {4,219,0,10}, "primary shot must bill")
for _,p in ipairs(forms) do assert(not env.C.Primed(p,"regression")) end

-- Exercise the actual item schedules, not only their shared service.
local paid = balances()
local before = {}
for i,p in ipairs(forms) do
    before[i] = #p.fired
    assert(env.use(env.Item.PLEASE_RETRY, p).Discharge)
end
env.update(31)
same(balances(), paid, "three scheduled retries must not bill")
for i,p in ipairs(forms) do assert(#p.fired == before[i]+3) end

for _,p in ipairs(forms) do env.give(p,"ONE_MORE_FINGER") end
for _=1,5 do
    env.frame = env.frame+1
    for _,p in ipairs(forms) do env.shoot(p) end
end
paid = balances()
for i,p in ipairs(forms) do before[i] = #p.fired end
env.update()
same(balances(), paid, "fifth-shot helper must not bill")
for i,p in ipairs(forms) do assert(#p.fired == before[i]+1) end

-- Do not turn the billing exemption into immunity to an active Limited penalty.
local usage = env.Risk.state.claudeUsage["0"]
usage.value, usage.limited = 100, 30
local weak = env.C.FireDerived(forms[1], Vector(10,0), 0.6)
assert(math.abs(weak.CollisionDamage-forms[1].Damage*0.6*0.4)<1e-8)
assert(usage.value == 100 and usage.limited == 30)
usage.limited = 0
env.frame = env.frame+1
env.C.FireDerived(forms[1], Vector(10,0), 0.6)
assert(usage.limited == 0, "a helper cannot start Limited at the threshold")
print("OK: real Retry/Finger helpers preserve four form resources; primary billing and Limited remain")
