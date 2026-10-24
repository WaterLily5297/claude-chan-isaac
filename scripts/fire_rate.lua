-- Fire-rate scaling that stays correct for every MaxFireDelay vanilla can produce.
-- Tears per second are 30 / (MaxFireDelay + 1), so a delay can sit between
-- -0.75 and 0 with Soy Milk, Almond Milk or stacked tears items. Multiplying
-- the raw delay there slows the player down instead of speeding them up;
-- scaling the whole interval (delay + 1) keeps every multiplier monotonic.

local FireRate = {}

FireRate.MIN_DELAY = -0.75

-- interval < 1 fires faster: 0.8 is 25% more tears, 0.5 doubles them.
function FireRate.ScaleInterval(maxFireDelay, interval)
    return math.max(FireRate.MIN_DELAY, (maxFireDelay + 1) * interval - 1)
end

return FireRate
