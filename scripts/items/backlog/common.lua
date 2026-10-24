-- Shared services for the fifty-row collectible backlog (docs/EXPANSION_DESIGN.md).
--
-- One instance is created in main.lua and passed to every family module, so
-- event lists, guards and timers are shared. Everything uses native engine
-- data: no weapon, sprite, tear flag or collision rule is replaced.
--
-- Attacks: a tear volley (all tears a player fires in one update), a laser,
-- a thrown knife or a Dr. Fetus bomb is one attack. Primed bonuses are not
-- written into entity damage; each entity of the boosted attack is leased a
-- multiplier for at most ATTACK_LEASE frames, applied when it actually hits.
-- That keeps other damage writers and continuous weapons bounded.
--
-- Saved state lives in Risk.state.backlog, keyed by player slot, versioned,
-- with a floor-scoped sub-table. No entity reference is ever saved.

local Common = {}

local VERSION = 1
local ATTACK_LEASE = 120

local function now() return Game():GetFrameCount() end
Common.Now = now

function Common.FloorKey()
    local level = Game():GetLevel()
    return tostring(level:GetDungeonPlacementSeed()) .. ":" .. level:GetStage() .. ":" .. level:GetStageType()
end

function Common.RoomKey()
    local desc = Game():GetLevel():GetCurrentRoomDesc()
    return Common.FloorKey() .. "/" .. tostring(desc and desc.SafeGridIndex or -1)
end

function Common.Players()
    local list = {}
    for i = 0, Game():GetNumPlayers() - 1 do list[#list + 1] = Isaac.GetPlayer(i) end
    return list
end

local function slot(player)
    local hash = GetPtrHash(player)
    for i = 0, Game():GetNumPlayers() - 1 do
        if GetPtrHash(Isaac.GetPlayer(i)) == hash then return tostring(i) end
    end
end

-- Owning player of an entity, including familiar-fired attacks.
function Common.Owner(entity)
    if not entity then return nil end
    local player = entity:ToPlayer()
    if player then return player end
    local familiar = entity:ToFamiliar()
    if familiar then return familiar.Player end
    local spawner = entity.SpawnerEntity
    if spawner then
        player = spawner:ToPlayer()
        if player then return player end
        familiar = spawner:ToFamiliar()
        if familiar then return familiar.Player end
    end
    return entity.Parent and entity.Parent:ToPlayer() or nil
end

function Common.Hostile(npc)
    return npc ~= nil and npc:Exists() and not npc:IsDead() and npc:IsVulnerableEnemy()
        and not npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)
end

local function enemies()
    local list = {}
    for _, e in ipairs(Isaac.GetRoomEntities()) do
        local npc = e:ToNPC()
        if Common.Hostile(npc) then list[#list + 1] = npc end
    end
    return list
end
Common.Enemies = enemies

-- Up to `max` hostile enemies within `radius`, nearest first, index as tie-break.
function Common.Nearby(position, radius, max, accept)
    local list = {}
    for _, npc in ipairs(enemies()) do
        local d = (npc.Position - position):LengthSquared()
        if d <= radius * radius and (not accept or accept(npc)) then list[#list + 1] = { npc = npc, d = d } end
    end
    table.sort(list, function(a, b)
        if a.d ~= b.d then return a.d < b.d end
        return a.npc.Index < b.npc.Index
    end)
    local out = {}
    for i = 1, math.min(max or #list, #list) do out[i] = list[i].npc end
    return out
end

function Common.NearestEnemy(position, radius, accept)
    return Common.Nearby(position, radius, 1, accept)[1]
end

-- Ordinary hostile bullets only, like Summary Stapler: no special variants or
-- flags, a living non-friendly NPC spawner.
function Common.OrdinaryBullet(entity)
    local bullet = entity:ToProjectile()
    if not bullet or not bullet:Exists() or bullet:IsDead()
        or bullet.Variant ~= 0 or bullet.SubType ~= 0
        or bullet.ProjectileFlags ~= 0 or bullet.ChangeFlags ~= 0 then return nil end
    local owner = bullet.SpawnerEntity and bullet.SpawnerEntity:ToNPC()
    if not owner or owner:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)
        or bullet:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then return nil end
    return bullet
end

function Common.Bullets(position, radius, max)
    local list = {}
    for _, e in ipairs(Isaac.GetRoomEntities()) do
        local b = Common.OrdinaryBullet(e)
        if b then
            local d = (b.Position - position):LengthSquared()
            if d <= radius * radius then list[#list + 1] = { b = b, d = d } end
        end
    end
    table.sort(list, function(x, y)
        if x.d ~= y.d then return x.d < y.d end
        return x.b.Index < y.b.Index
    end)
    local out = {}
    for i = 1, math.min(max or #list, #list) do out[i] = list[i].b end
    return out
end

function Common.Aim(player)
    local direction = player:GetShootingInput()
    if direction:LengthSquared() > 0 then return direction:Normalized() end
    local directions = {
        [Direction.LEFT] = Vector(-1, 0), [Direction.UP] = Vector(0, -1),
        [Direction.RIGHT] = Vector(1, 0), [Direction.DOWN] = Vector(0, 1),
    }
    return directions[player:GetHeadDirection()] or Vector(0, 1)
end

-- Adds charge to the primary active when it is an ordinary, not-full,
-- room-charged item. Timed, zero-charge and special actives never benefit.
function Common.AddCharge(player, amount)
    local slotId = ActiveSlot.SLOT_PRIMARY
    local id = player:GetActiveItem(slotId)
    if not id or id <= 0 then return false end
    local config = Isaac.GetItemConfig():GetCollectible(id)
    if not config or config.MaxCharges <= 0 or config.ChargeType ~= 0 then return false end
    local charge = player:GetActiveCharge(slotId)
    if charge >= config.MaxCharges then return false end
    player:SetActiveCharge(math.min(config.MaxCharges, charge + amount), slotId)
    return true
end

function Common.Caption(title, line)
    Game():GetHUD():ShowItemText(title, line or "")
end

function Common.NoUse()
    return { Discharge = false, Remove = false, ShowAnim = false }
end

function Common.Used()
    return { Discharge = true, Remove = false, ShowAnim = true }
end

function Common.Battery(flags)
    return (flags & UseFlag.USE_CARBATTERY) ~= 0
end

function Common:Init(mod, Risk)
    local listeners = {}
    local stats = { damage = {}, speed = {}, range = {}, shotspeed = {} }
    local leases, volleys, guards, timers, helpers, labels = {}, {}, {}, {}, {}, {}
    local pendingUse, hitThisRoom, lastAttack = {}, {}, {}
    local dealing = false
    local started = false

    function self.On(name, fn)
        listeners[name] = listeners[name] or {}
        table.insert(listeners[name], fn)
    end
    local function emit(name, ...)
        for _, fn in ipairs(listeners[name] or {}) do fn(...) end
    end

    -- Saved per-player table. `floor` is reset whenever the floor changes.
    function self.State(player)
        local key = slot(player)
        if not key then return nil end
        local all = Risk.state.backlog
        if type(all) ~= "table" or all.version ~= VERSION or type(all.players) ~= "table" then
            all = { version = VERSION, players = {}, cleared = {} }
            Risk.state.backlog = all
        end
        local s = all.players[key]
        if type(s) ~= "table" then s = {}; all.players[key] = s end
        local floor = Common.FloorKey()
        if s.floorKey ~= floor or type(s.floor) ~= "table" then
            local previous, old = s.floorKey, s.floor
            s.floorKey, s.floor = floor, {}
            if previous ~= nil and type(old) == "table" then emit("floorChanged", player, s, old) end
        end
        return s
    end

    -- Existing saved table only; never creates state for players without it.
    function self.Peek(player)
        local all, key = Risk.state.backlog, slot(player)
        if type(all) ~= "table" or all.version ~= VERSION or type(all.players) ~= "table"
            or not key or type(all.players[key]) ~= "table" then return nil end
        return self.State(player)
    end

    -- Safe number read from saved state.
    function self.Num(v, default, low, high)
        if type(v) ~= "number" or v ~= v then return default end
        if low and v < low then return default end
        if high and v > high then return default end
        return v
    end

    -- Transient per-player table, room-scoped part cleared on each new room.
    function self.Data(player)
        local data = player:GetData()
        data.ccBacklog = data.ccBacklog or { room = {} }
        return data.ccBacklog
    end

    -- Stat registry: fn(player) returns a multiplier (damage) or an addition.
    function self.Stat(kind, fn) table.insert(stats[kind], fn) end
    function self.Refresh(player)
        player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_SPEED
            | CacheFlag.CACHE_RANGE | CacheFlag.CACHE_SHOTSPEED)
        player:EvaluateItems()
    end
    mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player, flag)
        if flag == CacheFlag.CACHE_DAMAGE then
            local m = 1
            for _, fn in ipairs(stats.damage) do m = m * (fn(player) or 1) end
            if m ~= 1 then player.Damage = player.Damage * m end
        elseif flag == CacheFlag.CACHE_SPEED then
            local add = 0
            for _, fn in ipairs(stats.speed) do add = add + (fn(player) or 0) end
            if add ~= 0 then player.MoveSpeed = player.MoveSpeed + add end
        elseif flag == CacheFlag.CACHE_RANGE then
            local add = 0
            for _, fn in ipairs(stats.range) do add = add + (fn(player) or 0) end
            if add ~= 0 then player.TearRange = player.TearRange + add end
        elseif flag == CacheFlag.CACHE_SHOTSPEED then
            local add = 0
            for _, fn in ipairs(stats.shotspeed) do add = add + (fn(player) or 0) end
            if add ~= 0 then player.ShotSpeed = player.ShotSpeed + add end
        end
    end)

    -- Primed bonuses for the player's next attack.
    function self.Prime(player, key, mult, frames)
        local d = self.Data(player)
        d.primes = d.primes or {}
        d.primes[key] = { mult = mult, expires = frames and (now() + frames) or nil }
    end
    function self.Primed(player, key)
        local d = self.Data(player)
        local p = d.primes and d.primes[key]
        return p ~= nil and (not p.expires or p.expires >= now())
    end
    function self.Unprime(player, key)
        local d = self.Data(player)
        if d.primes then d.primes[key] = nil end
    end

    function self.LastAttack(player) return lastAttack[GetPtrHash(player)] end

    local function attack(player, kind, entity)
        local hash, frame = GetPtrHash(player), now()
        local volley = volleys[hash]
        if not volley or volley.frame ~= frame then
            -- A new attack: resolve and consume primes once for the whole volley.
            local d = self.Data(player)
            local mult = 1
            for key, p in pairs(d.primes or {}) do
                if not p.expires or p.expires >= frame then mult = mult * p.mult end
                d.primes[key] = nil
            end
            volley = { frame = frame, mult = mult, id = tostring(hash) .. ":" .. frame }
            volleys[hash] = volley
            lastAttack[hash] = frame
            emit("attack", player, kind, entity, volley.id)
        end
        leases[GetPtrHash(entity)] = { id = volley.id, mult = volley.mult, kind = kind,
            owner = hash, expires = frame + ATTACK_LEASE }
    end
    self.attack = attack

    local spawning = false
    -- Fire a native tear that is not an attack itself (no primes, no events).
    function self.FireDerived(player, velocity, mult, position)
        spawning = true
        local tear = player:FireTear(position or player.Position, velocity, false, true, false, player, mult)
        spawning = false
        if tear then leases[GetPtrHash(tear)] = { id = "derived", mult = 1, kind = "derived",
            owner = GetPtrHash(player), expires = now() + ATTACK_LEASE } end
        return tear
    end

    mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, function(_, tear)
        if spawning then
            -- FireTear dispatches before returning. Mark here, before the
            -- character callbacks, so helper shots cannot spend their resources.
            tear:GetData().ccThoughtDerived = true
            return
        end
        local player = tear.SpawnerEntity and tear.SpawnerEntity:ToPlayer()
        if player then attack(player, "tear", tear) end
    end)
    mod:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE, function(_, laser)
        if laser.FrameCount ~= 1 then return end
        local player = laser.SpawnerEntity and laser.SpawnerEntity:ToPlayer()
        if player then attack(player, "laser", laser) end
    end)
    mod:AddCallback(ModCallbacks.MC_POST_KNIFE_UPDATE, function(_, knife)
        local data = knife:GetData()
        local flying = knife:IsFlying()
        if flying and not data.ccBacklogFlying then
            local player, spawner = Common.Owner(knife), knife.SpawnerEntity
            if player and not (spawner and spawner:ToFamiliar()) then attack(player, "knife", knife) end
        end
        data.ccBacklogFlying = flying
    end)
    mod:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE, function(_, bomb)
        if bomb.FrameCount ~= 1 or not bomb.IsFetus then return end
        local player = bomb.SpawnerEntity and bomb.SpawnerEntity:ToPlayer()
        if player then attack(player, "bomb", bomb) end
    end)

    -- Target damage modifiers: fn(npc, player, lease) returns a multiplier.
    local modifiers = {}
    function self.TargetModifier(fn) table.insert(modifiers, fn) end

    -- One extra hit that is never an attack, a lease or a modifier input.
    function self.Pulse(npc, player, mult)
        if not Common.Hostile(npc) then return end
        dealing = true
        npc:TakeDamage(player.Damage * mult, 0, EntityRef(player), 0)
        dealing = false
    end

    local function realHit(flags)
        return ((flags or 0) & (DamageFlag.DAMAGE_FAKE | DamageFlag.DAMAGE_NO_PENALTIES)) == 0
    end
    local function enemySource(source)
        local e = source and source.Entity
        if not e then return nil end
        if e.Type == EntityType.ENTITY_PROJECTILE then return e end
        local npc = e:ToNPC()
        if npc and not npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then return e end
    end
    self.EnemySource = enemySource

    -- Guards absorb one ordinary hostile bullet hit each.
    function self.AddGuard(player, key, frames, max)
        local hash = GetPtrHash(player)
        guards[hash] = guards[hash] or {}
        local list = guards[hash]
        local count = 0
        for _, g in ipairs(list) do if g.key == key and g.expires >= now() then count = count + 1 end end
        if count >= (max or 1) then return false end
        list[#list + 1] = { key = key, expires = now() + frames }
        return true
    end
    function self.Guards(player, key)
        local count = 0
        for _, g in ipairs(guards[GetPtrHash(player)] or {}) do
            if (not key or g.key == key) and g.expires >= now() then count = count + 1 end
        end
        return count
    end

    -- Contact blockers cancel a player hit before any hit event is emitted.
    local blockers = {}
    function self.BlockContact(fn) table.insert(blockers, fn) end

    mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, entity, amount, flags, source, countdown)
        if dealing then return nil end
        local player = entity:ToPlayer()
        if player then
            local e = source and source.Entity
            if e then
                for _, fn in ipairs(blockers) do if fn(player, e) then return false end end
            end
            local enemy = enemySource(source)
            local list = guards[GetPtrHash(player)]
            if list and #list > 0 and enemy and realHit(flags) and Common.OrdinaryBullet(enemy) then
                for i, g in ipairs(list) do
                    if g.expires >= now() then
                        table.remove(list, i)
                        enemy:Remove()
                        emit("guarded", player, g.key)
                        return false
                    end
                end
            end
            if realHit(flags) then
                hitThisRoom[GetPtrHash(player)] = true
                if enemy then emit("playerHit", player, enemy, amount) end
            end
            return nil
        end
        local npc = entity:ToNPC()
        if not npc or npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then return nil end
        local src = source and source.Entity
        local owner = Common.Owner(src)
        if not owner then return nil end
        local lease = src and leases[GetPtrHash(src)]
        if lease and lease.expires < now() then leases[GetPtrHash(src)] = nil; lease = nil end
        local kind = lease and lease.kind or (src:ToFamiliar() and "familiar") or (src:ToPlayer() and "contact") or "other"
        local mult = lease and lease.mult or 1
        for _, fn in ipairs(modifiers) do mult = mult * (fn(npc, owner, kind, lease) or 1) end
        emit("hit", npc, owner, kind, lease and lease.id ~= "derived" and lease.id or nil, amount * mult)
        if mult ~= 1 and mult > 0 then
            dealing = true
            npc:TakeDamage(amount * mult, flags, source, countdown)
            dealing = false
            return false
        end
        return nil
    end)

    mod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, function(_, entity)
        local npc = entity:ToNPC()
        if npc then emit("kill", npc) end
    end)

    -- Timers count gameplay updates (paused frames do not run POST_UPDATE).
    function self.After(frames, fn, roomScoped)
        timers[#timers + 1] = { at = now() + frames, fn = fn, room = roomScoped }
    end

    -- Temporary helpers created by backlog items (decoys, wisps), never vanilla familiars.
    function self.AddHelper(player, entity, kind)
        local hash = GetPtrHash(player)
        helpers[hash] = helpers[hash] or {}
        table.insert(helpers[hash], { ref = EntityPtr(entity), kind = kind })
    end
    function self.Helpers(player)
        local out, list = {}, helpers[GetPtrHash(player)] or {}
        for i = #list, 1, -1 do
            local e = list[i].ref.Ref
            if e and e:Exists() then table.insert(out, 1, { entity = e, kind = list[i].kind })
            else table.remove(list, i) end
        end
        return out
    end

    function self.Label(player, key, text)
        labels[GetPtrHash(player)] = labels[GetPtrHash(player)] or {}
        labels[GetPtrHash(player)][key] = text
    end

    function self.HitThisRoom(player) return hitThisRoom[GetPtrHash(player)] == true end

    mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function(_, continued)
        -- Module-local effects must not rely on NEW_ROOM arriving after start.
        -- This is cleanup only: never synthesize a room-entry reward event.
        emit("runReset")
        started = true
        leases, volleys, guards, timers, helpers, labels, pendingUse, hitThisRoom, lastAttack = {}, {}, {}, {}, {}, {}, {}, {}, {}
        for _, p in ipairs(Common.Players()) do p:GetData().ccBacklog = nil end
        emit("started", continued)
        for _, p in ipairs(Common.Players()) do self.Refresh(p) end
    end)
    mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, function()
        started = false
        emit("runReset")
        timers, pendingUse = {}, {}
    end)

    mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
        leases, volleys, hitThisRoom = {}, {}, {}
        for i = #timers, 1, -1 do if timers[i].room then table.remove(timers, i) end end
        for _, p in ipairs(Common.Players()) do
            local d = self.Data(p)
            local hadRoom = next(d.room) ~= nil
            d.room = {}
            labels[GetPtrHash(p)] = nil
            if hadRoom then self.Refresh(p) end
        end
        if not started then return end
        emit("newRoom", Game():GetRoom())
    end)

    -- Settle floor-scoped state for every player as soon as a floor begins.
    mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, function()
        local all = Risk.state.backlog
        if not started or type(all) ~= "table" or type(all.players) ~= "table" then return end
        for _, p in ipairs(Common.Players()) do
            local key = slot(p)
            if key and all.players[key] then self.State(p) end
        end
    end)

    -- Unique clears are only tracked while someone holds an item that uses them.
    local clearItems = {}
    function self.WatchClears(id) clearItems[#clearItems + 1] = id end
    local function anyClearHolder()
        for _, p in ipairs(Common.Players()) do
            for _, id in ipairs(clearItems) do if id > 0 and p:HasCollectible(id) then return true end end
        end
        return false
    end

    mod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, function()
        if not started or not anyClearHolder() then return end
        local all = Risk.state.backlog
        if type(all) ~= "table" or all.version ~= VERSION then
            if #Common.Players() > 0 then self.State(Isaac.GetPlayer(0)) end
            all = Risk.state.backlog
        end
        if type(all.cleared) ~= "table" or all.clearedFloor ~= Common.FloorKey() then
            all.cleared, all.clearedFloor = {}, Common.FloorKey()
        end
        local key = Common.RoomKey()
        if all.cleared[key] then return end
        all.cleared[key] = true
        emit("uniqueClear", function(player) return not hitThisRoom[GetPtrHash(player)] end)
    end)

    mod:AddCallback(ModCallbacks.MC_PRE_USE_ITEM, function(_, id, _, player, flags, slotId)
        if not player or Common.Battery(flags) or (flags & UseFlag.USE_OWNED) == 0 then return nil end
        local config = Isaac.GetItemConfig():GetCollectible(id)
        if not config or config.MaxCharges <= 0 or config.ChargeType ~= 0 then return nil end
        pendingUse[#pendingUse + 1] = { player = player, id = id, slot = slotId,
            charge = player:GetActiveCharge(slotId), item = player:GetActiveItem(slotId), frame = now() }
        return nil
    end)

    mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
        if not started then return end
        local frame = now()
        -- A charged use counts only when the slot actually lost charge.
        for i = #pendingUse, 1, -1 do
            local u = pendingUse[i]
            local after = u.player:GetActiveCharge(u.slot)
            if u.player:GetActiveItem(u.slot) ~= u.item or after < u.charge then
                table.remove(pendingUse, i)
                emit("activeUsed", u.player, u.id, Game():GetRoom():IsClear())
            elseif frame - u.frame > 1 then
                table.remove(pendingUse, i)
            end
        end
        for i = #timers, 1, -1 do
            local t = timers[i]
            if t.at <= frame then table.remove(timers, i); t.fn() end
        end
        emit("update", frame)
    end)

    mod:AddCallback(ModCallbacks.MC_POST_RENDER, function()
        if not started or not Game():GetHUD():IsVisible() then return end
        for _, p in ipairs(Common.Players()) do
            local list = labels[GetPtrHash(p)]
            if list then
                local pos = Isaac.WorldToScreen(p.Position)
                local y = pos.Y + 6
                for _, text in pairs(list) do
                    Isaac.RenderText(text, pos.X - 3 * #text, y, 1, 1, 1, 0.8)
                    y = y + 10
                end
            end
        end
    end)

    return self
end

return Common
