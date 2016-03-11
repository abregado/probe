require('registry')
if DEBUG_MODE then
    require ('lovedebug')
end

function love.load()  
    gs.registerEvents()
    gs.switch(state.menu)
    math.randomseed(DEBUG_MODE and 1000 or os.time())
end

function love.quit()
end


function love.update(dt)
	
end


