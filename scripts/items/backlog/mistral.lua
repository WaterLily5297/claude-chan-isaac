-- Mistral family backlog items 29-32.
--
-- 29 Emergency Baguette (A4): a forward line strike 240 units long and 40
--    wide; each enemy on the line takes one 3x owner-damage hit. Walls and
--    obstacles stop the line. No player movement or contact immunity.
-- 30 Slipstream Boots (P): after two seconds of continuous movement, +0.15
--    speed. A sharp turn while boosted drops one slowing gust (one second,
--    80 units) with a three-second cooldown.
-- 31 Very Large Kitten (A6): a fictional cat stays where it was used for three
--    seconds and pushes up to twelve ordinary hostile bullets within 100 units
--    away, twice per second. No sprite or collision change for the player.
-- 32 Edge Compass (P): +0.25 shot speed while within 60 units of the room's
--    outer walls. Cache is refreshed only when that state changes.

local Constants = include("scripts.constants")

local Mistral = {}

local LINE_LENGTH, LINE_WIDTH = 240, 40
local MOVE_FRAMES, GUST_COOLDOWN, GUST_RADIUS = 60, 90, 80
local KITTEN_FRAMES, KITTEN_RADIUS = 90, 100
local EDGE = 60

function Mistral:Init(mod, Risk, C)
    local Item = Constants.Item

    -- 29 Emergency Baguette
    mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, _, _, player, flags)
        if C.Battery(flags) then return C.NoUse() end
        local room = Game():GetRoom()
        local aim = C.Aim(player)
        local stop = LINE_LENGTH
        -- Find where walls or solid grid block the line, in 20-unit steps.
        for step = 20, LINE_LENGTH, 20 do
            if not room:CheckLine(player.Position, player.Position + aim * step, 3, 0, false, false) then
                stop = step - 20; break
            end
        end
        local hit = 0
        for _, npc in ipairs(C.Enemies()) do
            local rel = npc.Position - player.Position
            local along = rel.X * aim.X + rel.Y * aim.Y
            local side = math.abs(rel.X * aim.Y - rel.Y * aim.X)
            if along >= 0 and along <= stop and side <= LINE_WIDTH / 2 + npc.Size then
                C.Pulse(npc, player, 3); hit = hit + 1
            end
        end
        for d = 20, stop, 40 do
            local e = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, player.Position + aim * d, Vector.Zero, player)
            e.Color = Color(0.9, 0.7, 0.4, 1, 0.2, 0.1, 0)
        end
        C.Caption("Emergency Baguette", hit > 0 and string.format("%d hit", hit) or "Fresh bread, no customers")
        return C.Used()
    end, Item.EMERGENCY_BAGUETTE)

    -- 31 Very Large Kitten
    local kittens = {}
    mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, _, _, player, flags)
        if C.Battery(flags) then return C.NoUse() end
        kittens[GetPtrHash(player)] = { position = player.Position, expires = C.Now() + KITTEN_FRAMES }
        C.Caption("Very Large Kitten", "Le gros chaton is here")
        return C.Used()
    end, Item.LARGE_KITTEN)
    C.On("newRoom", function() kittens = {} end)
    C.On("runReset", function() kittens = {} end)

    C.Stat("speed", function(p)
        return (p:HasCollectible(Item.SLIPSTREAM_BOOTS) and C.Data(p).slip) and 0.15 or 0
    end)
    C.Stat("shotspeed", function(p)
        return (p:HasCollectible(Item.EDGE_COMPASS) and C.Data(p).edge) and 0.25 or 0
    end)

    C.On("update", function(frame)
        for key, k in pairs(kittens) do
            if k.expires < frame then kittens[key] = nil
            elseif frame % 15 == 0 then
                for _, b in ipairs(C.Bullets(k.position, KITTEN_RADIUS, 12)) do
                    local away = b.Position - k.position
                    if away:LengthSquared() < 1 then away = Vector(0, 1) end
                    b.Velocity = away:Resized(math.max(6, b.Velocity:Length()))
                end
            end
        end
        local room = Game():GetRoom()
        for _, p in ipairs(C.Players()) do
            local d = C.Data(p)
            -- 30 Slipstream Boots
            if p:HasCollectible(Item.SLIPSTREAM_BOOTS) then
                local v = p.Velocity
                if v:LengthSquared() > 1 then
                    d.moving = d.moving or frame
                    local boosted = frame - d.moving >= MOVE_FRAMES
                    if boosted ~= (d.slip == true) then d.slip = boosted or nil; C.Refresh(p) end
                    local dir = v:Normalized()
                    if d.slip and d.lastDir and (dir.X * d.lastDir.X + dir.Y * d.lastDir.Y) < -0.5
                        and (d.gustReady or 0) <= frame then
                        d.gustReady = frame + GUST_COOLDOWN
                        for _, npc in ipairs(C.Nearby(p.Position, GUST_RADIUS)) do
                            npc:AddSlowing(EntityRef(p), 30, 0.5, Color(0.8, 0.9, 1, 1, 0, 0.1, 0.2))
                        end
                    end
                    d.lastDir = dir
                else
                    d.moving, d.lastDir = nil, nil
                    if d.slip then d.slip = nil; C.Refresh(p) end
                end
            end
            -- 32 Edge Compass
            if p:HasCollectible(Item.EDGE_COMPASS) and frame % 5 == 0 then
                local tl, br = room:GetTopLeftPos(), room:GetBottomRightPos()
                local pos = p.Position
                local near = pos.X - tl.X < EDGE or br.X - pos.X < EDGE or pos.Y - tl.Y < EDGE or br.Y - pos.Y < EDGE
                if near ~= (d.edge == true) then d.edge = near or nil; C.Refresh(p) end
            end
        end
    end)
end

return Mistral
