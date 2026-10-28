-- Co-op HUD lines must never overlap: every form draws through the shared
-- player bands, bands stay above the Risk lines, and story captions stay above
-- the highest band for one to four players.
local root = arg[1]
local players = 1
Isaac = { GetScreenHeight = function() return 270 end }
function Game() return { GetNumPlayers = function() return players end } end
local Layout = dofile(root .. "/scripts/hud_layout.lua")

local RISK_TOP = 270 - 28
local seen = {}
for i = 0, 3 do
    for row = 0, 1 do
        local y = Layout.PlayerRow(i, row)
        assert(not seen[y], string.format("player %d row %d collides at y=%d", i, row, y))
        assert(y + 12 <= RISK_TOP, "player rows stay above the Risk lines")
        seen[y] = true
    end
end
for n = 1, 4 do
    players = n
    local caption = Layout.CaptionY()
    -- Appeal Queue caption (2 lines) and the roster arc caption 30 above it.
    assert(caption + 24 <= Layout.PlayerRow(n - 1, 1), n .. " players: caption overlaps a band")
    assert(caption <= 270 - 105, "single-player caption position is unchanged or higher")
end
players = 1; assert(Layout.CaptionY() == 165, "one player keeps the original caption height")
print("PASS hud_layout: distinct co-op bands, above Risk, captions above bands")

-- No form may compute its own HUD height again (the old -52/-40 offsets collided).
local files = io.popen('ls "' .. root .. '"/scripts/characters/*.lua "' .. root .. '"/scripts/story*.lua')
for path in files:lines() do
    local source = assert(io.open(path)):read("a")
    if not path:find("dossiers", 1, true) then
        assert(not source:find("GetScreenHeight", 1, true), path .. " must place HUD text through hud_layout")
    end
end
files:close()
print("PASS hud_layout: every form and story caption uses the shared layout")

-- Long form lines move their trailing parts to row 1 instead of running off
-- narrow screens. Worst cases are assembled from each form's format strings at
-- their caps; widths use the layout's 6px glyph estimate.
local WORST = {
    "Qwen-chan: Adapters 3/3  Next Range  Active Range  Installing: stop firing",
    "Qwen-chan: Balanced  Variants 3/3  Awards 3/3  Pinned: 2 clears",
    "GLM-chan: Retries 3/3  Request Pending 2s  Restore connection",
    "Mistral-chan: Baguettes 2/2  Cooldown 2s  Combat to bake",
    "Compute 100/100  Valley 10.0s  Forks On  Reserved 100",
    "GLM-chan: Ticket ready! Tap DROP before next fight",
    "Llama-chan: Releases 2/2  Next 2/3  Between fights",
    "Kimi-chan: Tasks 3/3  Budget 9/9  Micromanaged 3",
}
for _, width in ipairs({480, 400, 360}) do
    for _, text in ipairs(WORST) do
        local first, rest = Layout.Split(text, width)
        local whole = rest and first .. "  " .. rest or first
        assert(whole == text, "splitting keeps every word in order: " .. text)
        for _, part in ipairs({first, rest}) do
            assert(50 + 6 * #part <= width - 8, string.format("%d wide: '%s' still overflows", width, part))
        end
    end
end
assert(select(2, Layout.Split(WORST[1], 480)) == "Installing: stop firing", "only the 74-character line splits at 480")
for i = 2, #WORST do assert(select(2, Layout.Split(WORST[i], 480)) == nil, WORST[i] .. " fits at 480") end
assert(Layout.Split("GLM-chan:NoSeparatorsAtAll", 60) == "GLM-chan:NoSeparatorsAtAll", "unsplittable text stays whole")

Isaac.GetScreenWidth = function() return 360 end
local drawn = {}
Layout.DrawPlayer({Draw = function(_, text, x, y) drawn[#drawn + 1] = {text, x, y} end}, 1, WORST[1], 1, 1, 1, 1)
assert(#drawn == 2 and drawn[1][3] == Layout.PlayerRow(1) and drawn[2][3] == Layout.PlayerRow(1, 1)
    and drawn[1][2] == 50 and drawn[2][2] == 50, "the overflow goes to row 1 of the same player's band")
print("PASS hud_layout: long form lines split onto row 1 at 480, 400 and 360 wide")

-- Only Claude-chan's forms place lines on rows directly (they use row 1 themselves).
for path in io.popen('ls "' .. root .. '"/scripts/characters/*.lua'):lines() do
    local source = assert(io.open(path)):read("a")
    if not path:find("claude_chan", 1, true) then
        assert(not source:find("HudLayout.PlayerRow", 1, true), path .. " must draw through HudLayout.DrawPlayer")
    end
end
print("PASS hud_layout: every other form draws through DrawPlayer")

-- Dossier cards: the portrait's visible box never covers the text column.
do
    local C = {Player = setmetatable({}, {__index = function() return -1 end})}
    function include(name)
        if name == "scripts.constants" then return C end
        return dofile(root .. "/" .. name:gsub("%.", "/") .. ".lua")
    end
    Isaac.GetPlayerTypeByName = function() return -1 end
    local Dossiers = include("scripts.characters.dossiers")
    local Roster = include("scripts.characters.model_roster")
    local defs = {}
    for _, def in ipairs(Dossiers.originals) do defs[#defs + 1] = def end
    for _, def in ipairs(Roster.definitions) do defs[#defs + 1] = def end
    assert(#defs == 22, "all 22 dossier cards are checked")
    for _, size in ipairs({{480, 270}, {400, 270}, {640, 360}, {960, 540}}) do
        for _, def in ipairs(defs) do
            local widest = 46
            for _, line in ipairs(def.lines) do widest = math.max(widest, #line) end
            local x, scale = Dossiers.Placement(def, size[1], size[2])
            assert(x - 192 * scale >= 50 + 6 * widest, string.format("%dx%d %s: portrait covers text", size[1], size[2], def.name))
            assert(x + 192 * scale <= size[1], string.format("%dx%d %s: portrait leaves the screen", size[1], size[2], def.name))
            assert(576 * scale <= size[2] - 48 + 0.001, def.name .. ": portrait fits the height")
        end
    end
    local x, scale = Dossiers.Placement(defs[1], 960, 540)
    assert(x == 860 and scale == 0.42, "wide screens keep the original placement")
end
print("PASS hud_layout: dossier portraits clear the text on 400 to 960 wide screens")
