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
local p=player('GPT-chan'); start(p)
near(p.Damage,13.5); near(p.MaxFireDelay,11)
tap(p)
near(p.Damage,8.5); near(p.MaxFireDelay,7)
-- A recreated entity and module must read the stored mode, not entity data.
fire('MC_PRE_GAME_EXIT'); p=player('GPT-chan'); players={p}
callbacks={}; include('scripts.characters.model_roster'):Init(mod,risk)
fire('MC_POST_NEW_LEVEL'); fire('MC_POST_GAME_STARTED',true)
near(p.Damage,8.5)
start(p); near(p.Damage,13.5)

p=player('Gemini-chan'); start(p); assert(p.TearFlags==1); near(p.Damage,12)
tap(p)
assert(p.TearFlags==2); near(p.Damage,9)
p=player('Grok-chan'); start(p); p.speed=1
for _=1,180 do fire('MC_POST_PEFFECT_UPDATE',p) end
near(p.Damage,12.5); p.speed=0
for _=1,50 do fire('MC_POST_PEFFECT_UPDATE',p) end
near(p.Damage,10)

p=player('Qwen-chan'); local other=player('Qwen-chan'); start(p,other)
for _=1,7 do clear() end
near(p.Damage,13); near(other.Damage,13)
fire('MC_ENTITY_TAKE_DMG',p,1,DamageFlag.DAMAGE_FAKE); near(p.Damage,13)
hit(p); near(p.Damage,10); near(other.Damage,13)
room=room+1; fire('MC_POST_NEW_ROOM'); hit(p); fire('MC_PRE_SPAWN_CLEAN_AWARD'); near(p.Damage,10)
clear(); near(p.Damage,10.6)
for _=1,5 do fire('MC_PRE_SPAWN_CLEAN_AWARD') end
near(p.Damage,10.6)
-- A hit persists through a process-style continue, preventing a false flawless award.
room=room+1; fire('MC_POST_NEW_ROOM'); hit(p); fire('MC_PRE_GAME_EXIT')
p=player('Qwen-chan'); players={p}; callbacks={}; include('scripts.characters.model_roster'):Init(mod,risk)
fire('MC_POST_NEW_ROOM'); fire('MC_POST_GAME_STARTED',true); fire('MC_PRE_SPAWN_CLEAN_AWARD'); near(p.Damage,10)

p=player('Llama-chan'); other=player('Claude-chan'); start(p,other)
clear(); assert(p.flies==0); clear(); assert(p.flies==2 and other.flies==2)
fire('MC_PRE_SPAWN_CLEAN_AWARD'); assert(p.flies==2)
near(p.Damage,9)
-- Reentering a previously awarded room cannot farm rewards.
local old=room; clear(); room=old; fire('MC_POST_NEW_ROOM'); fire('MC_PRE_SPAWN_CLEAN_AWARD')
assert(p.flies==2)

p=player('Mistral-chan'); start(p); near(p.MoveSpeed,1.15); near(p.ShotSpeed,1.25)
p.speed=1; p.shoot=0
for _=1,59 do fire('MC_POST_PEFFECT_UPDATE',p) end
assert(p.TearFlags==0); fire('MC_POST_PEFFECT_UPDATE',p); assert(p.TearFlags==4)
p.speed=0; fire('MC_POST_PEFFECT_UPDATE',p); assert(p.TearFlags==0)

p=player('Doubao-chan'); start(p); clear(); clear(); assert(p.hearts==2)
clear(); assert(p.hearts==4)
for _=1,3 do clear() end
assert(p.flies==2)
p=player('Kimi-chan'); start(p)
for _=1,10 do clear() end
near(p.Damage,12.4); assert(p.TearRange==250)
hit(p); near(p.Damage,11.6); assert(p.TearRange==200)
fire('MC_PRE_GAME_EXIT'); fire('MC_POST_GAME_STARTED',true); near(p.Damage,11.6)

-- Deliberate self-damage (Blood Donation, IV Bag, sacrifice rooms) is not a mistake.
p=player('Qwen-chan'); other=player('Kimi-chan'); start(p,other)
for _=1,3 do clear() end
near(p.Damage,11.8); near(other.Damage,11.2)
fire('MC_ENTITY_TAKE_DMG',p,1,DamageFlag.DAMAGE_NO_PENALTIES)
fire('MC_ENTITY_TAKE_DMG',other,1,DamageFlag.DAMAGE_NO_PENALTIES|32)
near(p.Damage,11.8); near(other.Damage,11.2)
clear(); near(p.Damage,12.4); near(other.Damage,11.6)
-- A hit from a player outside the player list must not crash.
local stray=player('Qwen-chan'); fire('MC_ENTITY_TAKE_DMG',stray,1,0)

-- Tears are tinted, so an item's own color and offsets survive.
p=player('GPT-chan'); start(p)
near(p.TearColor.R,0.4); near(p.TearColor.G,1); near(p.TearColor.B,0.75)
p.itemColor=Color(0.5,0.5,1,0.8,0.2,0,0.3); p:EvaluateItems()
near(p.TearColor.R,0.2); near(p.TearColor.G,0.5); near(p.TearColor.B,0.75)
near(p.TearColor.A,0.8); near(p.TearColor.RO,0.2); near(p.TearColor.BO,0.3)

p=player('GLM-chan'); start(p); assert(p.pocket==777)
for i=1,4 do frame=i; fire('MC_USE_ITEM',1,nil,p,0) end
near(p.Damage,13.6)
clear(); near(p.Damage,10)
frame=5; fire('MC_USE_ITEM',1,nil,p,32); near(p.Damage,10)
fire('MC_USE_ITEM',1,nil,p,0); fire('MC_USE_ITEM',1,nil,p,0); near(p.Damage,11.2)
p.pocket=123; fire('MC_PRE_GAME_EXIT'); fire('MC_POST_GAME_STARTED',true)
assert(p.pocket==123); near(p.Damage,11.2)

-- New IDs must not activate mechanics for either DeepSeek form or vanilla players.
p=player('DeepSeek-chan'); start(p)
assert(R:Find(p)==nil and next(risk.state.modelRoster)==nil)
p.kind=142; assert(R:Find(p)==nil)
p.kind=0; assert(R:Find(p)==nil)

-- Each update uses a new wrapper; cache and HUD must see the same charge.
p=player('Grok-chan'); other=player('Grok-chan'); start(p,other); p.speed=1
for _=1,150 do fire('MC_POST_PEFFECT_UPDATE',wrap(p)) end
wrap(p):EvaluateItems(); near(p.Damage,12.5); near(other.Damage,10)
collectgarbage('collect'); wrap(p):EvaluateItems(); near(p.Damage,12.5)
rendered={}; fire('MC_POST_RENDER')
assert(rendered[1]=='Grok-chan: Momentum 10/10')
assert(rendered[2]=='Grok-chan: Momentum 0/10')
room=room+1; fire('MC_POST_NEW_ROOM'); near(p.Damage,10)
for _=1,15 do fire('MC_POST_PEFFECT_UPDATE',wrap(p)) end
near(p.Damage,10.25)
fire('MC_PRE_GAME_EXIT'); fire('MC_POST_GAME_STARTED',true); near(p.Damage,10)

p=player('Mistral-chan'); other=player('Mistral-chan'); start(p,other)
p.speed=1; p.shoot=0
for _=1,59 do fire('MC_POST_PEFFECT_UPDATE',wrap(p)) end
assert(p.TearFlags==0)
fire('MC_POST_PEFFECT_UPDATE',wrap(p)); wrap(p):EvaluateItems()
assert(p.TearFlags==4 and other.TearFlags==0)
rendered={}; fire('MC_POST_RENDER'); assert(rendered[1]=='Mistral-chan: Tailwind')
room=room+1; fire('MC_POST_NEW_ROOM'); assert(p.TearFlags==0)
for _=1,60 do fire('MC_POST_PEFFECT_UPDATE',wrap(p)) end
assert(p.TearFlags==4); start(p); assert(p.TearFlags==0)

p=player('GLM-chan'); other=player('GLM-chan'); start(p,other); frame=7
fire('MC_USE_ITEM',1,nil,wrap(p),0)
fire('MC_USE_ITEM',1,nil,wrap(p),0)
fire('MC_USE_ITEM',1,nil,wrap(p),UseFlag.USE_CARBATTERY)
near(p.Damage,11.2); near(other.Damage,10)
fire('MC_USE_ITEM',1,nil,wrap(other),0); near(other.Damage,11.2)
frame=8; fire('MC_USE_ITEM',1,nil,wrap(p),0); near(p.Damage,12.4)

-- Reused pointers and an observed character change must not inherit charge.
p=player('Grok-chan'); start(p); p.speed=1
for _=1,150 do fire('MC_POST_PEFFECT_UPDATE',wrap(p)) end
near(p.Damage,12.5)
other=player('Grok-chan'); other.pointer=p.pointer; players={other}
other:EvaluateItems(); near(other.Damage,10)
other.speed=1
for _=1,150 do fire('MC_POST_PEFFECT_UPDATE',wrap(other)) end
near(other.Damage,12.5)
other.kind=Isaac.GetPlayerTypeByName('Mistral-chan',false); other:EvaluateItems()
other.kind=Isaac.GetPlayerTypeByName('Grok-chan',false); other:EvaluateItems()
near(other.Damage,10)
-- Long native DROP holds do not activate the mode ability at either edge.
p=player('GPT-chan'); other=player('Gemini-chan'); other.ControllerIndex=3
start(p,other); input(p,false); input(other,false)
for _=1,50 do input(p,true); near(p.Damage,13.5) end
input(p,false); near(p.Damage,13.5)
tap(other); near(other.Damage,9); near(p.Damage,13.5)

-- The paused render path must cancel even when the HUD is hidden and no
-- gameplay update occurs until after the pause menu closes.
input(p,true); paused=true; hudVisible=false; fire('MC_POST_RENDER')
paused=false; hudVisible=true; input(p,false); near(p.Damage,13.5)
tap(p); near(p.Damage,8.5)
input(p,true); room=room+1; fire('MC_POST_NEW_ROOM')
input(p,false); near(p.Damage,8.5)
tap(p); near(p.Damage,13.5)

-- Persist the selected mode, never an unfinished press across continue.
input(p,true); fire('MC_PRE_GAME_EXIT'); fire('MC_POST_GAME_STARTED',true)
input(p,false); near(p.Damage,13.5)
input(p,true); p.controls=false; input(p,true); p.controls=true
input(p,false); near(p.Damage,13.5)
tap(p); near(p.Damage,8.5)
assert(not callbacks.MC_INPUT_ACTION, 'roster must not override native DROP input')
print('OK: nine model mechanics, DROP tap/hold lifecycle, co-op isolation and duplicate effects')
