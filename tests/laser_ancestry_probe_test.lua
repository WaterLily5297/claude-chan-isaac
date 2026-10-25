-- Observer lifecycle and formatting only. These are not native ancestry observations.
local root = arg[1]
local frame, players, registrations, callbacks, lines = 10, 1, 0, {}, {}
local addFailure, logFailure = false, false
ModCallbacks = { MC_POST_LASER_INIT = "init", MC_POST_LASER_UPDATE = "laser_update", MC_POST_UPDATE = "tick",
    MC_POST_NEW_ROOM = "room", MC_POST_GAME_STARTED = "run", MC_PRE_GAME_EXIT = "exit" }
function Game() return { GetFrameCount = function() return frame end, GetNumPlayers = function() return players end } end
Isaac = { DebugString = function(line)
    if logFailure then error("logger unavailable") end
    lines[#lines + 1] = line
end }
function GetPtrHash(e) return e.ptr end
function RegisterMod()
    registrations = registrations + 1
    return { AddCallback = function(_, id, fn)
        if addFailure and id == "tick" then error("registration failure") end
        callbacks[#callbacks + 1] = { id = id, fn = fn }
    end, RemoveCallback = function(_, id, fn)
        for i = #callbacks, 1, -1 do
            if callbacks[i].id == id and callbacks[i].fn == fn then table.remove(callbacks, i) end
        end
    end }
end
local function fire(id, ...)
    local copy = {}; for i, cb in ipairs(callbacks) do copy[i] = cb end
    for _, cb in ipairs(copy) do if cb.id == id then assert(cb.fn(nil, ...) == nil) end end
end
local function load() return dofile(root .. "/tests/laser_ancestry_probe.lua") end
local source, probe = string.rep("a", 40), load()
assert(registrations == 0 and #callbacks == 0 and #lines == 0, "loading is inert")
assert(not probe:Start("bad label", source) and not probe:Start("techx", "missing"))
players = 0; assert(not probe:Start("techx", source)); players = 1
assert(registrations == 0 and #callbacks == 0)
assert(probe:Start("techx", source) and #callbacks == 6)
assert(load() == probe, "re-including retains the live manual Stop handle")
assert(not probe:Start("repeat", source) and not load():Start("duplicate_module", source), "one active observer")
local values = { ptr=1, Index=2, InitSeed=3, Type=7, Variant=2, SubType=0, FrameCount=0 }
local laser = setmetatable({}, { __index=values, __newindex=function() error("probe mutated entity") end })
fire("init", laser)
assert(lines[#lines]:find("event=init", 1, true) and lines[#lines]:find("parent=nil spawner=nil", 1, true))
assert(lines[#lines]:find("laser_seed=3", 1, true) and lines[#lines]:find("laser_frame=0", 1, true))
values.Parent = { ptr=4, Index=5, InitSeed=6, Type=7, Variant=1, SubType=0, FrameCount=9 }
values.SpawnerEntity = { ptr=7, Index=8, InitSeed=9, Type=1, Variant=0, SubType=0, FrameCount=40 }
values.FrameCount, frame = 1, 11
fire("laser_update", laser)
assert(lines[#lines]:find("parent_type=7", 1, true) and lines[#lines]:find("spawner_type=1", 1, true))
assert(lines[#lines]:find("game_frame=11", 1, true) and lines[#lines]:find("laser_frame=1", 1, true))
values.Parent = nil; fire("laser_update", laser)
assert(lines[#lines]:find("parent=nil", 1, true), "record the actual missing link, do not retain ancestry")
assert(probe:Stop() and #callbacks == 0 and not probe:Stop())
local before = #lines; fire("laser_update", laser); assert(#lines == before)

for _, event in ipairs({ "room", "run", "exit" }) do
    assert(probe:Start(event, source)); fire(event); assert(not probe.active and #callbacks == 0)
end
assert(probe:Start("empty_case", source))
frame = frame + probe.FRAME_LIMIT; fire("tick")
assert(not probe.active and #callbacks == 0 and lines[#lines]:find("reason=duration_limit", 1, true))
assert(probe:Start("bounded", source))
for _ = 1, probe.EVENT_LIMIT do fire("laser_update", laser) end
assert(not probe.active and #callbacks == 0 and probe.samples == probe.EVENT_LIMIT)
assert(lines[#lines]:find("reason=event_limit", 1, true))
assert(probe:Start("stale_handle", source))
fire("init", setmetatable({}, { __index=function() error("inaccessible entity") end }))
assert(not probe.active and #callbacks == 0 and lines[#lines]:find("reason=read_error", 1, true))
addFailure = true; assert(not probe:Start("setup_failure", source)); addFailure = false
assert(not probe.active and #callbacks == 0, "partial setup cleanup")
logFailure = true; assert(not probe:Start("log_failure", source)); logFailure = false
assert(not probe.active and #callbacks == 0, "logger failure cleanup")
assert(load():Start("fresh_module", source)); _G.__ClaudeChanActiveAncestryProbe:Stop()
assert(#callbacks == 0, "global active guard released on stop")
local f = assert(io.open(root .. "/main.lua")); local main = f:read("a"); f:close()
assert(not main:find("laser_ancestry_probe", 1, true), "observer must never auto-enable")
print("Ancestry observer: inert load, scalar snapshots, bounds and callback cleanup passed (offline only)")
