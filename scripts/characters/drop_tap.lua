-- Observe DROP without consuming or overriding the engine's native input.
-- A gesture is transient: interrupted presses must never become saved actions.
local DropTap = {}
local MAX_TAP_FRAMES = 12

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
