-- Real backlog modules across exit/start without reloading their Lua closures.
-- Retained entity-shaped objects intentionally stress pointer reuse; this is
-- not evidence of native entity serialization or actual engine callback order.
local root, selected = arg[1], arg[2] or "all"
local Env=dofile(root.."/tests/lib/backlog_env.lua")
local function near(a,b,label) assert(math.abs(a-b)<1e-6,label..": expected "..b..", got "..a) end
local function fresh(...)
    local env=Env.New(root)
    local p=env.player(300)
    env.load(); env.newRoom(); env.frame=1000
    for _,key in ipairs({...}) do env.give(p,key) end
    return env,p
end
local function restart(env,continued,exit)
    if exit then env.fire("MC_PRE_GAME_EXIT",nil,true) end
    env.frame=0
    -- Initial room before GAME_STARTED must not be relied on for run cleanup.
    env.fire("MC_POST_NEW_ROOM")
    env.Risk.state.sentinel={preserve=42}
    env.fire("MC_POST_GAME_STARTED",nil,continued)
    assert(env.Risk.state.sentinel.preserve==42,"run cleanup must not wipe persistent state")
end
local function run(name,fn)
    if selected=="all" or selected==name then fn(); print("PASS backlog lifecycle: "..name) end
end
run("kitten",function()
    for _,continued in ipairs({false,true}) do
        local env,p=fresh()
        local shooter=env.npc(350)
        env.use(env.Item.LARGE_KITTEN,p)
        local old=env.bullet(310,0,shooter)
        env.update(15); near(old.Velocity:Length(),6,"positive kitten control")
        restart(env,continued,true)
        local bullet=env.bullet(310,0,shooter)
        env.update(15)
        near(bullet.Velocity:Length(),1,"old kitten must not repel bullets after restart")
        env.use(env.Item.LARGE_KITTEN,p); env.update(15)
        near(bullet.Velocity:Length(),6,"kitten can be used again in the new run")
    end
end)
run("decoys",function()
    for _,exit in ipairs({false,true}) do
        local env,p=fresh()
        local fly=env.familiar(p)
        env.use(env.Item.UNCHANGED_PREVIEW,p)
        local first,second=env.spawned[1],env.spawned[2]
        assert(first:Exists() and second:Exists())
        if exit then
            env.fire("MC_PRE_GAME_EXIT",nil,true)
            assert(not first:Exists() and not second:Exists(),"owned decoys must be removed on exit")
        else
            env.fire("MC_POST_GAME_STARTED",nil,false)
            assert(not first:Exists() and not second:Exists(),"start must clear old decoys even without an exit event")
        end
        assert(fly:Exists(),"native familiars must remain untouched")
    end
end)
run("paint",function()
    local env,p=fresh()
    local target=env.npc(310)
    env.use(env.Item.NANO_BANANA,p); env.kill(target)
    local control=env.npc(320)
    env.update(10); assert(control.slowed,"positive peel control")
    restart(env,true,true)
    local nextTarget=env.npc(315)
    env.update(10)
    assert(not nextTarget.slowed,"old peel must not slow enemies after continue")
end)
run("stamp",function()
    local env,p=fresh()
    local target=env.npc(310)
    env.use(env.Item.RED_STAMP,p)
    assert(env.hitPlayer(p,target)==false,"positive stamp control")
    restart(env,false,true)
    assert(env.hitPlayer(p,target)==nil,"old stamp must not block contact after restart")
end)
run("notes",function()
    local env,p=fresh("COMMUNITY_NOTE")
    local target=env.npc(310)
    for _=1,3 do env.shoot(p,target); env.update() end
    env.shoot(p,target); near(target.damage[#target.damage],4.025,"positive exposure control")
    restart(env,true,true)
    env.shoot(p,target)
    near(target.damage[#target.damage],3.5,"old exposure must not survive continue")
end)
run("bowl",function()
    local env,p=fresh("ONE_BOWL")
    local pickup={Variant=PickupVariant.PICKUP_HEART,SubType=HeartSubType.HEART_FULL}
    env.fire("MC_PRE_PICKUP_COLLISION",nil,pickup,p)
    p.hearts=p.hearts+2
    restart(env,false,true)
    env.update()
    assert(env.C.Guards(p,"bowl")==0,"old pending heart must not grant a guard in a new run")
end)
run("consensus",function()
    local env,p=fresh("CONSENSUS_COIN")
    local target=env.npc(310)
    env.shoot(p,target); env.update()
    restart(env,true,true)
    local fly=env.familiar(p)
    target:TakeDamage(2,0,EntityRef(fly)); env.update()
    assert(#target.damage==2,"old source history must not complete a new run's consensus pulse")
end)
run("no-entry-reward",function()
    local env,p=fresh()
    local entries=0
    env.C.On("newRoom",function() entries=entries+1 end)
    env.fire("MC_PRE_GAME_EXIT",nil,false)
    env.fire("MC_POST_GAME_STARTED",nil,false)
    env.fire("MC_POST_GAME_STARTED",nil,true)
    assert(entries==0,"cleanup must not synthesize new-room rewards")
    env.newRoom(); assert(entries==1,"real room entry still dispatches once")
end)
