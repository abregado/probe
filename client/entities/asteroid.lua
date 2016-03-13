local ast = {}

function ast.new(rx,ry,dist,speed)
	local new_ast = {}
	new_ast.pivot = {}  
	new_ast.pivot.x = rx 
	new_ast.pivot.y = ry 
	new_ast.owner = "environment" 
	--speed in percent of circle per second
	new_ast.vel = speed 
	new_ast.rotation = 0
	new_ast.orbit = dist
	new_ast.scannable = true
	new_ast.visible = true
	new_ast.entType = 'asteroid'
	
	
	new_ast.isDead = false
	new_ast.radius = math.random(5,25)
	
	local x,y = math.cos(0)*dist, math.sin(0)*dist
	new_ast.x,new_ast.y = x+rx,y+ry
	
	
	return new_ast
end

function ast.update(ast,dt)
	--increase rotation
	local distance = math.pi*2/ast.speed*dt
	ast.rotation = ast.rotation + distance
	--recalculate x,y
	local x,y = math.cos(ast.rotation)*ast.orbit, math.sin(ast.rotation)*ast.orbit
	x,y = x+ast.pivot.x,y+ast.pivot.y
	--if outside bounds then reset rotation
	if x < 0 or x > 4000 or y < 0 or y > 4000 then
		ast.rotation = 0
		ast.orbit = math.random(2900,3100)
	end
end

function ast.draw(ast)
	lg.setColor(color.asteroid)
	lg.circle("fill",ast.x,ast.y,ast.radius,10)
end

return ast
