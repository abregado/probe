m = {}

function m.new(owner,x,y,tx,ty,payload)
    o = {}
    o.owner=owner
    o.target = {}
    o.x,o.y,o.target.x,o.target.y = x,y,tx,ty
    o.delta = {}
    o.delta.x,o.delta.y = vl.normalize(tx-x,ty-y)
    o.isDead = false
    o.entType="missile"
    
	o.accel = 1000
	o.vel = 0
	o.visible = 1
    o.payload = payload
    o.maxvel = 100000000
    
    return o
end

function m.update(missile,ents,dt)
    missile.vel = missile.vel+(missile.accel*dt)
    local arrived = false
    if missile.vel > missile.maxvel then missile.vel = missile.maxvel end
    local nx = missile.delta.x*missile.vel*dt
    local ny = missile.delta.y*missile.vel*dt
    local len = vl.len(nx,ny)
    local dist = vl.dist(missile.x,missile.y,missile.target.x,missile.target.y)
    if dist < len then
        missile.x,missile.y = missile.target.x,missile.target.y
        arrived=true
    else
        missile.x = missile.x+nx
        missile.y = missile.y+ny
    end
    
    if arrived and missile.payload then
		print("deploying payload")
		world:addObject(missile.payload)
		missile.isDead = true
	elseif arrived then
		missile.isDead = true
	end
	
    
    return arrived    
end

function m.draw(v)
    if v.visible == 1 then
        lg.setColor(color.weapons)
    else
        lg.setColor(color.probe)
    end
    lg.setLineWidth(1)
    lg.circle("fill",v.x,v.y,2,10)
    lg.line(v.x,v.y,v.x-(v.delta.x*v.vel/100),v.y-(v.delta.y*v.vel/100))
    --lg.line(v.x,v.y,v.tx,v.ty)
end

return m
