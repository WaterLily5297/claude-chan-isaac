-- Reactions Port Pack otherwise gives unknown characters an Isaac face.
-- Opt only our characters out of its fallback costumes. Keep sounds/music and
-- any explicitly supplied character support intact. Item costumes are
-- handled by scripts/characters/costume_lock.lua.
local Compatibility = {}
local ModelRoster = include("scripts.characters.model_roster")

function Compatibility:Register(pack)
    if type(pack) ~= "table" or type(pack.CostumeSets) ~= "table" then return end
    local ids=ModelRoster:AllForms()
    for _, set in pairs(pack.CostumeSets) do
        if type(set) == "table" and type(set.IDs) == "table" then
            for _, name in ipairs(set.IDs) do
                local costumes = set[name]
                if type(costumes) == "table" and type(costumes.Default) == "table" then
                    for _, id in ipairs(ids) do
                        if id >= 0 and costumes[id] == nil then
                            costumes[id] = { Apply = {}, Remove = {} }
                        end
                    end
                end
            end
        end
    end
end

function Compatibility:Init(mod)
    -- All mods and their costume packs are loaded before game start.
    mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function()
        self:Register(ReactionPack)
    end)
end

return Compatibility
