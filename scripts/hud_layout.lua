-- Shared HUD layout. Every player owns one 24-pixel band above the Risk lines:
-- row 0 is the form's main line, row 1 the line above it. One layout keeps
-- mixed co-op forms (Claude's two lines, every other form's one) from
-- overlapping, and keeps story captions above the highest band.
local HudLayout = {}

local BAND, ROW, BOTTOM = 24, 12, 40
-- Form lines start at x=50. GLYPH is an estimate of the default RenderText
-- advance (no width API exists for it); MARGIN keeps the last glyph on screen.
local LEFT, GLYPH, MARGIN = 50, 6, 8

function HudLayout.PlayerRow(index, row)
    return Isaac.GetScreenHeight() - BOTTOM - index * BAND - (row or 0) * ROW
end

function HudLayout.CaptionY()
    local players = math.max(1, Game():GetNumPlayers())
    local top = HudLayout.PlayerRow(players - 1, 1)
    return math.min(Isaac.GetScreenHeight() - 105, top - 26)
end

-- Split a form's line at its two-space separators so that the part drawn on
-- row 0 fits the screen width; the rest goes on row 1 of the same band, which
-- only Claude-chan otherwise uses. A line with no separator is left whole.
function HudLayout.Split(text, width)
    local limit = math.floor((width - LEFT - MARGIN) / GLYPH)
    local first, rest = text, nil
    while #first > limit do
        local cut = first:match("^.*()  ")
        if not cut or cut <= 1 then break end
        rest = first:sub(cut + 2) .. (rest and "  " .. rest or "")
        first = first:sub(1, cut - 1)
    end
    return first, rest
end

-- Draw one form line for player `index` through `hud` (scripts.hud_text).
function HudLayout.DrawPlayer(hud, index, text, r, g, b, a)
    local first, rest = HudLayout.Split(text, Isaac.GetScreenWidth())
    hud:Draw(first, LEFT, HudLayout.PlayerRow(index), r, g, b, a)
    if rest then hud:Draw(rest, LEFT, HudLayout.PlayerRow(index, 1), r, g, b, a) end
end

return HudLayout
