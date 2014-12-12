local c = {}

local tempCan = lg.newCanvas()

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
    local minRad = dist-(dist*(sr.accuracy)/100)
    local maxRad = dist+(dist*(sr.accuracy)/100)
    local thick = maxRad-minRad
    local detectedThickness = thick
    local detectedRadius = dist
    local detectedRadiusOffset = 0
    local detectedMax = maxRad
    local detectedMin = minRad
    
    local ax,ay = sr.tx-sr.x, sr.ty-sr.y
    local vx,vy = vl.normalize(ax,ay)
    local x,y = vx*sr.rMax,vy*sr.rMax 
    local posRad = vl.angleTo(vx,vy)
    local x,y = math.cos(posRad)*maxRad, math.sin(posRad)*maxRad
    local leftOff = (math.pi*2)/100*(sr.accuracy/5)
    detectedAngle = posRad
    detectedDif = leftOff
    
    lg.setColor(color.probe[1],color.probe[2],color.probe[3],sr.alpha)
    lg.arc("fill",sr.x,sr.y,detectedMax,detectedAngle-detectedDif+circ,detectedAngle+detectedDif+circ,50)
    lg.setColor(color.white)
    lg.setBlendMode("subtractive")
    lg.circle("fill",sr.x,sr.y,detectedMin,100)
    lg.setBlendMode("alpha")
    lg.setColor(color.probe[1],color.probe[2],color.probe[3])
    local ang1 = detectedAngle+detectedDif+circ
    local ang2 = detectedAngle-detectedDif+circ

    lg.setColor(color.probe[1],color.probe[2],color.probe[3],sr.alpha)
    lg.setLineWidth(2)
    local x,y = math.cos(ang1)*detectedMax,math.sin(ang1)*detectedMax
    lg.line(sr.x,sr.y,sr.x+x,sr.y+y)
    local x,y = math.cos(ang2)*detectedMax,math.sin(ang2)*detectedMax
    lg.line(sr.x,sr.y,sr.x+x,sr.y+y)

    lg.setLineWidth(1)
    lg.circle("fill",sr.tx,sr.ty,10,6)
    
    --lg.setColor(color.debug)
    --lg.circle("fill",sr.x,sr.y,10,5)
    --lg.circle("fill",sr.tx,sr.ty,10,5)
    
    lg.setCanvas()
    lg.setColor(255,255,255,125)
    lg.draw(tempCan)
end

function c.drawProbeMarker(x,y)
    lg.setColor(color.probe[1],color.probe[2],color.probe[3])
    lg.circle("fill",x,y,5,3)
    lg.setColor(color.probe[1],color.probe[2],color.probe[3])
    lg.circle("line",x,y,15,30)
end

return c
