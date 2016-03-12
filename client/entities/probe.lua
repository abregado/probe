p = {}

local minAlpha = 65
local maxAlpha = 255

local lg = love.graphics

local circ = math.pi*2

function p.new(owner,x,y,scanType)
    o = {}
    o.x = x
    o.y = y
    o.owner = owner
    o.scannable = false
    o.entType="probe"
    
    o.scanType = scanType
    o.visType = "point"
    if scanType == "sr_probe" then
        o.ranges = {
			max = 200,
			optimal = 150,
			min = 50
			}
		--range is number of pixels the scan can be off
		--angle is percent of a full circle it can be off
        o.accuracies = {
			range = 5,
			angle = 15
			}
		o.visType = "arc"
        o.pingLength = 0.5
        o.battery = 30
    else
		o.ranges = {
			max = 600,
			optimal = 300,
			min = 150
			}
		o.accuracies = {
			range = 200,
			angle = 2
			}
        o.visType = "lighthouse"
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
	local x_off = math.random(-30,30)
	local y_off = math.random(-30,30)
	
    return {x=target.x+x_off,y=target.y+y_off,dist=10,angle=1}
end

function p.create_scan(probe,target)
    local tx = target.x - probe.x
    local ty = target.y - probe.y
    
    --find angle to target
    local angle = vl.angleTo(tx,ty)
    --find distance to target
    local dist = vl.dist(tx,ty,0,0)
    
    
    --apply random inaccuracy to target distance and angle
    local angle_variation = circ/100*probe.accuracies.angle
	local dist_variation = probe.accuracies.range

    
    --find new random distance
    local dist_offset = dist+(math.random()*dist_variation*2)-dist_variation
    --apply innacuracy to angle
    local angle_offset = angle+(math.random()*angle_variation*2)-angle_variation
    
    local x,y = math.cos(angle_offset)*dist_offset, math.sin(angle_offset)*dist_offset
    
    return {dist=dist_offset,angle=angle_offset,x=x+probe.x,y=y+probe.y,ang_var=angle_variation,dist_var=dist_variation}
end

function p.draw_scan(probe)
	local x,y = probe.x,probe.y
	local dist = probe.scan.dist
	local dist_var = probe.scan.dist_var
	local angle = probe.scan.angle
	local angle_var = probe.scan.ang_var
	lg.setColor(color.scan)
		
	
	if probe.visType == "arc" then
		lg.setLineWidth(dist_var*2)
		lg.arc("line","open",x,y,dist,angle-angle_var+circ,angle+angle_var+circ,50)
	elseif probe.visType == "lighthouse" then
		lg.arc("fill","pie",x,y,dist+dist_var,angle-angle_var+circ,angle+angle_var+circ,50)
	elseif probe.visType == "circle" then
		x,y = probe.scan.x,probe.scan.y
		lg.circle("fill",x,y,dist_var,4)
	end
	
	lg.setLineWidth(1)
	lg.setColor(255,255,255)
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
