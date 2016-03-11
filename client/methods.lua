require 'enet'

local m = {}

--deploy
function m.deploy(self,data)
	if not data then self:msg("no data for deploy") return false end
	local method = (data.method == 'deploy')
	local ammo = data.ammo
	local target = {}
	target.x = data.target.x
	target.y = data.target.y
	
	if method and ammo and target.x and target.y then 
		local command = {
			method = 'deploy',
			ammo = data.ammo,
			target = data.target,
			username = self.username,
			password = self.password
			}
		self.server:send(serialize(command))
		self:msg("sent deploy request")
		return true
	end
	self:msg("could not sent malformed deploy command")
	return false
end

--move
function m.move(self,data)
	if not data then self:msg("no data for move") return false end
	local method = (data.method == 'move')
	local target = {}
	target.x = data.target.x
	target.y = data.target.y
	
	if method and target.x and target.y then 
		local command = {
			method = 'move',
			target = data.target,
			username = self.username,
			password = self.password
			}
		self.server:send(serialize(command))
		self:msg("sent move request")
		return true
	end
	self:msg("could not sent malformed moves command")
	return false
end

--respawn
function m.respawn(self,data)
	if not data then self:msg("no data for respawn command") return false end
	local method = (data.method == 'respawn')
	
	if method then 
		local command = {
			method = 'respawn',
			username = self.username,
			password = self.password
			}
		self.server:send(serialize(command))
		self:msg("sent respawn request")
		return true
	end
	self:msg("could not sent malformed respawn command")
	return false
end



return m
