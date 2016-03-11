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
    
    
    --test ships
	for i=1,3 do
	    local x,y = math.random(1000),math.random(1000)
		local newship = ship.new(x,y,"npc")
		world:addObject(newship)
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
	end
	
	server:draw(0,0)
end


