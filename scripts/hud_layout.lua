-- Shared HUD layout. Every player owns one 24-pixel band above the Risk lines:
-- row 0 is the form's main line, row 1 the line above it. One layout keeps
-- mixed co-op forms (Claude's two lines, every other form's one) from
-- overlapping, and keeps story captions above the highest band.
local HudLayout = {}

local BAND, ROW, BOTTOM = 24, 12, 40

function HudLayout.PlayerRow(index, row)
    return Isaac.GetScreenHeight() - BOTTOM - index * BAND - (row or 0) * ROW
end

function HudLayout.CaptionY()
    local players = math.max(1, Game():GetNumPlayers())
    local top = HudLayout.PlayerRow(players - 1, 1)
    return math.min(Isaac.GetScreenHeight() - 105, top - 26)
end

return HudLayout
