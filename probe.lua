p = {}

local minAlpha = 65
local maxAlpha = 255




function p.new(x,y,scanType)
    o = {}
    o.x = x
    o.y = y
    
    --sensor variables THIS NEEDS A ARCHETYPE SYSTEM
    o.scanType = scanType
    if scanType == "range" then
        o.radMax = 200
        o.radMin = 10
        o.accuracy = 15
        o.pingLength = 1
    else
        o.radMax = 600
        o.radMin = 100
        o.accuracy = 30
        o.pingLength = 3
    end
    
    --these are set at each ping
    o.detectedThickness = 0
    o.detectedRadius = 0
    o.detectedAngle = 0
    o.detectedDif = 0
    o.detectedRadiusOffset = 0
    o.detectedMax = 0
    o.detectedMin = 0
    
    o.target = nil
    o.sigType = "probe"
    
    o.alpha = maxAlpha
    o.pingRadius = o.radMin
    o.pingAng = 0
    o.pingTween = tween.new(o.pingLength,o,{alpha=minAlpha,pingRadius=o.radMax,pingAng=math.pi*2},'linear')
    
    lg.setColor(255,0,0)
    lg.setCanvas(state.game.coverageMap)
    lg.circle("fill",o.x,o.y,o.radMax,50)
    lg.setCanvas()
    
    return o
end

function p.drawCoverage()
    lg.setColor(255,255,255,30)
    lg.draw(state.game.coverageMap)
    lg.setColor(255,255,255)
end

function p.draw(probe)
    tempCan:clear()
    lg.setCanvas(tempCan)
    local circ = math.pi*2
    
    


    if probe.target then
        lg.setColor(color.probe[1],color.probe[2],color.probe[3])
        local dist = vl.dist(probe.x,probe.y,probe.target.x,probe.target.y)
        --lg.circle("line",probe.x,probe.y,dist,100)
        --if dist > probe.pingRadius then dist = probe.pingRadius end
        --lg.circle("line",probe.x,probe.y,probe.detectedRadius,100)
        
    --elseif probe.target and probe.scanType == "direction" then
        lg.setColor(color.probe[1],color.probe[2],color.probe[3],probe.alpha)
        lg.arc("fill",probe.x,probe.y,probe.detectedMax,probe.detectedAngle-probe.detectedDif+circ,probe.detectedAngle+probe.detectedDif+circ,50)
        --lg.arc("fill",x,y,rad,ang1,ang2,segs)
        lg.setColor(color.white)
        lg.setBlendMode("subtractive")
        lg.circle("fill",probe.x,probe.y,probe.detectedMin,100)
        lg.setBlendMode("alpha")
        lg.setColor(color.probe[1],color.probe[2],color.probe[3])
        local ang1 = probe.detectedAngle+probe.detectedDif+circ
        local ang2 = probe.detectedAngle-probe.detectedDif+circ
        
        lg.setColor(color.probe[1],color.probe[2],color.probe[3],probe.alpha)
        lg.setLineWidth(2)
        local x,y = math.cos(ang1)*probe.detectedMax,math.sin(ang1)*probe.detectedMax
        lg.line(probe.x,probe.y,probe.x+x,probe.y+y)
        local x,y = math.cos(ang2)*probe.detectedMax,math.sin(ang2)*probe.detectedMax
        lg.line(probe.x,probe.y,probe.x+x,probe.y+y)
        
        lg.setLineWidth(1)
        lg.circle("fill",probe.target.x,probe.target.y,probe.target.sig,6)
        
        
        
    end
    
    lg.setColor(color.alpha)
    lg.circle("line",probe.x,probe.y,probe.pingRadius,100)
    lg.circle("line",probe.x,probe.y,probe.pingRadius+3,100)
    lg.circle("line",probe.x,probe.y,probe.pingRadius+5,100)
    
    lg.setColor(color.probe[1],color.probe[2],color.probe[3])
    lg.circle("fill",probe.x,probe.y,5,3)
    lg.setColor(color.probe[1],color.probe[2],color.probe[3])
    lg.circle("line",probe.x,probe.y,15,30)
    
    lg.setLineWidth(1)
    lg.setCanvas()
    lg.setColor(255,255,255,minAlpha)
    lg.draw(tempCan)
end



function p.findTarget(probe,ents)
    result = {target=nil,dist=probe.radMax+1}
    for i,v in ipairs(ents) do
        local dist = vl.dist(v.x,v.y,probe.x,probe.y)
        if  dist <= result.dist and dist > probe.radMin then
            result = {target=v,dist=dist}
        end
    end
    return result.target
    --[[if result.target then
        p.aquireTarget(probe,result.target)
        return (result.target)
    else
        p.loseTarget(probe)
        return false
    end]]
end

function p.aquireTarget(probe,target)
    if target then
        --[[local dist = vl.dist(target.x,target.y,probe.x,probe.y)
        --math.randomseed(probe.seed)
        local minRad = dist-(dist*(probe.accuracy)/100)
        local maxRad = dist+(dist*(probe.accuracy)/100)
        local thick = maxRad-minRad
        probe.detectedThickness = thick
        probe.detectedRadius = dist
        probe.detectedRadiusOffset = 0
        probe.detectedMax = maxRad
        probe.detectedMin = minRad
        
        local ax,ay = target.x-probe.x, target.y-probe.y
        local vx,vy = vl.normalize(ax,ay)
        local x,y = vx*probe.radMax,vy*probe.radMax 
        local posRad = vl.angleTo(vx,vy)
        local x,y = math.cos(posRad)*probe.radMax, math.sin(posRad)*probe.radMax
        local leftOff = (math.pi*2)/100*(probe.accuracy/5)
        probe.detectedAngle = posRad
        probe.detectedDif = leftOff]]
        
        
        probe.target = target
    end
end



function p.loseTarget(probe)
    probe.target = nil
    --[[probe.detectedThickness = 0
    probe.detectedRadius = 0
    probe.detectedRadiusOffset = 0
    probe.detectedMax = 0
    probe.detectedMin = 0]]
end

function p.ping(probe)
    probe.alpha = maxAlpha
    probe.pingRadius = probe.radMin
    probe.pingAng = 0
    probe.pingTween = tween.new(probe.pingLength,probe,{alpha=minAlpha,pingRadius=probe.radMax,pingAng=math.pi*2},'linear')
end

function p.update(probe,ents,dt)
    local complete = probe.pingTween:update(dt)
    
    if complete then
        probe.target = server.getNewTarget(probe)
        p.ping(probe)
    end
end

return p
