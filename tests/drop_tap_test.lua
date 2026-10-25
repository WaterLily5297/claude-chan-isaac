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
        dead=false, controls=true, ghost=false, cards={}, pills={}, actives={},
        GetCard=function(p, slot) return p.cards[slot] or 0 end,
        GetPill=function(p, slot) return p.pills[slot] or 0 end,
        GetActiveItem=function(p, slot) return p.actives[slot] or 0 end,
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

-- The owner chose to reserve a multi-pocket gesture for native cycling.
local function inventory(cards, pills, actives)
    p.cards, p.pills, p.actives = cards or {}, pills or {}, actives or {}
end
local function gesture(expected, message)
    tracker:Reset(); poll(p,400,false); poll(p,401,true)
    assert(poll(p,402,false)==expected, message)
end
inventory({[0]=1}, {}, {[2]=10})
gesture(false, 'a card plus pocket active must not spend an ability')
inventory({}, {[3]=1}, {[3]=11})
gesture(false, 'a pill plus temporary pocket active must not spend an ability')
inventory({}, {}, {[2]=10,[3]=11})
gesture(false, 'two pocket actives must not spend an ability')
for a=0,3 do
    for b=0,3 do
        if a~=b then
            inventory({[a]=1,[b]=2}); gesture(false, 'two cards in any slots')
            inventory({}, {[a]=1,[b]=2}); gesture(false, 'two pills in any slots')
            inventory({[a]=1}, {[b]=2}); gesture(false, 'card and pill in any slots')
        end
    end
    inventory({[a]=1}); gesture(true, 'one card remains usable')
    inventory({}, {[a]=1}); gesture(true, 'one pill remains usable')
end
for slot=2,3 do
    inventory({}, {}, {[slot]=10}); gesture(true, 'one pocket active remains usable')
end
inventory({}, {}, {[0]=10,[1]=11}); gesture(true, 'main/Schoolbag slots are not pocket contents')
inventory(); gesture(true, 'empty pockets remain usable')

-- Seeing a second item at any sampled point cancels the whole gesture,
-- including a second poll in the same frame. Dropping/using it cannot rearm
-- the held button; a new released-then-pressed gesture is required.
for _, stage in ipairs({'press','held','release','same-frame'}) do
    inventory({[0]=1}); tracker:Reset(); poll(p,500,false)
    if stage=='press' then p.actives[2]=10 end
    assert(not poll(p,501,true))
    if stage=='held' or stage=='same-frame' then p.actives[2]=10 end
    assert(not poll(p,stage=='same-frame' and 501 or 502,true))
    if stage=='release' then p.actives[2]=10 else p.actives[2]=nil end
    assert(not poll(p,503,false), stage..' pocket conflict leaked an ability')
    p.actives[2]=nil
    assert(not poll(p,504,true)); assert(poll(p,505,false), stage..' never rearmed')
end
-- Another player's pockets cannot block this player's gesture.
inventory({[0]=1}, {}, {[2]=10}); q.cards={}; q.pills={}; q.actives={}
tracker:Reset(); poll(p,600,false); poll(q,600,false)
poll(p,601,true); poll(q,601,true)
assert(not poll(p,602,false)); assert(poll(q,602,false))
print('OK: DROP release timing, hold suppression, wrapper/controller isolation and interruption cancellation')
