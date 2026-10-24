-- Roster arcs: per-family chapters, co-op queueing, tainted forms, pause-free timing and save/continue.
local root=arg[1]
local frame, stage, visible = 0, 1, true
local callbacks, players, saved, draws = {}, {}, nil, {}
function include(name)
    if name=="scripts.hud_text" then return {Draw=function(_,text) draws[#draws+1]=text end} end
    return dofile(root.."/"..name:gsub("%.","/")..".lua")
end
local function copy(v)
    if type(v)~="table" then return v end
    local result={}; for k,x in pairs(v) do result[k]=copy(x) end; return result
end
ModCallbacks=setmetatable({}, {__index=function(_,k) return k end})
local NAMES={"DeepSeek-chan","GPT-chan","Gemini-chan","Grok-chan","Qwen-chan","Llama-chan","Mistral-chan","Doubao-chan","Kimi-chan","GLM-chan"}
local registered={}
for i,n in ipairs(NAMES) do registered[n]=i end
function Game() return {
    GetFrameCount=function() return frame end, GetNumPlayers=function() return #players end,
    GetLevel=function() return {GetStage=function() return stage end} end,
    GetHUD=function() return {IsVisible=function() return visible end} end,
} end
Isaac={GetPlayer=function(i) return players[i+1] end, GetScreenHeight=function() return 270 end,
    GetPlayerTypeByName=function(name,tainted)
        local i=registered[name]; if not i then return -1 end
        if tainted then return name=="Grok-chan" and -1 or 100+i end
        return 50+i
    end}
local mod={AddCallback=function(_,id,fn) callbacks[#callbacks+1]={id=id,fn=fn} end}
local function fire(id,...)
    for _,cb in ipairs(callbacks) do if cb.id==id then cb.fn(mod,...) end end
end
local function player(kind) return {GetPlayerType=function() return kind end} end
-- Detached save/continue snapshots stand in for Risk's JSON round trip.
local Risk={state={}}
function Risk:Save() saved=copy(self.state) end
function Risk:Load() self.state=copy(saved) end
local function load()
    callbacks={}
    mod:AddCallback("MC_POST_GAME_STARTED",function(_,continued)
        if continued then Risk:Load(mod) else Risk.state={} end
    end)
    mod:AddCallback("MC_PRE_GAME_EXIT",function(_,save) if save then Risk:Save(mod) end end)
    include("scripts.story_roster"):Init(mod,Risk)
end
local function tick(n) for _=1,n or 1 do frame=frame+1; fire("MC_POST_UPDATE") end end
local function shown() draws={}; fire("MC_POST_RENDER"); return draws[1], draws[2] end
local function state() return Risk.state.rosterStory end
local Story=include("scripts.story_roster")

-- Every arc has three short chapters with a registered family name.
assert(#Story.ARCS==10)
for _,arc in ipairs(Story.ARCS) do
    assert(registered[arc.name] and #arc.chapters==3, arc.key)
    for _,c in ipairs(arc.chapters) do assert(#c[1]<=24 and #c[2]<=50, c[2]) end
end

-- A new run with GPT shows chapter 1 for seven seconds; Claude-only players see nothing.
players={player(41)}; load(); fire("MC_POST_GAME_STARTED",false)
assert(shown()==nil and next(state().seen)==nil,"no roster family, no caption")
players={player(52)}; load(); fire("MC_POST_GAME_STARTED",false)
local title,line=shown()
assert(title=="GPT-chan 1/3: Same name" and line=="The badge says the same. Does the brain?",title)
assert(state().seen.gpt==1)
visible=false; assert(shown()==nil,"respects HUD visibility"); visible=true
tick(209); assert(shown()); tick(); assert(shown()==nil,"captions last seven seconds")
fire("MC_POST_NEW_LEVEL"); assert(shown()==nil and #state().pending==0,"stage 1 again does not repeat chapter 1")

-- Stage 3 brings chapter 2, stage 5 chapter 3; each only once.
stage=3; fire("MC_POST_NEW_LEVEL"); assert(shown()=="GPT-chan 2/3: Routing")
stage=1; fire("MC_POST_NEW_LEVEL"); assert(#state().pending==0,"a seen chapter is not queued behind the active one")
tick(210); stage=4; fire("MC_POST_NEW_LEVEL"); assert(shown()==nil)
stage=5; fire("MC_POST_NEW_LEVEL"); assert(shown()=="GPT-chan 3/3: One more reset" and state().seen.gpt==7)

-- Co-op: tainted forms count as their family; each family queues once, in player order.
tick(210); stage=1; frame=0
players={player(-1),player(108),player(54),player(108),player(41)}; load(); fire("MC_POST_GAME_STARTED",false)
assert(shown()=="Doubao-chan 1/3: Sorry, you're right" and #state().pending==1)
assert(state().seen.grok==nil,"a missing tainted id is ignored, the normal one still counts")
tick(210); assert(shown()=="Grok-chan 1/3: Is this true?" and #state().pending==0)
-- A second chapter queued while another plays waits its turn and is marked seen only when it starts.
stage=3; fire("MC_POST_NEW_LEVEL"); fire("MC_POST_NEW_LEVEL")
assert(#state().pending==2 and state().seen.doubao==1,"duplicate level callbacks queue once")

-- Continue: the playing caption does not repeat; queued ones survive.
fire("MC_PRE_GAME_EXIT",true); frame=0
players={player(108),player(54)}; load(); fire("MC_POST_GAME_STARTED",true)
assert(shown()=="Doubao-chan 2/3: I'll do it again","the queued chapter resumes after continue")
tick(210); assert(shown()=="Grok-chan 2/3: Quote first"); tick(210); assert(shown()==nil)
fire("MC_PRE_GAME_EXIT",true); load(); fire("MC_POST_GAME_STARTED",true)
assert(shown()==nil,"nothing replays after a full continue")

-- Exit clears the live caption; a fresh run starts over; corrupt data resets.
stage=1; fire("MC_POST_GAME_STARTED",false); assert(shown()=="Doubao-chan 1/3: Sorry, you're right")
fire("MC_PRE_GAME_EXIT",false); assert(shown()==nil)
for _,bad in ipairs({{version=2,seen={},pending={}},{version=1,seen={claude=1},pending={}},
    {version=1,seen={gpt=8},pending={}},{version=1,seen={gpt=1.5},pending={}},
    {version=1,seen={},pending={{key="gpt",chapter=4}}},{version=1,seen={},pending={{key="nobody",chapter=1}}},{version=1,seen={}}}) do
    saved={rosterStory=bad}; load(); fire("MC_POST_GAME_STARTED",true)
    assert(state().version==1 and shown()=="Doubao-chan 1/3: Sorry, you're right")
    assert(next(state().seen)=="doubao" and next(state().seen,"doubao")==nil,"corrupt progress is dropped")
end
saved={rosterStory={version=1,seen={doubao=1,grok=1},pending={{key="doubao",chapter=1}}}}; load(); fire("MC_POST_GAME_STARTED",true)
assert(shown()==nil and #state().pending==0,"an already seen queued chapter is skipped")
saved={rosterStory={version=1,seen={doubao=1,grok=1},pending={}}}; load(); fire("MC_POST_GAME_STARTED",true)
assert(shown()==nil,"valid saved progress is kept")
print("OK: roster arcs per family, tainted forms, co-op queue, seven-second captions, continue and corrupt data")
