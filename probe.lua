p = {}

local minAlpha = 65
local maxAlpha = 255



function p.new(owner,x,y,scanType)
    o = {}
    o.x = x
    o.y = y
    o.owner = owner
    
    o.entType="probe"
    
    --sensor variables THIS NEEDS A ARCHETYPE SYSTEM currently "range" and "long" work
    o.scanType = scanType
    if scanType == "range" then
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
    
    --these are set at each ping
    --[[o.detectedThickness = 0
    o.detectedRadius = 0
    o.detectedAngle = 0
    o.detectedDif = 0
    o.detectedRadiusOffset = 0
    o.detectedMax = 0
    o.detectedMin = 0]]
    
    o.target = nil
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
        probe.target = server.getNewTarget(probe)
        p.ping(probe)
        probe.battery = probe.battery - 1
    elseif complete and probe.battery == 0 then
        probe.isDead = true
        
    end
end


return p
