-- Gemini family backlog items 13-16.
--
-- 13 Nano Banana (A4): paint the nearest enemy within 180 units for six
--    seconds. If it dies while painted, a four-second banana peel at its
--    position slows enemies within 50 units. One paint and one peel per
--    owner; bosses can be painted. No target keeps the charge.
-- 14 One More Finger (P): every fifth attack adds one small native 0.3x tear
--    along the aim, at most once per half second. The extra tear is never an
--    attack itself, so it cannot recurse.
-- 15 Undo Brush (A4): erase up to six ordinary hostile bullets within 90
--    units; each gives +0.02 speed for four seconds (max +0.12). No bullets
--    keeps the charge. Nothing else is rolled back.
-- 16 Unchanged Preview (A6): two six-second decoy markers at free positions
--    near the player. Nearby enemies are pointed at them through the native
--    NPC target field. Max two per owner; reuse replaces them.

local Constants = include("scripts.constants")

local Gemini = {}

local PAINT_FRAMES, PAINT_RANGE, PEEL_FRAMES, PEEL_RADIUS = 180, 180, 120, 50
local FINGER_EVERY, FINGER_GAP = 5, 15
local BRUSH_RANGE, BRUSH_MAX, BRUSH_FRAMES = 90, 6, 120
local DECOY_FRAMES, DECOY_PULL = 180, 200

function Gemini:Init(mod, Risk, C)
    local Item = Constants.Item

    -- 13 Nano Banana
    local paints, peels = {}, {}
    mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, _, _, player, flags)
        if C.Battery(flags) then return C.NoUse() end
        local target = C.NearestEnemy(player.Position, PAINT_RANGE)
        if not target then return C.NoUse() end
        paints[GetPtrHash(player)] = { player = player, hash = GetPtrHash(target), expires = C.Now() + PAINT_FRAMES }
        target:SetColor(Color(1, 1, 0.3, 1, 0.3, 0.3, 0), PAINT_FRAMES, 1, false, false)
        C.Caption("Nano Banana", "Painted")
        return C.Used()
    end, Item.NANO_BANANA)
    C.On("kill", function(npc)
        for key, p in pairs(paints) do
            if p.hash == GetPtrHash(npc) and p.expires >= C.Now() then
                paints[key] = nil
                peels[key] = { player = p.player, position = npc.Position, expires = C.Now() + PEEL_FRAMES }
                local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, npc.Position, Vector.Zero, p.player)
                poof.Color = Color(1, 1, 0.2, 1, 0.4, 0.4, 0)
            end
        end
    end)

    -- 15 Undo Brush state shares the update loop below.
    mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, _, _, player, flags)
        if C.Battery(flags) then return C.NoUse() end
        local bullets = C.Bullets(player.Position, BRUSH_RANGE, BRUSH_MAX)
        if #bullets == 0 then return C.NoUse() end
        for _, b in ipairs(bullets) do b:Remove() end
        local d = C.Data(player)
        d.brush = { amount = math.min(0.12, 0.02 * #bullets), expires = C.Now() + BRUSH_FRAMES }
        C.Refresh(player)
        C.Caption("Undo Brush", string.format("Undid %d bullet(s)", #bullets))
        return C.Used()
    end, Item.UNDO_BRUSH)
    C.Stat("speed", function(p)
        local b = C.Data(p).brush
        return b and b.expires >= C.Now() and b.amount or 0
    end)

    -- 16 Unchanged Preview
    local decoys = {}
    local function clearDecoys(key)
        for _, ref in ipairs(decoys[key] or {}) do
            local e = ref.ptr.Ref
            if e and e:Exists() then e:Remove() end
        end
        decoys[key] = nil
    end
    mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, _, _, player, flags)
        if C.Battery(flags) then return C.NoUse() end
        local key = GetPtrHash(player)
        clearDecoys(key)
        local room = Game():GetRoom()
        decoys[key] = {}
        for i = 1, 2 do
            local offset = Vector(i == 1 and -80 or 80, 0)
            local position = room:FindFreePickupSpawnPosition(player.Position + offset, 0, true, false)
            local e = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.TARGET, 0, position, Vector.Zero, player)
            e.Color = Color(1, 1, 1, 0.6, 0.2, 0.2, 0.4)
            C.AddHelper(player, e, "decoy")
            table.insert(decoys[key], { ptr = EntityPtr(e), expires = C.Now() + DECOY_FRAMES })
        end
        C.Caption("Unchanged Preview", "Two previews, nothing changed")
        return C.Used()
    end, Item.UNCHANGED_PREVIEW)

    -- 14 One More Finger
    C.On("attack", function(player)
        if not player:HasCollectible(Item.ONE_MORE_FINGER) then return end
        local d = C.Data(player)
        d.fingers = (d.fingers or 0) + 1
        if d.fingers < FINGER_EVERY or (d.fingerReady or 0) > C.Now() then return end
        d.fingers, d.fingerReady = 0, C.Now() + FINGER_GAP
        C.After(1, function()
            if player:Exists() and not player:IsDead() then
                local aim = C.Aim(player)
                local tear = C.FireDerived(player, aim * (10 * player.ShotSpeed), 0.3)
                if tear then tear.Scale = tear.Scale * 0.6 end
            end
        end, true)
    end)

    C.On("update", function(frame)
        for key, p in pairs(peels) do
            if p.expires < frame then peels[key] = nil
            elseif frame % 10 == 0 then
                for _, npc in ipairs(C.Nearby(p.position, PEEL_RADIUS)) do
                    npc:AddSlowing(EntityRef(p.player), 15, 0.6, Color(1, 1, 0.5, 1, 0.2, 0.2, 0))
                end
            end
        end
        for key, p in pairs(paints) do if p.expires < frame then paints[key] = nil end end
        for key, list in pairs(decoys) do
            local alive = {}
            for _, ref in ipairs(list) do
                local e = ref.ptr.Ref
                if e and e:Exists() and ref.expires >= frame then alive[#alive + 1] = { e = e } else
                    if e and e:Exists() then e:Remove() end end
            end
            if #alive == 0 then decoys[key] = nil
            elseif frame % 5 == 0 then
                -- Each non-boss enemy in range is pointed at its nearest decoy.
                for _, a in ipairs(alive) do
                    for _, npc in ipairs(C.Nearby(a.e.Position, DECOY_PULL)) do
                        local best, bestD = nil, math.huge
                        for _, b in ipairs(alive) do
                            local dist = (b.e.Position - npc.Position):LengthSquared()
                            if dist < bestD then best, bestD = b.e, dist end
                        end
                        if not npc:IsBoss() and best == a.e then npc.Target = a.e end
                    end
                end
            end
        end
        for _, p in ipairs(C.Players()) do
            local b = C.Data(p).brush
            if b and b.expires < frame then C.Data(p).brush = nil; C.Refresh(p) end
        end
    end)
    C.On("newRoom", function()
        paints, peels = {}, {}
        for key in pairs(decoys) do clearDecoys(key) end
    end)
end

return Gemini
