local s = {}

s.ents ={}
s.probes = {}
s.missiles = {}


local player = {x=0,y=0}

local entSpeed = 20

local lastFrame = 0

local entsVisible = false


function s.requestUpdate()
    return s.ents,s.probes,s.missiles
end

function s.update(dt)
    for i,v in ipairs(s.probes) do
        probeLogic.update(v,s.ents,dt)
    end
    
    for i,v in ipairs(s.ents) do
        if v.isMoving then
            v.x = v.x-(entSpeed/dt/10000)
            if v.x < 0 then v.x = v.x + screen.w end
        end
    end
end

function s.init()
    local r1 = math.random()
    local r2 = math.random()
    for i=1,3 do
        --r1 = math.random(1,screen.w)
        r1 = screen.w
        r2 = math.random(1,screen.h)
        
        local newEnt = {x=r1,y=r2,isMoving=true,sig=8}
        table.insert(s.ents,newEnt)
    end
    for i=1,3 do
        r1 = math.random(1,screen.w)
        r2 = math.random(1,screen.h)
        
        local newEnt = {x=r1,y=r2,isMoving=false,sig=5}
        table.insert(s.ents,newEnt)
    end
    
    r1 = math.random(1,screen.w)
    r2 = math.random(1,screen.h)
    player = {x=r1,y=r2}
end

return s
