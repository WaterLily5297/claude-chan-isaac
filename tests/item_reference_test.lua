-- docs/ITEMS.md must match the current item XML and EID text.
local root = arg[1]
arg = { root, "--check" }
dofile(root .. "/tools/item_reference.lua")
