-- Experimental model-family characters. All persistent progress lives in Risk.state.
-- No changes to DeepSeek's direct connection or either existing character module.
local C = include("scripts.constants")
local Roster = {}
Roster.definitions = {
    {key="gpt", name="GPT-chan", title="Deliberate / Instant", color={0.4,1,0.75},
     lines={"Tap DROP: switch inference mode.", "Deliberate: +35% damage, slower tears.", "Instant: faster tears, -15% damage."}},
    {key="gemini", name="Gemini-chan", title="Two modalities", color={0.7,0.6,1},
     lines={"Tap DROP: switch Prism / Echo.", "Prism: piercing tears, +20% damage.", "Echo: homing tears, faster fire."}},
    {key="grok", name="Grok-chan", title="Live momentum", color={1,0.3,0.35},
     lines={"Keep moving to build momentum.", "Up to +25% damage after 5 seconds.", "Standing still drains momentum."}},
    {key="qwen", name="Qwen-chan", title="Task chain", color={0.8,0.5,1},
     lines={"Clear rooms without taking damage.", "Each success: +6% damage, up to 5.", "A hit breaks the chain."}},
    {key="llama", name="Llama-chan", title="Open collaboration", color={0.65,1,0.5},
     lines={"Every second unique combat clear:", "Each living player gains 2 blue flies.", "Personal damage starts 10% lower."}},
    {key="mistral", name="Mistral-chan", title="Tailwind", color={1,0.7,0.3},
     lines={"Move while firing to build tailwind.", "After 2 seconds: spectral tears.", "+0.15 speed; faster tear travel."}},
    {key="doubao", name="Doubao-chan", title="Warm meal", color={1,0.7,0.6},
     lines={"Every third unique combat clear:", "Recover one red heart.", "At full red health: gain 2 blue flies."}},
    {key="kimi", name="Kimi-chan", title="Long context", color={0.55,0.65,1},
     lines={"Flawless combat clears store pages.", "Each page: +4% damage and range.", "Up to 6 pages; a hit erases 2."}},
    {key="glm", name="GLM-chan", title="Tool orchestration", color={0.3,0.95,0.7},
     lines={"Using an active item builds a tool link.", "Each link: +12% damage, up to 3.", "Links expire on entering another room."}},
}
for _, def in ipairs(Roster.definitions) do
    def.id = Isaac.GetPlayerTypeByName(def.name, false)
end

function Roster:Find(player)
    local id = player:GetPlayerType()
    -- Protect existing characters even when a test/third-party resolver returns aliases.
    for _, existing in pairs(C.Player) do if id == existing then return nil end end
    for _, def in ipairs(self.definitions) do
        if def.id >= 0 and id == def.id then return def end
    end
end

function Roster:Init(mod, Risk)
    local ready = false
    local transient = {}
    local function slot(player)
        for i = 0, Game():GetNumPlayers() - 1 do
            if GetPtrHash(Isaac.GetPlayer(i)) == GetPtrHash(player) then return tostring(i) end
        end
    end
    local function state(player, def)
        local key = slot(player)
        if not key then return nil end
        local all = Risk.state.modelRoster
        if type(all) ~= "table" then all = {}; Risk.state.modelRoster = all end
        local s = all[key]
        if type(s) ~= "table" or s.key ~= def.key then
            s = {key=def.key, mode=0, chain=0, pages=0, meals=0, shares=0, links=0, awards={}}
            all[key] = s
        end
        return s
    end
    local function temp(player)
        -- Callbacks can wrap the same engine entity in different Lua objects.
        -- Keep only scalar identity, and reject a reused pointer or changed type.
        local pointer, seed, kind = GetPtrHash(player), player.InitSeed, player:GetPlayerType()
        local s = transient[pointer]
        if not s or s.seed ~= seed or s.kind ~= kind then
            s = {seed=seed, kind=kind, momentum=0, wind=0, toolFrame=-1}
            transient[pointer] = s
        end
        return s
    end
    local function refresh(player)
        player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_FIREDELAY |
            CacheFlag.CACHE_SPEED | CacheFlag.CACHE_RANGE | CacheFlag.CACHE_SHOTSPEED |
            CacheFlag.CACHE_TEARFLAG | CacheFlag.CACHE_TEARCOLOR | CacheFlag.CACHE_LUCK)
        player:EvaluateItems()
    end
    local function each(fn)
        for i=0,Game():GetNumPlayers()-1 do
            local p = Isaac.GetPlayer(i)
            local def = self:Find(p)
            if def then fn(p, def, state(p, def)) end
        end
    end
    local function roomKey()
        local level = Game():GetLevel()
        local desc = level:GetCurrentRoomDesc()
        return tostring(level:GetDungeonPlacementSeed()) .. ":" .. tostring(desc.SpawnSeed)
    end

    mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function(_, continued)
        transient = {}
        if not continued then Risk.state.modelRoster = {} end
        ready = true
        each(function(p, def, s)
            local key = roomKey()
            if s.room ~= key then s.room=key; s.hit=false; s.links=0 end

            if not continued and def.key == "glm" then
                p:SetPocketActiveItem(CollectibleType.COLLECTIBLE_BOOK_OF_SECRETS, ActiveSlot.SLOT_POCKET, false)
            end
            refresh(p)
        end)
    end)
    mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, function() ready=false; transient={} end)
    mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
        if not ready then return end
        each(function(p, def, s)
            local key=roomKey()
            if s.room ~= key then
                s.room=key; s.hit=false; s.links=0; temp(p).momentum=0; temp(p).wind=0

                refresh(p)
            end
        end)
    end)
    mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, function()
        if not ready then return end
        each(function(p, _, s) s.awards={}; refresh(p) end)
    end)
    mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, p, flag)
        local def=self:Find(p)
        if not def then return end
        local s=state(p,def)
        if not s then return end
        local t=temp(p)
        local key=def.key
        if flag == CacheFlag.CACHE_DAMAGE then
            local mult=1
            if key=="gpt" then mult=s.mode==0 and 1.35 or 0.85
            elseif key=="gemini" then mult=s.mode==0 and 1.2 or 0.9
            elseif key=="grok" then mult=1 + math.floor(t.momentum/15)*0.025
            elseif key=="qwen" then mult=1 + s.chain*0.06
            elseif key=="llama" then mult=0.9

            elseif key=="kimi" then mult=1+s.pages*0.04
            elseif key=="glm" then mult=1+s.links*0.12 end
            p.Damage=p.Damage*mult
        elseif flag==CacheFlag.CACHE_FIREDELAY then
            if key=="gpt" then p.MaxFireDelay=math.max(-0.75,(p.MaxFireDelay+1)*(s.mode==0 and 1.2 or 0.8)-1)
            elseif key=="gemini" and s.mode==1 then p.MaxFireDelay=math.max(-0.75,(p.MaxFireDelay+1)*0.9-1) end
        elseif flag==CacheFlag.CACHE_SPEED and key=="mistral" then p.MoveSpeed=p.MoveSpeed+0.15
        elseif flag==CacheFlag.CACHE_SHOTSPEED and key=="mistral" then p.ShotSpeed=p.ShotSpeed+0.25
        elseif flag==CacheFlag.CACHE_RANGE and key=="kimi" then p.TearRange=p.TearRange+s.pages*25
        elseif flag==CacheFlag.CACHE_TEARFLAG then
            if key=="gemini" then p.TearFlags=p.TearFlags | (s.mode==0 and TearFlags.TEAR_PIERCING or TearFlags.TEAR_HOMING)
            elseif key=="mistral" and t.wind>=60 then p.TearFlags=p.TearFlags | TearFlags.TEAR_SPECTRAL end
        elseif flag==CacheFlag.CACHE_TEARCOLOR then
            p.TearColor=Color(def.color[1],def.color[2],def.color[3],1,0,0,0)
        end
    end)
    mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function(_,p)
        if not ready then return end
        local def=self:Find(p)
        if not def or p:IsDead() then return end
        local s,t=state(p,def),temp(p)
        if not s then return end
        if (def.key=="gpt" or def.key=="gemini") and p:AreControlsEnabled()
            and Input.IsActionTriggered(ButtonAction.ACTION_DROP,p.ControllerIndex) then
            s.mode=1-s.mode; refresh(p)
            Game():GetHUD():ShowItemText(def.name, def.key=="gpt"
                and (s.mode==0 and "Deliberate" or "Instant") or (s.mode==0 and "Prism" or "Echo"))
        elseif def.key=="grok" then
            local before=math.floor(t.momentum/15)
            t.momentum=math.max(0,math.min(150,t.momentum+(p.Velocity:Length()>0.5 and 1 or -3)))
            if before~=math.floor(t.momentum/15) then refresh(p) end
        elseif def.key=="mistral" then
            local before=t.wind>=60
            if p.Velocity:Length()>0.5 and p:GetFireDirection()~=Direction.NO_DIRECTION then
                t.wind=math.min(60,t.wind+1)
            else t.wind=0 end
            if before~=(t.wind>=60) then refresh(p) end

        end
    end)
    mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_,entity,_,flags)
        if not ready then return end
        local p=entity:ToPlayer()
        local def=p and self:Find(p)
        if not def then return end
        if (flags & DamageFlag.DAMAGE_FAKE)~=0 then return end
        local s=state(p,def)
        s.hit=true; s.chain=0; s.pages=math.max(0,s.pages-2)
        refresh(p)
    end,EntityType.ENTITY_PLAYER)
    mod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, function()
        if not ready then return end
        each(function(p,def,s)
            local key=roomKey()
            if p:IsDead() or s.awards[key] then return end
            s.awards[key]=true
            if def.key=="qwen" and not s.hit then s.chain=math.min(5,s.chain+1)
            elseif def.key=="kimi" and not s.hit then s.pages=math.min(6,s.pages+1)
            elseif def.key=="llama" then
                s.shares=(s.shares+1)%2
                if s.shares==0 then
                    for i=0,Game():GetNumPlayers()-1 do
                        local ally=Isaac.GetPlayer(i)
                        if not ally:IsDead() then ally:AddBlueFlies(2,ally.Position,nil) end
                    end
                end
            elseif def.key=="doubao" then
                s.meals=(s.meals+1)%3
                if s.meals==0 then
                    if p:CanPickRedHearts() then p:AddHearts(2) else p:AddBlueFlies(2,p.Position,nil) end
                end
            end
            refresh(p)
        end)
    end)
    mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_,_,_,p,flags)
        if not ready then return end
        local def=self:Find(p)
        if not def or def.key~="glm" then return end
        if (flags & UseFlag.USE_CARBATTERY)~=0 then return end
        local t=temp(p)
        local now=Game():GetFrameCount()
        if t.toolFrame==now then return end
        t.toolFrame=now
        local s=state(p,def); s.links=math.min(3,s.links+1); refresh(p)
    end)
    mod:AddCallback(ModCallbacks.MC_POST_RENDER, function()
        if not ready or not Game():GetHUD():IsVisible() then return end
        each(function(p,def,s)
            local i=tonumber(slot(p)) or 0
            local value="Hold MAP: dossier"
            if def.key=="gpt" then value=s.mode==0 and "Deliberate" or "Instant"
            elseif def.key=="gemini" then value=s.mode==0 and "Prism" or "Echo"
            elseif def.key=="grok" then value="Momentum "..math.floor(temp(p).momentum/15).."/10"
            elseif def.key=="qwen" then value="Chain "..s.chain.."/5"
            elseif def.key=="kimi" then value="Pages "..s.pages.."/6"
            elseif def.key=="glm" then value="Tools "..s.links.."/3"
            elseif def.key=="doubao" then value="Meal "..s.meals.."/3"
            elseif def.key=="llama" then value="Share "..s.shares.."/2"




            elseif def.key=="mistral" then value=temp(p).wind>=60 and "Tailwind" or "Wind "..temp(p).wind.."/60" end
            Isaac.RenderText(def.name..": "..value,50,Isaac.GetScreenHeight()-52-i*12,1,1,1,0.9)
        end)
    end)
end
return Roster
