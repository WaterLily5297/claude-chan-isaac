-- Copy resolved shot properties without firing another player attack callback.
-- Entity links, collision history, attached targets and mod-private data are not clones.
local TearFork = {}

function TearFork.Copy(parent, child, damageMultiplier)
    child.CollisionDamage = parent.CollisionDamage * damageMultiplier
    child.Color = parent.Color
    child.TearFlags = parent.TearFlags
    child.Height = parent.Height
    child.FallingSpeed = parent.FallingSpeed
    child.FallingAcceleration = parent.FallingAcceleration
    child.HomingFriction = parent.HomingFriction
    child.KnockbackMultiplier = parent.KnockbackMultiplier
    child.Scale = parent.Scale
    child:ResetSpriteScale()
end

return TearFork
