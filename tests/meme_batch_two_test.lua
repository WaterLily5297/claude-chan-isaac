-- Check delegation boundaries, not native trapdoors, wisps or fly combat.
local root = arg[1]
function include(name) return dofile(root .. "/" .. name:gsub("%.", "/") .. ".lua") end
Isaac = {
    GetItemIdByName = function(n) return n == "Let's Delve" and 920 or 800 end,
    GetPillEffectByName = function(n) return n == "Six Seven" and 56 or 50 end,
    GetTrinketIdByName = function() return 190 end,
    GetPlayerTypeByName = function() return 41 end,
}
ModCallbacks = { MC_USE_ITEM = "use", MC_USE_PILL = "pill" }
CollectibleType = { COLLECTIBLE_WE_NEED_TO_GO_DEEPER = 84 }
UseFlag = { USE_NOANIM = 1, USE_NOCOSTUME = 2, USE_OWNED = 4, USE_ALLOWNONMAIN = 8,
    USE_CARBATTERY = 32, USE_VOID = 64, USE_MIMIC = 128, USE_ALLOWWISPSPAWN = 512, USE_NOHUD = 2048 }
local captions, callbacks = {}, {}
function Game() return { GetHUD = function() return { ShowItemText = function(_, name, text)
    captions[#captions + 1] = { name, text }
end } end } end
local mod = { AddCallback = function(_, event, fn, filter)
    callbacks[#callbacks + 1] = { event = event, fn = fn, filter = filter }
end }
local function fire(event, id, ...)
    local result
    for _, cb in ipairs(callbacks) do
        if cb.event == event and (not cb.filter or cb.filter == id) then result = cb.fn(mod, id, ...) end
    end
    return result
end
include("scripts.items.lets_delve"):Init(mod)
include("scripts.items.six_seven"):Init(mod)
local function player(rolls)
    local p = { Position = {}, uses = {}, flies = {}, draws = 0 }
    function p:UseActiveItem(id, flags, slot)
        self.uses[#self.uses + 1] = { id = id, flags = flags, slot = slot }
        -- Native UseActiveItem also emits MC_USE_ITEM. The filter must prevent recursion.
        assert(fire("use", id, {}, self, flags, slot) == nil)
    end
    function p:GetPillRNG(id)
        assert(id == 56, "use this pill's seeded stream")
        return { RandomInt = function(_, upper)
            assert(upper == 2)
            self.draws = self.draws + 1
            return assert(rolls[self.draws], "one draw per actual use")
        end }
    end
    function p:AddBlueFlies(count, position, target)
        assert(position == self.Position and target == nil, "flies belong to the user")
        self.flies[#self.flies + 1] = count
    end
    return p
end
local a, b = player({0, 1, 0, 1}), player({1})
assert(fire("use", 999, {}, a, 0, 0) == nil and #a.uses == 0, "unrelated active ignored")
local result = fire("use", 920, {}, a, UseFlag.USE_OWNED | UseFlag.USE_ALLOWWISPSPAWN, 2)
assert(result.Discharge and not result.Remove and result.ShowAnim)
assert(#a.uses == 1 and a.uses[1].id == 84 and a.uses[1].slot == -1, "native shovel without pocket ownership")
local delegated = a.uses[1].flags
assert((delegated & (UseFlag.USE_NOANIM | UseFlag.USE_NOCOSTUME | UseFlag.USE_ALLOWNONMAIN | UseFlag.USE_MIMIC)) == 139)
assert((delegated & (UseFlag.USE_OWNED | UseFlag.USE_ALLOWWISPSPAWN)) == 0, "no second owned use/wisp request")
result = fire("use", 920, {}, a, UseFlag.USE_CARBATTERY, 2)
assert(not result.Discharge and not result.Remove and not result.ShowAnim and #a.uses == 1 and #captions == 1)
result = fire("use", 920, {}, b, UseFlag.USE_VOID | UseFlag.USE_NOANIM | UseFlag.USE_NOHUD, 0)
assert(result.Discharge and not result.ShowAnim and #b.uses == 1 and #a.uses == 1 and #captions == 1)
assert((b.uses[1].flags & UseFlag.USE_NOHUD) ~= 0, "nested HUD suppression")
fire("use", 920, {}, a, 0, 1)
assert(#a.uses == 2, "separate primary uses must remain possible")

fire("pill", 55, a, 0)
assert(#a.flies == 0 and a.draws == 0, "unrelated pill ignored")
fire("pill", 56, a, 0)
fire("pill", 56, a, 0)
assert(a.flies[1] == 6 and a.flies[2] == 7 and a.draws == 2, "both seeded outcomes")
local before = #captions
fire("pill", 56, b, UseFlag.USE_MIMIC | UseFlag.USE_NOHUD)
assert(#b.flies == 1 and b.flies[1] == 7 and a.draws == 2 and #captions == before, "co-op and echo/mimic HUD")
fire("pill", 56, a, 0, 2048)
assert(a.flies[3] == 6, "optional horse color does not change the selected same-size rule")
fire("pill", 56, a, 0)
assert(a.flies[4] == 7, "no stale room or same-frame suppression")
print("Meme batch two: native delegation, repeat flags, seeded outcomes and co-op passed")
