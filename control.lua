require "defines"
require "config"

--[[
    This module handles the gameloop alteration, detecting fish entities wandering around or in front of fishing poles, and replacing them with fish items.

]]--

--[[
    
]]--

function removeKeys(myTable,toRemove)
    local n=#myTable

    for x=1,n do
        if toRemove[x] then
            myTable[x]=nil
            --globalPrint("["..x.."] = nil")
        end
    end

    local y=0
    for x=1,n do
        if myTable[x]~=nil then
            y=y+1
            myTable[y]=myTable[x]
            --globalPrint("["..y.."] = ["..x.."]")
        end
    end
    for x=y+1,n do
        myTable[x]=nil
        --globalPrint("["..x.."] = nil")
    end
    return myTable
end

function addPos(p1,p2)
  if not p1.x then
    error("Invalid position", 2)
  end
  if p2 and not p2.x then
    error("Invalid position 2", 2)
  end
  local p2 = p2 or {x=0,y=0}
  return {x=p1.x+p2.x, y=p1.y+p2.y}
end
function subPos(p1,p2)
  if not p1.x then
    error("Invalid position", 2)
  end
  if p2 and not p2.x then
    error("Invalid position 2", 2)
  end
  local p2 = p2 or {x=0,y=0}
  return {x=p1.x-p2.x, y=p1.y-p2.y}
end

function verifySettings()
	if (config.tickRate < 0) then
		config.tickRate = 0
		throwError("Tick rate must be >= 0.")
	end
end

function globalPrint(msg)
  local players = game.players
  if config.Debug then
      for x=1, #players do
        players[x].print(msg)
      end
  end
end

script.on_init(onload)
script.on_load(onload)

function onload()
	if (global.loaded == nil) then
		global.loaded = true
        
		verifySettings()
	end
end

function onCreate(event)
    local pole = event.created_entity
    
    if pole.name == "fishing-pole" then
        if global.pole == nil then
            global.pole = {}
        end
        table.insert(global.pole, pole)
    end
end

function tick()
    local toRemove = {}
	if (game.tick % config.tickRate) == 0 then
        --globalPrint("tick")
        if global.pole ~= nil then
            --globalPrint("hasPole")
            for k,pole in pairs(global.pole) do
                if pole.valid then 
                    
                    
                    local surface = pole.surface
                    local pos = pole.position
                    pos = addPos(pos,config.offset[pole.direction])
                    
                    --globalPrint("energy = "..pole.energy)
                    if pole.energy > 0 then -- Needs better energy gauge. ~350.something is cap, why? value in prototype is 0.4kw.
                    
                        --if pole.held_stack == nil then -- Invalid check, figure out why
                        
                            local tileName = surface.get_tile(pos.x, pos.y).name
                            
                            if ((tileName == "water") or (tileName == "deepwater")) then -- validate target location
                                --[[local existingItem
                                for _, entity in ipairs(surface.find_entities_filtered
                                    {
                                        area =
                                        {
                                            {pos.x-32,pos.y-32},
                                            {pos.x+32,pos.y+32}
                                        },
                                        name="item-on-ground"
                                    }
                                )do
                                    
                                end]]--
                                if true then -- Validate no existing fish item
                                    -- Validate fish in range
                                    -- For each, break on first.
                                    local fish
                                    for _, entity in ipairs(surface.find_entities_filtered
                                        {
                                            area =
                                            {
                                                {pos.x-config.pullRadius ,pos.y-config.pullRadius },
                                                {pos.x+config.pullRadius ,pos.y+config.pullRadius }
                                            },
                                            name="fish"
                                        }
                                    )do
                                        fish = entity
                                        --globalPrint("fish")
                                        break
                                    end
                                    
                                    
                                    if fish ~= nil then
                                        local fishDifference = subPos(fish.position,pos)
                                        --globalPrint("pos ("..pos.x..","..pos.y..")")
                                        --globalPrint("fish ("..fish.position.x..","..fish.position.y..")")
                                        --globalPrint("Dif ("..fishDifference.x..","..fishDifference.y..")")
                                        if (math.abs(fishDifference.x) < config.pickupRadius) and (math.abs(fishDifference.y) < config.pickupRadius) then
                                            --globalPrint("fish+")
                                            fish.destroy()
                                            surface.create_entity{name = "item-on-ground", position=pos, stack = {name="raw-fish"}}
                                        else
                                            local newPos = fish.position
                                            if fishDifference.x > 0 then
                                                newPos.x = math.max(fish.position.x-config.impulse,pos.x)
                                            else
                                                newPos.x = math.min(fish.position.x+config.impulse,pos.x)
                                            end
                                            
                                            if fishDifference.y > 0 then
                                                newPos.y = math.max(fish.position.y-config.impulse,pos.y)
                                            else
                                                newPos.y = math.min(fish.position.y+config.impulse,pos.y)
                                            end
                                            fish.teleport(newPos)
                                        end
                                    else
                                        -- No Fish :(
                                    end
                                else
                                    -- No existing fish item
                                end
                            else
                                -- Not at water
                            end
                        --else
                            -- Has fish or otherwise already
                        --end
                    else
                        
                        -- Not enough energy
                    end
                else
                    -- Doesn't exist, flag for removal.
                    table.insert(toRemove, k)
                    --globalPrint("Removed "..k)
                end
            end
        end
        if next(toRemove) then
                    --globalPrint("Removed ~")
            global.pole = removeKeys(global.pole,toRemove)
        end
    end
end

script.on_event(defines.events.on_built_entity, onCreate)
script.on_event(defines.events.on_robot_built_entity, onCreate)

script.on_event(defines.events.on_tick,tick)