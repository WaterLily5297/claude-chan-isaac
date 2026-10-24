-- Real visual feedback helper: vanilla poofs and timed tints only, and a
-- silent no-op when the API lacks the feature.
local root=arg[1]
local Feedback=dofile(root.."/scripts/characters/feedback.lua")
-- Without Isaac.Spawn or EffectVariant nothing happens and nothing errors.
Isaac={}
Feedback.Burst({X=0,Y=0},{1})
Feedback.Mark({},{1},10)
Feedback.Mark(nil,{1},10)
local spawned={}
EntityType={ENTITY_EFFECT=1000}; EffectVariant={POOF01=15}
function Vector(x,y) return {X=x,Y=y} end
function Isaac.Spawn(t,v,s,pos,vel,spawner)
    local e={Type=t,Variant=v,SubType=s,Position=pos,spawner=spawner}
    spawned[#spawned+1]=e; return e
end
local tint={0.5}
Feedback.Burst({X=3,Y=4},tint)
assert(#spawned==1 and spawned[1].Type==1000 and spawned[1].Variant==15,"a burst is one vanilla poof")
assert(spawned[1].Color==tint and spawned[1].Position.X==3 and spawned[1].spawner==nil)
local marked
local enemy={SetColor=function(_,color,frames,priority,fade,share) marked={color,frames,priority,fade,share} end}
Feedback.Mark(enemy,tint,60)
assert(marked[1]==tint and marked[2]==60 and marked[4]==true and marked[5]==false,"a mark is a fading tint that is not shared")
print("OK: visual feedback is vanilla poofs and fading tints only")
