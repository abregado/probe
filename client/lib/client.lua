require 'enet'


local c = {}

function c.new(port,server_address,gameObject,refresh,username,password)
	local new_client = {}
	new_client.messages = {}
	new_client.gameObject = gameObject
	new_client.host = enet.host_create()
	new_client.target = server_address
	new_client.server = nil
	new_client.commands = {}
	new_client.methods = {}
	new_client.username = username or "default-username"
	new_client.password = password or "default-password"
	new_client.next_refresh = os.time() + (refresh or 0)
	new_client.rate = refresh
	
	new_client.update = c.update
	new_client.process = c.process
	new_client.send_command = c.send_command
	new_client.register_method = c.register_method
	new_client.register_command = c.register_command
	new_client.login_details = c.login_details
	new_client.msg = c.msg
	new_client.shutdown = c.shutdown
	new_client.disconnect = c.disconnect
	new_client.connect = c.connect
	
	new_client:register_method("refresh",function(self,data) c.receive_refresh(self,data) end)
	new_client:register_method("error",function(self,data) c.receive_error(self,data) end)
	new_client:register_command("refresh",function(self,data) c.request_refresh(self,data) end)
	new_client:msg("Client initialized on port "..port)
	--new_client:connect()
	
	return new_client
end

--deal with incoming data and request updates if timing out
function c:update()
	local processed = false
	local event = self.host:service(100)
	if event and event.peer == self.server then
		if event.type == "receive" then
			--deal with incoming methods
			local command_data = deserialize(event.data)
			if type(command_data) == 'table' then
				self:process(command_data)
				processed = true
			end	
		end
	end
	
	local time = os.time()
	if time > self.next_refresh then
		self:send_command('refresh',{method='refresh'})
		self.next_refresh = time + self.rate
	end
	return processed
end

--check if incoming data has a method to handle it
function c:process(data)
	local methodName = data.method
	if self.methods[methodName] then
		self.methods[methodName](self,data)
	else
		self:msg("server sent unregistered request: "..methodName)		
	end
end

function c:receive_error(data)
	self:msg(data.msg)
end

--check if command is registered and run it with data
function c:send_command(commandName,data)
	local state = self.server:state()
	if state == "connected" then
		if self.commands[commandName] then
			self.commands[commandName](self,data)
			return true
		else
			self:msg("no command registered with name "..commandName)
			return false
		end
	else
		self:msg("tried to send command but server is not connected")
	end
end

--default refresh method handler. Added to every new client and can be replaced.
function c:receive_refresh(data)
	if data.data then
		for i,attr in pairs(data.data) do
			self.gameObject[i] = attr
		end
		self.next_refresh = os.time() + self.rate
		--self:msg("found and set game data from refresh")
		return true
	end
	self:msg("couldnt find game data in refresh")
	return false
end

--default refresh requester. Added to every new client and can be replaced.
function c:request_refresh()
	local request = {
		method = 'refresh',
		username = self.username,
		password = self.password
		}
	self.server:send(serialize(request))
	--self:msg("send a refresh request")
end

--register a new method. Should be only done during love.load
function c:register_method(methodName,callback)
	if self.methods and self.methods[methodName] then
		self.methods[methodName] = function(self,data) callback(self,data) end
		return false
	else
		self.methods[methodName] = function(self,data) callback(self,data) end
		return true
	end
end

--register a new command. Should be only done during love.load
function c:register_command(commandName,callback)
	if self.commands and self.commands[commandName] then
		self.commands[commandName] = function(self,data) callback(self,data) end
		return false
	else
		self.commands[commandName] = function(self,data) callback(self,data) end
		return true
	end
end

--change login details for this client. Should be run only at love.load or when client is disconnected.
function c:login_details(username,password)
	self.username = username
	self.password = password
	self:msg("username and password set for",username)
end

function c:msg(message)
	table.insert(self.messages,1,message)
	print("Client: "..message)
end

function c:shutdown()
	self.host:destroy()
end

function c:disconnect()
	self.host:flush()
	self.server:disconnect()
	self:msg("disconnected from server")
end

function c:connect()
	self.server = self.host:connect(self.target)
	self:msg("connecting to server...")
end

return c
