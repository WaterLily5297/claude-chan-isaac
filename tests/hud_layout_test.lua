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
