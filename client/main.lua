require('registry')
if DEBUG_MODE then
    require ('lovedebug')
end

function love.load()  
    gs.registerEvents()
    math.randomseed(DEBUG_MODE and 1000 or os.time())
    gs.switch(state.menu)
end

function love.quit()
end


function love.update(dt)
	
end


