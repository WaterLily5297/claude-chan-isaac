-- Real Summary -> Opus -> backlog -> GPT -> tainted Llama callback order.
-- FireTear callbacks are synchronous stub inputs, not native engine evidence.
-- The separate llama_hype_test.lua owns duration, targeting and save lifecycle.
local root = assert(arg[1])
local Env = dofile(root .. "/tests/lib/backlog_env.lua")
local passed, failures = 0, {}
local function test(name, fn)
    if arg[2] and not name:find(arg[2], 1, true) then return end
    local ok, err = pcall(fn)
    if ok then passed = passed + 1 else failures[#failures + 1] = name .. ": " .. tostring(err) end
end
local function near(a, b) assert(math.abs(a - b) < 1e-8, tostring(a) .. " != " .. tostring(b)) end
local function fresh()
    local env = Env.New(root)
    local nativeInclude = include
    function include(name)
        if name == "scripts.hud_text" then return { Draw = function() end } end
        return nativeInclude(name)
    end
    local nativeGame = Game
    function Game()
        local game, level = nativeGame(), nativeGame():GetLevel()
        function level:GetCurrentRoomDesc() return { SafeGridIndex = env.roomIndex, SpawnSeed = env.roomIndex * 13 } end
        function game:GetLevel() return level end
        return game
    end
    local vector = getmetatable(Vector(0, 0))
    function vector:Distance(other) return (self - other):Length() end
    EntityPartition, ButtonAction = { ENEMY = 8 }, { ACTION_DROP = 11 }
    TearFlags = { TEAR_LUDOVICO = 1 << 10 }
    CollectibleType.COLLECTIBLE_BIRTHRIGHT = 619
    local down = {}
    Input = { IsActionPressed = function(_, controller) return down[controller] or false end }
    function Isaac.GetPlayerTypeByName(name, tainted)
        if name == "Llama-chan" then return tainted and 155 or 55 end
        if name == "GPT-chan" then return tainted and 151 or 51 end
        return -1
    end
    function Isaac.FindInRadius(position, radius)
        local result = {}
        for _, entity in ipairs(env.entities) do
            if entity:ToNPC() and position:Distance(entity.Position) <= radius then result[#result + 1] = entity end
        end
        return result
    end
    local p, q = env.player(0), env.player(20)
    for index, player in ipairs({ p, q }) do
        player.form, player.InitSeed, player.ControllerIndex = index == 1 and 155 or 51, index * 10, index - 1
        player.coins, player.nativeShots = 5, {}
        function player:GetPlayerType() return self.form end
        function player:GetCard() return 0 end
        function player:GetPill() return 0 end
        function player:AreControlsEnabled() return true end
        function player:GetNumCoins() return self.coins end
        function player:AddCoins(n) self.coins = self.coins + n end
        function player:FireTear(position, velocity, canBeEye, noTractorBeam, canTriggerStreakEnd, source, mult)
            self.nativeShots[#self.nativeShots + 1] = {
                position = position, velocity = velocity, canBeEye = canBeEye, noTractorBeam = noTractorBeam,
                canTriggerStreakEnd = canTriggerStreakEnd, source = source, mult = mult,
            }
            local tear = env.tear(self)
            tear.Position, tear.Velocity, tear.mult, tear.CollisionDamage = position, velocity, mult, self.Damage * mult
            self.fired[#self.fired + 1] = tear
            env.fire("MC_POST_FIRE_TEAR", nil, tear)
            return tear
        end
    end
    include("scripts.items.summary_stapler"):Init(env.mod)
    include("scripts.items.opus_mode"):Init(env.mod)
    env.load()
    include("scripts.characters.gpt_downgrade"):Init(env.mod, env.Risk)
    include("scripts.characters.llama_hype"):Init(env.mod, env.Risk, env.C)
    env.fire("MC_POST_GAME_STARTED", nil, false)
    env.give(p, "OPUS_MODE"); env.give(q, "OPUS_MODE")
    function env.tap(player)
        down[player.ControllerIndex] = false; env.update()
        down[player.ControllerIndex] = true; env.update()
        down[player.ControllerIndex] = false; env.update()
    end
    function env.startHelper()
        env.Risk.state.llamaHype["0"].hype = 3
        env.tap(p)
        assert(env.Risk.state.llamaHype["0"].hype == 0, "DROP spends the helper's Hype")
    end
    return env, p, q
end
local function balance(player, count, coins)
    assert((player:GetData().ccOpusTears or 0) == count, "unexpected Opus attack count")
    assert(player.coins == coins, "unexpected wallet charge")
end
local function primary(env, player, ...)
    env.frame = env.frame + 1
    return env.shoot(player, ...)
end
local function nextHelper(env, player)
    local start = #player.fired
    for _ = 1, 31 do
        env.update()
        for i = start + 1, #player.fired do
            if player.fired[i]:GetData().ccLlamaHelper then return player.fired[i] end
        end
    end
    error("expected a scheduled Llama helper tear")
end

test("helper retains wallet and prime; next ordinary attack still pays", function()
    local env, p = fresh()
    env.npc(80)
    env.startHelper()
    p:GetData().ccOpusTears = 9
    env.C.Prime(p, "held", 2)
    local tear = nextHelper(env, p)
    balance(p, 9, 5)
    assert(tear:GetData().ccThoughtDerived and env.C.Primed(p, "held"), "helper must retain the next-attack prime")
    local ordinary = primary(env, p)
    balance(p, 0, 4)
    assert(not ordinary:GetData().ccThoughtDerived and not env.C.Primed(p, "held"), "next ordinary shot consumes its prime")
end)

test("helper does not complete Finger's fifth attack; next primary does", function()
    local env, p = fresh()
    env.npc(80)
    env.give(p, "ONE_MORE_FINGER")
    for _ = 1, 4 do primary(env, p) end
    assert(env.C.Data(p).fingers == 4)
    env.startHelper()
    nextHelper(env, p)
    assert(env.C.Data(p).fingers == 4, "Llama helper must not advance One More Finger")
    env.update()
    assert(#p.fired == 1, "helper must not schedule a Finger extra")
    primary(env, p); env.update()
    assert(env.C.Data(p).fingers == 0 and #p.fired == 2, "fifth primary still schedules exactly one extra")
    local finger = p.fired[2]
    assert(finger.mult == 0.3 and finger:GetData().ccThoughtDerived and not finger:GetData().ccLlamaHelper)
    balance(p, 5, 5)
end)

test("three helper hits do not complete Sanity; three primary attacks do", function()
    local env, p = fresh()
    local target, hits = env.npc(80, { hp = 1000 }), {}
    env.startHelper()
    assert(env.use(env.Item.SANITY_TEST, p).Discharge)
    env.C.On("hit", function(_, owner, kind, attackId)
        if owner == p then hits[#hits + 1] = { kind = kind, attackId = attackId } end
    end)
    for _ = 1, 3 do
        local helper = nextHelper(env, p)
        target:TakeDamage(helper.CollisionDamage, 0, EntityRef(helper))
        assert(env.C.Data(p).room.sanity.count == 0, "helper hit must not advance Sanity Test")
        local hit = hits[#hits]
        assert(hit.kind == "derived" and hit.attackId == nil, "helper must have no paid-attack identity")
    end
    env.update()
    assert(#target.damage == 3, "three helper hits must not add a Sanity pulse")
    for _ = 1, 3 do primary(env, p, target) end
    assert(env.C.Data(p).room.sanity == nil, "three distinct ordinary attacks still complete Sanity")
    env.update()
    assert(#target.damage == 7, "three helper hits, three primary hits, one pulse")
    near(target.damage[7], p.Damage * 3)
end)

test("helper keeps stationary origin, native arguments and 0.45x damage", function()
    local env, p = fresh()
    p.Position, p.ShotSpeed = Vector(10, 20), 1.5
    local target = env.npc(70, { y = 100, hp = 1000 })
    env.startHelper()
    p.Position = Vector(300, 300)
    env.C.Prime(p, "held", 2)
    local helper = nextHelper(env, p)
    local call = p.nativeShots[1]
    near(call.position.X, 10); near(call.position.Y, 20)
    near(call.velocity.X, 9); near(call.velocity.Y, 12)
    assert(call.canBeEye == false and call.noTractorBeam == true and call.canTriggerStreakEnd == false)
    assert(call.source == p and call.mult == 0.45 and helper.SpawnerEntity == p)
    assert(helper.Position == call.position and helper.Velocity == call.velocity and helper.Type == EntityType.ENTITY_TEAR)
    near(helper.CollisionDamage, p.Damage * 0.45)
    target:TakeDamage(helper.CollisionDamage, 0, EntityRef(helper))
    assert(#target.damage == 1, "helper damage is applied exactly once")
    near(target.damage[1], p.Damage * 0.45)
    assert(helper:GetData().ccLlamaHelper and helper:GetData().ccThoughtDerived and env.C.Primed(p, "held"))
end)

test("foreign primary remains paid while helper and target credit stay owner-scoped", function()
    local env, p, q = fresh()
    local target = env.npc(80, { hp = 1000 })
    env.Risk.state.gptRouting["1"].verified = false
    env.tap(q)
    assert(env.use(env.Item.SANITY_TEST, p).Discharge and env.use(env.Item.SANITY_TEST, q).Discharge)
    p:GetData().ccOpusTears, q:GetData().ccOpusTears = 9, 9
    env.C.Prime(p, "held", 2); env.C.Prime(q, "held", 2)
    env.startHelper()
    local nativeFire, foreignShot = p.FireTear
    function p:FireTear(...)
        foreignShot = env.shoot(q)
        return nativeFire(self, ...)
    end
    local helper = nextHelper(env, p)
    p.FireTear = nativeFire
    balance(p, 9, 5); balance(q, 0, 4)
    assert(not foreignShot:GetData().ccThoughtDerived and not env.C.Primed(q, "held"))
    assert(env.C.Primed(p, "held"), "only the helper owner's prime remains")
    target:TakeDamage(helper.CollisionDamage, 0, EntityRef(helper))
    assert(env.C.Data(p).room.sanity.count == 0 and env.C.Data(q).room.sanity.count == 0)
    assert(not env.Risk.state.gptRouting["1"].verified, "Llama helper cannot verify the GPT partner's target check")
    target:TakeDamage(q.Damage, 0, EntityRef(foreignShot))
    assert(env.C.Data(q).room.sanity.count == 1 and env.C.Data(p).room.sanity.count == 0)
    primary(env, q, target); primary(env, q, target)
    assert(env.Risk.state.gptRouting["1"].verified and env.C.Data(q).room.sanity == nil,
        "GPT's own distinct attacks still complete its character and item checks")
    assert(env.C.Primed(p, "held") and env.C.Data(p).room.sanity.count == 0)
end)

test("nil native tear does not break the helper's next scheduled shot", function()
    local env, p = fresh()
    env.npc(80)
    env.startHelper()
    p:GetData().ccOpusTears = 9
    env.C.Prime(p, "held", 2)
    local nativeFire, attempts = p.FireTear, 0
    function p:FireTear() attempts = attempts + 1; return nil end
    env.update(30)
    assert(attempts == 1 and #p.fired == 0, "a nil native tear must not be indexed or fabricated")
    p.FireTear = nativeFire
    local helper = nextHelper(env, p)
    balance(p, 9, 5)
    assert(helper:GetData().ccThoughtDerived and env.C.Primed(p, "held"), "later scheduled helper remains free")
    primary(env, p)
    balance(p, 0, 4)
    assert(not env.C.Primed(p, "held"), "ordinary attacks are not left exempt")
end)

test("helper Ludovico windows stay free while an ordinary held tear pays", function()
    local env, p = fresh()
    env.npc(80)
    env.startHelper()
    p:GetData().ccOpusTears = 9
    local helper = nextHelper(env, p)
    function helper:HasTearFlags(flag) return flag == TearFlags.TEAR_LUDOVICO end
    for age = 6, 18, 6 do
        env.frame, helper.FrameCount = env.frame + 6, age
        env.fire("MC_POST_TEAR_UPDATE", nil, helper)
    end
    balance(p, 9, 5)
    local ordinary = primary(env, p)
    balance(p, 0, 4)
    function ordinary:HasTearFlags(flag) return flag == TearFlags.TEAR_LUDOVICO end
    for age = 6, 12, 6 do
        env.frame, ordinary.FrameCount = env.frame + 6, age
        env.fire("MC_POST_TEAR_UPDATE", nil, ordinary)
    end
    balance(p, 2, 4)
end)

for _, failure in ipairs(failures) do print("FAIL " .. failure) end
assert(#failures == 0, tostring(#failures) .. " Llama helper groups failed")
print("PASS Llama helper billing: " .. passed .. " callback groups")
