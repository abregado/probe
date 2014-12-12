local game = {}


game.probes = {}
game.ents = {}
game.realEnts = {}
game.missiles = {}


local player = {x=0,y=0}

local entSpeed = 20

local lastFrame = 0

local entsVisible = false

function game.init()
    game.probes = {}
    game.ents = {}
    game.missiles = {}
end

function game:draw()
    probeLogic.drawCoverage()
    --probeLogic.drawScan(game.probes)
    
    

    
    for i,v in ipairs(game.probes) do
        probeLogic.draw(v)
    end
    
    if entsVisible then
        for i,v in ipairs(game.ents) do
            lg.setColor(color.ent)
            lg.circle("fill",v.x,v.y,5,10)
        end
    end
    
    for i,v in ipairs(game.missiles) do
        lg.setColor(color.weapons)
        lg.circle("fill",v.x,v.y,5,10)
    end
    
    lg.setColor(color.weapons)
    lg.circle("fill",player.x,player.y,10,5)
    lg.circle("line",player.x,player.y,16,30)
    
    lg.setColor(color.probe)
    lg.print("Click with the left and right mouse buttons to place probes, and try to locate the 6 objects",5,5)
    
end


function game:enter(from)
    lg.setBackgroundColor(color.gameBG)
    if from == state.menu then

    end
end

function game:leave()
    --sfx.theme[currentTheme]:stop()
end

function game:update(dt)
    game.ents,game.probes,game.missiles = server.requestUpdate()
    game.realEnts = server.ents
end



-- equiv to onTouchEnded
function game:mousereleased(x, y, button)

end

-- equiv to onTouchBegan
function game:mousepressed(x, y, button)
    if button == "l" then
        table.insert(game.probes,probeLogic.new(x,y,"range"))
    elseif button == "r" then
        table.insert(game.probes,probeLogic.new(x,y,"direction"))
    end
end

function game:keypressed(key, isrepeat)
    if key == " " then
        entsVisible = not entsVisible
    elseif key == "escape" then
        gs.switch(state.menu)
    end
end


return game
