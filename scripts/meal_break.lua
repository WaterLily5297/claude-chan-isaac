-- Shared food lockout. Save scalar countdowns; never change type or costume.
local MealBreak = {}
local MAX_FRAMES = 90

function MealBreak:Init(mod, Risk)
    local ready = false
    local bindings, slots = {}, {}
    local shooting = {
        [ButtonAction.ACTION_SHOOTLEFT] = true,
        [ButtonAction.ACTION_SHOOTRIGHT] = true,
        [ButtonAction.ACTION_SHOOTUP] = true,
        [ButtonAction.ACTION_SHOOTDOWN] = true,
    }
    local function allStates()
        if type(Risk.state.mealBreaks) ~= "table" then Risk.state.mealBreaks = {} end
        return Risk.state.mealBreaks
    end
    local function valid(s)
        return type(s) == "table" and s.version == 1
            and type(s.remaining) == "number" and s.remaining >= 0
            and s.remaining <= MAX_FRAMES and s.remaining == math.floor(s.remaining)
    end
    local function bindPlayers()
        local all, nextBindings, nextSlots = allStates(), {}, {}
        for i = 0, Game():GetNumPlayers() - 1 do
            local p, key = Isaac.GetPlayer(i), tostring(i)
            local pointer = GetPtrHash(p)
            local old = slots[key]
            if old and (old.pointer ~= pointer or old.seed ~= p.InitSeed) then
                all[key] = nil -- A replacement entity cannot inherit a departed player's meal.
            end
            if not valid(all[key]) then all[key] = {version = 1, remaining = 0} end
            local b = bindings[pointer]
            if not b or b.seed ~= p.InitSeed or b.slot ~= key then
                b = {seed = p.InitSeed, slot = key, frame = Game():GetFrameCount()}
            end
            b.state = all[key]
            nextBindings[pointer] = b
            nextSlots[key] = {pointer = pointer, seed = p.InitSeed}
        end
        for key in pairs(all) do if not nextSlots[key] then all[key] = nil end end
        bindings, slots = nextBindings, nextSlots
    end
    local function binding(player)
        local b = bindings[GetPtrHash(player)]
        if b and b.seed == player.InitSeed then return b end
    end
    local function keepDelay(player, remaining)
        if remaining > 0 then player.FireDelay = math.max(player.FireDelay, remaining) end
    end

    function self:Remaining(player)
        if not ready then return 0 end
        local b = binding(player)
        return b and b.state.remaining or 0
    end
    function self:Start(player, frames)
        if not ready or player:IsDead() then return false end
        bindPlayers()
        local b = binding(player)
        if not b then return false end
        b.state.remaining = math.max(b.state.remaining, math.min(MAX_FRAMES, frames))
        b.frame = Game():GetFrameCount()
        keepDelay(player, b.state.remaining)
        return true
    end

    mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function(_, continued)
        bindings, slots = {}, {}
        if not continued then Risk.state.mealBreaks = {} end
        ready = true
        bindPlayers() -- Risk loads first; restore before the first input poll.
        for i = 0, Game():GetNumPlayers() - 1 do
            local p = Isaac.GetPlayer(i)
            keepDelay(p, self:Remaining(p))
        end
    end)
    mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, function()
        ready = false
        bindings, slots = {}, {}
    end)
    mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
        if not ready then return end
        bindPlayers()
        local now, paused = Game():GetFrameCount(), Game():IsPaused()
        for i = 0, Game():GetNumPlayers() - 1 do
            local p = Isaac.GetPlayer(i)
            local b = binding(p)
            if p:IsDead() then
                b.state.remaining = 0
            elseif not paused then
                if now > b.frame then b.state.remaining = math.max(0, b.state.remaining - 1) end
                keepDelay(p, b.state.remaining)
            end
            b.frame = now
        end
    end)
    mod:AddCallback(ModCallbacks.MC_INPUT_ACTION, function(_, entity, hook, action)
        -- This callback is polled frequently: no player/room scan or state mutation.
        if not ready or not shooting[action] or not entity then return end
        local p = entity:ToPlayer()
        if not p or p:IsDead() or self:Remaining(p) <= 0 or Game():IsPaused() then return end
        if hook == InputHook.GET_ACTION_VALUE then return 0 end
        if hook == InputHook.IS_ACTION_PRESSED or hook == InputHook.IS_ACTION_TRIGGERED then return false end
    end)
end

return MealBreak
