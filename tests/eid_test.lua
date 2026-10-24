local root = arg[1]
function include(name) return dofile(root .. "/" .. name:gsub("%.", "/") .. ".lua") end
Isaac = {
    GetItemIdByName = (function() local ids, nxt = {}, 800 return function(n) ids[n] = ids[n] or nxt; nxt = nxt + 1; return ids[n] end end)(),
    GetTrinketIdByName = (function() local ids, nxt = {}, 190 return function(n) ids[n] = ids[n] or nxt; nxt = nxt + 1; return ids[n] end end)(),
    -- Distinct ids per form, so a missing or colliding entry changes the count.
    GetPlayerTypeByName = (function() local ids, nxt = {}, 41 return function(n, tainted)
        local key = n .. tostring(tainted); ids[key] = ids[key] or nxt; nxt = nxt + 1; return ids[key] end end)(),
    GetPillEffectByName = (function() local ids, nxt = {}, 50 return function(n) ids[n] = ids[n] or nxt; nxt = nxt + 1; return ids[n] end end)(),
}
local counts = {}
local function count(kind) return function(_, id, desc, name, lang) counts[kind] = (counts[kind] or 0) + 1; assert(type(desc) == "string" and type(name) == "string" and lang) end end
EID = { addCollectible = count("item"), addTrinket = count("trinket"), addPill = count("pill"), addCharacterInfo = count("character") }
include("scripts.eid"):Init()
for k, v in pairs(counts) do print(k, v) end
assert(counts.item == 17 * 3 + 1 + 8 + 49 and counts.trinket == 6 * 3 + 6)
assert(counts.pill == 2 * 3 + 2 and counts.character == 22 * 3, "all 22 forms in three languages")
