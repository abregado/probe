local World = require 'world'
local methods = require 'methods'

local game = {}
game.client = nil
game.world = {}
game.username = 'default-username'
game.password = 'default-password'
game.player = nil
game.selected_weapon = 1
game.buttons = {}
game.buttons[1] = false
game.buttons[2] = false

local probeTypes = {}



function game.init()
	game.world = World.new()
	game.client = Client.new(4999,'localhost:4999/',game.world,100,game.username,game.password)
	--register deploy command
	game.client:register_command('deploy',function(self,data) methods.deploy(self,data) end)
	--register move command
	game.client:register_command('move',function(self,data) methods.move(self,data) end)
	--register respawn command
	game.client:register_command('respawn',function(self,data) methods.respawn(self,data) end)
	
	game.grid_map = game.createGrid()
	game.scan_map = lg.newCanvas()
	game.coverage_map = lg.newCanvas()
	
	player_cam = Camera(2000,2000)
	
	probeTypes = {
		{name="lr_probe",desc="Launch Long Range Probe",cost=5,ammo=10,maxAmmo=10,color={255,0,0},ranges={min=400,max=1600,color=color.scan}},
		{name="sr_probe",desc="Launch Precise Probe",cost=5,ammo=10,maxAmmo=10,color={255,0,0},ranges={min=100,max=300,color=color.scan}},
		{name="torpedo",desc="Launch Active Torpedo",cost=5,ammo=2,maxAmmo=2,color={0,0,255},ranges={min=15,max=15,color=color.weapons}},
		{name="examine",desc="Examine Object",cost=5,ammo=2,maxAmmo=2,color={255,0,255}}
	}
end

function game:enter(from)
	game.username = string.random(10,'%l%d')
	game.password = string.random(10,'%l%d')
	game.client:login_details(game.username,game.password)
	game.client:connect()
	lg.setBackgroundColor(color.gameBG)
	
	game.grid_map = lg.newCanvas(4000,4000)
	lg.setCanvas(game.grid_map)
	lg.setColor(255,255,255)
	game.drawGrid()
	lg.setColor(255,255,255)
	lg.setCanvas()
	
	game.scan_map = lg.newCanvas(4000,4000)
end

function game.frustrum(screen,x,y)
	local x,y = tonumber(x),tonumber(y)
	if x > screen.x and x < screen.x+screen.w and y > screen.y and y < screen.y+screen.h then
		return true
	end
	return false
end

function game:draw()
	local screen = {}
	screen.x,screen.y = player_cam:worldCoords(0,0)
	screen.w,screen.h = lg.getWidth(),lg.getHeight()
	
	
	
	--drawCoverage
	--game.drawCoverage()
	lg.setCanvas(game.scan_map)
	lg.clear()
	lg.setBlendMode("alpha")
	for i,ent in pairs(game.world.objects) do
		if ent.entType == "probe" and ent.scan and game.frustrum(screen,ent.scan.x,ent.scan.y) then
			probe.draw_scan(ent)
		end
	end
	lg.setCanvas()
	
	player_cam:attach()
	lg.setBlendMode("alpha")
	lg.setColor(255,255,255)
	lg.draw(game.grid_map)
	lg.draw(game.scan_map)
	lg.setLineWidth(1)
	
	--draw grid
	--game.drawGrid()
	
	--set fonts to default small
	lg.setFont(fonts[1])
	--draw objects from game.world
	for i,ent in pairs(game.world.objects) do
		game.drawEnt(ent)
	end
	
	
	
	if game.player then 
		--draw player ship and movement ui
		game.drawPlayer()
		lg.circle("line",game.player.x,game.player.y,13,50)	
	else
		
	end
	
	local mx,my = love.mouse.getPosition()
	mx,my = player_cam:worldCoords(mx,my)
		
	if game.buttons[2] and game.selected_weapon == 4 then	
		local closest = World.findClosestObject(game.world,mx,my)
		if closest then
			lg.setColor(0,255,255)
			local angle = vl.angleTo(mx-closest.x,my-closest.y)
			local x,y = math.cos(angle)*25, math.sin(angle)*25
    
			lg.circle("line",closest.x,closest.y,25,30)
			lg.line(mx,my,closest.x+x,closest.y+y)
			lg.print(closest.entType,closest.x+25,closest.y-25)
			
		end
	elseif game.buttons[2] and game.selected_weapon < 4 then
		local weap = probeTypes[game.selected_weapon]
		lg.setColor(weap.color[1],weap.color[2],weap.color[3],100)
		lg.circle("line",mx,my,weap.ranges.min,50)
		lg.circle("line",mx,my,weap.ranges.max,50)
		lg.circle("line",mx,my,weap.ranges.max+3,50)
		lg.setColor(255,255,255)
	end
	
	player_cam:detach()
	
	if game.player then 
		--draw tubeUI
		game.drawTubeUI(5,5)
		--draw weaponUI
		game.drawWeaponUI(5,45)
		
		if game.world.count then
			lg.setColor(color.white)
			lg.setFont(fonts[2])
			lg.print("Stealth signatures in area: "..game.world.count,5,85)
		end
	else
		lg.setColor(color.weapons)
		lg.rectangle("fill",0,lg.getHeight()/2-40,lg.getWidth(),80)
		lg.setColor(color.black)
		lg.rectangle("fill",0,lg.getHeight()/2-30,lg.getWidth(),60)
		lg.setColor(color.white)
		local text = "You have no ship in this sector, press SPACE to warp in"
		local texth = fonts[2]:getHeight(text)
		local textw = fonts[2]:getWidth(text)
		lg.setFont(fonts[2])
		lg.print(text,(lg.getWidth()/2)-(textw/2),(lg.getHeight()/2)-(texth/2))
	end
	

end

function game:update(dt)
	local processed = game.client:update()
	
	--find player ship (object that is owned by player)
	game.player = game:findPlayer()
	if game.player then
		player_cam:lookAt(game.player.x,game.player.y)
	end
	--if no playership then defeat
	--if game.player == nil then gs.switch(state_defeat) end
	
	if processed then
		--redrawCoverageMap
		--game.redrawCoverage()
	end
	
	self.client:send_command('refresh',{method='refresh'})
end

function game:leave()
	game.client:disconnect()
end

function game:mousepressed(x,y,button)
	local x,y = player_cam:worldCoords(x,y)
	if button == 1 and game.buttons[2] == false then
		--giveMoveCommand
		self.client:send_command('move',{method='move',target={x=x,y=y}})
	elseif button == 1 and game.buttons[2] then
		game.buttons[2] = false
	elseif button == 2 then
		game.buttons[2] = true
	end
end

function game:mousereleased(x,y,button)
	local x,y = player_cam:worldCoords(x,y)
	if game.buttons[2] then
		if button == 2 and game.selected_weapon < 4 then
			--giveDeploy command
			self.client:send_command('deploy',{method='deploy',ammo=probeTypes[game.selected_weapon].name,target={x=x,y=y}})
			game.buttons[2] = false
		end
	elseif button == 2 then
		game.buttons[2] = false
	end
		
	
end

function game:keypressed(key)
    if key == "space" then
		--request a server refresh or respawn if no ship
		self.client:send_command('respawn',{method='respawn'})
	elseif key == 'c' then
		self.client:connect()
    elseif key == "escape" then
        gs.switch(state.menu)
    elseif key == "1" then
        game.selected_weapon = 1
    elseif key == "2" then
        game.selected_weapon = 2
    elseif key == "3" then
        game.selected_weapon = 3
    elseif key == "4" then
        game.selected_weapon = 4
    end
end

function game.drawTubeUI(x,y)
    local tw = 15
    local th = 30
    local gap = 5
    local tx,ty = x,y
    for i,v in ipairs(game.player.tubes) do
        lg.setColor(color.debug)
        lg.rectangle("fill",tx,ty,tw,th)
        lg.setColor(color.probe)
        local h = (th*v.v/5)
        lg.rectangle("fill",tx,ty,tw,h)
        tx=tx+tw+gap
    end
    
    lg.setFont(fonts[1])
    lg.setColor(color.weapons)
    lg.print("Tubes",tx+tw+gap,ty+5)    
end

function game.drawWeaponUI(x,y)
    local tw = 32
    local th = 32
    local gap = 5
    local tx,ty = x,y
    for i,v in ipairs(probeTypes) do
        lg.setColor(v.color)
        lg.rectangle("fill",tx,ty,tw,th)
    
        if game.selected_weapon == i then
            lg.setColor(255,255,255)
            lg.rectangle("line",tx,ty,tw,th)
    
            --draw white square around icon
        end
        tx=tx+tw+gap
    end
    
    lg.setFont(fonts[1])
    lg.setColor(color.weapons)
    lg.print("Command: Number keys to select",tx,ty)
    lg.print(probeTypes[game.selected_weapon].desc,tx,ty+15)
    
end

function game.createGrid()
	local grid_canvas = lg.newCanvas()
	lg.setLineWidth(2)
    lg.setCanvas(grid_canvas)
    local x = -1250
    local y = -1250
    local grid = 128
    while x < 1250 do
        lg.setColor(color.grid)
        lg.line(x,-1250,x,1250)
        x = x + grid
    end
    while y < 1250 do
        lg.setColor(color.grid)
        lg.line(-1250,y,1250,y)
        y = y + grid
    end
    lg.setCanvas()
    lg.setLineWidth(1)
    return grid_canvas
end

function game:findPlayer()
	for i,object in pairs(self.world.objects) do
		if object.owner == self.client.username and object.entType == "ship" then
			return object
		end
	end
	return nil
end

function game.redrawCoverage()
	lg.setCanvas(game.coverage_map)
    lg.clear()
	for i,ent in ipairs(game.world.objects) do
        if ent.entType=="probe" then
            game.addCoverage(ent)
        end
    end
    for i,ent in ipairs(game.world.objects) do
        if ent.entType=="probe" then
            game.addRangeCircles(ent)
        end
    end
    lg.setCanvas()
    return canvas
end

function game.addCoverage(probe)
    local tCan = lg.newCanvas()
    lg.setCanvas(tCan)
    lg.setColor(color.probeCoverage)
    lg.setBlendMode("alpha")
    lg.circle("fill",probe.x,probe.y,probe.ranges.max,50)
    lg.setLineWidth(5)
    lg.setBlendMode("subtract")
    lg.circle("fill",probe.x,probe.y,probe.ranges.min,50)
    lg.setBlendMode("alpha")
    lg.setLineWidth(1)
    lg.setColor(255,255,255)
    lg.setCanvas(game.coverage_map)
    lg.draw(tCan)
    lg.setCanvas()
end

function game.addRangeCircles(probe)
    lg.setColor(0,0,0)
    lg.setCanvas(game.coverage_map)
    lg.setLineWidth(1)
    lg.setBlendMode("subtract")
    lg.circle("line",probe.x,probe.y,probe.ranges.max,150)
    lg.circle("line",probe.x,probe.y,probe.ranges.min+3,150)
    lg.circle("line",probe.x,probe.y,probe.ranges.min,150)
    lg.setBlendMode("alpha")
    lg.setLineWidth(1)
    lg.setCanvas()
end

function game.drawCoverage()
    lg.setColor(255,255,255,125)
    lg.draw(game.coverage_map)
    lg.setColor(255,255,255)
end

function game.drawGrid()
	lg.setColor(color.grid)
	lg.setLineWidth(3)
	lg.circle('line',2000,2000,10,30)
	for i=1,30 do
		lg.circle('line',2000,2000,i*128,30*i)
	end
	
	local chunk = math.pi/16
	for i=1,32 do
		local x,y = math.cos(chunk*i)*3900, math.sin(chunk*i)*3900
		lg.line(2000,2000,x+2000,y+2000)
	end
	
	for i=1,30 do
		lg.setLineWidth(32)
		lg.setColor(color.black)
		lg.circle('line',2000,2000,64+(i*128),30*i)
	end

	for i=1,32 do
		local x,y = math.cos((chunk*i)+(chunk/2))*3000, math.sin((chunk*i)+(chunk/2))*3000
		lg.line(2000,2000,x+2000,y+2000)
	end
	
	lg.setLineWidth(3)
	lg.setColor(color.black)
	lg.circle('fill',2000,2000,120,60)
	lg.setColor(color.grid)
	lg.circle('line',2000,2000,10,30)

	lg.setLineWidth(1)
end

function game.drawEnt(ent)
    if ent.entType == "blast" then
        blast.draw(ent)
    elseif ent.entType == "probe" then
        probe.draw(ent)
    elseif ent.entType == "ship" then
        ship.draw(ent)
    elseif ent.entType == "missile" then
        missile.draw(ent)
    elseif ent.entType == "asteroid" then
        asteroid.draw(ent)
    else
		--unknown entType so draw a white circle
		lg.setColor(255,255,255)
		lg.circle("line",ent.x,ent.y,3,5)
    end
end

function game.drawPlayer()
	local player = game.player
	if player.isMoving == '1' then
        lg.setColor(color.debug)
        lg.line(player.x,player.y,player.target.x,player.target.y)
        lg.circle("fill",player.target.x,player.target.y,5,6)
    end
    lg.setColor(color.weapons)
    
    --lg.circle("fill",player.x,player.y,5,3)
    --lg.circle("line",player.x,player.y,11,30)
end

return game
