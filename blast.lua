b = {}

function b.new(x,y)
    o={}
    o.x=x
    o.y=y
    
    o.maxRad=15
    o.radius=0
    o.blastTime=1
    o.isDead = false
    o.entType = "blast"
    o.visible = true
    
    o.tween = tween.new(o.blastTime,o,{radius=o.maxRad},'outQuad')
    
    return o
end

function b.draw(blast)
    if blast.radius < (blast.maxRad/10) then
        lg.setColor(color.white)
    else
        lg.setColor(color.weapons)
    end
    lg.setLineWidth(1)
    lg.circle("line",blast.x,blast.y,blast.radius,50)
    if blast.radius < (blast.maxRad/3*2) then
        lg.circle("line",blast.x,blast.y,blast.radius+4,50)
    end
    if blast.radius < (blast.maxRad/3) then
        lg.circle("line",blast.x,blast.y,blast.radius+8,50)
    end    
end

function b.update(blast,ents,dt)
    local complete = blast.tween:update(dt)
    
    for i,v in ipairs(ents) do
        if b.isInBlast(v.x,v.y,blast) and v.entType ~= "blast" then
            print("entity destroyed")
            v.isDead = true
        end
    end
    
    if complete then blast.isDead = true end
    
    
end

function b.isInBlast(x,y,blast)
    local result = vl.dist(x,y,blast.x,blast.y) <= blast.radius
    return result
end

return b
