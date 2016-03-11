local w = {}

--data structure for world info to be shared with server
function w.new()
	local nw = {}
	nw.objects = {}
	
	return nw
end

return w
