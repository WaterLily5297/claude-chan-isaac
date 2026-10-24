-- Llama family backlog items 25-28.
--
-- 25 Open Weights (A4): two native blue flies for each living player (co-op ghosts excluded), up to
--    four recipients; a solo player receives four. Car Battery adds nothing.
--    Existing familiars are untouched.
-- 26 Herd Bell (P): while the owner has no blue flies, every third unique
--    clear grants one. Native fly behavior is unchanged (the "gather closer"
--    part of the design is not implemented). No helper reproduction.
-- 27 Please Come Back (P): three unique combat clears without a charged active
--    use add one charge to an eligible primary active. Progress resets on the
--    reward or on a charged use. Timed and zero-charge actives never benefit.
-- 28 Release Soon (A6): schedule three ordinary-bullet guards two seconds
--    later; they expire eight seconds after use. Leaving the room cancels
--    the pending release without refund.

local Constants = include("scripts.constants")
local Tools = include("scripts.characters.target_tools")

local Llama = {}

local RELEASE_DELAY, RELEASE_LIFE = 60, 180

local function blueFlies(player)
    local n = 0
    for _, e in ipairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_FLY)) do
        local f = e:ToFamiliar()
        if f and f.Player and GetPtrHash(f.Player) == GetPtrHash(player) then n = n + 1 end
    end
    return n
end

function Llama:Init(mod, Risk, C)
    local Item = Constants.Item
    C.WatchClears(Item.HERD_BELL)
    C.WatchClears(Item.PLEASE_COME_BACK)

    -- 25 Open Weights
    mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, _, _, player, flags)
        if C.Battery(flags) then return C.NoUse() end
        local living = {}
        for _, p in ipairs(C.Players()) do
            if Tools.Active(p) and #living < 4 then living[#living + 1] = p end
        end
        local each = #living == 1 and 4 or 2
        for _, p in ipairs(living) do p:AddBlueFlies(each, p.Position, nil) end
        C.Caption("Open Weights", "Free for everyone")
        return C.Used()
    end, Item.OPEN_WEIGHTS)

    C.On("uniqueClear", function()
        for _, p in ipairs(C.Players()) do
            local s = (p:HasCollectible(Item.HERD_BELL) or p:HasCollectible(Item.PLEASE_COME_BACK)) and C.State(p)
            -- 26 Herd Bell
            if s and p:HasCollectible(Item.HERD_BELL) then
                if blueFlies(p) == 0 then
                    s.herd = C.Num(s.herd, 0, 0, 3) + 1
                    if s.herd >= 3 then s.herd = 0; p:AddBlueFlies(1, p.Position, nil) end
                end
            end
            -- 27 Please Come Back
            if s and p:HasCollectible(Item.PLEASE_COME_BACK) then
                s.comeBack = C.Num(s.comeBack, 0, 0, 3) + 1
                if s.comeBack >= 3 then
                    s.comeBack = 0
                    if C.AddCharge(p, 1) then C.Caption("Please Come Back", "+1 charge") end
                end
            end
        end
    end)
    C.On("activeUsed", function(player)
        local s = C.Peek(player)
        if s then s.comeBack = 0 end
    end)

    -- 28 Release Soon
    mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, _, _, player, flags)
        if C.Battery(flags) then return C.NoUse() end
        C.After(RELEASE_DELAY, function()
            for _ = 1, 3 do C.AddGuard(player, "release", RELEASE_LIFE, 3) end
            C.Caption("Released", "3 guards for six seconds")
        end, true)
        C.Caption("Release Soon", "Coming in two seconds")
        return C.Used()
    end, Item.RELEASE_SOON)
end

return Llama
