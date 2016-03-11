-- Entry menu contains a buttonlist and some visual data

local menu = {}

local screen = {w=lg.getWidth(),h=lg.getHeight()}
local pos = {}
pos.x = screen.w/4
pos.y = screen.h/4

function menu:init()
    self.mlist = list.new(pos.x,pos.y,2,self)
    self.mlist.buttons[1].label = "Connect to Server"
    self.mlist.buttons[1].click = function() gs.switch(state.game) end
    self.mlist.buttons[2].label = "Quit"
    self.mlist.buttons[2].click = function() love.event.quit() end
    menu.clicked = false
    
end

function menu:enter(from)
    menu.clicked = false
    lg.setBackgroundColor(color.menuBG)
end

function menu:draw()
    lg.setColor(255,255,255)
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
	if button == 1 and b and menu.clicked then
		b:click()
	end
    menu.clicked=false
end

function menu:leave()
end

function menu:update(dt)
end

return menu
