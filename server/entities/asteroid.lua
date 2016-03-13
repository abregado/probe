local ast = {}

function ast.new(rx,ry,dist,speed,rot)
	local new_ast = {}
	new_ast.pivot = {}  
	new_ast.pivot.x = rx 
	new_ast.pivot.y = ry 
	new_ast.owner = "environment" 
	--speed in percent of circle per second
	new_ast.vel = speed or 1
	new_ast.rotation = rot or 0
	new_ast.orbit = dist
	new_ast.scannable = true
	new_ast.visible = true
	new_ast.entType = 'asteroid'
	
	
	new_ast.isDead = false
	new_ast.radius = math.random(2,8)
	
	local x,y = math.cos(0)*dist, math.sin(0)*dist
	new_ast.x,new_ast.y = x+rx,y+ry
	
	
	return new_ast
end

function ast.update(ast,ents,dt)
	--increase rotation
	local distance = math.pi*2/100*ast.vel*dt
	ast.rotation = ast.rotation + distance
	--recalculate x,y
	local x,y = math.cos(ast.rotation)*ast.orbit, math.sin(ast.rotation)*ast.orbit
	ast.x,ast.y = x+ast.pivot.x,y+ast.pivot.y
	--if outside bounds then reset rotation
	local d_to_centre = vl.dist(ast.x,ast.y,2000,2000)
	if d_to_centre > 5000 then
		ast.orbit = 1900+(math.random()*300)
		ast.vel = 0.025+(math.random()*0.025)
		ast.rotation = 0
	end
end

function ast.draw(ast)
	lg.setColor(color.asteroid)
	lg.circle("fill",ast.x,ast.y,ast.radius,5)
end

return ast
