-- Experimental model-family identities: names, titles, dossier lines and tear tint.
-- No changes to DeepSeek's direct connection or either existing character module.
local C = include("scripts.constants")
local Roster = {}
Roster.definitions = {
    -- Mechanics live in gpt_downgrade.lua, gemini_paint.lua, grok_check.lua,
    -- qwen_adapter.lua, llama_release.lua, mistral_pounce.lua, doubao_apology.lua,
    -- kimi_slides.lua and glm_queue.lua.
    {key="gpt", name="GPT-chan", title="Same Name, Smaller Brain", color={0.4,1,0.75},
     lines={"Verified: +15% damage. Clears add Routing.", "At 3 Routing, next combat: Fallback, -20%.", "Fallback: tap DROP, hit the Sanity Check 3x."}},
    {key="gemini", name="Gemini-chan", title="Nano Banana", color={0.7,0.6,1},
     lines={"Tap/release DROP: Paint the nearest enemy.", "Painted: +20% your damage for 8 seconds.", "Your kill leaves a slowing banana peel."}},
    {key="grok", name="Grok-chan", title="Is This True?", color={1,0.3,0.35},
     lines={"Tap/release DROP in combat: check an enemy.", "6s: +30% damage to it, -10% to others.", "3 hits or its defeat: +0.15 speed this room."}},
    {key="qwen", name="Qwen-chan", title="Everyone's Base Model", color={0.8,0.5,1},
     lines={"Tap/release DROP: pick Range, Tempo or Power.", "A new hostile room spends an Adapter on it.", "Earn an Adapter every two combat clears."}},
    {key="llama", name="Llama-chan", title="Please Stay Open", color={0.65,1,0.5},
     lines={"Tap/release DROP: spend a Release.", "Each living player gains two blue flies.", "Earn a Release every two combat clears."}},
    {key="mistral", name="Mistral-chan", title="Le Chat", color={1,0.7,0.3},
     lines={"Move while firing for 2s: charge a Pounce.", "Tap/release DROP: forward swipe, 2x damage.", "Standing still for 1s loses the Pounce."}},
    {key="doubao", name="Doubao-chan", title="Sorry, You're Right", color={1,0.7,0.6},
     lines={"The first enemy hit in a room: an Apology.", "Tap/release DROP within 6s: slow nearby", "enemies and clear up to four bullets."}},
    {key="kimi", name="Kimi-chan", title="Another Slide Deck", color={0.55,0.65,1},
     lines={"Each combat clear earns a Slide (up to 6).", "Tap/release DROP: spend 3 to present to the", "3 nearest enemies: slowed, +15% your damage."}},
    {key="glm", name="GLM-chan", title="Number in Queue", color={0.3,0.95,0.7},
     lines={"Each combat clear advances the Queue.", "At 3/3, tap/release DROP: Access Pass.", "Next 2 new hostile rooms: +20% damage."}},
}
for _, def in ipairs(Roster.definitions) do
    def.id = Isaac.GetPlayerTypeByName(def.name, false)
end

-- Registered tainted forms of these families. They run their own modules, so
-- Find ignores them, but they are still outside Claude's proxy account.
local TAINTED = {"GPT-chan", "Gemini-chan", "Grok-chan", "Qwen-chan", "Llama-chan", "Mistral-chan", "Doubao-chan"}
Roster.tainted = {}
for _, name in ipairs(TAINTED) do
    local id = Isaac.GetPlayerTypeByName(name, true)
    if id >= 0 then Roster.tainted[#Roster.tainted + 1] = id end
end

function Roster:IsFamily(player)
    if self:Find(player) then return true end
    local id = player:GetPlayerType()
    -- Claude and DeepSeek forms are never roster families, even under aliases.
    for _, existing in ipairs({C.Player.CLAUDE_CHAN, C.Player.CLAUDE_CHAN_B,
        C.Player.DEEPSEEK_CHAN, C.Player.DEEPSEEK_CHAN_B}) do
        if id == existing then return false end
    end
    for _, tainted in ipairs(self.tainted) do if id == tainted then return true end end
    return false
end

function Roster:Find(player)
    local id = player:GetPlayerType()
    -- Protect existing characters even when a test/third-party resolver returns aliases.
    for _, existing in pairs(C.Player) do if id == existing then return nil end end
    for _, def in ipairs(self.definitions) do
        if def.id >= 0 and id == def.id then return def end
    end
end

-- Every family's mechanics live in its own module; the roster only tints tears.
function Roster:Init(mod)
    mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, p, flag)
        if flag ~= CacheFlag.CACHE_TEARCOLOR then return end
        local def = self:Find(p)
        if not def then return end
        -- Tint rather than replace, so item colors (Ipecac, Spoon Bender) stay readable.
        local c, k = p.TearColor, def.color
        if c then p.TearColor = Color(c.R*k[1], c.G*k[2], c.B*k[3], c.A, c.RO, c.GO, c.BO)
        else p.TearColor = Color(k[1], k[2], k[3], 1, 0, 0, 0) end
    end)
end
return Roster
