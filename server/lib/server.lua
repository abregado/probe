require "enet"

local s = {}

function s.new(port,gameObject)
	local new_server = {}
	new_server.host = enet.host_create("localhost:"..port)
	new_server.gameObject = gameObject
	new_server.methods = {}
	new_server.users = {}
	new_server.messages = {}
	
	new_server.update = s.update
	new_server.add_user = s.add_user
	new_server.remove_user = s.remove_user
	new_server.process = s.process
	new_server.register_method = s.register_method
	new_server.broadcast_refresh = s.broadcast_refresh
	new_server.shutdown = s.shutdown
	new_server.msg = s.msg
	new_server.error = s.error
	new_server.draw = s.draw
	
	new_server:register_method("refresh",function(self,peer,data) s.send_update(self,peer,data) end)
	new_server:msg("Server initialized on port "..port)
	
	return new_server
end

function s:update()
	local event = self.host:service(100)
	if event then
		if event.type == "receive" then
			--deal with incoming methods
			local command_data = deserialize(event.data)
			local user = self.users[event.peer:connect_id()]
			if type(command_data) == 'table' then
				if command_data.username and command_data.method and user and command_data.username == user.username and command_data.password == user.password then 
					--user seems safe so process the request
					self:process(event.peer,command_data)
				elseif command_data.username and command_data.method and user then
					--user has connected but has not had username and password set
					self:msg("first command from this user")
					user.username = command_data.username
					user.password = command_data.password
					self:process(event.peer,command_data)
				else
					--user request is malformed so disconnect them after telling them why
					self:msg("disconnected user "..event.peer:connect_id().." due to no username")
					self:error(event.peer,"failed authentication")
					event.peer:disconnect() 
				end
			end			
		elseif event.type == "disconnect" then
			--user has requested to be disconnected
			local removed = self:remove_user(event.peer:connect_id())
			if removed then
				self:msg(event.peer:connect_id().." disconnected and removed from userlist")
			else
				self:msg(event.peer:connect_id().." disconnected but was not in userlist")
			end
		elseif event.type == "connect" then
			--user has requested a connection
			local user_generated = self:add_user(event.peer:connect_id())
			if user_generated then
				self:msg(event.peer:connect_id().." connected and was added to userlist")
			else
				self:msg(event.peer:connect_id().." connected but was already in userlist")
			end
		end
	end

end

--add a new empty user to the servers list. return false if the user already exists for some reason
function s:add_user(id)
	local old_user = self.users[id]
	if old_user then
		return false
	else
		self.users[id] = {
			username = nil,
			password = nil,
			last_seen = os.time()
			}
		return true
	end
end

--remove user from internal userlist. Does not disconnect the user
function s:remove_user(id)
	local dead_user = self.users[id]
	if dead_user then
		for i,user in pairs(self.users) do
			if dead_user == user then
				table.remove(self.users,i)
				return true
			end
		end
	end
	return false
end

--used for default method. Sends the peer the entire gameObject. Can be overwritten.
function s:send_update(peer,data)
	--self:msg("sending refreshed game data")
	local update = {
		method = 'refresh',
		data = self.gameObject
		}
	peer:send(serialize(update))
end

--try to process data from a peer. Sends an error message if the method is not available
function s:process(peer,data)
	local methodName = data.method
	if self.methods[methodName] then
		self.methods[methodName](self,peer,data)
	else
		self:error(peer,'server method not registered')
		self:msg("unregistered method request: "..methodName)		
	end
end

--simple error sending in a client readable format
function s:error(peer,message)
	peer:send(serialize({method = 'error',msg = message}))
end

--register a new method. Should be only done during love.load
function s:register_method(methodName,callback)
	if self.methods and self.methods[methodName] then
		self.methods[methodName] = function(self,peer,data) callback(self,peer,data) end
		return false
	else
		self.methods[methodName] = function(self,peer,data) callback(self,peer,data) end
		return true
	end
end

--sends all peers a gameObject update in client readable format 
function s:broadcast_refresh()
	self.msg("broadcasting update to all clients")
	self.host:broadcast(serialize(self.gameObject))
end

--kills the server and frees up ports, but does not destroy the server object 
function s:shutdown()
	self.host:destroy()
end

--logs a message to the console and records it internally
function s:msg(message)
	table.insert(self.messages,1,message)
	print("Server: "..message)
end

--draws userlist and messages
function s:draw(x,y)
	local x,y = x,y
	local text_color = {255,255,255} 
	love.graphics.setColor(text_color)
	love.graphics.print("Connected Users:",x,y)
	y = y + 20
	for i,user in pairs(self.users) do
		love.graphics.print("["..i.."]: "..(user.username or "unnamed"),x,y)
		y = y + 20
	end
	y = y+5
	love.graphics.print("Server Logs",x,y)
	y = y+20
	for i,msg in pairs(self.messages) do
		love.graphics.print(msg,x,y)
		y = y +20
	end
end

return s
