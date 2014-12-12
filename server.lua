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

function s.getNewTarget(probe)
    local target = probeLogic.findTarget(probe,s.ents)
    local circ = math.pi*4
    local newTarget = nil
    if target then
        newTarget = {}
        local dist = vl.dist(target.x,target.y,probe.x,probe.y)
        local minRad = dist-(dist*(probe.accuracy)/100)
        local maxRad = dist+(dist*(probe.accuracy)/100)
        
        local ax,ay = target.x-probe.x, target.y-probe.y
        local vx,vy = vl.normalize(ax,ay)
        local x,y = vx*probe.radMax,vy*probe.radMax 
        local posRad = vl.angleTo(vx,vy)+circ
        local x,y = math.cos(posRad)*probe.radMax, math.sin(posRad)*probe.radMax
        local leftOff = (math.pi*2)/100*(probe.accuracy/5)
        
        local rRad = math.random(minRad,maxRad)
        local minAng = posRad-leftOff+circ
        local maxAng = posRad+leftOff+circ
        local dRad = posRad+(math.random()*leftOff*2)-leftOff
        
        newTarget.sig = target.sig
        newTarget.x = probe.x+math.cos(dRad)*rRad
        newTarget.y = probe.y+math.sin(dRad)*rRad
        print (newTarget.x,newTarget.y,target.x,target.y)
    end
    
    return newTarget
end


function s.init()
    if DEBUG_MODE then
        local newEnt = {x=screen.w/2,y=screen.h/2,isMoving=true,sig=5}
        table.insert(s.ents,newEnt)
        table.insert(s.probes,probeLogic.new(newEnt.x-50,newEnt.y-50,"range"))
    else
            
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
    end
    
    player = {x=r1,y=r2}
end

return s
