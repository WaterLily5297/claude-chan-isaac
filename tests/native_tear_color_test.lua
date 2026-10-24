-- Real character callbacks must compose with native color, alpha and offsets.
local root = arg[1]
local callbacks = {}
local C = {Player={CLAUDE_CHAN=41, DEEPSEEK_CHAN=42, DEEPSEEK_CHAN_B=44}, Item={}}
function include(name)
    if name == "scripts.constants" then return C end
    if name == "scripts.hud_text" then return {} end
    return dofile(root.."/"..name:gsub("%.","/")..".lua")
end
function Color(r,g,b,a,ro,go,bo) return {R=r,G=g,B=b,A=a,RO=ro,GO=go,BO=bo} end
ModCallbacks = setmetatable({}, {__index=function(_,k) return k end})
CacheFlag = {CACHE_DAMAGE=1,CACHE_RANGE=2,CACHE_SHOTSPEED=3,CACHE_SPEED=4,CACHE_TEARCOLOR=5}
local mod = {}
function mod:AddCallback(id,fn) callbacks[#callbacks+1]={id,fn} end
include("scripts.characters.claude_chan"):Init(mod,{state={}})
include("scripts.characters.deepseek_chan"):Init(mod)
local function apply(kind, base)
    local p={TearColor=base,GetPlayerType=function() return kind end}
    for _,c in ipairs(callbacks) do
        if c[1]==ModCallbacks.MC_EVALUATE_CACHE then c[2](mod,p,CacheFlag.CACHE_TEARCOLOR) end
    end
    return p.TearColor
end
local function near(a,b) assert(math.abs(a-b)<1e-8, tostring(a).." ~= "..b) end
for _,case in ipairs({{41,1,0.55,0.25},{42,0.35,0.65,1},{44,0.45,1,0.95}}) do
    local base=Color(0.2,0.7,0.9,0.6,0.11,0.22,0.33)
    local c=apply(case[1],base)
    near(c.R,base.R*case[2]); near(c.G,base.G*case[3]); near(c.B,base.B*case[4])
    assert(c.A==base.A and c.RO==base.RO and c.GO==base.GO and c.BO==base.BO)
    assert(base.R==0.2 and base.A==0.6, "do not mutate shared native color objects")
    local reset=apply(case[1],Color(1,1,1,1,0,0,0))
    near(reset.R,case[2]); near(reset.G,case[3]); near(reset.B,case[4])
    assert(reset.A==1 and reset.RO==0, "item removal recomputes from the native cache")
end
local native=Color(0,1,0,1,0,0.5,0)
assert(apply(0,native)==native, "unrelated players must remain unchanged")
local limited=include("scripts.characters.tear_tint").Apply(native,0.5,0.5,0.5,0.7)
assert(limited.R==0 and limited.G==0.5 and limited.B==0 and limited.GO==0.5 and limited.A==0.7)
print("OK: native item color, opacity and additive offsets survive identity and Limited tints")
