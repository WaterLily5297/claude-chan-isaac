-- Explicitly loaded engine observer for E2. Never include from main.lua.
-- It only registers temporary callbacks and writes bounded CCANCESTRY log lines.
local activeKey = "__ClaudeChanActiveAncestryProbe"
-- Re-including from the console must retain the live handle for manual Stop.
if _G[activeKey] then return _G[activeKey] end
local Probe = { FRAME_LIMIT = 900, EVENT_LIMIT = 2000 }

local function atom(value)
    if value == nil then return "nil" end
    return type(value) == "number" and tostring(value) or "unavailable"
end

local function entityFields(prefix, entity)
    if entity == nil then return prefix .. "=nil" end
    return table.concat({ prefix .. "_ptr=" .. atom(GetPtrHash(entity)),
        prefix .. "_index=" .. atom(entity.Index), prefix .. "_seed=" .. atom(entity.InitSeed),
        prefix .. "_type=" .. atom(entity.Type), prefix .. "_variant=" .. atom(entity.Variant),
        prefix .. "_subtype=" .. atom(entity.SubType), prefix .. "_frame=" .. atom(entity.FrameCount) }, " ")
end

function Probe:Log(event, detail)
    Isaac.DebugString("CCANCESTRY v=1 case=" .. self.case .. " source_declared=" .. self.source
        .. " event=" .. event .. " game_frame=" .. tostring(Game():GetFrameCount())
        .. " samples=" .. tostring(self.samples) .. " " .. detail)
end

function Probe:Stop(reason)
    if not self.active then return false end
    self.active = false
    for _, cb in ipairs(self.callbacks) do self.mod:RemoveCallback(cb.id, cb.fn) end
    self.callbacks = {}
    if _G[activeKey] == self then _G[activeKey] = nil end
    -- Cleanup happens even when the engine logger itself is unavailable.
    pcall(self.Log, self, "stop", "reason=" .. (reason or "manual"))
    return true
end

function Probe:Capture(phase, laser)
    if not self.active then return end
    if Game():GetFrameCount() - self.started >= self.FRAME_LIMIT then
        self:Stop("duration_limit")
        return
    end
    self.samples = self.samples + 1
    self:Log(phase, entityFields("laser", laser) .. " " .. entityFields("parent", laser.Parent)
        .. " " .. entityFields("spawner", laser.SpawnerEntity))
    if self.samples >= self.EVENT_LIMIT then self:Stop("event_limit") end
end

function Probe:Start(caseLabel, declaredSource)
    if self.active or _G[activeKey] then return false, "An ancestry observer is already active" end
    if type(caseLabel) ~= "string" or #caseLabel > 40 or not caseLabel:match("^[a-z0-9_%-]+$") then
        return false, "Use a short lowercase case label"
    end
    if type(declaredSource) ~= "string" or #declaredSource ~= 40 or not declaredSource:match("^[0-9a-f]+$") then
        return false, "Supply the full source commit from the verified installation receipt"
    end
    if Game():GetNumPlayers() < 1 then return false, "Start an authorized disposable test run first" end
    self.mod = self.mod or RegisterMod("Claude-chan manual ancestry observer", 1)
    self.case, self.source = caseLabel, declaredSource
    self.started, self.samples, self.callbacks = Game():GetFrameCount(), 0, {}
    self.active, _G[activeKey] = true, self
    local function add(id, fn)
        self.mod:AddCallback(id, fn)
        self.callbacks[#self.callbacks + 1] = { id = id, fn = fn }
    end
    local function sample(phase)
        return function(_, laser)
            local ok = pcall(self.Capture, self, phase, laser)
            if not ok then self:Stop("read_error") end
        end
    end
    local ok = pcall(function()
        add(ModCallbacks.MC_POST_LASER_INIT, sample("init"))
        add(ModCallbacks.MC_POST_LASER_UPDATE, sample("update"))
        add(ModCallbacks.MC_POST_UPDATE, function()
            if self.active and Game():GetFrameCount() - self.started >= self.FRAME_LIMIT then
                self:Stop("duration_limit")
            end
        end)
        add(ModCallbacks.MC_POST_NEW_ROOM, function() self:Stop("room_change") end)
        add(ModCallbacks.MC_POST_GAME_STARTED, function() self:Stop("run_change") end)
        add(ModCallbacks.MC_PRE_GAME_EXIT, function() self:Stop("run_exit") end)
        self:Log("start", "frame_limit=" .. self.FRAME_LIMIT .. " event_limit=" .. self.EVENT_LIMIT)
    end)
    if not ok then self:Stop("start_error"); return false, "Observer setup failed; callbacks removed" end
    return true
end

return Probe
