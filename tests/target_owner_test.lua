-- A familiar's contact damage is not a player's own targeted attack.
-- These entity-shaped fixtures model attribution, not native damage timing.
local root = arg[1]
EntityType = { ENTITY_PLAYER=1, ENTITY_TEAR=2, ENTITY_FAMILIAR=3,
    ENTITY_BOMB=4, ENTITY_LASER=7, ENTITY_KNIFE=8 }
local Tools = dofile(root.."/scripts/characters/target_tools.lua")
local function entity(kind, spawner, parent)
    return {Type=kind, SpawnerEntity=spawner, Parent=parent,
        ToPlayer=function(self) if self.Type==EntityType.ENTITY_PLAYER then return self end end}
end
local p, partner = entity(1), entity(1)
assert(Tools.Owner(nil)==nil)
assert(Tools.Owner(p)==p and Tools.Owner(partner)==partner)
for _,kind in ipairs({2,4,7,8}) do
    assert(Tools.Owner(entity(kind,p))==p, "native player attacks keep their owner")
    assert(Tools.Owner(entity(kind,nil,partner))==partner, "parent-only native attacks keep their owner")
end
local contact = entity(3,p)
assert(Tools.Owner(contact)==nil, "familiar contact must not become player damage through its spawner")
assert(Tools.Owner(entity(3,nil,p))==nil, "familiar contact must not become player damage through its parent")
for _,kind in ipairs({2,4,7,8}) do
    assert(Tools.Owner(entity(kind,contact,p))==nil,
        "familiar-spawned attacks must not fall through to a player parent")
end
assert(Tools.Owner(entity(2,partner,p))==partner, "the actual spawner wins over another player's parent")
assert(Tools.Owner(entity(2))==nil, "unowned shots remain unowned")
print("PASS targeted attack attribution: native owners, co-op, familiar contact and familiar shots")
