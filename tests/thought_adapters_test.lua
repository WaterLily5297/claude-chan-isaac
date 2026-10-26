-- Remaining native Thought adapters: delayed bursts, mimic familiars, melee swings and Epic Fetus.
local root=arg[1]
local frame, paused, clear, room, floor = 0, false, true, 1, 10
local callbacks, players, saved, draws = {}, {}, nil, {}
local C={Player={DEEPSEEK_CHAN=42},Item={LUNCH_BREAK=749,MILLION_CONTEXT=739}}
function include(name)
    if name=="scripts.characters.deepseek_rice" and arg[2] then return dofile(arg[2]) end
    if name=="scripts.constants" then return C end
    if name=="scripts.characters.model_roster" then return {Find=function() end} end
    if name=="scripts.hud_text" then return {Draw=function(_,text) draws[#draws+1]=text end} end
    return dofile(root.."/"..name:gsub("%.","/")..".lua")
end
local function copy(v)
    if type(v)~="table" then return v end
    local result={}; for k,x in pairs(v) do result[k]=copy(x) end; return result
end
package.preload.json=function() return {
    encode=function(v) saved=copy(v); return "snapshot" end,
    decode=function() return copy(saved) end,
} end
ModCallbacks=setmetatable({}, {__index=function(_,k) return k end})
TearFlags={TEAR_LUDOVICO={highBit=127}}
EffectVariant={TARGET=30,ROCKET=31}
EntityType={ENTITY_LASER=7,ENTITY_BOMB=4,ENTITY_KNIFE=8,ENTITY_EFFECT=1000}
FamiliarVariant={INCUBUS=80,TWISTED_BABY=270,BROTHER_BOBBY=1}
KnifeSubType={CLUB_HITBOX=4}
DamageFlag={DAMAGE_EXPLOSION=4}
function EntityPtr(e) return setmetatable({}, {__index=function(_,k) if k=="Ref" and e:Exists() then return e end end}) end
CacheFlag={CACHE_SPEED=1}; CollectibleType={COLLECTIBLE_BIRTHRIGHT=619}
ButtonAction={ACTION_DROP=11,ACTION_SHOOTLEFT=4,ACTION_SHOOTRIGHT=5,ACTION_SHOOTUP=6,ACTION_SHOOTDOWN=7}
InputHook={IS_ACTION_PRESSED=0,IS_ACTION_TRIGGERED=1,GET_ACTION_VALUE=2}
local down={}
Input={IsActionPressed=function(_,controller) return down[controller] or false end}
function GetPtrHash(p) return p.pointer end
function Game() return {
    GetFrameCount=function() return frame end, GetNumPlayers=function() return #players end,
    IsPaused=function() return paused end,
    GetRoom=function() return {IsClear=function() return clear end} end,
    GetLevel=function() return {
        GetDungeonPlacementSeed=function() return floor end,
        GetStage=function() return 1 end,GetStageType=function() return 0 end,
        GetCurrentRoomDesc=function() return {SpawnSeed=room*13,SafeGridIndex=room} end,
    } end,
    GetHUD=function() return {IsVisible=function() return true end} end,
} end
Isaac={GetPlayer=function(i) return players[i+1] end,GetScreenHeight=function() return 270 end}
local mod={AddCallback=function(_,id,fn) callbacks[#callbacks+1]={id=id,fn=fn} end}
function mod:SaveData(s) self.saved=s end
function mod:LoadData() return self.saved end
function mod:HasData() return saved~=nil end
local function fire(id,...)
    local result
    for _,cb in ipairs(callbacks) do if cb.id==id then
        local value=cb.fn(mod,...); if value~=nil then result=value end
    end end
    return result
end
local function player(pointer,seed,controller)
    local p={pointer=pointer,InitSeed=seed,ControllerIndex=controller,kind=42,
        FireDelay=0,MoveSpeed=1,hearts=2,charge=2,dead=false,controls=true,shooting=false}
    function p:GetPlayerType() return self.kind end
    function p:ToPlayer() return self end
    function p:IsDead() return self.dead end
    function p:AreControlsEnabled() return self.controls end
    function p:HasCollectible(id) return (id==619 and self.birthright) or (id==739 and self.context) end
    function p:GetShootingInput() return {LengthSquared=function() return self.shooting and 1 or 0 end} end
    function p:AddCacheFlags() end
    function p:EvaluateItems() self.MoveSpeed=1; fire("MC_EVALUATE_CACHE",self,1) end
    return p
end
local Risk=include("scripts.risk")
local Meal
local function load()
    callbacks={}
    mod:AddCallback("MC_POST_GAME_STARTED",function(_,continued)
        if continued then Risk:Load(mod) else Risk.state={} end
    end)
    mod:AddCallback("MC_PRE_GAME_EXIT",function(_,save) if save then Risk:Save(mod) end end)
    Meal=include("scripts.meal_break"); Meal:Init(mod,Risk)
    include("scripts.items.million_context"):Init(mod)
    include("scripts.characters.deepseek_rice"):Init(mod,Risk,Meal)
end
local function tick(n)
    for _=1,n or 1 do frame=frame+1; fire("MC_POST_UPDATE") end
end
local function state(i) return Risk.state.deepseekRice[tostring(i or 0)] end
local function tap(p)
    down[p.ControllerIndex]=false; tick()
    down[p.ControllerIndex]=true; tick()
    down[p.ControllerIndex]=false; tick()
end
local function enter(index,hostile)
    room=index; clear=not hostile; fire("MC_POST_NEW_ROOM")
end
local function complete()
    clear=true; fire("MC_PRE_SPAWN_CLEAN_AWARD")
end
local function shot(p)
    local data={}
    local t={SpawnerEntity=p,CollisionDamage=4,Scale=1.7,TearFlags=1<<52,
        GetData=function() return data end, Exists=function() return true end,
        HasTearFlags=function() return false end}
    fire("MC_POST_FIRE_TEAR",t)
    return t
end

local nextEntity=1000
local function entity(p,kind)
    nextEntity=nextEntity+1
    local data={}
    local e={pointer=nextEntity,InitSeed=nextEntity,SpawnerEntity=p,Type=kind or 2,
        CollisionDamage=4,ExplosionDamage=20,Scale=1.7,Color="native",TearFlags=1<<52,
        Height=-23,FallingSpeed=-1,FallingAcceleration=0.17,HomingFriction=0.08,
        KnockbackMultiplier=1.4,FrameCount=0,OneHit=false,DisableFollowParent=false,
        Position={},Velocity={},Variant=0}
    function e:GetData() return data end
    function e:Exists() return not self.removed end
    function e:HasTearFlags(flag) assert(flag==TearFlags.TEAR_LUDOVICO); return self.ludo or false end
    function e:IsCircleLaser() return self.circle or false end
    function e:IsFlying() return self.flying or false end
    function e:ResetSpriteScale() self.spriteScale=self.Scale end
    function e:ToPlayer() return nil end
    return e
end
local p,q
local function freshRun()
    players={player(1,11,0),player(2,22,1)}; p,q=players[1],players[2]
    paused=false; down={}; frame=0; load(); fire("MC_POST_GAME_STARTED",false); tick(150)
end
local function update(entries,n)
    for _=1,n or 1 do
        frame=frame+1
        for _,entry in ipairs(entries) do
            entry[2].FrameCount=entry[2].FrameCount+1
            fire(entry[1],entry[2])
        end
        fire("MC_POST_UPDATE")
    end
end
local function near(a,b) assert(math.abs(a-b)<1e-8,tostring(a).." ~= "..tostring(b)) end

local function familiar(variant,owner)
    local f={Variant=variant,Player=owner,Type=3}
    function f:ToFamiliar() return self end
    function f:ToPlayer() return nil end
    return f
end
local function copyTear(f)
    local t=entity(f,2)
    update({{"MC_POST_TEAR_UPDATE",t}})
    return t
end
local function victim()
    local v={hits={}}
    function v:ToPlayer() return nil end
    function v:TakeDamage(amount,flags,source,countdown)
        if fire("MC_ENTITY_TAKE_DMG",self,amount,flags,source,countdown)~=false then self.hits[#self.hits+1]=amount end
    end
    return v
end

-- Delayed bursts: discrete shots before the native firing cycle could repeat share one payment.
freshRun(); p.MaxFireDelay=10
local first=shot(p); assert(first.CollisionDamage==7.6 and state().thought==0)
tick(3); local late=shot(p)
assert(late.CollisionDamage==7.6 and state().thought==3,"a delayed burst rides on the paid volley")
tick(6); local edge=shot(p); assert(edge.CollisionDamage==7.6,"still inside the ten-update cycle")
tick(1); local next=shot(p)
near(next.CollisionDamage,4*(1+0.9*10/150)); assert(state().thought==0,"the next firing cycle pays again")
p.MaxFireDelay=30; tick(30); local slow=shot(p); near(slow.CollisionDamage,4*(1+0.9*30/150))
tick(14); assert(shot(p).CollisionDamage==slow.CollisionDamage,"slow builds still burst")
tick(1); near(shot(p).CollisionDamage,4*(1+0.9*15/150)); assert(state().thought==0,"bursts are capped at fifteen updates")
p.MaxFireDelay=0.5; tick(30); shot(p); tick(1); local fast=shot(p)
near(fast.CollisionDamage,4*(1+0.9*1/150)); assert(state().thought==0,"very fast fire keeps same-frame volleys only")
p.MaxFireDelay=9.5; tick(150); shot(p); tick(9); near(shot(p).CollisionDamage,4*(1+0.9*9/150)); p.MaxFireDelay=10
local lead=entity(p,7); tick(150); update({{"MC_POST_LASER_UPDATE",lead}}); state().thought=150; tick(2)
assert(shot(p).CollisionDamage==7.6 and state().thought==0,"a discrete shot never rides a continuous volley")
tick(150); shot(p); paused=true; tick(30); paused=false; tick(2)
assert(shot(p).CollisionDamage==7.6,"pause does not age a burst")
local held=state().thought; enter(2,true); near(shot(p).CollisionDamage,4*(1+0.9*held/150)); assert(held>0); assert(state().thought==0,"a new room starts a new volley")
local beamAfter=entity(p,7); tick(150); shot(p); tick(1)
update({{"MC_POST_LASER_UPDATE",beamAfter}}); assert(state().thought==0,"continuous attacks never ride a discrete burst"); near(beamAfter.CollisionDamage,4*(1+0.9*1/150))

-- Mimic familiars copy a paid volley without paying; other familiars stay native.
freshRun(); p.MaxFireDelay=10
local incubus,twin,bobby=familiar(80,p),familiar(270,p),familiar(1,p)
local unpaid=copyTear(incubus); assert(unpaid.CollisionDamage==4 and state().thought==150,"no volley, no bonus")
shot(p); local copy=copyTear(incubus); local copy2=copyTear(twin)
assert(copy.CollisionDamage==7.6 and copy2.CollisionDamage==7.6 and state().thought==2,"copies share the paid multiplier")
update({{"MC_POST_TEAR_UPDATE",copy}},5); assert(copy.CollisionDamage==7.6,"never multiplied twice")
assert(copyTear(bobby).CollisionDamage==4,"ordinary familiars keep native damage")
assert(copyTear(familiar(80,q)).CollisionDamage==4,"another player's familiar does not borrow p's volley")
tick(12); assert(copyTear(incubus).CollisionDamage==4,"a copy after the cycle gets nothing")
update({{"MC_POST_TEAR_UPDATE",unpaid}}); shot(p); update({{"MC_POST_TEAR_UPDATE",unpaid}})
assert(unpaid.CollisionDamage==4,"a copy is judged once, on its first update")
local zero=shot(p); tick(1); local flat=copyTear(incubus); assert(zero.CollisionDamage==flat.CollisionDamage)
p.dead=true; tick(150); p.dead=false; shot(p); p.dead=true; assert(copyTear(incubus).CollisionDamage==4); p.dead=false
q.kind=0; assert(copyTear(familiar(80,q)).CollisionDamage==4,"non-DeepSeek owners are ignored")
local negative=entity(incubus,2); negative.CollisionDamage=-1; tick(150); shot(p); update({{"MC_POST_TEAR_UPDATE",negative}})
assert(negative.CollisionDamage==-1,"invalid damage is left alone")
local ring=entity(p,7); local beside=entity(incubus,2); tick(150)
update({{"MC_POST_LASER_UPDATE",ring},{"MC_POST_TEAR_UPDATE",beside}}); assert(beside.CollisionDamage==4,"copies follow discrete volleys only")
paused=true; tick(1); local pausedCopy=entity(incubus,2); fire("MC_POST_TEAR_UPDATE",pausedCopy); paused=false
assert(pausedCopy.CollisionDamage==4)

-- Melee swings: each club or sword hitbox is one paid attack, snapshotted once.
freshRun()
local weapon=entity(p,8); weapon.SubType=0
update({{"MC_POST_KNIFE_UPDATE",weapon}},5); assert(weapon.CollisionDamage==4 and state().thought==150,"holding the club pays nothing")
local swing=entity(nil,8); swing.SubType=4; swing.Parent=weapon
update({{"MC_POST_KNIFE_UPDATE",swing},{"MC_POST_KNIFE_UPDATE",weapon}},6)
assert(swing.CollisionDamage==7.6 and weapon.CollisionDamage==4 and state().thought==5,"one payment per swing")
tick(30); local swing2=entity(nil,8); swing2.SubType=4; swing2.Parent=weapon
update({{"MC_POST_KNIFE_UPDATE",swing2}}); near(swing2.CollisionDamage,4*(1+0.9*35/150)); assert(swing.CollisionDamage==7.6)
local held=entity(familiar(80,p),8); local foreign=entity(nil,8); foreign.SubType=4; foreign.Parent=held
tick(30); update({{"MC_POST_KNIFE_UPDATE",foreign}}); assert(foreign.CollisionDamage==4,"familiar-held weapons are not billed")
local direct=entity(p,8); direct.SubType=4; update({{"MC_POST_KNIFE_UPDATE",direct}}); assert(direct.CollisionDamage>4,"a hitbox spawned by the player is billed")

-- Epic Fetus: the rocket snapshots one payment; its explosion is re-dealt once.
freshRun()
local target=entity(p,1000); target.Variant=30
local rocket=entity(target,1000); rocket.Variant=31
fire("MC_POST_EFFECT_UPDATE",rocket); tick(5); fire("MC_POST_EFFECT_UPDATE",rocket)
assert(state().thought==5,"one payment per rocket")
local v=victim(); v:TakeDamage(30,DamageFlag.DAMAGE_EXPLOSION,{Entity=rocket},0)
assert(#v.hits==1 and v.hits[1]==57,"the explosion is re-dealt at 1.9x")
v:TakeDamage(30,0,{Entity=rocket},0); assert(v.hits[2]==30,"only explosions")
assert(fire("MC_ENTITY_TAKE_DMG",p,30,DamageFlag.DAMAGE_EXPLOSION,{Entity=rocket},0)==nil,"players are never re-dealt")
v:TakeDamage(30,DamageFlag.DAMAGE_EXPLOSION,{Entity=target},0); assert(v.hits[3]==30,"the marker itself is not a rocket")
v:TakeDamage(30,DamageFlag.DAMAGE_EXPLOSION,nil,0); assert(v.hits[4]==30)
tick(1); local own=entity(p,1000); own.Variant=31; fire("MC_POST_EFFECT_UPDATE",own)
v:TakeDamage(30,DamageFlag.DAMAGE_EXPLOSION,{Entity=own},0); near(v.hits[5],30*(1+0.9*6/150))
local stranger=entity(familiar(1,p),1000); stranger.Variant=30
local stray=entity(stranger,1000); stray.Variant=31; tick(30); fire("MC_POST_EFFECT_UPDATE",stray)
assert(state().thought==30 and stray:GetData().ccThoughtAttack==nil,"a familiar's rocket is not billed")
local decoy=entity(p,1000); decoy.Variant=99; local odd=entity(decoy,1000); odd.Variant=31; tick(30); fire("MC_POST_EFFECT_UPDATE",odd)
assert(odd:GetData().ccThoughtAttack==nil,"only the target marker passes ownership on")
local fetus=entity(p,4); fetus.IsFetus=true; update({{"MC_POST_BOMB_UPDATE",fetus}}); assert(fetus.ExplosionDamage>20)
local hits=#v.hits; v:TakeDamage(30,DamageFlag.DAMAGE_EXPLOSION,{Entity=fetus},0); assert(v.hits[hits+1]==30,"Dr. Fetus bombs are not re-dealt")
tick(30); paused=true; local frozen=entity(p,1000); frozen.Variant=31; fire("MC_POST_EFFECT_UPDATE",frozen); paused=false
assert(state().thought==30 and frozen:GetData().ccThoughtAttack==nil,"no payment while paused")
fire("MC_POST_EFFECT_UPDATE",frozen); assert(state().thought==0,"the rocket pays once play resumes")
print("OK: delayed bursts, mimic familiars, melee swing hitboxes and Epic Fetus rocket Thought adapters")
