se = {}

local speedMod = 200

function se.new(x,y,owner)
    o={}
    o.x,o.y=x,y
    o.origin = {x=x,y=y}
    o.isHuman = 1
    o.entType="ship"
    o.owner=owner or "npc"
    o.scanMod = 1
    o.scannable = true
    o.vel = 15
    
    if owner == "npc" or owner == "environment" then
        o.isHuman = false
        o.rx = 0
        o.ry = 0
        o.vel = 5
    end
    
    o.target = {x=x+1,y=y+1}
    o.delta = {x=0,y=0}
    
    o.isMoving = 1
    o.canMove = 1
    o.tubes = {{v = 0},{v = 0},{v = 0},{v = 0}}  
    
    return o
end

function se.update(sig,ents,dt)
    --update tubes
    for i,tube in pairs(sig.tubes) do
		if tube.v > 0 then
			tube.v = tube.v - dt
		end
		if tube.v < 0 then tube.v = 0 end
	end
    
    local arrived = false
    if sig.isMoving == 1 then
		local dx = sig.target.x-sig.x
		local dy = sig.target.y-sig.y
		local nx,ny = vl.normalize(dx,dy)
		nx = nx*sig.vel*dt
		ny = ny*sig.vel*dt
		local len = vl.len(nx,ny)
        local dist = vl.dist(sig.x,sig.y,sig.target.x,sig.target.y)
        if dist < len then
            sig.x,sig.y = sig.target.x,sig.target.y
            arrived=true
        else
            sig.x = sig.x+nx
            sig.y = sig.y+ny
        end
    end
    
    
    if arrived and not sig.isHuman then
        local rx = math.random(1000,3000)
        local ry = math.random(1000,3000)
        se.setNewDest(sig,rx,ry)
    elseif arrived and sig.isHuman then
        sig.isMoving = 0
    end
    
    return arrived
end



function se.setNewDest(sig,tx,ty)
    if sig.canMove ==1 then
        sig.target.x,sig.target.y = tx,ty
        sig.delta.x,sig.delta.y = vl.normalize(sig.target.x-sig.x,sig.target.y-sig.y)
        sig.isMoving = 1
    end
end


function se.draw(ship)
	lg.setColor(color.weapons)
	lg.circle("fill",ship.x,ship.y,3,30)
	lg.circle("line",ship.x,ship.y,9,30)
end

function se.countTubes(ship)
    local result = 0
    for i,v in pairs(ship.tubes) do
        if v.v==0 then
          result = result +1
        end
    end
    return result
end

function se.getEmptyTube(ship)
    for i,v in ipairs(ship.tubes) do
        if v.v==0 then
            return v
        end
    end
    return nil
end

function se.setTube(tube,value)
    for i,v in ipairs(ship.tubes) do
        if tube == v then
            v.v=value
        end
    end
end

function se.useTube(tube,cost)
    tube.v=cost
end

return se
