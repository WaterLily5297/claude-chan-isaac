-- Bounded offline measurements of the real GPT/Grok binders and choice ledger.
-- Usage: texlua tools/profile_target_hotpaths.lua . [iterations, default 6000]
-- This is not an engine benchmark or a wall-clock CI threshold.
local root = assert(arg[1], "repository root required")
local iterations = tonumber(arg[2]) or 6000
assert(iterations >= 1 and iterations <= 60000 and iterations % 1 == 0,
    "iterations must be an integer from 1 to 60000")

local function upvalue(fn, wanted)
    for i = 1, math.huge do
        local name, value = debug.getupvalue(fn, i)
        if not name then break end
        if name == wanted then return value end
    end
    error("missing measurement seam: "..wanted)
end

function include(name)
    if name == "scripts.hud_text" then return {} end
    return dofile(root.."/"..name:gsub("%.", "/")..".lua")
end
ModCallbacks = setmetatable({}, {__index=function(_, key) return key end})
function GetPtrHash(p) return p.pointer end

local function measureBinding(module, count, matching)
    local players, typeCalls, scans, frame = {}, 0, 0, 0
    -- Cached engine stand-ins avoid measuring fresh tables allocated by Game().
    local game = {
        GetNumPlayers=function() return #players end,
        GetFrameCount=function() return frame end,
    }
    function Game() return game end
    Isaac = {
        GetPlayerTypeByName=function() return 51 end,
        GetPlayer=function(i) return players[i + 1] end,
        FindInRadius=function() scans = scans + 1; return {} end,
        GetRoomEntities=function() scans = scans + 1; return {} end,
    }
    for i = 1, count do
        players[i] = {pointer=i, InitSeed=i + 100, kind=matching and 51 or 0,
            GetPlayerType=function(self) typeCalls = typeCalls + 1; return self.kind end}
    end
    local callbacks, risk = {}, {state={}}
    local mod = {AddCallback=function(_, id, fn) callbacks[id] = fn end}
    include("scripts.characters."..module):Init(mod, risk)
    -- Isolate the actual binding closure, not a rewritten imitation. No other
    -- callback, rendering, native C++ work or garbage-collector pause is timed.
    local bind = upvalue(assert(callbacks.MC_POST_UPDATE), "bind")
    for _ = 1, 20 do bind() end
    typeCalls, scans = 0, 0
    collectgarbage("collect")
    collectgarbage("stop")
    local before, started = collectgarbage("count"), os.clock()
    for i = 1, iterations do frame = i; bind() end
    local seconds = os.clock() - started
    local allocated = collectgarbage("count") - before
    collectgarbage("restart")
    collectgarbage("collect")
    print(string.format("bind,%s,%d,%s,%d,%d,%d,%.3f,%.6f",
        module, count, matching and "matching" or "unrelated", iterations,
        typeCalls, scans, allocated, seconds))
end

print("# ".._VERSION.."; GC-stopped heap growth is allocation pressure, not a leak or native memory use")
print("kind,module,players,scenario,iterations,player_type_calls,entity_scans,heap_growth_KiB,cpu_seconds")
for _, module in ipairs({"gpt_downgrade", "grok_ratio"}) do
    for _, count in ipairs({1, 4}) do
        measureBinding(module, count, false)
        measureBinding(module, count, true)
    end
end

-- A proxy counts numeric entry reads made only inside Resolve. No timings from
-- this instrumented representation are compared with normal ledger timings.
local Choices = include("scripts.characters.attack_choices")
local ledger, reads = Choices.New(), 0
local entries = ledger.entries
ledger.entries = setmetatable({}, {
    __len=function() return #entries end,
    __index=function(_, key)
        if type(key) == "number" then reads = reads + 1 end
        return entries[key]
    end,
    __newindex=function(_, key, value) entries[key] = value end,
})
local function resolve()
    local before = reads
    local value = Choices.Resolve(ledger, 3)
    return reads - before, value
end
local total = 0
for i = 1, 600 do
    Choices.Record(ledger, "attack"..i, i % 2 == 0)
    local n = resolve(); total = total + n
end
print("scenario,ledger_entries,resolve_entry_reads")
print(string.format("600_append_and_resolve,%d,%d", #entries, total))
total = 0
for _ = 1, iterations do local n = resolve(); total = total + n end
print(string.format("unchanged_resolve_%d,%d,%d", iterations, #entries, total))
total = 0
for i = 1, 600 do
    Choices.Record(ledger, "attack"..i, false)
    local n = resolve(); total = total + n
end
print(string.format("600_duplicate_hits,%d,%d", #entries, total))
Choices.Record(ledger, "attack1", true)
local replayReads = resolve()
print(string.format("late_first_attack_revision,%d,%d", #entries, replayReads))
Choices.Half(ledger)
local halfReads = resolve()
print(string.format("transfer_half_marker,%d,%d", #entries, halfReads))
print("# Synthetic keys are supplied here; no weapon attribution or native billing is exercised.")
