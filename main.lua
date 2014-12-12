require('registry')
if DEBUG_MODE then
    require ('lovedebug')
end

function love.load()
    server.init()
   
    gs.registerEvents()
    gs.switch(state.menu)
	
    math.randomseed(DEBUG_MODE and 1000 or os.time())
    
end

function love.quit()
end


function love.update(dt)
    server.update(dt)
end

function spairs(t, order)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys 
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end
