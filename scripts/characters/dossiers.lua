-- Full illustrations are shown deliberately in safe rooms while MAP is held.
local C=include("scripts.constants")
local Roster=include("scripts.characters.model_roster")
local Dossiers={}
local originals={
    {id=C.Player.CLAUDE_CHAN,key="claude",name="Claude-chan",title="Careful reasoning",
     lines={"Watch your usage and account risk.","Ban Hammer controls a crowded room."}},
    {id=C.Player.CLAUDE_CHAN_B,key="claude_b",name="Tainted Claude-chan",title="Weekly allowance",
     lines={"A limited weekly budget per floor.","Banked Reset restores the allowance."}},
    {id=C.Player.DEEPSEEK_CHAN,key="deepseek",name="DeepSeek-chan",title="Rice First",
     lines={"Tap/release DROP: spend one rice bowl.","Two-second meal: full Thought, +0.15 speed.","Earn a bowl every two combat clears."}},
    {id=C.Player.DEEPSEEK_CHAN_B,key="deepseek_b",name="Tainted DeepSeek-chan",title="Wenfeng / Wengu",
     lines={"Paid volleys add two half-damage forks.","Valley: cost 2, recovers when not firing.","Peak: cost 4. Tap/release DROP: Forks On/Saving."}},
    {id=C.Player.GPT_CHAN_B,key="gpt_b",name="Tainted GPT-chan",title="Reset Watcher",
     lines={"Tap/release DROP: Standard / Full Send (1.5x).","Full Send costs 1 of 80 Credits per attack.","3 clears bank a Tibo reset: DROP refills."}},
}
function Dossiers:Init(mod)
    local ready=false
    local sprites={}
    mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED,function() ready=true end)
    mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT,function() ready=false; sprites={} end)
    mod:AddCallback(ModCallbacks.MC_POST_RENDER,function()
        if not ready or not Game():GetHUD():IsVisible() or not Game():GetRoom():IsClear() then return end
        for i=0,Game():GetNumPlayers()-1 do
            local p=Isaac.GetPlayer(i)
            -- The default co-op display remains readable: show one requested card at a time.
            if Input.IsActionPressed(ButtonAction.ACTION_MAP,p.ControllerIndex) then
                local def=Roster:Find(p)
                if not def then
                    for _,entry in ipairs(originals) do
                        if entry.id>=0 and entry.id==p:GetPlayerType() then def=entry; break end
                    end
                end
                if def then
                    if not sprites[def.key] then
                        local sprite=Sprite()
                        sprite:Load("gfx/ui/dossiers/"..def.key..".anm2",true)
                        sprite:Play("Idle",true)
                        sprites[def.key]=sprite
                    end
                    local width,height=Isaac.GetScreenWidth(),Isaac.GetScreenHeight()
                    local sprite=sprites[def.key]
                    local scale=math.min(0.42,(height-48)/576)
                    sprite.Scale=Vector(scale,scale)
                    sprite:Render(Vector(width-100,height/2),Vector.Zero,Vector.Zero)
                    Isaac.RenderText(def.name,50,70,1,0.9,0.7,1)
                    Isaac.RenderText(def.title,50,86,1,1,1,1)
                    for n,line in ipairs(def.lines) do Isaac.RenderText(line,50,98+n*12,1,1,1,1) end
                    Isaac.RenderText("Release MAP to close",50,158,0.8,0.8,0.8,1)
                    Isaac.RenderText("Design: ZipZipPipe | Non-commercial fan art",50,174,0.7,0.7,0.7,1)
                    if def.key=="deepseek" or def.key=="deepseek_b" then
                        Isaac.RenderText("Whale girl: Shangshan Wuxing | CC BY-NC-SA 4.0",50,186,0.7,0.7,0.7,1)
                    end
                    return
                end
            end
        end
    end)
end
return Dossiers
