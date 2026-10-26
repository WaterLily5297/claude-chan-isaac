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
    -- Distinct ids per form, so a missing or colliding entry changes the count.
    GetPlayerTypeByName = (function() local ids, nxt = {}, 41 return function(n, tainted)
        local key = n .. tostring(tainted); ids[key] = ids[key] or nxt; nxt = nxt + 1; return ids[key] end end)(),
    GetPillEffectByName = idsFrom("pill", 50),
}
local counts, english, characterText = {}, {}, {}
local function count(kind) return function(_, id, desc, name, lang)
    counts[kind] = (counts[kind] or 0) + 1
    assert(type(desc) == "string" and type(name) == "string" and lang)
    assert(desc ~= "" and not desc:find("##", 1, true) and desc:sub(1, 1) ~= "#" and desc:sub(-1) ~= "#", "malformed EID lines: " .. name)
    if kind == "character" then
        assert(desc:find("DROP ability requires at most one pocket item", 1, true), "missing pocket restriction: " .. name)
        characterText[name] = characterText[name] or {}
        characterText[name][lang] = desc
    end
    if lang == "en_us" then english[kind .. id] = name end
end end
EID = { addCollectible = count("item"), addTrinket = count("trinket"), addPill = count("pill"), addCharacterInfo = count("character") }
include("scripts.eid"):Init()
for k, v in pairs(counts) do print(k, v) end
assert(counts.item == 17 * 3 + 1 + 8 + 49 + 4 + 1 and counts.trinket == 6 * 3 + 6)
assert(counts.pill == 2 * 3 + 2 + 1 and counts.character == 22 * 3, "all 22 forms in three languages")

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
assert(declared == 80 + 12 + 5)

-- B1: display the candidate values in every language registration. These
-- checks complement real-module damage/timer tests and guard against giving
-- Gemini Kimi's percentage when updating shared dossier strings.
local expected = {
    ["Claude-chan"] = {"+0.15 damage per floor", "max +1.2"},
    ["Tainted Claude-chan"] = {"Damage x1.2#", "damage x0.5"},
    ["DeepSeek-chan"] = {"up to x1.9 damage"},
    ["Tainted DeepSeek-chan"] = {"2.5 Compute per second", "x1.3 damage"},
    ["GPT-chan"] = {"damage x1.1#"},
    ["Tainted GPT-chan"] = {"Damage x1.4,"},
    ["Gemini-chan"] = {"damage to it is x1.15#", "marked damage x1.25#"},
    ["Tainted Gemini-chan"] = {"pulse of 1.8x"},
    ["Grok-chan"] = {"damage is x1.25"},
    ["Tainted Grok-chan"] = {"pulse of 0.9x"},
    ["Qwen-chan"] = {"interval x0.92", "damage x1.08"},
    ["Tainted Qwen-chan"] = {"+0.15 damage", "+0.25 per award"},
    ["Llama-chan"] = {"damage x0.92#"},
    ["Tainted Llama-chan"] = {"one 0.45x damage"},
    ["Mistral-chan"] = {"for 1.8x damage"},
    ["Tainted Mistral-chan"] = {"2.25x damage"},
    ["Doubao-chan"] = {"for 1.5 seconds"},
    ["Tainted Doubao-chan"] = {"Confident at 1.3x"},
    ["Kimi-chan"] = {"take x1.12 damage"},
    ["Tainted Kimi-chan"] = {"three 0.55x", "deal 0.65x"},
    ["GLM-chan"] = {"damage x1.15"},
    ["Tainted GLM-chan"] = {"takes 1.8x", "max 4.8x"},
}
for name, fragments in pairs(expected) do
    for _, lang in ipairs({"en_us", "zh_cn", "ja_jp"}) do
        local desc = assert(characterText[name][lang], name .. ": missing " .. lang)
        for _, fragment in ipairs(fragments) do
            assert(desc:find(fragment, 1, true), name .. " " .. lang .. ": missing " .. fragment)
        end
    end
end
local roster = include("scripts.characters.model_roster")
local dossierValues = {gpt="Verified: +10%", gemini="Painted: +15%", grok="6s: +25%",
    mistral="swipe, 1.8x", kimi="+12% your damage", glm="rooms: +15%"}
for _, form in ipairs(roster.definitions) do
    local expectedText = dossierValues[form.key]
    if expectedText then
        assert(table.concat(form.lines, " "):find(expectedText, 1, true), form.key .. ": stale dossier values")
    end
end
