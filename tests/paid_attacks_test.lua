-- Real shared paid-attack observer: held beams and Ludovico windows, knife
-- throws, melee swings and Epic Fetus rockets each bill once; starts, single
-- hits, child beams and familiar weapons do not.
local root=arg[1]
function include(name) return dofile(root.."/"..name:gsub("%.","/")..".lua") end
ModCallbacks=setmetatable({}, {__index=function(_,k) return k end})
EntityType={ENTITY_TEAR=2,ENTITY_BOMB=4,ENTITY_LASER=7,ENTITY_KNIFE=8,ENTITY_EFFECT=1000}
EffectVariant={TARGET=30,ROCKET=31}
KnifeSubType={CLUB_HITBOX=4}
TearFlags={TEAR_LUDOVICO=1}
local frame, paused, callbacks = 0, false, {}
function Game() return {GetFrameCount=function() return frame end, IsPaused=function() return paused end} end
function GetPtrHash(e) return e.pointer end
local mod={}
function mod:AddCallback(id,fn,param) callbacks[#callbacks+1]={id=id,fn=fn,param=param} end
local function fire(id,...) for _,c in ipairs(callbacks) do if c.id==id then c.fn(mod,...) end end end
local paid={}
local function player(pointer)
    local p={pointer=pointer,firing=false}
    function p:ToPlayer() return self end
    function p:GetShootingInput() return {LengthSquared=function() return p.firing and 1 or 0 end} end
    return p
end
local p,q=player(1),player(2)
local familiar={ToPlayer=function() end}
local function entity(fields)
    local e=fields or {}; local data={}
    function e:GetData() return data end
    function e:IsFlying() return self.flying end
    function e:HasTearFlags(f) return (self.flags or 0)&f~=0 end
    function e:IsCircleLaser() return self.circle or false end
    function e:ToPlayer() end
    return e
end
include("scripts.characters.paid_attacks").Observe(mod,function(owner) paid[owner.pointer]=(paid[owner.pointer] or 0)+1 end)
local function count(x) return paid[x.pointer] or 0 end
local function hold(e,id,n)
    for _=1,n do frame=frame+1; e.FrameCount=(e.FrameCount or -1)+1; fire(id,e) end
end

-- A held beam: the start is billed elsewhere, then one payment per 0.2 seconds.
local beam=entity({SpawnerEntity=p})
hold(beam,"MC_POST_LASER_UPDATE",6); assert(count(p)==0,"the start window is the init payment")
hold(beam,"MC_POST_LASER_UPDATE",1); assert(count(p)==1,"the second window pays")
hold(beam,"MC_POST_LASER_UPDATE",5); assert(count(p)==1,"one payment per six updates")
hold(beam,"MC_POST_LASER_UPDATE",1); assert(count(p)==2)
-- A second beam held at the same time shares the player's window.
local twin=entity({SpawnerEntity=p,FrameCount=20})
frame=frame+1; fire("MC_POST_LASER_UPDATE",twin); assert(count(p)==2,"two beams share one window")
paused=true; hold(beam,"MC_POST_LASER_UPDATE",12); paused=false; assert(count(p)==2,"pause bills nothing")
paid={}
-- Single-hit beams, released rings, child beams and familiar beams are free here.
hold(entity({SpawnerEntity=p,OneHit=true}),"MC_POST_LASER_UPDATE",20)
hold(entity({SpawnerEntity=p,circle=true}),"MC_POST_LASER_UPDATE",20)
hold(entity({SpawnerEntity=p,Parent={Type=EntityType.ENTITY_LASER}}),"MC_POST_LASER_UPDATE",20)
hold(entity({SpawnerEntity=familiar}),"MC_POST_LASER_UPDATE",20)
hold(entity({SpawnerEntity=p,DisableFollowParent=true}),"MC_POST_LASER_UPDATE",20)
assert(count(p)==0,"only held repeated-hit beams pay per window")
-- A Ludovico ring keeps billing while it is held.
hold(entity({SpawnerEntity=p,circle=true,flags=1}),"MC_POST_LASER_UPDATE",7); assert(count(p)==1)
paid={}

-- A Ludovico tear pays per window only while its owner fires.
local ludo=entity({SpawnerEntity=p,flags=1})
hold(ludo,"MC_POST_TEAR_UPDATE",12); assert(count(p)==0,"an idle Ludovico tear is free")
p.firing=true; hold(ludo,"MC_POST_TEAR_UPDATE",7); assert(count(p)==2,"a steered Ludovico tear pays per window")
hold(entity({SpawnerEntity=p}),"MC_POST_TEAR_UPDATE",12); assert(count(p)==2,"ordinary tears pay at fire, not here")
local derived=entity({SpawnerEntity=p,flags=1}); derived:GetData().ccThoughtDerived=true
hold(derived,"MC_POST_TEAR_UPDATE",30); assert(count(p)==2,"derived tears never pay")
p.firing=false; paid={}

-- Mom's Knife: one payment per throw; resting on the player is free.
local knife=entity({SpawnerEntity=p,SubType=0,flying=false})
hold(knife,"MC_POST_KNIFE_UPDATE",10); assert(count(p)==0)
knife.flying=true; hold(knife,"MC_POST_KNIFE_UPDATE",10); assert(count(p)==1,"a throw pays once")
knife.flying=false; hold(knife,"MC_POST_KNIFE_UPDATE",1)
knife.flying=true; hold(knife,"MC_POST_KNIFE_UPDATE",3); assert(count(p)==2,"the next throw pays again")
-- Melee: one payment per swing hitbox; a familiar's weapon is free.
local club=entity({Type=EntityType.ENTITY_KNIFE,SpawnerEntity=p,SubType=0})
local swing=entity({SubType=4,Parent=club})
hold(swing,"MC_POST_KNIFE_UPDATE",8); assert(count(p)==3,"a swing pays once")
hold(entity({SubType=4,Parent=entity({Type=EntityType.ENTITY_KNIFE,SpawnerEntity=familiar,SubType=0})}),"MC_POST_KNIFE_UPDATE",8)
hold(entity({SpawnerEntity=familiar,SubType=0,flying=true}),"MC_POST_KNIFE_UPDATE",8)
assert(count(p)==3,"familiar weapons are not billed")
paid={}

-- Epic Fetus: each rocket pays once, through the target marker.
local target=entity({Type=EntityType.ENTITY_EFFECT,Variant=EffectVariant.TARGET,SpawnerEntity=q})
local rocket=entity({SpawnerEntity=target})
hold(rocket,"MC_POST_EFFECT_UPDATE",10); assert(count(q)==1,"a rocket pays once")
hold(entity({SpawnerEntity=target}),"MC_POST_EFFECT_UPDATE",1); assert(count(q)==2)
assert(count(p)==0,"payments stay with their owner")

-- Room changes forget windows, so a fresh room never inherits a stale one.
fire("MC_POST_NEW_ROOM"); paid={}
local fresh=entity({SpawnerEntity=p,FrameCount=5})
frame=frame+1; fire("MC_POST_LASER_UPDATE",fresh); assert(count(p)==0)
frame=frame+1; fresh.FrameCount=6; fire("MC_POST_LASER_UPDATE",fresh); assert(count(p)==1)
print("OK: paid-attack observer bills held beams, Ludovico, throws, swings and rockets once each")
