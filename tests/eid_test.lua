local root = arg[1]
function include(name) return dofile(root .. "/" .. name:gsub("%.", "/") .. ".lua") end
local idNames = {}
local function idsFrom(kind, start)
    local ids, nxt = {}, start
    return function(n)
        if not ids[n] then ids[n] = nxt; idNames[kind .. nxt] = n; nxt = nxt + 1 end
        return ids[n]
    end
end
Isaac = {
    GetItemIdByName = idsFrom("item", 800),
    GetTrinketIdByName = idsFrom("trinket", 190),
    GetPlayerTypeByName = function(n, tainted) return (n == "Claude-chan" and 41 or 42) + (tainted and 100 or 0) end,
    GetPillEffectByName = idsFrom("pill", 50),
}
local counts, english = {}, {}
local function count(kind) return function(_, id, desc, name, lang)
    counts[kind] = (counts[kind] or 0) + 1
    assert(type(desc) == "string" and type(name) == "string" and lang)
    assert(desc ~= "" and not desc:find("##", 1, true) and desc:sub(1, 1) ~= "#" and desc:sub(-1) ~= "#", "malformed EID lines: " .. name)
    if lang == "en_us" then english[kind .. id] = name end
end end
EID = { addCollectible = count("item"), addTrinket = count("trinket"), addPill = count("pill"), addCharacterInfo = count("character") }
include("scripts.eid"):Init()
for k, v in pairs(counts) do print(k, v) end
assert(counts.item == 17 * 3 + 1 + 8 + 49 and counts.trinket == 6 * 3 + 6)
assert(counts.pill == 2 * 3 + 2 and counts.character == 4 * 3, "normal + tainted for both characters")

-- Every collectible, trinket and pill declared in the XML has an English EID entry under the same name.
local function read(path) local f = assert(io.open(root .. "/" .. path)); local s = f:read("a"); f:close(); return s end
local function unescape(s) return (s:gsub("&gt;", ">"):gsub("&lt;", "<"):gsub("&quot;", "\""):gsub("&apos;", "'"):gsub("&amp;", "&")) end
local declared = 0
local function expect(kind, name)
    declared = declared + 1
    local id = (kind == "item" and Isaac.GetItemIdByName or kind == "trinket" and Isaac.GetTrinketIdByName or Isaac.GetPillEffectByName)(name)
    assert(english[kind .. id] == name, kind .. " has no matching English EID entry: " .. name .. " (got " .. tostring(english[kind .. id]) .. ")")
end
for tag, name, rest in read("content/items.xml"):gmatch("<(%a+)%s+name=\"([^\"]+)\"([^>]*)>") do
    assert(rest:match("description=\"[^\"]+\""), "missing pickup description: " .. name)
    expect(tag == "trinket" and "trinket" or "item", unescape(name))
end
for name in read("content/pocketitems.xml"):gmatch("<pilleffect%s+name=\"([^\"]+)\"") do expect("pill", unescape(name)) end
for key in pairs(english) do
    if not key:match("^character") then assert(idNames[key], "EID entry for an undeclared id: " .. key) end
end
print("declared with EID", declared)
assert(declared == 75 + 12 + 4)
