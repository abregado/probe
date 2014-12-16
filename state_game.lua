local game = {}

game.ents = {}
game.missiles = {}
game.scans = {}

local player = {x=0,y=0}
local tubes = {{v = 0},{v = 0},{v = 0},{v = 0}}
local entSpeed = 20

local probeTypes = {}
probeTypes[1] = {name="long",desc="Long Range Probe",cost=8}
probeTypes[2] = {name="torpedo",desc="Active Torpedo",cost=20}
probeTypes[3] = {name="range",desc="Precise Probe",cost=5}

local currentProbe = 1

local lastFrame = 0
local mustRedraw = false

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
    lg.setFont(fonts[1])
    
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
                local newScan = {x=v.x,y=v.y,tx=v.target.x,ty=v.target.y,accuracyD=v.accuracyD,accuracyR=v.accuracyR,rMin=v.radMin,rMax=v.radMax,alpha=v.alpha}
                client.drawScanResult(newScan,game.scanMap)
            end
        end
    end
    
    lg.setColor(color.weapons)
    lg.circle("fill",client.playerPos.x,client.playerPos.y,10,5)
    lg.circle("line",client.playerPos.x,client.playerPos.y,16,30)
    
    lg.setColor(color.probe) 
    lg.print("Click with the left and right mouse buttons to place probes, and try to locate the 6 objects",5,5)
    lg.print("Currently Selected Probe: "..probeTypes[currentProbe].desc,5,30)
    lg.print("Targets in Area: "..server.countSigs(client.ownerID),5,55)
    lg.print("Launch Tubes Available: "..countTubes(),5,80)
    
    
    
end

function countTubes()
    local result = 0
    for i,v in pairs(tubes) do
        if v.v==0 then
          result = result +1
        end
    end
    return result
end

function getEmptyTube()
    for i,v in ipairs(tubes) do
        if v.v==0 then
            return v
        end
    end
    return false
end

function setTube(tube,value)
    for i,v in ipairs(tubes) do
        if tube == v then
            v.v=value
        end
    end
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
        tubes = {{v = 0},{v = 0},{v = 0},{v = 0}}
    end
end

function game:leave()
    --sfx.theme[currentTheme]:stop()
end

function game:update(dt)
    mustRedraw = false
    game.ents,mustRedraw = server.requestUpdate(client.ownerID)
    --game.realEnts = server.ents
    if mustRedraw then
        client.redrawCoverage()
    end
    
    for i,v in ipairs(tubes) do
        if v.v >dt then
            v.v=v.v-dt
        elseif v.v < dt then
            v.v=0            
        end
    end
    
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
    local tube = getEmptyTube()
    if button == "l" then
        --client.addMissile(client.ownerID,x,y,currentProbe)
        --table.insert(game.probes,probeLogic.new(x,y,"range"))
    elseif button == "r" and tube then
        client.addMissile(client.ownerID,x,y,probeTypes[currentProbe].name)
        setTube(tube,probeTypes[currentProbe].cost)
        --table.insert(game.probes,probeLogic.new(x,y,"direction"))
    end
end

function game:keypressed(key, isrepeat)
    if key == " " then
        entsVisible = not entsVisible
    elseif key == "escape" then
        gs.switch(state.menu)
    elseif key == "1" then
        currentProbe = 1
    elseif key == "2" then
        currentProbe = 2
    elseif key == "3" then
        currentProbe = 3
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
