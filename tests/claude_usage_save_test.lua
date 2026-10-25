-- Real usage/item callbacks across a process-style save boundary.
-- JSON is a detached snapshot stub; engine save-file acceptance stays separate.
local root = arg[1]
local callbacks, players, frame, saved = {}, {}, 1, nil
local C = {Player={CLAUDE_CHAN=41}, Item={BAN_HAMMER=733, COMPACT=735, BANKED_RESET=744}}
local Hud = {T=function(_,key,...) return key..":"..table.concat({...},",") end, Draw=function() end}
function include(name)
    if name=="scripts.constants" then return C end
    if name=="scripts.characters.model_roster" then return {Find=function() end} end
    if name=="scripts.hud_text" then return Hud end
    return dofile(root.."/"..name:gsub("%.","/")..".lua")
end
local function copy(v)
    if type(v)~="table" then return v end
    local t={}; for k,x in pairs(v) do t[k]=copy(x) end; return t
end
package.preload.json=function() return {
    encode=function(v) saved=copy(v); return "snapshot" end,
    decode=function() return copy(saved) end,
} end
ModCallbacks=setmetatable({}, {__index=function(_,k) return k end})
CacheFlag={CACHE_DAMAGE=1}; ActiveSlot={SLOT_POCKET=2}
CollectibleType={COLLECTIBLE_BIRTHRIGHT=619}; ButtonAction={ACTION_DROP=11}
local down, clear, room, floor, paused = false, true, 1, 1, false
Input={IsActionPressed=function() return down end}
EntityType={ENTITY_PROJECTILE=9}; EntityFlag={FLAG_FRIENDLY=1}
function Color(...) return {...} end
function EntityRef(p) return p end
function GetPtrHash(p) return p.pointer end
local nextPointer=0
local function player(kind)
    nextPointer=nextPointer+1
    local p={kind=kind or 41,pointer=nextPointer,data={},InitSeed=nextPointer,ControllerIndex=0}
    function p:IsDead() return self.dead or false end
    function p:AreControlsEnabled() return true end
    function p:HasCollectible(id) return id==619 and self.birthright end
    function p:GetShootingInput() return {LengthSquared=function() return self.shooting and 1 or 0 end} end
    function p:GetPlayerType() return self.kind end
    function p:GetCard() return 0 end
    function p:GetPill() return 0 end
    function p:GetActiveItem() return 0 end
    function p:GetData() return self.data end
    function p:ToPlayer() return self end
    function p:SetPocketActiveItem(id) self.pocket=id end
    function p:AddCacheFlags() end
    function p:EvaluateItems()
        self.Damage=3.5
        for _,c in ipairs(callbacks) do if c.id=="MC_EVALUATE_CACHE" then c.fn(mod,self,CacheFlag.CACHE_DAMAGE) end end
    end
    return p
end
Isaac={GetPlayer=function(i) return players[i+1] end,
    GetRoomEntities=function() return {} end, GetScreenHeight=function() return 270 end}
function Game() return {GetNumPlayers=function() return #players end,
    GetFrameCount=function() return frame end, IsPaused=function() return paused end,
    GetRoom=function() return {IsClear=function() return clear end} end,
    GetLevel=function() return {GetDungeonPlacementSeed=function() return floor end,
        GetStage=function() return 1 end, GetStageType=function() return 0 end,
        GetCurrentRoomDesc=function() return {SpawnSeed=room,SafeGridIndex=room} end} end,
    GetHUD=function() return {ShowItemText=function() end,IsVisible=function() return true end} end} end
local mod={}
function mod:AddCallback(id,fn,param) callbacks[#callbacks+1]={id=id,fn=fn,param=param} end
function mod:SaveData(s) self.saved=s end
function mod:HasData() return saved~=nil end
function mod:LoadData() return self.saved end
local Risk=include("scripts.risk")
function Risk:IsSuspended() return false end
function Risk:Add(n) self.state.risk=(self.state.risk or 0)+n end
local function fire(id,...)
    for _,c in ipairs(callbacks) do
        if c.id==id and (id~="MC_USE_ITEM" or c.param==select(1,...)) then c.fn(mod,...) end
    end
end
local function module()
    callbacks={}
    -- Match main.lua: Risk loads/saves before the character lifecycle callback.
    mod:AddCallback("MC_POST_GAME_STARTED",function(_,continued)
        if continued then Risk:Load(mod) else Risk.state={} end
    end)
    mod:AddCallback("MC_PRE_GAME_EXIT",function(_,save) if save then Risk:Save(mod) end end)
    include("scripts.items.compact"):Init(mod)
    include("scripts.items.banked_reset"):Init(mod,Risk)
    include("scripts.characters.claude_chan"):Init(mod,Risk)
end
-- Each call is a separate volley on a new frame.
local function shot(p)
    frame=frame+1
    local data={}
    local t={SpawnerEntity=p,CollisionDamage=10,GetData=function() return data end}
    fire("MC_POST_FIRE_TEAR",t); return t
end
local function wrap(p) return setmetatable({}, {__index=p,__newindex=p}) end
players={player(),player()}; module(); fire("MC_POST_GAME_STARTED",false)
for _=1,25 do shot(players[1]) end
for _=1,5 do shot(players[2]);fire("MC_POST_PEFFECT_UPDATE",players[1]) end
assert(players[1].data.ccUsage.limited==145)
assert(players[2].data.ccUsage.value==20)
fire("MC_PRE_GAME_EXIT",true)
players={player(),player()}; module()
fire("MC_POST_NEW_LEVEL"); fire("MC_POST_GAME_STARTED",true)
assert(math.abs(players[1].Damage-3.5*0.4)<1e-9 and math.abs(players[2].Damage-3.5)<1e-9,
    "continue must not erase an active usage limit")
shot(wrap(players[1]))
assert(players[1].data.ccUsage.limited==145,"continue must preserve the remaining countdown")
assert(shot(players[2]).CollisionDamage==10 and players[2].data.ccUsage.value==24,
    "each continued player must retain their own meter")
assert(players[1].data.ccUsage~=players[2].data.ccUsage,"co-op meters must not alias")

-- Item changes must be saved even before a later character update/tear callback.
fire("MC_USE_ITEM",C.Item.COMPACT,nil,players[2])
assert(players[2].data.ccUsage.value==74)
fire("MC_USE_ITEM",C.Item.BANKED_RESET,nil,players[1])
assert(players[1].data.ccUsage.value==0 and players[1].data.ccUsage.limited==0)
fire("MC_POST_PEFFECT_UPDATE",players[1])
assert(math.abs(players[1].Damage-3.5)<1e-9,"an item that clears Limited restores damage on the next update")
assert(players[2].data.ccUsage.value==74)
fire("MC_PRE_GAME_EXIT",true)
players={player(),player()}; module(); fire("MC_POST_GAME_STARTED",true)
assert(shot(players[1]).CollisionDamage==10 and players[1].data.ccUsage.value==4)
assert(players[2].data.ccUsage.value==74,"Compact must persist without another update")

-- An observed character change and a rewrapped player retain the same slot debt.
players[2].kind=0; fire("MC_POST_PEFFECT_UPDATE",players[2])
players[2].kind=41; fire("MC_POST_PEFFECT_UPDATE",wrap(players[2]))
assert(players[2].data.ccUsage.value==74)

for _=1,7 do shot(players[2]) end
assert(players[2].data.ccUsage.limited==150)
for _=1,149 do frame=frame+1; fire("MC_POST_PEFFECT_UPDATE",wrap(players[2])) end
assert(players[2].data.ccUsage.limited==1)
fire("MC_PRE_GAME_EXIT",true); players={player(),player()}; module(); fire("MC_POST_GAME_STARTED",true)
assert(math.abs(players[2].Damage-3.5*0.4)<1e-9,"the last Limited frame survives continue")
shot(players[2])
fire("MC_POST_PEFFECT_UPDATE",players[2])
assert(players[2].data.ccUsage.limited==0 and players[2].data.ccUsage.value==0)
assert(math.abs(players[2].Damage-3.5)<1e-9,"the end of Limited restores the damage stat")
for _=1,5 do shot(players[2]); fire("MC_POST_PEFFECT_UPDATE",players[2]) end
assert(players[2].data.ccUsage.value==20,"a paid volley's own frame never drains")
players[2].shooting=true
for _=1,30 do frame=frame+1; fire("MC_POST_PEFFECT_UPDATE",players[2]) end
assert(players[2].data.ccUsage.value==20,"held fire blocks the drain")
players[2].shooting=false
for _=1,30 do frame=frame+1; fire("MC_POST_PEFFECT_UPDATE",players[2]) end
assert(players[2].data.ccUsage.value==10,"not firing drains 10 per second")
players[2].data.ccUsage.value=0

-- A fresh run on reused player objects must not inherit their former aliases.
fire("MC_PRE_GAME_EXIT",false); fire("MC_POST_GAME_STARTED",false)
assert(shot(players[1]).CollisionDamage==10 and players[1].data.ccUsage.value==4)
assert(players[2].data.ccUsage.value==0)
fire("MC_PRE_GAME_EXIT",false)
local before=players[1].data.ccUsage.value
fire("MC_POST_PEFFECT_UPDATE",players[1]); shot(players[1])
assert(players[1].data.ccUsage.value==before,"inactive callbacks must not mutate run usage")
-- Old saves have no usage record; initialize safely without inventing a penalty.
saved={risk=0}; players={player()}; module();fire("MC_POST_GAME_STARTED",true)
assert(shot(players[1]).CollisionDamage==10 and players[1].data.ccUsage.value==4)

-- Timer progress belongs to gameplay frames, not callback invocation count.
players={player(),player()}; module(); fire("MC_POST_GAME_STARTED",false)
local p,q=players[1],players[2]
local a,b=p.data.ccUsage,q.data.ccUsage
a.value=100; a.limited=150; b.value=100; b.limited=90
frame=frame+1
fire("MC_POST_PEFFECT_UPDATE",p); fire("MC_POST_PEFFECT_UPDATE",wrap(p))
fire("MC_POST_PEFFECT_UPDATE",q); fire("MC_POST_PEFFECT_UPDATE",wrap(q))
assert(a.limited==149 and b.limited==89,"duplicate wrappers must not shorten either player's timer")
paused=true; frame=frame+1
fire("MC_POST_PEFFECT_UPDATE",p); fire("MC_POST_PEFFECT_UPDATE",q)
assert(a.limited==149 and b.limited==89,"paused callbacks must freeze timers")
paused=false; p.dead=true; frame=frame+1
fire("MC_POST_PEFFECT_UPDATE",p); fire("MC_POST_PEFFECT_UPDATE",q)
assert(a.limited==149 and b.limited==88,"a dead player's timer freezes without blocking the partner")
p.dead=false; frame=frame+1; fire("MC_POST_PEFFECT_UPDATE",wrap(p))
assert(a.limited==148,"revival resumes one frame without catching up skipped time")
for _=1,147 do
    frame=frame+1
    fire("MC_POST_PEFFECT_UPDATE",p); fire("MC_POST_PEFFECT_UPDATE",wrap(p))
end
assert(a.limited==1 and a.value==100,"duplicate callbacks must not expire the five-second limit early")
frame=frame+1; fire("MC_POST_PEFFECT_UPDATE",p)
assert(a.limited==0 and a.value==0,"the final active frame expires and clears usage once")

-- Drain has the same once-per-frame, pause and death contract.
a.value=10; b.value=20; b.limited=0
frame=frame+3-frame%3
fire("MC_POST_PEFFECT_UPDATE",p); fire("MC_POST_PEFFECT_UPDATE",wrap(p))
fire("MC_POST_PEFFECT_UPDATE",q); fire("MC_POST_PEFFECT_UPDATE",wrap(q))
assert(a.value==9 and b.value==19,"a drain frame subtracts one per player")
paused=true; frame=frame+3; fire("MC_POST_PEFFECT_UPDATE",p)
assert(a.value==9,"pause must not drain usage")
paused=false; p.dead=true; frame=frame+3; fire("MC_POST_PEFFECT_UPDATE",p)
assert(a.value==9,"death must not drain usage")
p.dead=false; p.shooting=true; frame=frame+3; fire("MC_POST_PEFFECT_UPDATE",p)
assert(a.value==9,"held fire still blocks drainage")

-- A new run may reuse the same pointer and frame; no stale timer guard survives.
fire("MC_PRE_GAME_EXIT",false); fire("MC_POST_GAME_STARTED",false)
a=p.data.ccUsage; a.value=100; a.limited=150
fire("MC_POST_PEFFECT_UPDATE",p)
assert(a.limited==149,"fresh-run lifecycle clears the transient frame guard")
fire("MC_PRE_GAME_EXIT",true); fire("MC_POST_GAME_STARTED",true)
a=p.data.ccUsage
fire("MC_POST_PEFFECT_UPDATE",wrap(p))
assert(a.limited==148,"continue at the same frame clears transient guards without erasing debt")
for _, interruption in ipairs({"pause", "death"}) do
    a.limited=0; a.value=60; a.appeals=1
    down=false; frame=frame+1; fire("MC_POST_PEFFECT_UPDATE",p)
    down=true; frame=frame+1; fire("MC_POST_PEFFECT_UPDATE",p)
    paused=interruption=="pause"; p.dead=interruption=="death"
    fire("MC_POST_PEFFECT_UPDATE",wrap(p)) -- Interrupt even after this frame was already processed.
    paused=false; p.dead=false
    down=false; frame=frame+1; fire("MC_POST_PEFFECT_UPDATE",p)
    assert(a.appeals==1 and a.value==60,"interrupted DROP release must not consume an Appeal")
    down=true; frame=frame+1; fire("MC_POST_PEFFECT_UPDATE",p)
    down=false; frame=frame+1; fire("MC_POST_PEFFECT_UPDATE",p)
    assert(a.appeals==0 and a.value==20,"a fresh DROP gesture after recovery still works")
end
print("OK: Claude usage save/continue, detached entities, wrapper identity, co-op and item aliases")
