local game = {}

game.ents = {}
game.scans = {}

local player = {x=0,y=0}

local entSpeed = 20

local lastFrame = 0

local entsVisible = false

game.coverageMap = lg.newCanvas()
game.scanMap = lg.newCanvas()
game.tempCan = lg.newCanvas()

function game.init()
end

function game:draw()
    probeLogic.drawCoverage()
    --probeLogic.drawScan(game.probes)
    
    

    
    for i,v in ipairs(game.probes) do
        --probeLogic.draw(v)
        if v.target then
            local newScan = {x=v.x,y=v.y,tx=v.target.x,ty=v.target.y,accuracy=v.accuracy,rMin=v.radMin,rMax=v.radMax,alpha=v.alpha}
            client.drawScanResult(newScan)
        end
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
    
    for i,v in ipairs(game.probes) do
        client.drawProbeMarker(v.x,v.y)
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

function game.drawScan(probes)
    scanMap:clear()
    lg.setCanvas(game.scanMap)
    lg.setColor(255,0,0)
    lg.setLineWidth(1)
    for i,probe in ipairs(probes) do
        lg.circle("fill",probe.x,probe.y,probe.detectedMax,100)
    end
    lg.setBlendMode("subtractive")
    for i,probe in ipairs(probes) do
        lg.circle("fill",probe.x,probe.y,probe.detectedMin,100)
    end
    lg.setBlendMode("alpha")
    lg.setCanvas()
    lg.setColor(255,255,255,125)
    lg.draw(game.scanMap)
end


return game
