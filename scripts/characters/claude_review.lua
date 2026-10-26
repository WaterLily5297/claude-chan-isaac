-- Compliance Review: earn the existing account-age award by controlling kill order.
-- Only primitive room/target identifiers enter the per-player Usage save table.
local C = include("scripts.constants")
local Feedback = include("scripts.characters.feedback")
local Review = {}
local PHASE = {none=true, waiting=true, active=true, won=true, missed=true}

local function floorKey()
    local level = Game():GetLevel()
    return tostring(level:GetDungeonPlacementSeed())..":"..level:GetStage()..":"..level:GetStageType()
end
local function roomKey()
    local desc = Game():GetLevel():GetCurrentRoomDesc()
    return tostring(desc.SpawnSeed)..":"..tostring(desc.SafeGridIndex)
end
local function targetKey(e)
    return table.concat({e.InitSeed, e.Type, e.Variant, e.SubType}, ":")
end
local function fresh()
    return {version=1, floor=floorKey(), phase="none", seen={}}
end
local function valid(r)
    if type(r) ~= "table" or r.version ~= 1 or not PHASE[r.phase]
        or type(r.floor) ~= "string" or type(r.seen) ~= "table" then return false end
    for k, v in pairs(r.seen) do if type(k) ~= "string" or v ~= true then return false end end
    return r.phase ~= "active" or (type(r.room) == "string" and type(r.target) == "string"
        and (r.killed == nil or type(r.killed) == "boolean"))
end
local function hostile(e)
    return e:Exists() and not e:IsDead() and e:IsEnemy() and not e:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)
end

function Review:Init(mod, Risk, usageFor, refresh)
    local ready, slots = false, {}
    local function each(fn)
        local present = {}
        for i = 0, Game():GetNumPlayers() - 1 do
            local p, key = Isaac.GetPlayer(i), tostring(i)
            local old, pointer = slots[key], GetPtrHash(p)
            present[key] = {pointer=pointer, seed=p.InitSeed, kind=p:GetPlayerType()}
            if p:GetPlayerType() == C.Player.CLAUDE_CHAN then
                local usage = usageFor(p)
                if old and (old.pointer ~= pointer or old.seed ~= p.InitSeed or old.kind ~= p:GetPlayerType()) then
                    usage.review = nil
                end
                if not valid(usage.review) then usage.review = fresh() end
                fn(p, usage, usage.review)
            elseif old and old.kind == C.Player.CLAUDE_CHAN then
                local all = Risk.state.claudeUsage
                if all and all[key] then all[key].review = nil end
            end
        end
        slots = present
    end
    local function observe(r)
        local floor = floorKey()
        if r.floor ~= floor then
            r.floor = floor; r.phase = Risk:IsSuspended() and "none" or "waiting"; r.seen = {}
            r.target = nil; r.room = nil; r.killed = nil
        end
        if r.phase == "active" and r.room ~= roomKey() then r.phase = "missed" end
    end
    mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function()
        ready = true; slots = {}
        each(function(_, _, r) observe(r) end)
    end)
    mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, function() ready = false; slots = {} end)
    local function changedRoom()
        if ready then each(function(_, _, r) observe(r) end) end
    end
    mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, changedRoom)
    mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, changedRoom)
    mod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, function(_, e)
        if not ready then return end
        each(function(_, _, r)
            if r.phase == "active" and r.floor == floorKey() and r.room == roomKey()
                and targetKey(e) == r.target then r.killed = true end
        end)
    end)
    mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
        if not ready or Game():IsPaused() then return end
        -- Resolve after all same-frame deaths, so room-clearing attacks count as last.
        each(function(p, usage, r)
            observe(r)
            if p:IsDead() then if r.phase == "active" then r.phase = "missed" end; return end
            if r.phase ~= "waiting" and r.phase ~= "active" then return end
            local enemies, target, eligible = {}, nil, {}
            for _, e in ipairs(Isaac.GetRoomEntities()) do
                if hostile(e) then
                    enemies[#enemies + 1] = e
                    if e:IsVulnerableEnemy() then eligible[#eligible + 1] = e end
                    if r.target and targetKey(e) == r.target then target = e end
                end
            end
            if r.phase == "waiting" and not Game():GetRoom():IsClear() and not r.seen[roomKey()] then
                r.seen[roomKey()] = true
                if #eligible >= 2 then
                    table.sort(eligible, function(a, b)
                        local da, db = p.Position:Distance(a.Position), p.Position:Distance(b.Position)
                        if da ~= db then return da < db end
                        if a.InitSeed ~= b.InitSeed then return a.InitSeed < b.InitSeed end
                        return targetKey(a) < targetKey(b)
                    end)
                    target = eligible[1]; r.phase = "active"; r.room = roomKey(); r.target = targetKey(target)
                    Game():GetHUD():ShowItemText("Compliance Review", "Defeat the marked target last")
                end
            end
            if r.phase == "active" then
                if r.killed then
                    if #enemies == 0 and not Risk:IsSuspended() then
                        r.phase = "won"; usage.age = math.min(8, usage.age + 1); refresh(p)
                        Game():GetHUD():ShowItemText("Review passed", "Account age +1")
                    else r.phase = "missed" end
                    r.killed = nil
                elseif not target or not target:IsVulnerableEnemy() then r.phase = "missed"
                else Feedback.Mark(target, Color(1, 0.7, 0.3, 1, 0.3, 0.1, 0), 2) end
            end
        end)
    end)
end
return Review
