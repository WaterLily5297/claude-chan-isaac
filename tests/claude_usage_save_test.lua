-- Real usage/item callbacks across a process-style save boundary.
-- JSON is a detached snapshot stub; engine save-file acceptance stays separate.
local root = arg[1]
local callbacks, players, frame, saved = {}, {}, 1, nil
local C = {Player={CLAUDE_CHAN=41}, Item={BAN_HAMMER=733, COMPACT=735, BANKED_RESET=744}}
local Hud = {T=function(_,key,...) return key..":"..table.concat({...},",") end, Draw=function() end}
function include(name)
    if name=="scripts.constants" then return C end
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
EntityType={ENTITY_PROJECTILE=9}; EntityFlag={FLAG_FRIENDLY=1}
function Color(...) return {...} end
function EntityRef(p) return p end
function GetPtrHash(p) return p.pointer end
local nextPointer=0
local function player(kind)
    nextPointer=nextPointer+1
    local p={kind=kind or 41,pointer=nextPointer,data={}}
    function p:GetPlayerType() return self.kind end
    function p:GetData() return self.data end
    function p:ToPlayer() return self end
    function p:SetPocketActiveItem(id) self.pocket=id end
    return p
end
Isaac={GetPlayer=function(i) return players[i+1] end,
    GetRoomEntities=function() return {} end, GetScreenHeight=function() return 270 end}
function Game() return {GetNumPlayers=function() return #players end,
    GetFrameCount=function() return frame end,
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
local function shot(p)
    local t={SpawnerEntity=p,CollisionDamage=10}
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
assert(shot(wrap(players[1])).CollisionDamage==4,"continue must not erase an active usage limit")
assert(players[1].data.ccUsage.limited==145,"continue must preserve the remaining countdown")
assert(shot(players[2]).CollisionDamage==10 and players[2].data.ccUsage.value==24,
    "each continued player must retain their own meter")
assert(players[1].data.ccUsage~=players[2].data.ccUsage,"co-op meters must not alias")

-- Item changes must be saved even before a later character update/tear callback.
fire("MC_USE_ITEM",C.Item.COMPACT,nil,players[2])
assert(players[2].data.ccUsage.value==74)
fire("MC_USE_ITEM",C.Item.BANKED_RESET,nil,players[1])
assert(players[1].data.ccUsage.value==0 and players[1].data.ccUsage.limited==0)
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
for _=1,149 do fire("MC_POST_PEFFECT_UPDATE",wrap(players[2])) end
assert(players[2].data.ccUsage.limited==1)
fire("MC_PRE_GAME_EXIT",true); players={player(),player()}; module(); fire("MC_POST_GAME_STARTED",true)
assert(shot(players[2]).CollisionDamage==4)
fire("MC_POST_PEFFECT_UPDATE",players[2])
assert(players[2].data.ccUsage.limited==0 and players[2].data.ccUsage.value==0)
frame=6; shot(players[2]);fire("MC_POST_PEFFECT_UPDATE",players[2])
assert(players[2].data.ccUsage.value==3,"keep the six-frame drain cadence")

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
print("OK: Claude usage save/continue, detached entities, wrapper identity, co-op and item aliases")
