require('registry')
if DEBUG_MODE then
    require ('lovedebug')
end

local server = nil

function love.load()
    server = Server.new(4999,world)
    server:register_method("move",function(self,peer,data) methods.move(self,peer,data) end)
    server:register_method("respawn",function(self,peer,data) methods.respawn(self,peer,data) end)
    server:register_method("deploy",function(self,peer,data) methods.deploy(self,peer,data) end)
    server:register_method("refresh",function(self,peer,data) methods.refresh(self,peer,data) end)
    
    
    --test ships
	for i=1,7 do
	    local x,y = math.random(1500,2500),math.random(1500,2500)
		local newship = ship.new(x,y,"npc")
		world:addObject(newship)
	end
	
	for i=1,200 do
		local dist = 1900+(math.random()*300)
		local speed = 0.025+(math.random()*0.025)
		local rot = math.pi+(math.random()*math.pi*2/4*3)
		local ast = asteroid.new(200,3500,dist,speed,rot)
		
		table.insert(world.objects,ast)
	end
	
end

function love.quit()
	server:shutdown()
end

function love.update(dt)
	server:update()
	world:update(dt)
end

function love.draw()
	local obj_types = {}
	obj_types["ship"] = {0,255,0}
	obj_types["missile"] = {0,0,255}
	obj_types["probe"] = {255,0,0}
	obj_types["sig"] = {125,255,125}
	obj_types["asteroid"] = {0,255,255}
	obj_types["blast"] = {255,0,255}
	
	--basic drawing of all objects
	for i, obj in pairs(world.objects) do
		lg.setColor(obj_types[obj.entType] or {255,255,255})
		lg.circle("fill",obj.x,obj.y,3,5)
		if obj.isMoving then
			lg.line(obj.x,obj.y,obj.target.x,obj.target.y)
		end
		if obj.scan then
			lg.setColor(obj_types["asteroid"])
			lg.circle("fill",obj.scan.x,obj.scan.y,8,3)
		end
	end
	
	server:draw(0,0)
end


