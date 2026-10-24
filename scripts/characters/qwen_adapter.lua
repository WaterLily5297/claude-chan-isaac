-- Normal Qwen: Everyone's Base Model. Choose one adapter per new hostile room.
-- The joke is community enthusiasm for fine-tunes and variants, not a claim
-- about any product. Saved per player; the active bonus ends on room exit.
local HudText = include("scripts.hud_text")
local DropTap = include("scripts.characters.drop_tap")
local Qwen = {}

local ADAPTER_START, ADAPTER_CAP, BIRTHRIGHT_CAP = 1, 2, 3
local CLEARS_PER_ADAPTER = 2
local KINDS = {"Range", "Tempo", "Power"}
local RANGE_BONUS, TEMPO_INTERVAL, POWER_DAMAGE = 60, 0.9, 1.1

local function integer(v, minimum, maximum)
    return type(v) == "number" and v == v and v >= minimum and v <= maximum and v == math.floor(v)
end
local function fresh()
    return {version=1, adapters=ADAPTER_START, clears=0, selected=1, awards={}, seen={}}
end
local function keys(t)
    if type(t) ~= "table" then return false end
    for k, v in pairs(t) do
        if type(k) ~= "string" or v ~= true then return false end
    end
    return true
end
local function valid(s)
    return type(s) == "table" and s.version == 1 and integer(s.adapters, 0, BIRTHRIGHT_CAP)
        and integer(s.clears, 0, CLEARS_PER_ADAPTER - 1) and integer(s.selected, 1, #KINDS)
        and keys(s.awards) and keys(s.seen)
        and (s.activeRoom == nil or type(s.activeRoom) == "string")
        and (s.activeRoom == nil) == (s.active == nil)
        and (s.active == nil or integer(s.active, 1, #KINDS))
end
local function cap(p)
    return p:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) and BIRTHRIGHT_CAP or ADAPTER_CAP
end

function Qwen:Init(mod, Risk)
    local id = Isaac.GetPlayerTypeByName("Qwen-chan", false)
    local ready, bindings, slots = false, {}, {}
    local drop = DropTap.New()
    local function isQwen(p)
        return p and id >= 0 and p:GetPlayerType() == id
    end
    local function allStates()
        if type(Risk.state.qwenAdapter) ~= "table" then Risk.state.qwenAdapter = {} end
        return Risk.state.qwenAdapter
    end
    local function roomKey()
        local level = Game():GetLevel()
        return tostring(level:GetDungeonPlacementSeed())..":"..tostring(level:GetCurrentRoomDesc().SpawnSeed)
    end
    local function floorKey()
        local level = Game():GetLevel()
        return tostring(level:GetDungeonPlacementSeed())..":"..level:GetStage()..":"..level:GetStageType()
    end
    local function refresh(p)
        p:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_RANGE)
        p:EvaluateItems()
    end
    local function bind()
        local all, nextBindings, nextSlots = allStates(), {}, {}
        for i = 0, Game():GetNumPlayers() - 1 do
            local p, key = Isaac.GetPlayer(i), tostring(i)
            local pointer, previous = GetPtrHash(p), slots[key]
            if isQwen(p) then
                if previous and (previous.pointer ~= pointer or previous.seed ~= p.InitSeed
                    or previous.kind ~= p:GetPlayerType()) then all[key] = nil end
                if not valid(all[key]) then all[key] = fresh() end
                local b = bindings[pointer]
                if not b or b.seed ~= p.InitSeed or b.slot ~= key then
                    b = {seed=p.InitSeed, slot=key, armed={}}
                end
                b.state = all[key]; nextBindings[pointer] = b
            else
                all[key] = nil
            end
            nextSlots[key] = {pointer=pointer, seed=p.InitSeed, kind=p:GetPlayerType()}
        end
        for key in pairs(all) do if not nextSlots[key] then all[key] = nil end end
        bindings, slots = nextBindings, nextSlots
    end
    local function binding(p)
        if not ready or not isQwen(p) then return end
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
    local function observeFloor(b)
        local s, floor = b.state, floorKey()
        if s.floor ~= floor then
            if s.floor ~= nil then s.awards = {}; s.seen = {}; b.armed = {} end
            s.floor = floor
        end
    end
    -- The bonus belongs to the room it was spent in.
    local function active(b)
        local s = b.state
        if s.activeRoom and s.activeRoom == roomKey() then return s.active end
    end

    mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function(_, continued)
        ready = true; bindings = {}; slots = {}; drop:Reset()
        if not continued then Risk.state.qwenAdapter = {} end
        bind()
        each(function(p, b) observeFloor(b); refresh(p) end)
    end)
    mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, function()
        ready = false; bindings = {}; slots = {}; drop:Reset()
    end)
    mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
        drop:Reset()
        if not ready then return end
        bind()
        if not next(bindings) then return end
        local room = roomKey()
        each(function(p, b)
            local s = b.state
            observeFloor(b)
            if s.activeRoom and s.activeRoom ~= room then
                s.activeRoom = nil; s.active = nil; refresh(p)
            end
        end)
    end)
    mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, function() drop:Reset() end)
    mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
        if not ready then return end
        bind()
        if not next(bindings) then return end
        if Game():IsPaused() then drop:Reset(); return end
        local combat = not Game():GetRoom():IsClear()
        local room = roomKey()
        each(function(p, b)
            local s = b.state
            observeFloor(b)
            s.adapters = math.min(s.adapters, cap(p))
            if p:IsDead() then drop:Forget(p); return end
            if drop:Poll(p, true) then
                s.selected = s.selected % #KINDS + 1
                Game():GetHUD():ShowItemText("Qwen-chan", "Next adapter: "..KINDS[s.selected])
            end
            if combat then
                b.armed[room] = true
                -- A newly entered hostile room spends one adapter on the selection.
                if not s.seen[room] then
                    s.seen[room] = true
                    if s.adapters > 0 and s.activeRoom ~= room then
                        s.adapters = s.adapters - 1
                        s.active = s.selected; s.activeRoom = room
                        Game():GetHUD():ShowItemText("Qwen-chan", KINDS[s.active].." adapter")
                        refresh(p)
                    end
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
            s.clears = s.clears + 1
            if s.clears >= CLEARS_PER_ADAPTER then
                s.clears = 0
                s.adapters = math.min(cap(p), s.adapters + 1)
            end
        end)
    end)
    mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, p, flag)
        local b = binding(p)
        local kind = b and active(b)
        if not kind then return end
        if flag == CacheFlag.CACHE_RANGE and kind == 1 then
            p.TearRange = p.TearRange + RANGE_BONUS
        elseif flag == CacheFlag.CACHE_FIREDELAY and kind == 2 then
            p.MaxFireDelay = math.max(-0.75, (p.MaxFireDelay + 1) * TEMPO_INTERVAL - 1)
        elseif flag == CacheFlag.CACHE_DAMAGE and kind == 3 then
            p.Damage = p.Damage * POWER_DAMAGE
        end
    end)
    mod:AddCallback(ModCallbacks.MC_POST_RENDER, function()
        if not ready then return end
        if Game():IsPaused() then drop:Reset() end
        if not Game():GetHUD():IsVisible() or not next(bindings) then return end
        each(function(p, b, i)
            local s, kind = b.state, active(b)
            local text = string.format("Qwen-chan: Adapters %d/%d  Next %s  Active %s",
                s.adapters, cap(p), KINDS[s.selected], kind and KINDS[kind] or "none")
            HudText:Draw(text, 50, Isaac.GetScreenHeight() - 52 - i * 12, 0.8, 0.5, 1, 0.9)
        end)
    end)
end

return Qwen
