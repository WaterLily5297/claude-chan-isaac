-- Compose identity tints with native item colors; never erase additive offsets.
local Tint = {}

function Tint.Apply(base, r, g, b, a)
    if not base then return Color(r, g, b, a, 0, 0, 0) end
    return Color(base.R * r, base.G * g, base.B * b, base.A * a,
        base.RO, base.GO, base.BO)
end

return Tint
