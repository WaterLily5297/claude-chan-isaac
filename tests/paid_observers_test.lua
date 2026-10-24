-- Real Opus registers first, as in main.lua. Later resource observers must
-- receive the same native attack once, even when Opus is not owned.
local root=arg[1]
local selected=arg[2] or "all"
ModCallbacks=setmetatable({}, {__index=function(_,k) return k end})
EntityType={ENTITY_LASER=7,ENTITY_KNIFE=8,ENTITY_EFFECT=1000}
EffectVariant={TARGET=30,ROCKET=31}
KnifeSubType={CLUB_HITBOX=4}
CacheFlag={CACHE_DAMAGE=1}
local callbacks,frame={},0
function Game() return {GetFrameCount=function() return frame end,IsPaused=function() return false end} end
function GetPtrHash(e) return e.pointer end
function include(name)
    if name=="scripts.constants" then return {Item={OPUS_MODE=747}} end
    return dofile(root.."/"..name:gsub("%.","/")..".lua")
end
local mod={}
function mod:AddCallback(id,fn,param) callbacks[#callbacks+1]={id=id,fn=fn,param=param} end
local function fire(id,entity)
    frame=frame+1
    for _,cb in ipairs(callbacks) do
        if cb.id==id and (not cb.param or cb.param==entity.Variant) then cb.fn(mod,entity) end
    end
end
local function player(pointer,opus)
    local data={}
    local p={pointer=pointer,coins=5,opus=opus}
    function p:ToPlayer() return self end
    function p:GetData() return data end
    function p:HasCollectible(id) assert(id==747); return self.opus end
    function p:GetNumCoins() return self.coins end
    function p:AddCoins(n) self.coins=self.coins+n end
    return p
end
local function entity(fields)
    local data={}
    function fields:GetData() return data end
    function fields:IsFlying() return self.flying end
    function fields:ToPlayer() end
    return fields
end
local function run(kind)
    if selected~="all" and selected~=kind then return end
    for _,owned in ipairs({false,true}) do
        callbacks={}
        include("scripts.items.opus_mode"):Init(mod)
        local Paid=include("scripts.characters.paid_attacks")
        local p,q=player(1,owned),player(2,false)
        local counts={0,0,0}
        -- Same module instance twice, then a fresh include: isolate each
        -- Observe call, not merely each Lua module or player.
        Paid.Observe(mod,function(owner) if owner==p then counts[1]=counts[1]+1 end end)
        Paid.Observe(mod,function(owner) if owner==p then counts[2]=counts[2]+1 end end)
        include("scripts.characters.paid_attacks").Observe(mod,function(owner)
            if owner==q then counts[3]=counts[3]+1 end
        end)
        local id=kind=="rocket" and "MC_POST_EFFECT_UPDATE" or "MC_POST_KNIFE_UPDATE"
        local function attack(owner)
            if kind=="rocket" then
                return entity({Variant=EffectVariant.ROCKET,SpawnerEntity=entity({
                    Type=EntityType.ENTITY_EFFECT,Variant=EffectVariant.TARGET,SpawnerEntity=owner})})
            elseif kind=="swing" then
                return entity({SubType=4,Parent=entity({Type=EntityType.ENTITY_KNIFE,SpawnerEntity=owner})})
            end
            return entity({SubType=0,SpawnerEntity=owner,flying=true})
        end
        local knife
        for n=1,10 do
            local a=knife or attack(p)
            fire(id,a); fire(id,a); fire(id,a)
            assert(counts[1]==n and counts[2]==n,"every resource observer must receive "..kind.." once")
            assert(counts[3]==0,"other owner must not be billed")
            if kind=="knife" then
                a.flying=false; fire(id,a); a.flying=true; knife=a
            end
        end
        assert(p.coins==(owned and 4 or 5),"Opus must bill ten attacks once, only when owned")
        assert((p:GetData().ccOpusTears or 0)==0,"duplicate callbacks must not leave extra Opus charges")
        local partner=attack(q);fire(id,partner);fire(id,partner)
        assert(counts[1]==10 and counts[2]==10 and counts[3]==1,"co-op owner isolation")
        local familiar={ToPlayer=function() end}
        fire(id,attack(familiar))
        assert(counts[1]==10 and counts[2]==10 and counts[3]==1,"familiar weapons stay free")
    end
    print("PASS paid observer isolation: "..kind)
end
run("knife");run("swing");run("rocket")
