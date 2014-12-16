local s = {}


s.ents ={}
s.probes = {}
s.missiles = {}

s.connections = {}
local nextID = 7

local world = {}
world.w = lg.getWidth()
world.h = lg.getHeight()

local mustRedraw = false
local player = {x=0,y=0}

local entSpeed = 20

local lastFrame = 0

local entsVisible = false

s.methods = {}

function s.requestUpdate(owner)
    local ownerSigs = {}
    for i,v in ipairs(s.ents) do
        if v.owner == owner or v.visible then
            table.insert(ownerSigs,v)
        end
    end
    return ownerSigs,mustRedraw
end

function s.methods.connect()
    local playerEnt = s.newPlayer(nextID)
    return playerEnt
end

function s.findPlayerShip(owner)
    for j,k in ipairs(s.ents) do
        if k.owner == owner then
            return k, "player ship found"
        end
    end
    return nil, "no ship"
end

function s.checkOwner(owner)
    local result = false
    for i,v in ipairs(s.connections) do
        if v==owner then
            result = true
        end
    end
    return owner
end

function s.methods.addMissile(owner,tx,ty,payload)
    local p = s.findPlayerShip(owner)
    if p then
        local m = missile.new(owner,p.x,p.y,tx,ty,payload)
        table.insert(s.ents,m)
        return true
    else
        return false
    end
end

function s.methods.addProbe(owner,x,y,probeModel)
    local p = probeLogic.new(owner,x,y,probeModel)
    table.insert(s.ents,p)
end

function s.methods.addBlast(x,y)
    local nb = blast.new(x,y)
    table.insert(s.ents,nb)
end

function s.countSigs(owner)
    local result = 0
    for i,v in ipairs(s.ents) do
        if v.owner ~= owner then
            result = result +1
        end
    end
    return result
end

function s.newPlayer(owner)
    local newEnt = nil
    local rx = math.random(0,world.w)
    local ry = math.random(0,world.h)
    newEnt = {x=rx,y=ry,isMoving=false,sig=5,owner=owner}
    table.insert(s.ents,newEnt)
    table.insert(s.connections,{ID=owner,ship=newEnt})
    nextID = owner+1
    return newEnt
end 

function s.update(dt)
    mustRedraw = false

    for i,v in ipairs(s.ents) do
        if v.entType=="probe" then
            probeLogic.update(v,s.ents,dt)
        elseif v.entType == "missile" then
            if missile.update(v,dt) then
                v:cb()
            end
        elseif v.entType == "blast" then
            blast.update(v,s.ents,dt)
        elseif v.entType == "sig" then
            if v.isMoving then
                v.x = v.x-(entSpeed/dt/10000)
            end
            if v.x < 0 then v.x = v.x + screen.w end
        end
    end
    
    for i,v in ipairs(s.ents) do
        if v.isDead then
            table.remove(s.ents,i)
            mustRedraw = true
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
        local minRad = dist-(dist*(probe.accuracyD)/100)
        local maxRad = dist+(dist*(probe.accuracyD)/100)
        
        local ax,ay = target.x-probe.x, target.y-probe.y
        local vx,vy = vl.normalize(ax,ay)
        local x,y = vx*probe.radMax,vy*probe.radMax 
        local posRad = vl.angleTo(vx,vy)+circ
        local x,y = math.cos(posRad)*probe.radMax, math.sin(posRad)*probe.radMax
        local leftOff = (math.pi*2)/100*(probe.accuracyR)
        
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
    local r1 = math.random()
    local r2 = math.random()
    local r3 = math.random()
    local r4 = math.random()

    for i=1,3 do
        --r1 = math.random(1,screen.w)
        r1 = screen.w
        r2 = math.random(1,screen.h)

        local newEnt = {x=r1,y=r2,isMoving=true,sig=8,entType="sig",owner="npc"}
        table.insert(s.ents,newEnt)
    end

    for i=1,3 do
        r1 = math.random(1,screen.w)
        r2 = math.random(1,screen.h)

        local newEnt = {x=r1,y=r2,isMoving=false,sig=5,entType="sig",owner="npc"}
        table.insert(s.ents,newEnt)
    end

    --add random missiles
    for i=1,3 do
        r1 = math.random(1,screen.w)
        r2 = math.random(1,screen.h)
        r3 = math.random(1,screen.w)
        r4 = math.random(1,screen.h)

        local newM = missile.new(0,r1,r2,r3,r4,"torpedo")
        table.insert(s.missiles,newM)
    end
    
    print("server initialized")  
end

return s
