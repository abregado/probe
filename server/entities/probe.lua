p = {}

local minAlpha = 65
local maxAlpha = 255

local lg = love.graphics

function p.new(owner,x,y,scanType)
    o = {}
    o.x = x
    o.y = y
    o.owner = owner
    
    o.entType="probe"
    
    o.scanType = scanType
    if scanType == "sr_probe" then
        o.radMax = 200
        o.radMin = 50
        o.accuracyD = 30
        o.accuracyR = 2
        o.pingLength = 1
        o.battery = 30
    else
        o.radMax = 600
        o.radMin = 100
        o.accuracyD = 3
        o.accuracyR = 30
        o.pingLength = 3
        o.battery = 10
    end
    
    o.target = nil
    o.scan = nil
    o.sigType = "probe"
    
    o.alpha = maxAlpha
    o.pingRadius = o.radMin
    o.pingAng = 0
    o.pingTween = tween.new(o.pingLength,o,{alpha=minAlpha,pingRadius=o.radMax,pingAng=math.pi*2},'linear')
    
    return o
end

function p.findTarget(probe,ents)
    result = {target=nil,dist=probe.radMax+1}
    for i,v in ipairs(ents) do
        if v.owner == probe.owner then
            --dont detect probes
        elseif v.entType=="sig" or v.entType=="asteroid" or v.entType == "debris" then
            local dist = vl.dist(v.x,v.y,probe.x,probe.y)
            if  dist <= result.dist and dist > probe.radMin then
                result = {target=v,dist=dist}
            end
        end
    end
    return result.target
end

function p.aquireTarget(probe,target)
    if target then
        probe.target = target
    end
end



function p.loseTarget(probe)
    probe.target = nil
end

function p.ping(probe)
    probe.alpha = maxAlpha
    probe.pingRadius = probe.radMin
    probe.pingAng = 0
    probe.pingTween = tween.new(probe.pingLength,probe,{alpha=minAlpha,pingRadius=probe.radMax,pingAng=math.pi*2},'linear')
end

function p.update(probe,ents,dt)
    local complete = probe.pingTween:update(dt)
    
    if complete and probe.battery > 0 then
        --probe.target = server.getNewTarget(probe)
        --p.ping(probe)
        probe.battery = probe.battery - 1
    elseif complete and probe.battery == 0 then
        probe.isDead = true
        
    end
end

function p.draw_scan(ent)
    local temp_canvas = lg.newCanvas()
    lg.setCanvas(temp_canvas)
    local sr = ent.scan
    local circ = math.pi*2
    
    local dist = vl.dist(sr.tx,sr.ty,sr.x,sr.y)
    
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
    lg.setBlendMode("subtract")
    lg.circle("fill",sr.x,sr.y,detectedMin,100)
    lg.setBlendMode("alpha")
    lg.setColor(color.probe[1],color.probe[2],color.probe[3])
    local ang1 = detectedAngle+detectedDif+circ
    local ang2 = detectedAngle-detectedDif+circ

    lg.setCanvas()
    lg.setColor(255,255,255,125)
    lg.draw(temp_canvas)
end

function p.draw(probe)
	local variant = probe.scanType
	local x,y = probe.x,probe.y
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


return p
