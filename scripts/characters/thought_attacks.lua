-- Native attack adapters. Never replace weapons, sprites, flags or collision rules.
local Attacks = {}
local KEY = "ccThoughtAttack"

-- Cooperating damage writers must snapshot the unboosted continuous baseline.
-- Ordinary released shots intentionally keep their resolved multiplier in flight.
function Attacks.BaseDamage(entity)
    local record=entity:GetData()[KEY]
    if record and (record.mode=="window" or record.mode=="derived")
        and entity.CollisionDamage==record.written then return record.base end
    return entity.CollisionDamage
end

-- Raw Swarm forks inherit resolved damage, never another payment. Continuous
-- forks follow the parent's factor so a copied Ludovico bonus cannot last forever.
function Attacks.CopyLease(parent, child)
    local data=child:GetData()
    data.ccThoughtDerived=true
    local source=parent:GetData()[KEY]
    if source and (source.mode=="window" or source.mode=="derived") then
        data[KEY]={mode="derived", parent=source, factor=source.factor,
            base=child.CollisionDamage/source.factor, written=child.CollisionDamage}
        source.children=source.children or {}
        source.children[#source.children+1]={ref=EntityPtr(child),record=data[KEY]}
    end
end

function Attacks:Init(mod, hooks)
    local leases={}
    local function owner(entity)
        -- Do not traverse familiar, reflected-laser or bomb-child ancestry and
        -- accidentally bill the primary player for a derived attack.
        if entity.SpawnerEntity then return entity.SpawnerEntity:ToPlayer() end
        return entity.Parent and entity.Parent:ToPlayer()
    end
    local function usable(entity,p)
        return entity:Exists() and p and hooks.Eligible(p) and not p:IsDead()
    end
    local function validDamage(value)
        return type(value)=="number" and value>0 and value<math.huge
    end
    local function scale(entity,record,factor,field)
        local current=entity[field]
        -- Engine damage refreshes supply a new base; an unchanged previous write
        -- must not be multiplied again. Conflicting external writers need testing.
        if current~=record.written then record.base=current end
        entity[field]=record.base*factor
        record.factor=factor; record.written=entity[field]; record.field=field
    end
    local function restore(entity,record)
        local field=record.field or "CollisionDamage"
        if entity and entity:Exists() and entity[field]==record.written then
            entity[field]=record.base
        end
        record.factor=1; record.written=nil
        for _,child in ipairs(record.children or {}) do restore(child.ref.Ref,child.record) end
    end
    local function track(entity,record)
        leases[GetPtrHash(entity)]={ref=EntityPtr(entity), record=record}
    end
    local function clear()
        for _,entry in pairs(leases) do
            local entity=entry.ref.Ref
            restore(entity,entry.record)
            if entity and entity:Exists() then entity:GetData()[KEY]=nil end
        end
        leases={}
    end
    local function once(entity,p,field)
        if not usable(entity,p) or Game():IsPaused() or not validDamage(entity[field]) then return end
        local data=entity:GetData()
        if data[KEY] or data.ccThoughtDerived then return end
        local factor=hooks.Resolve(p,false)
        if not factor then return end
        data[KEY]={mode="shot",factor=factor}
        scale(entity,data[KEY],factor,field)
    end
    local function window(entity,p)
        local data=entity:GetData()
        local record=data[KEY]
        if not usable(entity,p) then
            if record then restore(entity,record) end
            return
        end
        if Game():IsPaused() or not validDamage(entity.CollisionDamage) then return end
        if data.ccThoughtDerived and (not record or record.mode~="derived") then return end
        local factor
        if record and record.mode=="derived" then
            -- A child updated before its parent must still lose an expired bonus.
            factor=math.min(record.parent.factor,hooks.WindowFactor(p))
        else
            hooks.Active(p)
            factor=hooks.Resolve(p,true)
        end
        if not factor then return end
        if not record then record={mode="window"}; data[KEY]=record end
        scale(entity,record,factor,"CollisionDamage")
        track(entity,record)
    end
    local function ludo(entity)
        -- TEAR_LUDOVICO is a high BitSet128 flag in current Repentance.
        return entity:HasTearFlags(TearFlags.TEAR_LUDOVICO)
    end

    mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR,function(_,tear)
        local p=owner(tear)
        if not usable(tear,p) then return end
        if ludo(tear) then window(tear,p) else once(tear,p,"CollisionDamage") end
    end)
    mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE,function(_,tear)
        local record=tear:GetData()[KEY]
        local p=owner(tear)
        if record and (record.mode=="window" or record.mode=="derived") then
            window(tear,p)
        elseif p and hooks.Eligible(p) and ludo(tear) then
            window(tear,p)
        end
    end)
    mod:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE,function(_,laser)
        local p=owner(laser)
        if laser.Parent and laser.Parent.Type==EntityType.ENTITY_LASER then return end
        if laser.DisableFollowParent and not laser:IsCircleLaser() then return end
        -- Single-hit beams and released Tech X rings are one attack. Repeated-hit
        -- beams (including Brimstone) use bounded six-update damage windows.
        if laser.OneHit or (laser:IsCircleLaser() and not ludo(laser)) then
            once(laser,p,"CollisionDamage")
        else
            window(laser,p)
        end
    end)
    mod:AddCallback(ModCallbacks.MC_POST_KNIFE_UPDATE,function(_,knife)
        local data=knife:GetData()
        local record=data[KEY]
        local p=owner(knife)
        if not usable(knife,p) then
            if record then restore(knife,record); data[KEY]=nil end
            return
        end
        if Game():IsPaused() then return end
        if not knife:IsFlying() then
            if record then restore(knife,record); data[KEY]=nil end
            return -- Idle contact damage and melee swings do not spend Thought.
        end
        if not validDamage(knife.CollisionDamage) or data.ccThoughtDerived then return end
        if not record then
            local factor=hooks.Resolve(p,false)
            if not factor then return end
            record={mode="knife",factor=factor}; data[KEY]=record
        end
        scale(knife,record,record.factor,"CollisionDamage")
        track(knife,record)
    end)
    mod:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE,function(_,bomb)
        if not bomb.IsFetus then return end -- Ordinary bombs keep native damage.
        if bomb.Parent and bomb.Parent.Type==EntityType.ENTITY_BOMB then return end
        once(bomb,owner(bomb),"ExplosionDamage")
    end)
    mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE,function(_,entity)
        local key=GetPtrHash(entity)
        local entry=leases[key]
        if entry then restore(nil,entry.record); leases[key]=nil end
    end)
    mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM,clear)
    mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT,clear)
    mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED,clear)
end

return Attacks
