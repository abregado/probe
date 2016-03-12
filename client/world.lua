local w = {}

--data structure for world info to be shared with server
function w.new()
	local nw = {}
	nw.objects = {}
	
	nw.update = w.update
	nw.addObject = w.addObject
	nw.findOwnedObjects = w.findOwnedObjects
	
	return nw
end

function w:update(dt)
	local update_list = {}
	update_list["missile"] = missile.update
	update_list["ship"] = ship.update
	update_list["probe"] = probe.update
	update_list["blast"] = blast.update
	
	--update all objects
	for i,obj in pairs(self.objects) do
		local this_update = update_list[obj.entType]
		if this_update then this_update(obj,self.objects,dt) end
	end
	
	--garbage collection
	for i,obj in pairs(self.objects) do
		if obj.isDead then
			table.remove(self.objects,i)
		end
	end
end

function w:addObject(object)
	table.insert(self.objects,object)
	print("added new object of type "..object.entType)
end

function w:findOwnedObjects(owner,entType)
	local results = {}
	for i,ent in pairs(self.objects) do
		if entType and ent.entType == entType and ent.owner == owner then
			table.insert(results,ent)
		elseif owner == ent.owner then
			table.insert(results,ent)
		end
	end
	return results
end

function w.findClosestObject(self,x,y)
	local dist = 100000
	local target = nil
	for i,obj in pairs(self.objects) do
		local d = vl.dist(x,y,obj.x,obj.y)
		if d < dist then
			dist = d
			target = obj
		end
	end
	return target
end

return w
