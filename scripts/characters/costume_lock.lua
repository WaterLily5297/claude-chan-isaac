-- Fixed character look (owner request, 2026-10-24): every mod form keeps its
-- own skin. Items, trinkets, pills, cards and transformations still apply all
-- of their effects; only the costume layers they draw are cleared. Flight,
-- scale, tear and stat changes are untouched. Vanilla characters are ignored.
--
-- Vanilla Lua has no hook that refuses a costume, so the lock clears costumes
-- when something that can add one happens (pickup, removal, temporary effect,
-- use, new room, continue, type change), keeps clearing for a few frames while
-- the engine settles, and sweeps slowly for anything that slipped through.
-- State lives in GetData only; nothing here is saved.
local ModelRoster = include("scripts.characters.model_roster")
local CostumeLock = {
    SETTLE_FRAMES = 3, -- clears after a detected change (costumes can land late)
    SWEEP_FRAMES = 30, -- background re-check for item-state costumes
}

local locked

local function Ids()
    if not locked then
        locked = {}
        for _, id in ipairs(ModelRoster:AllForms()) do
            if id >= 0 then locked[id] = true end
        end
    end
    return locked
end

function CostumeLock:IsLocked(player)
    return player ~= nil and Ids()[player:GetPlayerType()] == true
end

-- Everything that can add or drop a costume without a callback of its own.
local function Signature(player)
    local effects = player:GetEffects()
    local list = effects and effects:GetEffectsList()
    return table.concat({
        player:GetPlayerType(),
        player:GetCollectibleCount(),
        list and list.Size or 0,
        player:GetTrinket(0),
        player:GetTrinket(1),
    }, ":")
end

function CostumeLock:MarkDirty(player)
    if player then player:GetData().ccCostumeSettle = self.SETTLE_FRAMES end
end

local function EachPlayer(fn)
    for i = 0, Game():GetNumPlayers() - 1 do fn(Isaac.GetPlayer(i)) end
end

-- A form changed away from ours (Clicker, revival): give back item costumes
-- and acquired native transformation costumes the lock removed. This restores
-- visuals only; never grant the transformation or replay its stat/effect gains.
local function Restore(player)
    local config = Isaac.GetItemConfig()
    local size = config:GetCollectibles().Size
    for id = 1, size - 1 do
        local item = config:GetCollectible(id)
        if item and player:HasCollectible(id, true) then player:AddCostume(item, false) end
    end
    for form = 0, PlayerForm.NUM_PLAYER_FORMS - 1 do
        if player:HasPlayerForm(form) then player:AddPlayerFormCostume(form) end
    end
end

function CostumeLock:Update(player)
    local data = player:GetData()
    local isLocked = self:IsLocked(player)
    if not isLocked then
        if data.ccCostumeLocked then
            data.ccCostumeLocked, data.ccCostumeSig, data.ccCostumeSettle = nil, nil, nil
            Restore(player)
        end
        return
    end
    data.ccCostumeLocked = true
    local sig = Signature(player)
    if sig ~= data.ccCostumeSig then
        data.ccCostumeSig = sig
        data.ccCostumeSettle = self.SETTLE_FRAMES
    end
    local settle = data.ccCostumeSettle or 0
    if settle > 0 then
        data.ccCostumeSettle = settle - 1
        player:ClearCostumes()
    elseif Game():GetFrameCount() % self.SWEEP_FRAMES == 0 then
        player:ClearCostumes()
    end
end

function CostumeLock:Init(mod)
    mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function(_, player)
        self:Update(player)
    end)
    local function DirtyAll() EachPlayer(function(p) self:MarkDirty(p) end) end
    -- Rooms and continues rebuild costume layers without changing the signature.
    mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, DirtyAll)
    mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, DirtyAll)
    mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, _, _, player)
        self:MarkDirty(player)
    end)
    mod:AddCallback(ModCallbacks.MC_USE_CARD, function(_, _, player) self:MarkDirty(player) end)
    mod:AddCallback(ModCallbacks.MC_USE_PILL, function(_, _, player) self:MarkDirty(player) end)
end

return CostumeLock
