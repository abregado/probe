local game = {}

game.ents = {}
game.missiles = {}
game.scans = {}


local player = {x=0,y=0}
local tubes = {}
local entSpeed = 20

local probeTypes = {}
probeTypes[1] = {name="long",desc="Launch Long Range Probe",cost=5,ammo=10,maxAmmo=10,color={255,0,0}}
probeTypes[2] = {name="range",desc="Launch Precise Probe",cost=5,ammo=10,maxAmmo=10,color={255,0,0}}
probeTypes[3] = {name="torpedo",desc="Launch Active Torpedo",cost=5,ammo=2,maxAmmo=2,color={0,0,255}}
probeTypes[4] = {name="move",desc="Move your ship",cost=0,ammo=0,maxAmmo=0,color={0,255,0}}

local currentProbe = 1

local lastFrame = 0
local mustRedraw = false

local entsVisible = false
local nextFadeTime = 0

game.coverageMap = lg.newCanvas()
game.scanMap = lg.newCanvas()
game.tempCan = lg.newCanvas()
game.gridCan = lg.newCanvas()

function game.init()
    game.drawGrid()
end

function game.drawGrid()
    lg.setCanvas(game.gridCan)
    local x = 0
    local y = 0
    local grid = 128
    while x < lg.getWidth() do
        lg.setColor(color.grid)
        lg.line(x,0,x,lg.getHeight())
        x = x + grid
    end
    while y < lg.getHeight() do
        lg.setColor(color.grid)
        lg.line(0,y,lg.getWidth(),y)
        y = y + grid
    end
    lg.setCanvas()
end

function game.drawCoverage()
    lg.setColor(255,255,255,125)
    lg.draw(game.coverageMap)
    lg.setColor(255,255,255)
end

function game.addCoverage(probe)
    local tCan = lg.newCanvas()
    lg.setCanvas(tCan)
    lg.setColor(color.probeCoverage)
    lg.setBlendMode("alpha")
    lg.circle("fill",probe.x,probe.y,probe.radMax,50)
    lg.setLineWidth(5)
    lg.setBlendMode("subtract")
    lg.circle("fill",probe.x,probe.y,probe.radMin,50)
    lg.setBlendMode("alpha")
    lg.setLineWidth(1)
    lg.setColor(255,255,255)
    lg.setCanvas(game.coverageMap)
    lg.draw(tCan)
    lg.setCanvas()
end

function game.addRangeCircles(probe)
    lg.setColor(0,0,0)
    lg.setCanvas(game.coverageMap)
    lg.setLineWidth(1)
    lg.setBlendMode("subtract")
    lg.circle("line",probe.x,probe.y,probe.radMax,150)
    lg.circle("line",probe.x,probe.y,probe.radMin+3,150)
    lg.circle("line",probe.x,probe.y,probe.radMin,150)
    lg.setBlendMode("alpha")
    lg.setLineWidth(1)
    lg.setCanvas()
    
end

function game.redrawCoverage()
	lg.setCanvas(game.coverageMap)
    lg.clear()
	lg.setCanvas()
    for i,v in ipairs(game.ents) do
        if v.entType=="probe" then
            game.addCoverage(v)
        end
    end
    for i,v in ipairs(game.ents) do
        if v.entType=="probe" then
            game.addRangeCircles(v)
        end
    end
    
end

function game:draw()
    lg.setCanvas()
    lg.setColor(255,255,255)
    game.drawCoverage()
    lg.setColor(255,255,255,125)
    lg.draw(game.gridCan)
    
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
                local newScan = {x=v.x,y=v.y,tx=v.target.x,ty=v.target.y,range=v.radMax,accuracyD=v.accuracyD*v.target.scanMod,accuracyR=v.accuracyR*v.target.scanMod,rMin=v.radMin,rMax=v.radMax,alpha=v.alpha}
                client.drawScanResult(newScan,game.scanMap)
            end
        end
    end
    
    lg.setFont(fonts[1])
    
    
    --destination of playership
    local pship = client.playerPos.ship
    
    if client.playerPos.ship.isMoving then
        lg.setColor(color.path)
        lg.line(pship.x,pship.y,pship.tx,pship.ty)
        lg.circle("fill",pship.tx,pship.ty,5,6)
    end
    lg.setColor(color.weapons)
    
    lg.circle("fill",client.playerPos.ship.x,client.playerPos.ship.y,3,3)
    lg.circle("line",client.playerPos.ship.x,client.playerPos.ship.y,9,30)
    
    
    --currently selected probetype and ammo
    game.drawTubes(5,55)
    
    lg.setFont(fonts[2])
    lg.setColor(color.probe)
    lg.print(server.countSigs(client.ownerID),10,5)
    lg.setFont(fonts[1])
    lg.setColor(color.weapons)
    lg.print("Targets remaining",35,10)
    lg.print("Torpedoes Launched: "..score.torps,5,150)
    lg.print("Probes Launched: "..score.probes,5,170)
    
    game.drawWeapons(5,95)
    
    if DEBUG_MODE then
        for i,v in ipairs(server.ents) do
            lg.setColor(color.debug)
            lg.circle("fill",v.x,v.y,3,3)
            if v.canMove and v.isMoving then
                lg.circle("fill",v.tx,v.ty,2,3)
                lg.line(v.x,v.y,v.tx,v.ty)
            end
        end
    end
    
    
end

function game.drawTubes(x,y)
    local tw = 15
    local th = 30
    local gap = 5
    local tx,ty = x,y
    for i,v in ipairs(tubes) do
        lg.setColor(color.debug)
        lg.rectangle("fill",tx,ty,tw,th)
        lg.setColor(color.probe)
        local h = (th*v.v/5)
        lg.rectangle("fill",tx,ty,tw,h)
        tx=tx+tw+gap
    end
    
    lg.setFont(fonts[1])
    lg.setColor(color.weapons)
    lg.print("Tubes",tx+tw+gap,ty+5)
    
end

function game.drawWeapons(x,y)
    local tw = 32
    local th = 32
    local gap = 5
    local tx,ty = x,y
    for i,v in ipairs(probeTypes) do
        lg.setColor(v.color)
        lg.rectangle("fill",tx,ty,tw,th)
    
        if currentProbe == i then
            lg.setColor(255,255,255)
            lg.rectangle("line",tx,ty,tw,th)
    
            --draw white square around icon
        end
        tx=tx+tw+gap
    end
    
    lg.setFont(fonts[1])
    lg.setColor(color.weapons)
    lg.print("Command: Number keys to select",tx,ty)
    lg.print(probeTypes[currentProbe].desc,tx,ty+15)
    
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
	lg.setCanvas(game.coverageMap)
    lg.clear()
	lg.setCanvas()
    if from == state.menu then
        client.connect()
        tubes = {{v = 0},{v = 0},{v = 0},{v = 0}}
    elseif from == state.victory then
        server.init()
        client.connect()
        tubes = {{v = 0},{v = 0},{v = 0},{v = 0}}
    end
end

function game:leave()
    --sfx.theme[currentTheme]:stop()
end

function game:update(dt)
    mustRedraw = false
    game.ents,mustRedraw,client.playerPos.ship = server.requestUpdate(client.ownerID)
    --game.realEnts = server.ents
    if mustRedraw then
        game.redrawCoverage()
    end
    
    for i,v in ipairs(tubes) do
        if v.v >dt then
            v.v=v.v-dt
        elseif v.v < dt then
            v.v=0            
        end
    end
    
    if server.countSigs(client.ownerID) == 0 then
        gs.switch(state.victory)
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
    if button == 1 then
        --client.addMissile(client.ownerID,x,y,currentProbe)
        --table.insert(game.probes,probeLogic.new(x,y,"range"))
    elseif button == 2 and tube and currentProbe ~= 4 then
        client.addMissile(x,y,probeTypes[currentProbe].name)
        setTube(tube,probeTypes[currentProbe].cost)
    elseif button == 2 and currentProbe == 4 then
        client.givePlayerMovementCommand(x,y)
    
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
    elseif key == "4" then
        currentProbe = 4
    end
end

function game.drawScan(probes)
    lg.setCanvas(game.scanMap)
    lg.clear()
    lg.setColor(255,0,0)
    lg.setLineWidth(1)
    for i,probe in ipairs(probes) do
        lg.circle("fill",probe.x,probe.y,probe.detectedMax,100)
    end
    lg.setBlendMode("subtract")
    for i,probe in ipairs(probes) do
        lg.circle("fill",probe.x,probe.y,probe.detectedMin,100)
    end
    lg.setBlendMode("alpha")
    lg.setCanvas()
    lg.setColor(255,255,255,125)
    lg.draw(game.scanMap)
end


return game
