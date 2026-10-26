-- Offline diagnostic, not an acceptance test or an engine probe.
-- Usage: texlua tools/probe_charged_use.lua .
-- Reports current behavior; it deliberately does not assert known bad rewards.
local root = assert(arg[1], "repository root required")
local Env = dofile(root.."/tests/lib/backlog_env.lua")
local cases = {
    "refused_unchanged", "refused_replace_equal", "refused_replace_lower",
    "refused_remove", "refused_swap", "accepted_discharge", "accepted_remove",
}

print("# Offline supplied callbacks/inventory changes, not observed native item behavior.")
print("# accepted_remove deliberately removes Red Stamp after its successful handler; Red Stamp does not remove itself.")
print("# Exit success checks fixture setup only. Read emitted events/effects to assess F12; this is not a passing regression gate.")
print("case,slot,handler_discharge,slot_changed,total_before,total_after,events,base_model,come_back,access_spent,damage")

for _, name in ipairs(cases) do
    for slot = 0, 3 do
        local env = Env.New(root)
        local p = env.player(300)
        p.Position = Vector(300, 200)
        env.load(); env.newRoom()
        for _, key in ipairs({"BASE_MODEL", "PLEASE_COME_BACK", "ACCESS_PASS"}) do env.give(p, key) end
        env.C.State(p).comeBack = 2
        local item, replacement = env.Item.RED_STAMP, 999
        env.config[item] = {MaxCharges=4, ChargeType=0}
        env.config[replacement] = {MaxCharges=4, ChargeType=0}
        p.active[slot], p.charge[slot], p.battery[slot] = item, 4, 4
        if name:match("^accepted_") then env.npc(320, {y=200}) end
        local events = 0
        env.C.On("activeUsed", function(owner, id)
            assert(owner == p and id == item, "fixture attributed a different activation")
            events = events + 1
        end)
        env.fire("MC_PRE_USE_ITEM", nil, item, nil, p, UseFlag.USE_OWNED, slot)
        local result = env.use(item, p, nil, slot)
        assert(type(result) == "table" and result.Discharge == (name:match("^accepted_") ~= nil),
            "Red Stamp must accept only the supplied nearby-target cases")

        -- These transitions are inputs, not an emulation of engine discharge,
        -- reroll, Schoolbag, Butter!, item removal, or callback scheduling.
        if name == "refused_replace_equal" then
            p.active[slot] = replacement
        elseif name == "refused_replace_lower" then
            p.active[slot], p.charge[slot], p.battery[slot] = replacement, 0, 0
        elseif name == "refused_remove" or name == "accepted_remove" then
            p.active[slot], p.charge[slot], p.battery[slot] = 0, 0, 0
        elseif name == "refused_swap" then
            local other = (slot + 1) % 4
            p.active[other], p.charge[other], p.battery[other] = item, 4, 4
            p.active[slot], p.charge[slot], p.battery[slot] = replacement, 4, 4
        elseif name == "accepted_discharge" then
            p.battery[slot] = 0
        end
        local changed = p.active[slot] ~= item
        local after = p.charge[slot] + p.battery[slot]
        env.update(3)
        local state = env.C.State(p)
        print(string.format("%s,%d,%s,%s,8,%d,%d,%s,%d,%s,%.3f",
            name, slot, tostring(result.Discharge), tostring(changed), after, events,
            tostring(env.C.Primed(p, "baseModel")), state.comeBack,
            tostring(state.floor.access == true), p.Damage))
    end
end
