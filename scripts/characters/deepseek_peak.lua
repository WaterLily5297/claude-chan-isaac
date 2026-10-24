-- Tainted DeepSeek: Wenfeng / Wengu. Peak / Valley compute scheduling.
-- Saved per-player Compute, phase and mode. No proxy, IP or risk mechanics.
-- Tear volleys buy two half-damage forks. Every other native attack (laser
-- starts and 0.2-second beam windows, knife throws, melee swings, Dr. Fetus
-- bombs, Epic Fetus rockets) buys the same-priced "off-peak boost" instead:
-- that attack's hits deal 1.3x, re-dealt once behind a recursion guard.
local C = include("scripts.constants")
local HudText = include("scripts.hud_text")
local HudLayout = include("scripts.hud_layout")
local DropTap = include("scripts.characters.drop_tap")
local TearFork = include("scripts.tear_fork")
local PaidAttacks = include("scripts.characters.paid_attacks")
local Peak = {}

local PHASE_FRAMES = 360 -- Twelve active-combat seconds.
local START_COMPUTE, CAP, BIRTHRIGHT_CAP = 12, 24, 32
local REGEN_FRAMES = 10 -- Three Compute per second.
local COST = {valley=2, peak=4}
local TOGGLE_FRAMES = 30
local FORK_SPREAD, FORK_DAMAGE = 12, 0.5
local BOOST_DAMAGE = 1.3 -- Two half-damage forks, landed on one target.
local WINDOW = 6
local BOOST = "ccPeakBoost"

local function tainted(p)
    return p and C.Player.DEEPSEEK_CHAN_B >= 0 and p:GetPlayerType() == C.Player.DEEPSEEK_CHAN_B
end
local function integer(v, minimum, maximum)
    return type(v) == "number" and v == v and v >= minimum and v <= maximum and v == math.floor(v)
end
local function fresh()
    return {version=1, compute=START_COMPUTE, regen=0, phase="valley", remaining=PHASE_FRAMES, saving=false}
end
local function cap(p)
    return p:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) and BIRTHRIGHT_CAP or CAP
end

function Peak:Init(mod, Risk)
    local ready, bindings, slots = false, {}, {}
    local drop = DropTap.New()
    local function allStates()
        if type(Risk.state.deepseekPeak) ~= "table" then Risk.state.deepseekPeak = {} end
        return Risk.state.deepseekPeak
    end
    local function valid(s)
        return type(s) == "table" and s.version == 1 and integer(s.compute, 0, BIRTHRIGHT_CAP)
            and integer(s.regen, 0, REGEN_FRAMES - 1) and COST[s.phase] ~= nil
            and integer(s.remaining, 1, PHASE_FRAMES) and type(s.saving) == "boolean"
    end
    local function bind()
        local all, nextBindings, nextSlots = allStates(), {}, {}
        for i = 0, Game():GetNumPlayers() - 1 do
            local p, key = Isaac.GetPlayer(i), tostring(i)
            local pointer, previous = GetPtrHash(p), slots[key]
            if tainted(p) then
                if previous and (previous.pointer ~= pointer or previous.seed ~= p.InitSeed
                    or previous.kind ~= p:GetPlayerType()) then all[key] = nil end
                if not valid(all[key]) then all[key] = fresh() end
                local b = bindings[pointer]
                if not b or b.seed ~= p.InitSeed or b.slot ~= key then
                    b = {seed=p.InitSeed, slot=key, frame=Game():GetFrameCount(), clock=0, toggleReady=0}
                end
                b.state = all[key]; nextBindings[pointer] = b
            else
                -- Observed character changes discard the former form's Compute.
                all[key] = nil
            end
            nextSlots[key] = {pointer=pointer, seed=p.InitSeed, kind=p:GetPlayerType()}
        end
        for key in pairs(all) do if not nextSlots[key] then all[key] = nil end end
        bindings, slots = nextBindings, nextSlots
    end
    local function binding(p)
        if not ready or not tainted(p) then return end
        local b = bindings[GetPtrHash(p)]
        if b and b.seed == p.InitSeed then return b end
    end
    local function observeFloor(s)
        local level = Game():GetLevel()
        local floor = tostring(level:GetDungeonPlacementSeed())..":"..level:GetStage()..":"..level:GetStageType()
        if s.floor ~= floor then
            -- Every floor starts in Valley; Compute carries over.
            if s.floor ~= nil then s.phase = "valley"; s.remaining = PHASE_FRAMES; s.regen = 0 end
            s.floor = floor
        end
    end
    local function each(fn)
        for i = 0, Game():GetNumPlayers() - 1 do
            local p = Isaac.GetPlayer(i)
            local b = binding(p)
            if b then fn(p, b, i) end
        end
    end

    mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function(_, continued)
        ready = true; bindings = {}; slots = {}; drop:Reset()
        if not continued then Risk.state.deepseekPeak = {} end
        bind()
        each(function(_, b) observeFloor(b.state) end)
    end)
    mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, function()
        ready = false; bindings = {}; slots = {}; drop:Reset()
    end)
    mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
        drop:Reset()
        if not ready then return end
        bind()
        each(function(_, b) b.volley = nil; observeFloor(b.state) end)
    end)
    mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, function() drop:Reset() end)
    mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
        if not ready then return end
        bind()
        local now = Game():GetFrameCount()
        if Game():IsPaused() then
            drop:Reset()
            each(function(_, b) b.frame = now end)
            return
        end
        local combat = not Game():GetRoom():IsClear()
        each(function(p, b)
            local s = b.state
            observeFloor(s)
            s.compute = math.min(s.compute, cap(p))
            if p:IsDead() then drop:Forget(p); b.frame = now; return end
            local advanced = now > b.frame
            if now < b.frame then b.volley = nil; drop:Forget(p) end
            b.frame = now
            if advanced then
                b.clock = b.clock + 1
                -- Empty rooms freeze both the schedule and Valley recovery.
                if combat then
                    s.remaining = s.remaining - 1
                    if s.remaining <= 0 then
                        s.phase = s.phase == "valley" and "peak" or "valley"
                        s.remaining = PHASE_FRAMES; s.regen = 0
                    end
                    local firing = p:GetShootingInput():LengthSquared() > 0
                        or (b.volley and b.volley.frame == now)
                    if s.phase == "valley" and not firing and s.compute < cap(p) then
                        s.regen = s.regen + 1
                        if s.regen >= REGEN_FRAMES then s.regen = 0; s.compute = s.compute + 1 end
                    else
                        s.regen = 0
                    end
                end
            end
            if drop:Poll(p, true) and b.clock >= b.toggleReady then
                s.saving = not s.saving; b.toggleReady = b.clock + TOGGLE_FRAMES
            end
        end)
    end)
    -- One payment per frame, shared by every tear and weapon in it.
    local function charge(b)
        local s, now = b.state, Game():GetFrameCount()
        if not b.volley or b.volley.frame ~= now then
            local cost = COST[s.phase]
            local paid = not s.saving and s.compute >= cost
            if paid then s.compute = s.compute - cost end
            b.volley = {frame=now, forks=paid}
        end
        return b.volley.forks
    end
    mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, function(_, tear)
        local data = tear:Exists() and tear:GetData()
        if not data or data.ccThoughtDerived or data.ccPeakSeen then return end
        local p = tear.SpawnerEntity and tear.SpawnerEntity:ToPlayer()
        local b = binding(p)
        if not b or p:IsDead() or Game():IsPaused() then return end
        data.ccPeakSeen = true
        -- One volley is one payment; every tear in a paid volley forks once.
        if not charge(b) then return end
        for _, angle in ipairs({-FORK_SPREAD, FORK_SPREAD}) do
            local fork = Isaac.Spawn(EntityType.ENTITY_TEAR, tear.Variant, 0, tear.Position,
                tear.Velocity:Rotated(angle), p):ToTear()
            if fork then TearFork.Copy(tear, fork, FORK_DAMAGE) end
        end
    end)
    -- Non-tear attacks: a paid attack marks its weapon until the attack ends
    -- (the window for a held beam, the flight for a knife throw, otherwise the
    -- entity's life); an unpaid one clears the mark.
    local function boost(p, entity, lasting)
        local b = binding(p)
        if not b or not entity or p:IsDead() or Game():IsPaused() then return end
        if entity.Type == EntityType.ENTITY_TEAR then return end -- Tears fork instead.
        local now = Game():GetFrameCount()
        entity:GetData()[BOOST] = charge(b) and (lasting and math.huge or now + WINDOW) or nil
    end
    local function owner(entity)
        local spawner = entity and (entity.SpawnerEntity or entity.Parent)
        return spawner and spawner:ToPlayer()
    end
    mod:AddCallback(ModCallbacks.MC_POST_LASER_INIT, function(_, laser)
        if not ready then return end
        local circle = laser.IsCircleLaser and laser:IsCircleLaser()
        boost(owner(laser), laser, laser.OneHit or circle)
    end)
    mod:AddCallback(ModCallbacks.MC_POST_BOMB_INIT, function(_, bomb)
        if ready and bomb.IsFetus then boost(owner(bomb), bomb, true) end
    end)
    PaidAttacks.Observe(mod, function(p, entity)
        if not ready then return end
        boost(p, entity, entity and entity.Type ~= EntityType.ENTITY_LASER)
    end)
    local redealing = false
    mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, target, amount, flags, source, countdown)
        if redealing or not ready or target:ToPlayer() then return end
        local weapon = source and source.Entity
        if not weapon or not weapon.GetData then return end
        local mark = weapon:GetData()[BOOST]
        if not mark or Game():GetFrameCount() > mark then return end
        -- A knife's throw ends when it returns; resting contact is unpaid.
        if weapon.Type == EntityType.ENTITY_KNIFE and weapon.IsFlying
            and weapon.SubType ~= (KnifeSubType and KnifeSubType.CLUB_HITBOX or 4)
            and not weapon:IsFlying() then return end
        redealing = true
        target:TakeDamage(amount * BOOST_DAMAGE, flags, source, countdown)
        redealing = false
        return false
    end)
    mod:AddCallback(ModCallbacks.MC_POST_RENDER, function()
        if not ready then return end
        if Game():IsPaused() then drop:Reset() end
        if not Game():GetHUD():IsVisible() then return end
        each(function(p, b, i)
            local s = b.state
            local text = string.format("Compute %d/%d  %s %.1fs  %s", s.compute, cap(p),
                s.phase == "peak" and "Peak" or "Valley", s.remaining / 30, s.saving and "Saving" or "Forks On")
            HudText:Draw(text, 50, HudLayout.PlayerRow(i), 0.45, 1, 0.95, 1)
        end)
    end)
end

return Peak
