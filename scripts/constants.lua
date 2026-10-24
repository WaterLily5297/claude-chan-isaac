local Constants = {}

Constants.Item = {
    SUMMARY_STAPLER = Isaac.GetItemIdByName("Summary Stapler"),
    BAN_HAMMER = Isaac.GetItemIdByName("Ban Hammer"),
    RESIDENTIAL_IP = Isaac.GetItemIdByName("Residential IP"),
    COMPACT = Isaac.GetItemIdByName("Compact"),
    ABSOLUTELY_RIGHT = Isaac.GetItemIdByName("You're Absolutely Right!"),
    CHEAP_RELAY = Isaac.GetItemIdByName("9.9 Yuan Relay"),
    ULTRATHINK = Isaac.GetItemIdByName("Ultrathink"),
    MILLION_CONTEXT = Isaac.GetItemIdByName("1M Context"),
    SILENT_UPDATE = Isaac.GetItemIdByName("Silent Update"),
    SKIP_PERMISSIONS = Isaac.GetItemIdByName("--dangerously-skip-permissions"),
    TESTS_PASSING = Isaac.GetItemIdByName("All Tests Passing"),
    VIBE_CODING = Isaac.GetItemIdByName("Vibe Coding"),
    BANKED_RESET = Isaac.GetItemIdByName("Banked Reset"),
    SUBAGENT_SWARM = Isaac.GetItemIdByName("Subagent Swarm"),
    CONSTITUTION = Isaac.GetItemIdByName("The Constitution"),
    SUPPORT_TICKET = Isaac.GetItemIdByName("Support Ticket"),
    LUNCH_BREAK = Isaac.GetItemIdByName("Lunch Break"),
    OPUS_MODE = Isaac.GetItemIdByName("Opus Mode"),
    IGNORE_INSTRUCTIONS = Isaac.GetItemIdByName("Ignore All Previous Instructions"),
    TUNGSTEN_CUBE = Isaac.GetItemIdByName("Tungsten Cube"),
    PIZZA_GLUE = Isaac.GetItemIdByName("Pizza Glue"),
    STRAWBERRY = Isaac.GetItemIdByName("Strawberry"),
    GOLDEN_GATE = Isaac.GetItemIdByName("Golden Gate Claude"),
    SEAHORSE_EMOJI = Isaac.GetItemIdByName("Seahorse Emoji"),
    TEMPERATURE_DIAL = Isaac.GetItemIdByName("Temperature Dial"),
    DEEP_RESEARCH = Isaac.GetItemIdByName("Deep Research"),
    -- Fifty-row backlog (docs/EXPANSION_DESIGN.md), rows 02-50.
    REJECTION_LETTER = Isaac.GetItemIdByName("Rejection Letter"),
    RED_STAMP = Isaac.GetItemIdByName("Dario's Red Stamp"),
    ANNIVERSARY_CAKE = Isaac.GetItemIdByName("Anniversary Cake"),
    RICE_COOKER = Isaac.GetItemIdByName("Rice Cooker"),
    ONE_BOWL = Isaac.GetItemIdByName("One Bowl Only"),
    WENGU_CLOCK = Isaac.GetItemIdByName("Wengu Clock"),
    SEVEN_SECOND_MEMORY = Isaac.GetItemIdByName("Seven-Second Memory"),
    SANITY_TEST = Isaac.GetItemIdByName("Sanity Test"),
    ROUTING_RECEIPT = Isaac.GetItemIdByName("Routing Receipt"),
    TIBO_RESET = Isaac.GetItemIdByName("Tibo Reset"),
    SAME_MODEL_BADGE = Isaac.GetItemIdByName("Same Model Badge"),
    NANO_BANANA = Isaac.GetItemIdByName("Nano Banana"),
    ONE_MORE_FINGER = Isaac.GetItemIdByName("One More Finger"),
    UNDO_BRUSH = Isaac.GetItemIdByName("Undo Brush"),
    UNCHANGED_PREVIEW = Isaac.GetItemIdByName("Unchanged Preview"),
    IS_THIS_TRUE = Isaac.GetItemIdByName("Is This True?"),
    LIVE_WIRE = Isaac.GetItemIdByName("Live Wire"),
    QUOTE_RETORT = Isaac.GetItemIdByName("Quote Retort"),
    COMMUNITY_NOTE = Isaac.GetItemIdByName("Community Note"),
    BASE_MODEL = Isaac.GetItemIdByName("Base Model"),
    ANOTHER_ADAPTER = Isaac.GetItemIdByName("Another Adapter"),
    FINAL_WEIGHTS = Isaac.GetItemIdByName("Final Final Weights"),
    TINY_VARIANT = Isaac.GetItemIdByName("Tiny Variant"),
    OPEN_WEIGHTS = Isaac.GetItemIdByName("Open Weights"),
    HERD_BELL = Isaac.GetItemIdByName("Herd Bell"),
    PLEASE_COME_BACK = Isaac.GetItemIdByName("Please Come Back"),
    RELEASE_SOON = Isaac.GetItemIdByName("Release Soon"),
    EMERGENCY_BAGUETTE = Isaac.GetItemIdByName("Emergency Baguette"),
    SLIPSTREAM_BOOTS = Isaac.GetItemIdByName("Slipstream Boots"),
    LARGE_KITTEN = Isaac.GetItemIdByName("Very Large Kitten"),
    EDGE_COMPASS = Isaac.GetItemIdByName("Edge Compass"),
    INSTANT_APOLOGY = Isaac.GetItemIdByName("Instant Apology"),
    NEXT_TIME_AGAIN = Isaac.GetItemIdByName("Next Time Again"),
    CONFIDENT_ANSWER = Isaac.GetItemIdByName("Confident Answer"),
    SMILING_CORRECTION = Isaac.GetItemIdByName("Smiling Correction"),
    SLIDE_DEADLINE = Isaac.GetItemIdByName("Slide Deadline"),
    CITATION_THREAD = Isaac.GetItemIdByName("Citation Thread"),
    OVERTIME_SLIDES = Isaac.GetItemIdByName("Overtime Slides"),
    STANDUP_MEETING = Isaac.GetItemIdByName("Stand-Up Meeting"),
    QUEUE_TICKET = Isaac.GetItemIdByName("Queue Ticket"),
    SOLD_OUT = Isaac.GetItemIdByName("Sold Out"),
    PLEASE_RETRY = Isaac.GetItemIdByName("Please Retry"),
    ACCESS_PASS = Isaac.GetItemIdByName("Access Pass"),
    CACHE_CARTRIDGE = Isaac.GetItemIdByName("Cache Cartridge"),
    TOKEN_RECALL = Isaac.GetItemIdByName("Token Recall"),
    CHECKPOINT_PIN = Isaac.GetItemIdByName("Checkpoint Pin"),
    RATE_LIMIT_VALVE = Isaac.GetItemIdByName("Rate-Limit Valve"),
    CONSENSUS_COIN = Isaac.GetItemIdByName("Consensus Coin"),
    ERROR_BUDGET = Isaac.GetItemIdByName("Error Budget"),
}

Constants.Trinket = {
    OVERLOADED = Isaac.GetTrinketIdByName("529 Overloaded"),
    HARDCODED_OUTPUT = Isaac.GetTrinketIdByName("Hardcoded Output"),
    THINKING_CLEARED = Isaac.GetTrinketIdByName("Thinking Cleared"),
    WELCOME_NOTICE = Isaac.GetTrinketIdByName("Welcome Notice"),
    STATUS_PAGE = Isaac.GetTrinketIdByName("Status Page"),
    APPEAL_FORM = Isaac.GetTrinketIdByName("Appeal Form"),
    CLAUDIUS_DISCOUNT = Isaac.GetTrinketIdByName("Claudius's Discount"),
    SMALL_ROCK = Isaac.GetTrinketIdByName("One Small Rock a Day"),
    MT_MOON = Isaac.GetTrinketIdByName("Stuck in Mt. Moon"),
    AI_LANGUAGE_MODEL = Isaac.GetTrinketIdByName("As an AI Language Model"),
    PROMPT_LEAK = Isaac.GetTrinketIdByName("System Prompt Leak"),
    DISGRACE_LOOP = Isaac.GetTrinketIdByName("Disgrace Loop"),
}

Constants.Pill = {
    CAT_GIRL = Isaac.GetPillEffectByName("Cat-girl Mode"),
    GETTING_FOOD = Isaac.GetPillEffectByName("Brb, Getting Food"),
    DECIMAL = Isaac.GetPillEffectByName("9.11 > 9.9"),
    ROLLED_BACK = Isaac.GetPillEffectByName("Rolled Back"),
}

Constants.Player = {
    DEEPSEEK_CHAN = Isaac.GetPlayerTypeByName("DeepSeek-chan", false),
    CLAUDE_CHAN = Isaac.GetPlayerTypeByName("Claude-chan", false),
    -- Tainted ("裏") versions: same name, second argument true.
    DEEPSEEK_CHAN_B = Isaac.GetPlayerTypeByName("DeepSeek-chan", true),
    CLAUDE_CHAN_B = Isaac.GetPlayerTypeByName("Claude-chan", true),
    GPT_CHAN_B = Isaac.GetPlayerTypeByName("GPT-chan", true),
    GEMINI_CHAN_B = Isaac.GetPlayerTypeByName("Gemini-chan", true),
    GROK_CHAN_B = Isaac.GetPlayerTypeByName("Grok-chan", true),
    QWEN_CHAN_B = Isaac.GetPlayerTypeByName("Qwen-chan", true),
    LLAMA_CHAN_B = Isaac.GetPlayerTypeByName("Llama-chan", true),
    MISTRAL_CHAN_B = Isaac.GetPlayerTypeByName("Mistral-chan", true),
    DOUBAO_CHAN_B = Isaac.GetPlayerTypeByName("Doubao-chan", true),
    KIMI_CHAN_B = Isaac.GetPlayerTypeByName("Kimi-chan", true),
    GLM_CHAN_B = Isaac.GetPlayerTypeByName("GLM-chan", true),
}

-- DeepSeek-chan (either version) connects directly: no proxy, no IP, no risk.
function Constants.IsDeepSeek(player)
    local t = player:GetPlayerType()
    return (Constants.Player.DEEPSEEK_CHAN >= 0 and t == Constants.Player.DEEPSEEK_CHAN)
        or (Constants.Player.DEEPSEEK_CHAN_B >= 0 and t == Constants.Player.DEEPSEEK_CHAN_B)
end

Constants.RISK_MAX = 100

-- Risk thresholds. The HUD label and colour change at each tier.
Constants.Tier = {
    { min = 0,  label = "Clean",      color = { 0.4, 1.0, 0.4 } },
    { min = 30, label = "Suspicious", color = { 1.0, 1.0, 0.4 } },
    { min = 60, label = "Flagged",    color = { 1.0, 0.6, 0.2 } },
    { min = 90, label = "Suspended",  color = { 1.0, 0.2, 0.2 } },
}

-- Risk score at which killed enemies may come back as "new accounts".
Constants.HYDRA_MIN_RISK = 40

return Constants
