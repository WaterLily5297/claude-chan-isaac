-- Which doors an item may force open or unlock without breaking the run.
-- Special exits use negative grid indices: Mega Satan (key pieces), Boss Rush
-- and Hush (timers), the Blue Womb, the Mausoleum/Mines/Downpour secret exits,
-- the devil/angel room and the I AM ERROR room. Opening those by force skips
-- their native requirements, so only doors into ordinary rooms of this floor
-- qualify. Secret rooms stay behind their bombable walls.
local DoorSafety = {}

local SECRET = {}
if RoomType then
    for _, name in ipairs({ "ROOM_SECRET", "ROOM_SUPERSECRET", "ROOM_ULTRASECRET" }) do
        if RoomType[name] then SECRET[RoomType[name]] = true end
    end
end

function DoorSafety.Ordinary(door)
    if not door then return false end
    local index = door.TargetRoomIndex
    if type(index) ~= "number" or index < 0 then return false end
    return not SECRET[door.TargetRoomType]
end

return DoorSafety
