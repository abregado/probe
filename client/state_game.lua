local World = require 'world'
local methods = require 'methods'

local game = {}
game.client = nil
game.world = {}
game.username = 'default-username'
game.password = 'default-password'
game.player = nil
game.selected_weapon = 1

local probeTypes = {
	{name="long",desc="Launch Long Range Probe",cost=5,ammo=10,maxAmmo=10,color={255,0,0}},
	{name="range",desc="Launch Precise Probe",cost=5,ammo=10,maxAmmo=10,color={255,0,0}},
	{name="torpedo",desc="Launch Active Torpedo",cost=5,ammo=2,maxAmmo=2,color={0,0,255}}
}


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
end

function game:enter(from,username,password)
	game.username = username or 'default-username2'
	game.password = password or 'default-password2'
	game.client:login_details(game.username,game.password)
	game.client:connect()
	lg.setBackgroundColor(color.gameBG)
end

function game:draw()
	--drawCoverage
	game.drawCoverage()
	--draw grid
	game.drawGrid()
	--set fonts to default small
	lg.setFont(fonts[1])
	--draw objects from game.world
	for i,ent in pairs(game.world.objects) do
		game.drawEnt(ent)
	end
	
	for i,ent in pairs(game.world.objects) do
		if ent.entType == "probe" then
			probe.draw_scan(ent)
		end
	end
	
	
	if game.player then 
		--draw player ship and movement ui
		game.drawPlayer()
		lg.circle("line",game.player.x,game.player.y,13,50)
		--draw tubeUI
		game.drawTubeUI(5,55)
		--draw weaponUI
		game.drawWeaponUI(5,95)
	end
	
end

function game:update(dt)
	local processed = game.client:update()
	
	--find player ship (object that is owned by player)
	game.player = game:findPlayer()
	--if no playership then defeat
	--if game.player == nil then gs.switch(state_defeat) end
	
	if processed then
		--redrawCoverageMap
		game.redrawCoverage()
	end
	
	self.client:send_command('refresh',{method='refresh'})
end

function game:leave()
	game.client:disconnect()
end

function game:mousepressed(x,y,button)
	if button == 1 then
		--giveMoveCommand
		self.client:send_command('move',{method='move',target={x=x,y=y}})
	elseif button == 2 then
		--giveDeploy command
		self.client:send_command('deploy',{method='deploy',ammo='torpedo',target={x=x,y=y}})
	end
end

function game:keypressed(key)
    if key == "space" then
		--request a server refresh or respawn if no ship
		if not game.player then
			self.client:send_command('respawn',{method='respawn'})
		end
	elseif key == 'c' then
		self.client:connect()
    elseif key == "escape" then
        gs.switch(state.menu)
    elseif key == "1" then
        currentProbe = 1
    elseif key == "2" then
        currentProbe = 2
    elseif key == "3" then
        currentProbe = 3
    elseif key == "4" then
        currentProbe = 4
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
    lg.setCanvas(grid_canvas)
    local x = 0
    local y = 0
    local grid = 128
    while x < lg.getWidth() do
        lg.setColor(color.grid)
        lg.line(x,0,x,lg.getHeight())
        x = x + grid
    end
    while y < lg.getHeight() do
        lg.setColor(color.grid)
        lg.line(0,y,lg.getWidth(),y)
        y = y + grid
    end
    lg.setCanvas()
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
    lg.circle("fill",probe.x,probe.y,probe.radMax,50)
    lg.setLineWidth(5)
    lg.setBlendMode("subtract")
    lg.circle("fill",probe.x,probe.y,probe.radMin,50)
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
    lg.circle("line",probe.x,probe.y,probe.radMax,150)
    lg.circle("line",probe.x,probe.y,probe.radMin+3,150)
    lg.circle("line",probe.x,probe.y,probe.radMin,150)
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
    lg.setColor(255,255,255,125)
    lg.draw(game.grid_map)
    lg.setColor(255,255,255)
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
