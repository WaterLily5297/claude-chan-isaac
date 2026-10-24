-- Real module callbacks with independent lifecycle, boundary and co-op fixtures.
local root=arg[1]
function include(n)
    if n=='scripts.characters.model_roster' and arg[2] then return dofile(arg[2]) end
    return dofile(root.."/"..n:gsub("%.","/")..".lua")
end
local names={"GPT-chan","Gemini-chan","Grok-chan","Qwen-chan","Llama-chan","Mistral-chan","Doubao-chan","Kimi-chan","GLM-chan"}
Isaac={GetItemIdByName=function() return -1 end, GetTrinketIdByName=function() return -1 end,
    GetPillEffectByName=function() return -1 end}
function Isaac.GetPlayerTypeByName(n,b)
    if n=="Claude-chan" then return b and 141 or 41 end
    if n=="DeepSeek-chan" then return b and 142 or 42 end
    for i,name in ipairs(names) do if n==name then return 50+i end end
    return -1
end
ModCallbacks=setmetatable({},{__index=function(_,k) return k end})
CacheFlag={CACHE_DAMAGE=1,CACHE_FIREDELAY=2,CACHE_SPEED=4,CACHE_RANGE=8,CACHE_SHOTSPEED=16,CACHE_TEARFLAG=32,CACHE_TEARCOLOR=64,CACHE_LUCK=128}
TearFlags={TEAR_PIERCING=1,TEAR_HOMING=2,TEAR_SPECTRAL=4}
DamageFlag={DAMAGE_FAKE=8,DAMAGE_NO_PENALTIES=268435456}; UseFlag={USE_CARBATTERY=32}
EntityType={ENTITY_PLAYER=1,ENTITY_PROJECTILE=9}; Direction={NO_DIRECTION=-1}
ProjectileFlags={CANT_HIT_PLAYER=1}
ButtonAction={ACTION_DROP=1,ACTION_MAP=2}; ActiveSlot={SLOT_POCKET=2}
CollectibleType={COLLECTIBLE_BOOK_OF_SECRETS=777,COLLECTIBLE_DECK_OF_CARDS=778}
function GetPtrHash(p) return p.pointer end
function Color(r,g,b,a,ro,go,bo) return {R=r,G=g,B=b,A=a,RO=ro,GO=go,BO=bo} end
local trigger=false
local pressed, paused, hudVisible = {}, false, true
Input={IsActionTriggered=function() return trigger end,
    IsActionPressed=function(_, controller) return pressed[controller] == true end}
local callbacks={}
local mod={AddCallback=function(_,id,fn) callbacks[id]=fn end}
local function fire(id,...) if callbacks[id] then return callbacks[id](mod,...) end end
local room,floor,frame=101,200,0
local players={}
local risk={state={}}
function Isaac.GetPlayer(i) return players[i+1] end
function Isaac.GetScreenHeight() return 270 end
local rendered={}
function Isaac.RenderText(text) rendered[#rendered+1]=text end
function Game() return {
    GetNumPlayers=function() return #players end,
    GetFrameCount=function() return frame end,
    IsPaused=function() return paused end,
    GetLevel=function() return {GetDungeonPlacementSeed=function() return floor end,
        GetCurrentRoomDesc=function() return {SpawnSeed=room} end} end,
    GetHUD=function() return {ShowItemText=function() end,IsVisible=function() return hudVisible end} end,
} end
local nextPointer=0
local function player(name)
    nextPointer=nextPointer+1
    local p={kind=Isaac.GetPlayerTypeByName(name,false),speed=0,shoot=-1,flies=0,hearts=2,dead=false,
        Position={},ControllerIndex=0,pocket=0,pointer=nextPointer,InitSeed=nextPointer*101}
    function p:GetPlayerType() return self.kind end
    function p:ToPlayer() return self end
    function p:IsDead() return self.dead end
    function p:AreControlsEnabled() return self.controls ~= false end
    function p:GetFireDirection() return self.shoot end
    function p:AddBlueFlies(n) self.flies=self.flies+n end
    function p:AddHearts(n) self.hearts=math.min(4,self.hearts+n) end
    function p:CanPickRedHearts() return self.hearts<4 end
    function p:SetPocketActiveItem(id) self.pocket=id end
    function p:AddCacheFlags() end
    function p:EvaluateItems()
        self.Damage=10; self.MaxFireDelay=9; self.MoveSpeed=1; self.ShotSpeed=1; self.TearRange=100; self.TearFlags=0; self.Luck=0
        self.TearColor=self.itemColor or Color(1,1,1,1,0,0,0)
        for _,f in pairs(CacheFlag) do fire('MC_EVALUATE_CACHE',self,f) end
    end
    p.Velocity={Length=function() return p.speed end}
    return p
end
local R=include('scripts.characters.model_roster')
R:Init(mod,risk)
local function start(...)
    players={...}; room=101; floor=200; frame=0; trigger=false
    pressed={}; paused=false; hudVisible=true
    fire('MC_POST_GAME_STARTED',false)
    for _,x in ipairs(players) do x:EvaluateItems() end
end
local function clear()
    room=room+1; fire('MC_POST_NEW_ROOM'); fire('MC_PRE_SPAWN_CLEAN_AWARD')
end
local function hit(p) fire('MC_ENTITY_TAKE_DMG',p,1,0) end
local function near(a,b) assert(math.abs(a-b)<1e-8,tostring(a)..' ~= '..tostring(b)) end
-- Different Lua references may point at the same engine entity. Forward both
-- reads and writes while keeping the wrapper's table identity distinct.
local function wrap(p) return setmetatable({}, {__index=p, __newindex=p}) end
local function input(p, down)
    frame=frame+1; pressed[p.ControllerIndex]=down; trigger=down
    fire('MC_POST_PEFFECT_UPDATE',wrap(p)); trigger=false
end
local function tap(p)
    input(p,false)
    local before=p.Damage
    input(p,true)
    near(p.Damage,before) -- Pressing to begin a hold must not change mode.
    input(p,false)
end
-- Every family keeps its mechanics in its own module; the roster only tints them.
for _,name in ipairs(names) do
    local x=player(name); start(x)
    near(x.Damage,10); near(x.MaxFireDelay,9); assert(x.TearFlags==0)
    x.speed=1; for _=1,180 do fire('MC_POST_PEFFECT_UPDATE',x) end
    tap(x); near(x.Damage,10); near(x.MaxFireDelay,9); assert(x.TearFlags==0)
    rendered={}; fire('MC_POST_RENDER'); assert(#rendered==0,name..' draws its own HUD line')
end

local p
-- The roster ignores hits, clears and active items; it keeps no state.
p=player('Kimi-chan'); start(p)
for _=1,3 do clear() end; hit(p); fire('MC_USE_ITEM',1,nil,p,0); near(p.Damage,10); assert(p.TearRange==100)
p=player('GLM-chan'); start(p); assert(p.pocket==0,'GLM starts without a forced pocket item')
assert(risk.state.modelRoster==nil)

-- Tears are tinted, so an item's own color and offsets survive.
p=player('GPT-chan'); start(p)
near(p.TearColor.R,0.4); near(p.TearColor.G,1); near(p.TearColor.B,0.75)
p.itemColor=Color(0.5,0.5,1,0.8,0.2,0,0.3); p:EvaluateItems()
near(p.TearColor.R,0.2); near(p.TearColor.G,0.5); near(p.TearColor.B,0.75)
near(p.TearColor.A,0.8); near(p.TearColor.RO,0.2); near(p.TearColor.BO,0.3)

-- New IDs must not activate mechanics for either DeepSeek form or vanilla players.
p=player('DeepSeek-chan'); start(p)
assert(R:Find(p)==nil)
p.kind=142; assert(R:Find(p)==nil)
p.kind=0; assert(R:Find(p)==nil)

for id in pairs(callbacks) do assert(id=='MC_EVALUATE_CACHE', 'roster registers only the tint: '..id) end
print('OK: roster identities, tint-only callbacks for all nine families and protected existing characters')
