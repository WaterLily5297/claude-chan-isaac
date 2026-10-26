-- Ignore All Previous Instructions (active, 4 charges)
-- Prompt-injection parody: the nearest vulnerable enemy within range receives
-- new instructions and is charmed for 8 seconds. A boss only loses track of
-- its instructions (2 seconds of confusion). The effect uses native statuses.
-- No target keeps the charge. Car Battery's second use skips the first
-- selected enemy, including a boss or an enemy that resisted the status.

local Constants = include("scripts.constants")

local Inject = {}

local RANGE_SQUARED = 200 * 200
local CHARM_FRAMES, BOSS_CONFUSE_FRAMES = 240, 60

local function eligible(npc)
    return npc and npc:Exists() and not npc:IsDead() and npc:IsVulnerableEnemy()
        and not npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)
        and not npc:HasEntityFlags(EntityFlag.FLAG_CHARM)
end

function Inject.FindTarget(player, excluded)
    local best, bestDistance
    local excludedHash = excluded and GetPtrHash(excluded)
    for _, entity in ipairs(Isaac.GetRoomEntities()) do
        local npc = entity:ToNPC()
        if eligible(npc) and (not excludedHash or GetPtrHash(npc) ~= excludedHash) then
            local distance = (npc.Position - player.Position):LengthSquared()
            if distance <= RANGE_SQUARED and (not best or distance < bestDistance
                    or (distance == bestDistance and npc.Index < best.Index)) then
                best, bestDistance = npc, distance
            end
        end
    end
    return best
end

local function remember(entity)
    return { ref = EntityPtr(entity), seed = entity.InitSeed }
end

local function resolve(record)
    local entity = record and record.ref.Ref
    if entity and entity:Exists() and entity.InitSeed == record.seed then return entity end
end

function Inject:Init(mod)
    -- Only the latest primary for each live owner/slot can exclude a target.
    -- The repeat consumes that record. No entity is saved or frame delay assumed.
    local primaries = {}
    local function clearPrimaries() primaries = {} end
    mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, clearPrimaries)
    mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, clearPrimaries)
    mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, _, _, player, flags, slot)
        local batteryRepeat = ((flags or 0) & UseFlag.USE_CARBATTERY) ~= 0
        local ownerHash, slotKey = GetPtrHash(player), slot or -1
        local previous = primaries[ownerHash]
        if previous and (previous.owner.seed ~= player.InitSeed or not resolve(previous.owner)) then
            primaries[ownerHash], previous = nil, nil
        end
        local excluded = batteryRepeat and previous and resolve(previous.targets[slotKey])
        if previous then previous.targets[slotKey] = nil end
        local target = Inject.FindTarget(player, excluded)
        if not batteryRepeat and target then
            if not previous then previous = { owner = remember(player), targets = {} } end
            previous.targets[slotKey] = remember(target)
            primaries[ownerHash] = previous
        elseif previous and next(previous.targets) == nil then
            primaries[ownerHash] = nil
        end
        if not target then
            return { Discharge = false, Remove = false, ShowAnim = false }
        end
        local ref = EntityRef(player)
        if target:IsBoss() then
            target:AddConfusion(ref, BOSS_CONFUSE_FRAMES, false)
            Game():GetHUD():ShowItemText("Ignore all previous instructions", "The boss refused, mostly")
        else
            target:AddCharmed(ref, CHARM_FRAMES)
            Game():GetHUD():ShowItemText("Ignore all previous instructions", "New instructions: help them")
        end
        return { Discharge = true, Remove = false, ShowAnim = true }
    end, Constants.Item.IGNORE_INSTRUCTIONS)
end

return Inject
