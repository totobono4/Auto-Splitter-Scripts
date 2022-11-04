-- Spacegulls auto-splitter
-- file: Spacegulls-light.lua
-- author: totobono4
-- git: https://github.com/totobono4/Auto-Splitter-Scripts

-- Starts on start pressed.
-- Splits on entering save rooms.
-- Ends on touching the 5th save button.

-- LiveSplit function from trysdyn: https://github.com/trysdyn/bizhawk-speedrun-lua
local function init_livesplit()
    pipe_handle = io.open("//./pipe/LiveSplit", 'a')

    if not pipe_handle then
        error("\nFailed to open LiveSplit named pipe!\n" ..
              "Please make sure LiveSplit is running and is at least 1.7, " ..
              "then load this script again")
    end

    pipe_handle:write("reset\r\n")
    pipe_handle:flush()

    return pipe_handle
end

press_start = 0x244 -- start pressed
x_save_coords = 0x47B -- x coord in save
y_save_coords = 0x47C -- y coord in save
x_room_coords = 0x5E -- x coord on map
y_room_coords = 0x5F -- y coord on map

started = false -- the rum has started
finished = false -- the run has finished

save = 1 -- saves passed
saves = {
    {10, 11},
    {6, 11},
    {6, 9},
    {10, 8}
} -- saves coordinates
nbSaves = 4 -- number of saves

ends = {10, 7} -- end coordinates

local function start()
    local start_pressed = memory.readbyte(press_start)

    if not started and start_pressed == 1 then
        started = true
        finished = false
        save = 1
        return true
    end
    return false
end

local function reset()
    local start_pressed = memory.readbyte(press_start)

    if started and start_pressed == 0 then
        started = false
        finished = false
        save = 1
        return true
    end
    return false
end

local function split()
    local x_save_coord = memory.readbyte(x_save_coords)
    local y_save_coord = memory.readbyte(y_save_coords)
    local x_room_coord = memory.readbyte(x_room_coords)
    local y_room_coord = memory.readbyte(y_room_coords)

    if save <= nbSaves and x_room_coord == saves[save][1] and y_room_coord == saves[save][2] then
        save = save + 1
        return true
    end

    if not finished and x_save_coord == ends[1] and y_save_coord == ends[2] then
        finished = true
        return true
    end

    return false
end

pipe_handle = init_livesplit()

memory.usememorydomain("RAM")

while true do
    if start() then
        print("Timer starts!")
        pipe_handle:write("starttimer\r\n")
        pipe_handle:flush()
    end

    if reset() then
        print("Timer resets!")
        pipe_handle:write("reset\r\n")
        pipe_handle:flush()
    end

    if split() then
        print("Do a split roll!!")
        pipe_handle:write("split\r\n")
        pipe_handle:flush()
    end

    emu.frameadvance()
end
