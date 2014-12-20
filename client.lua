local c = {}

c.ownerID = "unconnected"
c.playerPos = {x=0,y=0,active=false,ship=nil}

local tempCan = lg.newCanvas()

function c.connect()
    local player = server.methods.connect()
    if player then
        c.playerPos = {x=player.x,y=player.y,active=true}
        c.ownerID = player.owner
        print("player ",c.ownerID," connected to server")
    else
        print("server denied join request")
    end
        
end

function c.drawEnt(ent)
    if ent.entType == "blast" then
        blast.draw(ent)
    elseif ent.entType == "probe" then
        c.drawProbeMarker(ent.x,ent.y,ent.scanType)
    elseif ent.entType == "missile" then
        missile.draw(ent)
    elseif ent.entType == "sig" then
        lg.setColor(color.ent)
        lg.circle("fill",ent.x,ent.y,5,10)
    end
end

function c.drawProbe(probe)
    lg.setColor(color.alpha)
    lg.circle("line",probe.x,probe.y,probe.pingRadius,100)
    lg.circle("line",probe.x,probe.y,probe.pingRadius+3,100)
    lg.circle("line",probe.x,probe.y,probe.pingRadius+5,100)
    

    lg.setColor(color.probe)
    lg.circle("fill",probe.x,probe.y,5,3)
    lg.setColor(color.probe)
    lg.circle("line",probe.x,probe.y,15,30)
end

function c.drawScanResult(sr)
    tempCan:clear()
    lg.setCanvas(tempCan)
    local circ = math.pi*2
    --sr variables
    --x,y,tx,ty,accuracy
    
    local dist = vl.dist(sr.tx,sr.ty,sr.x,sr.y)
    
        --math.randomseed(probe.seed)
    local minRad = dist-(dist*(sr.accuracyD)/100)
    local maxRad = dist+(dist*(sr.accuracyD)/100)
    local thick = maxRad-minRad
    local detectedThickness = thick
    local detectedRadius = dist
    local detectedRadiusOffset = 0
    local detectedMax = maxRad
    if sr.range < detectedMax then detectedMax = sr.range end
    local detectedMin = minRad
    
    local ax,ay = sr.tx-sr.x, sr.ty-sr.y
    local vx,vy = vl.normalize(ax,ay)
    local x,y = vx*sr.rMax,vy*sr.rMax 
    local posRad = vl.angleTo(vx,vy)
    local x,y = math.cos(posRad)*maxRad, math.sin(posRad)*maxRad
    local leftOff = (math.pi*2)/100*(sr.accuracyR)
    detectedAngle = posRad
    detectedDif = leftOff
    
    lg.setColor(color.scan[1],color.scan[2],color.scan[3],sr.alpha)
    lg.arc("fill",sr.x,sr.y,detectedMax,detectedAngle-detectedDif+circ,detectedAngle+detectedDif+circ,50)
    lg.setColor(color.white)
    lg.setBlendMode("subtractive")
    lg.circle("fill",sr.x,sr.y,detectedMin,100)
    lg.setBlendMode("alpha")
    lg.setColor(color.probe[1],color.probe[2],color.probe[3])
    local ang1 = detectedAngle+detectedDif+circ
    local ang2 = detectedAngle-detectedDif+circ

    

    --lg.setLineWidth(1)
    --lg.circle("fill",sr.tx,sr.ty,10,6)
    
    --lg.setColor(color.debug)
    --lg.circle("fill",sr.x,sr.y,10,5)
    --lg.circle("fill",sr.tx,sr.ty,10,5)
    
    lg.setCanvas()
    lg.setColor(255,255,255,125)
    lg.draw(tempCan)
end

function c.drawProbeMarker(x,y,variant)
    if variant == "long" then
        lg.setLineWidth(1)
        lg.setColor(color.probe[1],color.probe[2],color.probe[3])
        lg.circle("fill",x,y,4,5)
        lg.circle("line",x,y,7,30)
    else
        lg.setLineWidth(1)
        lg.setColor(color.probe[1],color.probe[2],color.probe[3])
        lg.circle("fill",x,y,2,3)
        lg.circle("line",x,y,5,30)
    end

end

function c.givePlayerMovementCommand(tx,ty)
    server.methods.playerShipMoveCommand(c.ownerID,tx,ty)
end

function c.addMissile(tx,ty,payload)
    local mr = server.methods.addMissile(c.ownerID,tx,ty,payload)
    if mr then
        --table.insert(c.missiles,missile)
        print("server permitted new missile")
    else
        print("server denied missile request")
    end
end

return c
