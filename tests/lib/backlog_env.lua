-- Offline engine stub for the fifty-row backlog suites. It models callback
-- inputs, entities and saved state; it does not emulate native AI, physics,
-- status effects or rendering.
local Env = {}

function Env.New(root)
    local env = { frame = 0, entities = {}, players = {}, callbacks = {}, captions = {}, spawned = {} }
    function include(name) return dofile(root .. "/" .. name:gsub("%.", "/") .. ".lua") end

    local ids, nextId = {}, 700
    Isaac = {}
    function Isaac.GetItemIdByName(n) if not ids[n] then ids[n] = nextId; nextId = nextId + 1 end return ids[n] end
    function Isaac.GetTrinketIdByName() return 190 end
    function Isaac.GetPillEffectByName() return 50 end
    function Isaac.GetPlayerTypeByName() return 41 end
    env.id = Isaac.GetItemIdByName

    ModCallbacks = setmetatable({}, { __index = function(_, k) return k end })
    CacheFlag = { CACHE_DAMAGE = 1, CACHE_FIREDELAY = 2, CACHE_SHOTSPEED = 4, CACHE_RANGE = 8, CACHE_SPEED = 16 }
    DamageFlag = { DAMAGE_FAKE = 1 << 21, DAMAGE_NO_PENALTIES = 1 << 28 }
    EntityFlag = { FLAG_FRIENDLY = 1 }
    EntityType = { ENTITY_PLAYER = 1, ENTITY_TEAR = 2, ENTITY_FAMILIAR = 3, ENTITY_PROJECTILE = 9, ENTITY_EFFECT = 1000 }
    UseFlag = { USE_CARBATTERY = 1 << 5, USE_OWNED = 1 << 11 }
    ActiveSlot = { SLOT_PRIMARY = 0 }
    Direction = { LEFT = 0, UP = 1, RIGHT = 2, DOWN = 3 }
    EffectVariant = { POOF01 = 15, TARGET = 30 }
    FamiliarVariant = { BLUE_FLY = 43 }
    PickupVariant = { PICKUP_HEART = 10 }
    HeartSubType = { HEART_FULL = 1, HEART_HALF = 2, HEART_SOUL = 3, HEART_DOUBLEPACK = 5, HEART_SCARED = 9 }
    TearVariant = { BLUE = 0, BLOOD = 1 }
    CollectibleType = {}

    local V = {}
    V.__index = V
    Vector = setmetatable({}, { __call = function(_, x, y) return setmetatable({ X = x, Y = y }, V) end })
    V.__add = function(a, b) return Vector(a.X + b.X, a.Y + b.Y) end
    V.__sub = function(a, b) return Vector(a.X - b.X, a.Y - b.Y) end
    V.__mul = function(a, b) if type(a) == "number" then a, b = b, a end return Vector(a.X * b, a.Y * b) end
    V.__eq = function(a, b) return a.X == b.X and a.Y == b.Y end
    function V:LengthSquared() return self.X * self.X + self.Y * self.Y end
    function V:Length() return math.sqrt(self:LengthSquared()) end
    function V:Normalized() local l = self:Length(); return l == 0 and Vector(0, 0) or Vector(self.X / l, self.Y / l) end
    function V:Resized(n) return self:Normalized() * n end
    Vector.Zero = Vector(0, 0)
    function Color(...) return { ... } end
    function EntityRef(e) return { Entity = e } end
    function EntityPtr(e) return { Ref = e } end
    function GetPtrHash(e) return e and e.hash end

    local hash = 0
    local function newHash() hash = hash + 1; return hash end

    env.floor, env.stage, env.roomIndex, env.clear, env.firstVisit = 1, 1, 10, false, true
    env.lineBlockedAt = nil
    function Game() return {
        GetFrameCount = function() return env.frame end,
        GetNumPlayers = function() return #env.players end,
        IsPaused = function() return false end,
        GetLevel = function() return {
            GetDungeonPlacementSeed = function() return env.floor end,
            GetStage = function() return env.stage end, GetStageType = function() return 0 end,
            GetCurrentRoomDesc = function() return { SafeGridIndex = env.roomIndex } end,
        } end,
        GetRoom = function() return {
            IsClear = function() return env.clear end,
            IsFirstVisit = function() return env.firstVisit end,
            CheckLine = function(_, a, b)
                if env.lineBlockedAt and (b - a):Length() > env.lineBlockedAt then return false, b end
                return true, b
            end,
            FindFreePickupSpawnPosition = function(_, pos) return pos end,
            GetTopLeftPos = function() return Vector(0, 0) end,
            GetBottomRightPos = function() return Vector(600, 400) end,
        } end,
        GetHUD = function() return {
            IsVisible = function() return true end,
            ShowItemText = function(_, a, b) env.captions[#env.captions + 1] = a end,
        } end,
    } end
    function Isaac.GetPlayer(i) return env.players[i + 1] end
    function Isaac.GetRoomEntities() return env.entities end
    function Isaac.FindByType(t, v)
        local out = {}
        for _, e in ipairs(env.entities) do
            if e.Type == t and (v == nil or v == -1 or e.Variant == v) then out[#out + 1] = e end
        end
        return out
    end
    function Isaac.WorldToScreen(p) return p end
    function Isaac.RenderText() end
    env.config = {}
    function Isaac.GetItemConfig() return { GetCollectible = function(_, id) return env.config[id] end } end

    local function base(kind)
        local e = { hash = newHash(), Index = hash, Position = Vector(0, 0), Velocity = Vector(0, 0),
            Size = 10, FrameCount = 0, data = {}, flags = 0, alive = true, kind = kind }
        function e:GetData() return self.data end
        function e:Exists() return self.alive end
        function e:IsDead() return not self.alive end
        function e:Remove() self.alive = false end
        function e:HasEntityFlags(f) return (self.flags & f) ~= 0 end
        function e:ToPlayer() return self.kind == "player" and self or nil end
        function e:ToNPC() return self.kind == "npc" and self or nil end
        function e:ToFamiliar() return self.kind == "familiar" and self or nil end
        function e:ToTear() return self.kind == "tear" and self or nil end
        function e:ToProjectile() return self.kind == "projectile" and self or nil end
        function e:SetColor() end
        return e
    end

    function env.player(x)
        local p = base("player")
        p.Type, p.Position = EntityType.ENTITY_PLAYER, Vector(x or 0, 0)
        p.Damage, p.MoveSpeed, p.TearRange, p.ShotSpeed = 3.5, 1, 260, 1
        p.items, p.charge, p.active, p.hearts, p.canHeal, p.flies, p.fired, p.aim = {}, {}, {}, 2, true, 0, {}, Vector(1, 0)
        function p:HasCollectible(id) return (self.items[id] or 0) > 0 end
        function p:GetCollectibleNum(id) return self.items[id] or 0 end
        function p:GetActiveItem(s) return self.active[s or 0] or 0 end
        function p:GetActiveCharge(s) return self.charge[s or 0] or 0 end
        function p:SetActiveCharge(c, s) self.charge[s or 0] = c end
        function p:GetHearts() return self.hearts end
        function p:CanPickRedHearts() return self.canHeal end
        function p:AddBlueFlies(n) self.flies = self.flies + n end
        function p:GetShootingInput() return self.aim end
        function p:GetHeadDirection() return Direction.DOWN end
        function p:GetPlayerType() return 0 end
        function p:AddCacheFlags() end
        function p:EvaluateItems()
            self.Damage, self.MoveSpeed, self.TearRange, self.ShotSpeed = 3.5, 1, 260, 1
            for _, f in pairs(CacheFlag) do env.fire("MC_EVALUATE_CACHE", nil, self, f) end
        end
        function p:FireTear(pos, vel, _, _, _, _, mult)
            local t = env.tear(self); t.Position, t.Velocity, t.mult = pos, vel, mult
            self.fired[#self.fired + 1] = t
            -- Assume the engine reports Lua-fired tears too; derived tears must not recurse.
            env.fire("MC_POST_FIRE_TEAR", nil, t)
            return t
        end
        env.players[#env.players + 1] = p
        return p
    end

    function env.npc(x, opts)
        opts = opts or {}
        local n = base("npc")
        n.Type, n.Position, n.HitPoints, n.boss = 10, Vector(x or 0, opts.y or 0), opts.hp or 100, opts.boss
        n.damage, n.slowed, n.frozen = {}, nil, nil
        if opts.friendly then n.flags = EntityFlag.FLAG_FRIENDLY end
        function n:IsVulnerableEnemy() return not opts.invulnerable end
        function n:IsBoss() return self.boss or false end
        function n:AddSlowing(_, frames) self.slowed = frames end
        function n:AddFreeze(_, frames) self.frozen = frames end
        function n:TakeDamage(amount, flags, source)
            -- Route through the real callbacks, like the engine.
            local r = env.fire("MC_ENTITY_TAKE_DMG", self.Type, self, amount, flags or 0, source, 0)
            if r ~= false then self.damage[#self.damage + 1] = amount; self.HitPoints = self.HitPoints - amount end
        end
        env.entities[#env.entities + 1] = n
        return n
    end

    function env.tear(owner)
        local t = base("tear")
        t.Type, t.Variant, t.SpawnerEntity, t.Scale = EntityType.ENTITY_TEAR, TearVariant.BLUE, owner, 1
        t.Position = owner and owner.Position or Vector(0, 0)
        env.entities[#env.entities + 1] = t
        return t
    end

    function env.bullet(x, y, spawner)
        local b = base("projectile")
        b.Type, b.Variant, b.SubType, b.ProjectileFlags, b.ChangeFlags = EntityType.ENTITY_PROJECTILE, 0, 0, 0, 0
        b.Position, b.Velocity, b.SpawnerEntity = Vector(x, y or 0), Vector(1, 0), spawner
        env.entities[#env.entities + 1] = b
        return b
    end

    function env.familiar(owner)
        local f = base("familiar")
        f.Type, f.Variant, f.Player = EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_FLY, owner
        env.entities[#env.entities + 1] = f
        return f
    end

    function Isaac.Spawn(t, v, s, pos, vel, spawner)
        local e = base("effect")
        e.Type, e.Variant, e.Position, e.SpawnerEntity = t, v, pos, spawner
        env.entities[#env.entities + 1] = e
        env.spawned[#env.spawned + 1] = e
        return e
    end

    env.mod = { AddCallback = function(_, id, fn, filter)
        env.callbacks[#env.callbacks + 1] = { id = id, fn = fn, filter = filter }
    end }
    function env.fire(id, filter, ...)
        local result
        for _, cb in ipairs(env.callbacks) do
            if cb.id == id and (cb.filter == nil or filter == nil or cb.filter == filter) then
                local r = cb.fn(env.mod, ...)
                if r ~= nil then result = r; if id == "MC_ENTITY_TAKE_DMG" then return r end end
            end
        end
        return result
    end

    env.Risk = { state = {}, suspended = false }
    function env.Risk:IsSuspended() return self.suspended end
    env.Meal = { eating = {} }
    function env.Meal:Start(p, frames)
        -- Like scripts/meal_break.lua: a running meal is extended, never refused.
        if p:IsDead() then return false end
        self.eating[p] = math.max(self.eating[p] or 0, env.frame + frames); return true
    end
    function env.Meal:Remaining(p) return math.max(0, (self.eating[p] or 0) - env.frame) end

    function env.load()
        local C = include("scripts.items.backlog.common")
        C:Init(env.mod, env.Risk)
        for _, family in ipairs({ "claude", "deepseek", "gpt", "gemini", "grok", "qwen", "llama",
                "mistral", "doubao", "kimi", "glm", "shared" }) do
            include("scripts.items.backlog." .. family):Init(env.mod, env.Risk, C, env.Meal)
        end
        env.C = C
        env.Item = include("scripts.constants").Item
        env.fire("MC_POST_GAME_STARTED", nil, false)
        return C
    end

    function env.update(n)
        for _ = 1, n or 1 do env.frame = env.frame + 1; env.fire("MC_POST_UPDATE") end
    end
    function env.newRoom(opts)
        opts = opts or {}
        env.roomIndex = opts.index or (env.roomIndex + 1)
        env.clear, env.firstVisit = opts.clear or false, opts.first ~= false
        env.entities = opts.keep and env.entities or {}
        for _, p in ipairs(env.players) do env.entities[#env.entities + 1] = p end
        env.fire("MC_POST_NEW_ROOM")
    end
    function env.newFloor()
        env.floor, env.stage = env.floor + 1, env.stage + 1
        env.fire("MC_POST_NEW_LEVEL")
        env.newRoom()
    end
    function env.clearRoom()
        env.clear = true
        env.fire("MC_PRE_SPAWN_CLEAN_AWARD")
    end
    -- An attack: a player tear volley, then optionally hits on targets.
    function env.shoot(player, ...)
        local t = env.tear(player)
        env.fire("MC_POST_FIRE_TEAR", nil, t)
        for _, npc in ipairs({ ... }) do npc:TakeDamage(player.Damage, 0, EntityRef(t)) end
        return t
    end
    function env.use(id, player, flags)
        return env.fire("MC_USE_ITEM", id, id, { RandomInt = function() return 0 end }, player, flags or UseFlag.USE_OWNED, 0)
    end
    -- A charged active use, confirmed by the next update.
    function env.chargedUse(player, id)
        env.config[id] = env.config[id] or { MaxCharges = 4, ChargeType = 0 }
        player.active[0], player.charge[0] = id, 4
        env.fire("MC_PRE_USE_ITEM", nil, id, nil, player, UseFlag.USE_OWNED, 0)
        player.charge[0] = 0
        env.update()
    end
    function env.hitPlayer(player, source, flags)
        return env.fire("MC_ENTITY_TAKE_DMG", EntityType.ENTITY_PLAYER, player, 1, flags or 0, EntityRef(source), 0)
    end
    function env.kill(npc)
        npc.alive = false
        env.fire("MC_POST_ENTITY_KILL", nil, npc)
    end
    function env.give(player, key) player.items[env.Item[key]] = (player.items[env.Item[key]] or 0) + 1; player:EvaluateItems() end
    return env
end

return Env
