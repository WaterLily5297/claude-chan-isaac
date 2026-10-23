local root = arg[1]
function include(name) return dofile(root .. "/" .. name:gsub("%.", "/") .. ".lua") end
Isaac = {
    GetItemIdByName = (function() local ids, nxt = {}, 800 return function(n) ids[n] = ids[n] or nxt; nxt = nxt + 1; return ids[n] end end)(),
    GetTrinketIdByName = (function() local ids, nxt = {}, 190 return function(n) ids[n] = ids[n] or nxt; nxt = nxt + 1; return ids[n] end end)(),
    GetPlayerTypeByName = function(n, tainted) return (n == "Claude-chan" and 41 or 42) + (tainted and 100 or 0) end,
    GetPillEffectByName = function(n) return n == "Cat-girl Mode" and 50 or 51 end,
}
local counts = {}
local function count(kind) return function(_, id, desc, name, lang) counts[kind] = (counts[kind] or 0) + 1; assert(type(desc) == "string" and type(name) == "string" and lang) end end
EID = { addCollectible = count("item"), addTrinket = count("trinket"), addPill = count("pill"), addCharacterInfo = count("character") }
include("scripts.eid"):Init()
for k, v in pairs(counts) do print(k, v) end
assert(counts.item == 17 * 3 + 1 and counts.trinket == 6 * 3)
assert(counts.pill == 2 * 3 and counts.character == 4 * 3, "normal + tainted for both characters")
