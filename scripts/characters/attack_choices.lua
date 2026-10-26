-- Aggregate target choices without changing paid-attack identities or billing.
-- A favorable hit wins for the same attack, including a later piercing hit.
-- Scalar history lives only with the room check/quote; no entities are retained.
local Choices = {}
function Choices.New()
    return {entries={}, index={}, value=0}
end
function Choices.Record(ledger, key, favorable)
    local entry = ledger.index[key]
    if not entry then
        entry = {good=favorable == true, position=#ledger.entries + 1}
        ledger.index[key] = entry
        ledger.entries[#ledger.entries + 1] = entry
        ledger.dirty = ledger.dirty or entry.position
    elseif favorable and not entry.good then
        entry.good = true; ledger.dirty = math.min(ledger.dirty or entry.position, entry.position)
    end
end
function Choices.Half(ledger)
    ledger.entries[#ledger.entries + 1] = {half=true}
    ledger.dirty = ledger.dirty or #ledger.entries
end
-- Reconcile once after damage callbacks. Replaying clamps is necessary when a
-- delayed hit changes an earlier attack: undoing just its last delta is wrong.
function Choices.Resolve(ledger, cap)
    if ledger.cap ~= cap then ledger.cap = cap; ledger.dirty = 1 end
    if ledger.dirty then
        local first = ledger.dirty
        local value = first > 1 and ledger.entries[first - 1].after or 0
        for i = first, #ledger.entries do
            local entry = ledger.entries[i]
            if entry.half then value = math.floor(value / 2)
            else value = math.max(0, math.min(cap, value + (entry.good and 1 or -1))) end
            entry.after = value
        end
        ledger.value = value; ledger.dirty = nil
    end
    return ledger.value
end
return Choices
