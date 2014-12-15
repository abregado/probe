m = {}

local maxVelo = 1000000
local speedMod = 200

function m.new(owner,x,y,tx,ty,payload)
    o = {}
    o.owner=owner
    o.x,o.y,o.tx,o.ty = x,y,tx,ty
    o.dx,o.dy = vl.normalize(tx-x,ty-y)
    o.isDead = false
    
    
    o.payload = payload
    if payload == "torpedo" then
        o.cb = m.explode
        o.accel = 10000
        o.v = 0
        o.visible = true
    else
        o.cb = m.deploy
        o.accel = 100
        o.v = 0
        o.visible = false
    end
    
    
    return o
end

function m:explode()
    --run callback and clean self up
    print("missiles arrived")
    self.isDead = true
end

function m:deploy()
    --run callback and clean self up
    print("probe deployment successful")
    server.methods.addProbe(self.owner,self.x,self.y,"range")
    self.isDead = true
end

function m.update(missile,dt)
    missile.v = missile.v+(missile.accel*dt/1000*speedMod)
    local arrived = false
    if missile.v > maxVelo then missile.v = maxVelo end
    local nx = missile.dx*missile.v*dt*speedMod/1000
    local ny = missile.dy*missile.v*dt*speedMod/1000
    local dist = vl.dist(missile.x,missile.y,missile.tx,missile.ty)
    if dist < (missile.v*dt*speedMod/1000) then
        missile.x,missile.y = missile.tx,missile.ty
        arrived=true
    else
        missile.x = missile.x+nx
        missile.y = missile.y+ny
    end
    
    return arrived
    
    --check arrival
    
end

function m.getClientMissile(missile)
    local ms = missile
    local ncm = {x=ms.x,y=ms.y,v=ms.v,dx=ms.dx,dy=ms.dy}
    return ncm
end

return m
