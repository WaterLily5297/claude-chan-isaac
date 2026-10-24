-- Timing/identity contract for passive DROP observation, not native input replay.
local root = arg[1]
local DropTap = dofile(root .. '/scripts/characters/drop_tap.lua')
local frame, paused, pressed = 0, false, {}
ButtonAction = {ACTION_DROP=17}
Input = {IsActionPressed=function(action, controller)
    assert(action == 17)
    return pressed[controller] == true
end}
function Game() return {
    GetFrameCount=function() return frame end, IsPaused=function() return paused end,
} end
function GetPtrHash(p) return p.pointer end
local function player(pointer, controller)
    return {pointer=pointer, InitSeed=pointer*100, kind=51, ControllerIndex=controller,
        dead=false, controls=true, ghost=false,
        IsDead=function(p) return p.dead end,
        IsCoopGhost=function(p) return p.ghost end,
        AreControlsEnabled=function(p) return p.controls end,
        GetPlayerType=function(p) return p.kind end}
end
local p, q = player(1, 0), player(2, 3)
local tracker = DropTap.New()
local function poll(person, at, down, enabled)
    frame=at; pressed[person.ControllerIndex]=down
    return tracker:Poll(person, enabled ~= false)
end
assert(not poll(p, 0, false))
assert(not poll(p, 1, true), 'press must not switch')
assert(poll(p, 2, false), 'one-frame tap switches on release')
assert(not poll(p, 2, false), 'duplicate wrapper/callback must not switch twice')
assert(not poll(p, 3, false), 'idle release cannot repeat')
assert(not poll(p, 4, true))
assert(poll(p, 16, false), 'twelve-frame tap is accepted')
assert(not poll(p, 17, true))
assert(not poll(p, 30, false), 'thirteen-frame hold must not switch')
assert(not poll(p, 31, true))
for n=32,100 do assert(not poll(p,n,true), 'held DROP must never switch') end
assert(not poll(p,101,false), 'release after native hold must not switch')

-- A fresh tracker, reset or new player cannot inherit a button already held.
tracker:Reset()
assert(not poll(p,102,true)); assert(not poll(p,103,false))
assert(not poll(p,104,true)); assert(poll(p,105,false))
assert(not poll(p,106,true)); tracker:Reset(); assert(not poll(p,107,false))

-- Distinct callback wrappers still refer to the same gesture and actor.
local wrapper=setmetatable({}, {__index=p,__newindex=p})
assert(not poll(p,108,true)); assert(poll(wrapper,109,false))
assert(not poll(p,109,false))
assert(not poll(q,109,false)); assert(not poll(p,110,true))
assert(not poll(q,110,false)); assert(not poll(q,111,true))
assert(poll(wrapper,111,false)); assert(poll(q,112,false))

-- A co-op ghost holding DROP never triggers its form's ability.
tracker:Reset(); p.ghost=true
for n=150,160 do assert(not poll(p,n,n%2==0), 'co-op ghost must not tap') end
p.ghost=false

-- Loss of control, death, co-op ghost, pause, unsupported type and controller swaps cancel.
for _, reason in ipairs({'controls','dead','ghost','pause','unsupported','controller','seed','kind'}) do
    tracker:Reset(); p.controls=true; p.dead=false; paused=false
    poll(p,200,false); poll(p,201,true)
    if reason=='controls' then p.controls=false
    elseif reason=='dead' then p.dead=true
    elseif reason=='ghost' then p.ghost=true
    elseif reason=='pause' then paused=true
    elseif reason=='controller' then p.ControllerIndex=p.ControllerIndex+1
    elseif reason=='seed' then p.InitSeed=p.InitSeed+1
    elseif reason=='kind' then p.kind=p.kind+1 end
    assert(not poll(p,202,true,reason~='unsupported'))
    p.controls=true; p.dead=false; p.ghost=false; paused=false
    assert(not poll(p,203,false), reason..' leaked a release')
    assert(not poll(p,204,true)); assert(poll(p,205,false), reason..' never rearmed')
end
tracker:Reset(); poll(p,300,false); poll(p,301,true)
assert(not poll(p,10,false), 'frame rollback must not complete an old tap')
poll(p,11,true); tracker:Forget(p); assert(not poll(p,12,false))
print('OK: DROP release timing, hold suppression, wrapper/controller isolation and interruption cancellation')
