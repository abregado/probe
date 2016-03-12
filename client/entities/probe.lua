p = {}

local minAlpha = 65
local maxAlpha = 255

local lg = love.graphics

function p.new(owner,x,y,scanType)
    o = {}
    o.x = x
    o.y = y
    o.owner = owner
    o.scannable = false
    o.entType="probe"
    
    o.scanType = scanType
    if scanType == "sr_probe" then
        o.ranges = {
			max = 200,
			optimal = 150,
			min = 50
			}
        o.accuracies = {
			range = {min=0.5,max=1},
			angle = {min=0.5,max=3}
			}
        o.accuracyD = 30
        o.accuracyR = 2
        o.pingLength = 2
        o.battery = 10
    else
		o.ranges = {
			max = 600,
			optimal = 300,
			min = 150
			}
		o.accuracies = {
			range = {min=5,max=10},
			angle = {min=0.5,max=1}
			}
        o.accuracyD = 3
        o.accuracyR = 30
        o.pingLength = 6
        o.battery = 10
    end
    
    o.scan = nil
    o.sigType = "probe"
    
    o.alpha = maxAlpha
    o.pingRadius = o.radMin
    o.pingAng = 0
    o.pingTween = tween.new(o.pingLength,o,{alpha=minAlpha,pingRadius=o.radMax,pingAng=math.pi*2},'linear')
    
    return o
end

function p.findTarget(probe,ents)
    result = {target=nil,dist=probe.ranges.max+1}
    for i,v in ipairs(ents) do
        if v.owner == probe.owner then
            --dont detect probes
        elseif v.scannable then
            local dist = vl.dist(v.x,v.y,probe.x,probe.y)
            if  dist <= result.dist and dist > probe.ranges.min then
                result = {target=v,dist=dist}
            end
        end
    end
    return result.target
end

function p.ping(probe,ents)
	
	--get closest target
	local target = nil
	local distance = probe.ranges.max
	for i,ent in pairs(ents) do
		if ent.scannable then
			local dist = vl.dist(probe.x,probe.y,ent.x,ent.y)
			if dist < distance and dist > probe.ranges.min then
				target = ent
				distance = dist
			end
		end
	end
	
	if target then
		--generate scan results
		--store in probe
		probe.scan = p.create_scan(probe,target)
	else
		probe.scan = nil
	end
	--update tween for next ping
    probe.pingTween = tween.new(probe.pingLength,probe,{alpha=minAlpha,pingRadius=probe.radMax,pingAng=math.pi*2},'linear')
end

function p.update(probe,ents,dt)
    local complete = probe.pingTween:update(dt)
    
    if complete and probe.battery > 0 then
        p.ping(probe,ents)
        probe.battery = probe.battery - 1
    elseif complete and probe.battery == 0 then
        probe.isDead = true
        
    end
end

function p.findAccuracyAtRange(probe,range)
	local best_acc = 0.9
	local worst_acc = 0.1
	local mx = probe.ranges.max
	local op = probe.ranges.optimal
	local mn = probe.ranges.min
	
	if range > op  and range < mx then
		return 1-(range-op)/(mx-op)
	elseif range < op  and range > mn then
		return math.clamp(worst_acc,(range-mn)/(op-mn),best_acc)
	end
	return 0
end

function p.create_scan(probe,target)
    local tx = target.x - probe.x
    local ty = target.y - probe.y
    local circ = math.pi*2
    
    --apply random inaccuracy to target distance and angle
    
    --find distance to target
    local dist = vl.dist(tx,ty,0,0)
    
    --calculate inaccuracies at this range
    --local accuracy = p.findAccuracyAtRange(probe,dist)
    local accuracy = 0.95
    --apply inacuracy to distance
    local dist_offset_max = dist*((1-accuracy)*(probe.accuracies.range.max-probe.accuracies.range.min))
    local dist_offset_min = dist*((1-accuracy)*(probe.accuracies.range.min))
    local dist_offset = math.random(dist-dist_offset_max,dist+dist_offset_max)+math.random(-dist_offset_min,dist_offset_min)
    --find angle to target
    local angle = vl.angleTo(tx,ty)+circ
    --apply innacuracy to angle
    local angle_offset_max = angle*((1-accuracy)*(probe.accuracies.angle.max-probe.accuracies.angle.min))
    local angle_offset_min = angle*((1-accuracy)*probe.accuracies.angle.min)
    local angle_offset = math.random(angle-angle_offset_max,angle+angle_offset_max)+math.random(-angle_offset_min,angle_offset_min)
    
    local x,y = math.cos(angle_offset)*dist_offset, math.sin(angle_offset)*dist_offset
    
    return {dist=dist_offset,angle=angle_offset,x=x+probe.x,y=y+probe.y}
end

function p.draw_scan(probe)
	--local temp_canvas = lg.newCanvas()
    --lg.setCanvas(temp_canvas)
    local dist = probe.scan.dist
    local angle = probe.scan.angle
    
    local circ = math.pi*4
	--local accuracy = p.findAccuracyAtRange(probe,dist)
	local accuracy = 0.95
	local dist_offset_max = dist*((1-accuracy)*(probe.accuracies.range.max))
    local angle_offset_max = angle*((1-accuracy)*probe.accuracies.angle.max)
	
	local maxAng = probe.scan.angle+angle_offset_max+circ
	local minAng = probe.scan.angle-angle_offset_max+circ
	local maxDist = math.clamp(probe.ranges.min,probe.scan.dist+dist_offset_max,probe.ranges.max)
	local minDist = probe.scan.dist-dist_offset_max
	if minDist < tonumber(probe.ranges.min) then minDist = probe.ranges.min end

	
	lg.setColor(color.scan[1],color.scan[2],color.scan[3],probe.alpha)
	lg.setBlendMode("alpha")
	lg.arc('fill',"pie",probe.x,probe.y,maxDist,minAng,maxAng,50)
	lg.setColor(color.white)
	lg.setBlendMode("subtract")
	lg.circle('fill',probe.x,probe.y,minDist,50)
	lg.setBlendMode("alpha")
	
	--lg.setCanvas()
    --lg.setColor(255,255,255)
    --lg.draw(temp_canvas)
    
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
