-- Visual-only feedback for DROP abilities: a vanilla poof or a timed entity
-- tint. Nothing here deals damage, blocks shots or changes collision, and
-- every call is skipped when the API (or a test stub) lacks the feature.
local Feedback = {}

-- A short vanilla dust poof at a position, tinted to the ability's colour.
function Feedback.Burst(position, color)
    if not (Isaac.Spawn and EntityType and EntityType.ENTITY_EFFECT
        and EffectVariant and EffectVariant.POOF01 and Vector) then return end
    local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, position, Vector(0, 0), nil)
    if effect and color then effect.Color = color end
end

-- Tint an entity for a number of frames; the colour fades out on its own.
function Feedback.Mark(entity, color, frames)
    if entity and entity.SetColor and color then entity:SetColor(color, frames, 1, true, false) end
end

return Feedback
