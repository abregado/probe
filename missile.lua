m = {}

function m.new(x,y,tx,ty,callback)
    o = {}
    o.x,o.y,o.tx,o.ty = x,y,tx,ty
    o.cb = callback
    o.accel = 10
    o.velocity = 0
    o.ang = vl.angleTo(x,y,tx,ty)
    --movement tween, if it looks good (inOutQuad for probes, outQuad for missiles)
end

function m.arrive(missile)
    --run callback and clean self up
end

function m.update(missile,dt)
    --update travel tween
    --check arrival
end

return m
