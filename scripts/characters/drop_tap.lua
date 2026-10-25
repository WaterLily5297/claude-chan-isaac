-- Observe DROP without consuming or overriding the engine's native input.
-- A gesture is transient: interrupted presses must never become saved actions.
local DropTap = {}
local MAX_TAP_FRAMES = 12

local function hasPocketChoice(player)
    local count = 0
    -- Card/pill slots 0-3 are distinct from active slots. GetPocketItem is
    -- unusable in base Repentance, so inspect the documented getters instead.
    for slot = 0, 3 do
        if player:GetCard(slot) ~= 0 or player:GetPill(slot) ~= 0 then
            count = count + 1
            if count > 1 then return true end
        end
    end
    -- ActiveSlot.SLOT_POCKET and SLOT_POCKET2; exclude main and Schoolbag.
    for slot = 2, 3 do
        if player:GetActiveItem(slot) ~= 0 then
            count = count + 1
            if count > 1 then return true end
        end
    end
    return false
end

function DropTap.New()
    local records = {}
    local tracker = {}

    function tracker:Reset()
        if next(records) then records = {} end
    end

    function tracker:Forget(player)
        records[GetPtrHash(player)] = nil
    end

    function tracker:Poll(player, enabled)
        local pointer = GetPtrHash(player)
        -- A co-op ghost keeps its character type but must not use abilities.
        if not enabled or player:IsDead() or not player:AreControlsEnabled()
            or (player.IsCoopGhost and player:IsCoopGhost()) or Game():IsPaused() then
            records[pointer] = nil
            return false
        end
        local frame, controller = Game():GetFrameCount(), player.ControllerIndex
        local pressed = Input.IsActionPressed(ButtonAction.ACTION_DROP, controller)
        local kind, seed = player:GetPlayerType(), player.InitSeed
        local s = records[pointer]
        if not s or s.seed ~= seed or s.kind ~= kind or s.controller ~= controller
            or frame < s.frame then
            -- Observe a release before accepting a new press. This prevents a
            -- button held through entry, continue or control reassignment firing.
            records[pointer] = {seed=seed, kind=kind, controller=controller,
                frame=frame, down=pressed}
            return false
        end
        -- Native cycling owns any gesture that encounters multiple pocket
        -- items. Never rearm it just because one was used/dropped while held.
        -- Check before duplicate-frame rejection: inventory can change between
        -- two callbacks in that same frame.
        if (pressed or s.started) and hasPocketChoice(player) then
            s.frame, s.down, s.started = frame, pressed, nil
            return false
        end
        if frame == s.frame then return false end
        s.frame = frame
        if pressed then
            if not s.down then s.started = frame end
            if s.started and frame - s.started > MAX_TAP_FRAMES then s.started = nil end
            s.down = true
            return false
        end
        local tapped = s.down and s.started ~= nil
            and frame - s.started >= 1 and frame - s.started <= MAX_TAP_FRAMES
        s.down, s.started = false, nil
        return tapped
    end

    return tracker
end

return DropTap
