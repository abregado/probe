-- Entry menu contains a buttonlist and some visual data

local menu = {}

local screen = {w=lg.getWidth(),h=lg.getHeight()}
local pos = {}
pos.x = screen.w/4
pos.y = screen.h/4*3

function menu:init()
    self.mlist = list.new(pos.x,pos.y,1,self)
    self.mlist.buttons[1].label = "Retry"
    self.mlist.buttons[1].click = function() gs.switch(state.game) end
    menu.clicked = false
    
end

function menu:enter(from)
    menu.clicked = false
    menu.from = from
    --lg.setBackgroundColor(color.menuBG)
end

function menu:draw()

    lg.setColor(255,255,255)
    menu.from:draw()
	self.mlist:draw()
end

function menu:keypressed(key,code)
    if key == "escape" then
        love.event.quit()
    end
end

function menu:mousepressed(x,y,button)
    menu.clicked = true
end

function menu:mousereleased(x,y,button)
	local b = self.mlist:checkClick(x,y)
	if button == "l" and b and menu.clicked then
		b:click()
	end
    menu.clicked=false
end

function menu:leave()
end

function menu:update(dt)
end

return menu
