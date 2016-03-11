se = {}

local speedMod = 200

function se.new(x,y,sig,owner)
    o={}
    o.x,o.y=x,y
    o.isHuman = true
    o.entType=sig or "sig"
    o.owner=owner or "npc"
    o.scanMod = 1
    if owner == "npc" or owner == "environment" then
        o.isHuman = false
    end
    
    if sig == "asteroid" then
        o.canMove = false
        o.isMoving = false
        o.tx,o.ty=x,y
        o.dx,o.dy=0,0
        o.v=0
        o.scanMod = 0.5
    elseif sig == "sig" then
        o.canMove = true
        o.isMoving = true
        o.tx,o.ty=x,y
        o.dx,o.dy=0,0
        o.v=30
        o.scanMod = 1
        
        local rx = math.random(0,lg.getWidth())
        local ry = math.random(0,lg.getHeight())
        if not o.isHuman then se.setNewDest(o,rx,ry) end
    elseif sig == "debris" then
        o.canMove = true
        o.isMoving = true
        o.tx,o.ty=x,y
        o.dx,o.dy=0,0
        o.v=10
        o.scanMod = 0.5
        local rx = math.random(0,lg.getWidth())
        local ry = math.random(0,lg.getHeight())
        local ox = math.random(-5,5)
        local oy = math.random(-5,5)
        o.x = o.x+ox
        o.y = o.y+oy
        se.setMomentum(o,rx,ry)
    end
    
    
    
    return o
end

function se.move(sig,dt)
    
    local arrived = false
    if sig.isMoving or sig.entType == "debris" then
        local nx = sig.dx*sig.v*dt*speedMod/1000
        local ny = sig.dy*sig.v*dt*speedMod/1000
        local dist = vl.dist(sig.x,sig.y,sig.tx,sig.ty)
        if dist < (sig.v*dt*speedMod/1000) then
            sig.x,sig.y = sig.tx,sig.ty
            arrived=true
        else
            sig.x = sig.x+nx
            sig.y = sig.y+ny
        end
    end
    
    
    if arrived and not sig.isHuman then
        local rx = math.random(0,lg.getWidth())
        local ry = math.random(0,lg.getHeight())
        se.setNewDest(sig,rx,ry)
    elseif arrived and sig.isHuman then
        sig.isMoving = false
    end
    
    
    return arrived
end



function se.setNewDest(sig,tx,ty)
    if sig.canMove then
        sig.tx,sig.ty = tx,ty
        sig.dx,sig.dy = vl.normalize(sig.tx-sig.x,sig.ty-sig.y)
        sig.isMoving = true
    end
end

function se.setMomentum(sig,tx,ty)
    sig.isMoving = true
    sig.dx,sig.dy = vl.normalize(tx-sig.x,ty-sig.y)
    print("setting momentum")
end

function se.draw(ship)
	lg.setColor(color.weapons)
	lg.circle("fill",ship.x,ship.y,3,30)
	lg.circle("line",ship.x,ship.y,9,30)
end

return se
