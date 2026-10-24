-- Normal GPT: Same Name, Smaller Brain. Verified / Fallback routing with a Sanity Check.
-- Saved per-player status, Routing and unique clears. No proxy, IP or risk mechanics.
local HudText = include("scripts.hud_text")
local DropTap = include("scripts.characters.drop_tap")
local Gpt = {}

local VERIFIED_DAMAGE, FALLBACK_DAMAGE = 1.15, 0.8
local ROUTING_CAP = 3
local CHECK_RADIUS = 200
local CHECK_HITS, BIRTHRIGHT_HITS = 3, 2
local WINDOW_FRAMES = 6 -- One continuous-weapon payment window (0.2 seconds).

local function integer(v, minimum, maximum)
    return type(v) == "number" and v == v and v >= minimum and v <= maximum and v == math.floor(v)
end
local function fresh()
    return {version=1, verified=true, routing=0, awards={}}
end
local function needed(p)
    return p:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) and BIRTHRIGHT_HITS or CHECK_HITS
end

function Gpt:Init(mod, Risk)
    local id = Isaac.GetPlayerTypeByName("GPT-chan", false)
    local ready, bindings, slots = false, {}, {}
    local drop = DropTap.New()
    local function isGpt(p)
        return p and id >= 0 and p:GetPlayerType() == id
    end
    local function allStates()
        if type(Risk.state.gptRouting) ~= "table" then Risk.state.gptRouting = {} end
        return Risk.state.gptRouting
    end
    local function valid(s)
        if type(s) ~= "table" or s.version ~= 1 or type(s.verified) ~= "boolean"
            or not integer(s.routing, 0, ROUTING_CAP) or type(s.awards) ~= "table" then return false end
        if s.checkRoom ~= nil and type(s.checkRoom) ~= "string" then return false end
        for k, v in pairs(s.awards) do
            if type(k) ~= "string" or v ~= true then return false end
        end
        return true
    end
    local function roomKey()
        local level = Game():GetLevel()
        return tostring(level:GetDungeonPlacementSeed())..":"..tostring(level:GetCurrentRoomDesc().SpawnSeed)
    end
    local function refresh(p)
        p:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
        p:EvaluateItems()
    end
    local function bind()
        local all, nextBindings, nextSlots = allStates(), {}, {}
        for i = 0, Game():GetNumPlayers() - 1 do
            local p, key = Isaac.GetPlayer(i), tostring(i)
            local pointer, previous = GetPtrHash(p), slots[key]
            if isGpt(p) then
                if previous and (previous.pointer ~= pointer or previous.seed ~= p.InitSeed
                    or previous.kind ~= p:GetPlayerType()) then all[key] = nil end
                if not valid(all[key]) then all[key] = fresh() end
                local b = bindings[pointer]
                if not b or b.seed ~= p.InitSeed or b.slot ~= key then
                    b = {seed=p.InitSeed, slot=key, armed={}}
                end
                b.state = all[key]; nextBindings[pointer] = b
            else
                -- A character change discards GPT's routing instead of transferring it.
                all[key] = nil
            end
            nextSlots[key] = {pointer=pointer, seed=p.InitSeed, kind=p:GetPlayerType()}
        end
        for key in pairs(all) do if not nextSlots[key] then all[key] = nil end end
        bindings, slots = nextBindings, nextSlots
    end
    local function binding(p)
        if not ready or not isGpt(p) then return end
        local b = bindings[GetPtrHash(p)]
        if b and b.seed == p.InitSeed then return b end
    end
    local function each(fn)
        for i = 0, Game():GetNumPlayers() - 1 do
            local p = Isaac.GetPlayer(i)
            local b = binding(p)
            if b then fn(p, b, i) end
        end
    end
    local function observeFloor(p, b)
        local s, level = b.state, Game():GetLevel()
        local floor = tostring(level:GetDungeonPlacementSeed())..":"..level:GetStage()..":"..level:GetStageType()
        if s.floor ~= floor then
            -- Every floor starts Verified; continue on the same floor does not.
            if s.floor ~= nil then
                local changed = not s.verified
                s.verified = true; s.routing = 0; s.awards = {}; s.checkRoom = nil
                b.check = nil; b.armed = {}
                if changed then refresh(p) end
            end
            s.floor = floor
        end
    end
    local function verify(p, b)
        b.state.verified = true; b.state.routing = 0; b.check = nil
        Game():GetHUD():ShowItemText("GPT-chan", "Verified")
        refresh(p)
    end
    local function attacker(entity)
        if not entity then return end
        local spawner = entity.SpawnerEntity or entity.Parent
        return spawner and spawner:ToPlayer()
    end
    -- One paid attack is one volley or one continuous-weapon window. Derived
    -- tears share their parent's spawn frame; unregistered splits never count.
    local function attackKey(entity, now)
        if entity.Type == EntityType.ENTITY_TEAR then
            local data = entity:GetData()
            if data.ccGptVolley then return "v"..data.ccGptVolley end
            if data.ccThoughtDerived then return "v"..(now - entity.FrameCount) end
            return nil
        elseif entity.Type == EntityType.ENTITY_LASER or entity.Type == EntityType.ENTITY_KNIFE then
            return "w"..math.floor(now / WINDOW_FRAMES)
        elseif entity.Type == EntityType.ENTITY_BOMB then
            return "v"..(now - entity.FrameCount)
        end
    end
    local function nearestTarget(p)
        local best, distance
        for _, e in ipairs(Isaac.FindInRadius(p.Position, CHECK_RADIUS, EntityPartition.ENEMY)) do
            if e:IsVulnerableEnemy() and not e:IsDead() and not e:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then
                local d = p.Position:Distance(e.Position)
                if d <= CHECK_RADIUS and (not distance or d < distance) then best, distance = e, d end
            end
        end
        return best
    end

    mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function(_, continued)
        ready = true; bindings = {}; slots = {}; drop:Reset()
        if not continued then Risk.state.gptRouting = {} end
        bind()
        each(function(p, b) observeFloor(p, b); refresh(p) end)
    end)
    mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, function()
        ready = false; bindings = {}; slots = {}; drop:Reset()
    end)
    mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
        drop:Reset()
        if not ready then return end
        bind()
        -- Leaving the room fails an unfinished check; Fallback remains.
        each(function(p, b) b.check = nil; observeFloor(p, b) end)
    end)
    mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, function() drop:Reset() end)
    mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
        if not ready then return end
        bind()
        if Game():IsPaused() then drop:Reset(); return end
        if not next(bindings) then return end
        local combat = not Game():GetRoom():IsClear()
        local room = roomKey()
        each(function(p, b)
            local s = b.state
            observeFloor(p, b)
            if p:IsDead() then drop:Forget(p); return end
            if combat then
                b.armed[room] = true
                if s.verified and s.routing >= ROUTING_CAP then
                    s.verified = false
                    Game():GetHUD():ShowItemText("GPT-chan", "Fallback: same name, smaller brain")
                    refresh(p)
                end
            end
            if b.check and (not b.check.ref.Ref or not b.check.ref.Ref:Exists()) then b.check = nil end
            local canCheck = not s.verified and s.checkRoom ~= room and b.check == nil
            if drop:Poll(p, canCheck) then
                local target = nearestTarget(p)
                -- No target means no attempt is spent.
                if target then
                    s.checkRoom = room
                    b.check = {ref=EntityPtr(target), hash=GetPtrHash(target), hits={}, count=0}
                    Game():GetHUD():ShowItemText("GPT-chan", "Sanity Check")
                end
            end
        end)
    end)
    mod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, function()
        if not ready or not next(bindings) then return end
        local room = roomKey()
        each(function(p, b)
            local s = b.state
            if p:IsDead() or not b.armed[room] or s.awards[room] then return end
            s.awards[room] = true
            if s.verified then s.routing = math.min(ROUTING_CAP, s.routing + 1) end
        end)
    end)
    mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, function(_, tear)
        if not ready or not next(bindings) then return end
        local data = tear:Exists() and tear:GetData()
        if not data or data.ccThoughtDerived or data.ccGptVolley then return end
        if not binding(attacker(tear)) then return end
        data.ccGptVolley = Game():GetFrameCount()
    end)
    mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, entity, _, _, source)
        if not ready or not next(bindings) then return end
        local src = source and source.Entity
        local p = attacker(src)
        local b = binding(p)
        if not b or not b.check or GetPtrHash(entity) ~= b.check.hash then return end
        local now = Game():GetFrameCount()
        b.check.credit = now
        local key = attackKey(src, now)
        if not key then return end
        if b.check.hits[key] then return end
        b.check.hits[key] = true
        b.check.count = b.check.count + 1
        if b.check.count >= needed(p) then verify(p, b) end
    end)
    mod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, function(_, entity)
        if not ready or not next(bindings) then return end
        local now = Game():GetFrameCount()
        each(function(p, b)
            local check = b.check
            if check and GetPtrHash(entity) == check.hash and check.credit and now - check.credit <= 1 then
                verify(p, b)
            end
        end)
    end)
    mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, p, flag)
        if flag ~= CacheFlag.CACHE_DAMAGE then return end
        local b = binding(p)
        if b then p.Damage = p.Damage * (b.state.verified and VERIFIED_DAMAGE or FALLBACK_DAMAGE) end
    end)
    mod:AddCallback(ModCallbacks.MC_POST_RENDER, function()
        if not ready then return end
        if Game():IsPaused() then drop:Reset() end
        if not Game():GetHUD():IsVisible() then return end
        each(function(p, b, i)
            local s = b.state
            local text
            if s.verified then
                text = string.format("GPT-chan: Verified  Routing %d/%d", s.routing, ROUTING_CAP)
            elseif b.check then
                text = string.format("GPT-chan: Fallback  Check %d/%d", b.check.count, needed(p))
            else
                text = "GPT-chan: Fallback  "..(s.checkRoom == roomKey() and "Check failed" or "DROP: Sanity Check")
            end
            HudText:Draw(text, 50, Isaac.GetScreenHeight() - 52 - i * 12, 0.4, 1, 0.75, 0.9)
        end)
    end)
end

return Gpt
