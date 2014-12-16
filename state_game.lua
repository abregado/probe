local game = {}

game.ents = {}
game.missiles = {}
game.scans = {}

local player = {x=0,y=0}

local entSpeed = 20

local currentProbe = "long"

local lastFrame = 0

local entsVisible = false
local nextFadeTime = 0

game.coverageMap = lg.newCanvas()
game.scanMap = lg.newCanvas()
game.tempCan = lg.newCanvas()

function game.init()
end

function game:draw()
    lg.setCanvas()
    probeLogic.drawCoverage()
    
    --[[lg.setBlendMode("additive")
    lg.draw(game.scanMap)
    lg.setBlendMode("alpha")]]
    
    for i,v in ipairs(game.ents) do
        if v.entType == "sig" and entsVisible then
            client.drawEnt(v)
        elseif v.entType ~= "sig" then 
            client.drawEnt(v)
        end
    end
    
    for i,v in ipairs(game.ents) do
        if v.entType=="probe" then
            if v.target then
                local newScan = {x=v.x,y=v.y,tx=v.target.x,ty=v.target.y,accuracy=v.accuracy,rMin=v.radMin,rMax=v.radMax,alpha=v.alpha}
                client.drawScanResult(newScan,game.scanMap)
            end
        end
    end
    
    lg.setColor(color.weapons)
    lg.circle("fill",client.playerPos.x,client.playerPos.y,10,5)
    lg.circle("line",client.playerPos.x,client.playerPos.y,16,30)
    
    lg.setColor(color.probe) 
    lg.print("Click with the left and right mouse buttons to place probes, and try to locate the 6 objects",5,5)
    
    
end

function replacementCanvas(canvas)
    local temp = lg.newCanvas()
    lg.setCanvas(temp)
    lg.setColor(255,255,255,254)
    lg.draw(canvas)
    lg.setCanvas()
    lg.setColor(color.white)
    return temp
end

function game:enter(from)
    lg.setBackgroundColor(color.gameBG)
    if from == state.menu then
        client.connect()
    end
end

function game:leave()
    --sfx.theme[currentTheme]:stop()
end

function game:update(dt)
    game.ents = server.requestUpdate()
    game.realEnts = server.ents
    --[[local t = os.time()
    if t > nextFadeTime then
        game.scanMap = replacementCanvas(game.scanMap)
        nextFadeTime = t+0.1
    end]]
end



-- equiv to onTouchEnded
function game:mousereleased(x, y, button)

end

-- equiv to onTouchBegan
function game:mousepressed(x, y, button)
    if button == "l" then
        client.addMissile(client.ownerID,x,y,currentProbe)
        --table.insert(game.probes,probeLogic.new(x,y,"range"))
    elseif button == "r" then
        client.addMissile(client.ownerID,x,y,"torpedo")
        --table.insert(game.probes,probeLogic.new(x,y,"direction"))
    end
end

function game:keypressed(key, isrepeat)
    if key == " " then
        entsVisible = not entsVisible
    elseif key == "escape" then
        gs.switch(state.menu)
    elseif key == "1" then
        currentProbe = "range"
    elseif key == "2" then
        currentProbe = "long"
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
