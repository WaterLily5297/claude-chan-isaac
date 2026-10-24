-- Pickups an item must never delete: run-ending chests, the trophy, beds and
-- Mom's chest. Deleting one can leave a floor with no way to finish the run.
local PickupSafety = {}

local PROTECTED = {}
for name, fallback in pairs({ PICKUP_BIGCHEST = 340, PICKUP_TROPHY = 370, PICKUP_BED = 380, PICKUP_MOMSCHEST = 390 }) do
    PROTECTED[(PickupVariant and PickupVariant[name]) or fallback] = true
end

function PickupSafety.Protected(pickup)
    return pickup ~= nil and PROTECTED[pickup.Variant] == true
end

return PickupSafety
