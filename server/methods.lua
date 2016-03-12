require "enet"

local m = {}

--[[function m:send_update(peer,data)
	self:msg("sending refreshed game data")
	local update = {
		method = 'refresh',
		data = self.gameObject
		}
	peer:send(serialize(update))
end]]

function m:refresh(peer,data)
	local method = (data.method == 'refresh')
	local username = data.username
	local password = data.password
	local id = peer:connect_id()
	local user = self.users[id]
	
	if method and user and username == user.username and password == user.password then 
		--find player ship
		local objects = world:findOwnedObjects(username,"ship")
		if #objects > 0 then
			local player = objects[1]
			--create a subset of world and send it
			local sub_world = World:new()
			for i,obj in pairs(world.objects) do
				if obj.owner == username or obj.visible then
					table.insert(sub_world.objects,obj)
				end
			end
			local update = {
				method = 'refresh',
				data = sub_world
				}
			peer:send(serialize(update))
			return true
		else
			self:msg("cant send refresh to player with no ship")
			return false
		end
	else
		--something was missing from request
	end
	self:msg("could not process malformed refresh command")
	return false
end


--deploy method handler
function m:deploy(peer,data)
	local method = (data.method == 'deploy')
	local username = data.username
	local password = data.password
	local id = peer:connect_id()
	local user = self.users[id]
	local target = {}
	target.x = data.target.x
	target.y = data.target.y
	local ammo = data.ammo
	
	if method and user and username == user.username and password == user.password and ammo and target.x and target.y then 
		--find player ship
		local objects = world:findOwnedObjects(username,"ship")
		if #objects > 0 then			
			local player = objects[1]
			--check free tube
			local tube = ship.getEmptyTube(player)
			if not tube then self:msg("no free tubes for launch requested by "..username) return false end
			
			
			--create payload
			local payload = nil
			local tube_heat = 5
			if ammo == "torpedo" then 
				payload = blast.new(target.x,target.y)
			else 
				payload = probe.new(username,target.x,target.y,ammo)
			end 
			
			ship.useTube(tube,tube_heat)
			
			--create missile
			local new_missile = missile.new(username,player.x,player.y,target.x,target.y,payload)
			world:addObject(new_missile)
			self:msg(ammo.." deployment requested by "..username)
			return true
		else
			self:msg("no ship found for "..username)
			return false
		end
		
	end
	self:msg("could not process malformed deploy command")
	return false
end

--move method handler
function m:move(peer,data)
	local method = (data.method == 'move')
	local username = data.username
	local password = data.password
	local id = peer:connect_id()
	local user = self.users[id]
	local target = {}
	target.x = data.target.x
	target.y = data.target.y
	
	if method and user and username == user.username and password == user.password and target.x and target.y then 
		--find player ship
		local objects = world:findOwnedObjects(username,"ship")
		if #objects > 0 then
			local player = objects[1]
			--set ship destination 
			ship.setNewDest(player,target.x,target.y)
			self:msg("move requested by "..username)
			return true
		else
			self:msg("no ship found for "..username)
			return false
		end
		
	end
	self:msg("could not process malformed move command")
	return false
end

--respawn method handler
function m:respawn(peer,data)
	local method = (data.method == 'respawn')
	local username = data.username
	local password = data.password
	local id = peer:connect_id()
	local user = self.users[id]
	
	if method and user and username == user.username and password == user.password then 
		--check if player already has a ship
		local owned_objects = world:findOwnedObjects(username,"ship")
		local player = owned_objects[1]
		if not player then
			--spawn player ship
			local x,y = math.random(1500,2500),math.random(1500,2500)
			local newship = ship.new(x,y,username)
			world:addObject(newship)
			self:msg("respawned player "..username)
			return true
		else
			self:msg("player "..username.." already had a ship")
			return false
		end
	end
	self:msg("could not process malformed respawn command")
	return false
end


return m
