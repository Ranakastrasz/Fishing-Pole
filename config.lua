
if not config then
    config = {}
end
--config.Debug = true
config.tickRate = 4-- Logic runs each time this many ticks pass
config.ticksPerSecond = 60 -- absolute constant, but I have no idea how to get this from factorio itself.
config.secondsPerTick = config.tickRate/config.ticksPerSecond -- To avoid division operations in a loop

config.impulse = 1.0 / config.ticksPerSecond
config.pullRadius = 2.5
config.pickupRadius = 0.5

offset = 5
config.offset =
{
    [0] = {x =  0,y = -offset}, -- Needs const multiplier.
    [2] = {x =  offset,y =  0},
    [4] = {x =  0,y =  offset},
    [6] = {x = -offset,y =  0}
}