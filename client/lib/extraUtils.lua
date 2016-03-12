function lg.dottedLine(x1, y1, x2, y2, size, interval)
    local size = size or 5
    local interval = interval or 2

    local dx = (x1-x2)*(x1-x2)
    local dy = (y1-y2)*(y1-y2)
    local length = math.sqrt(dx+dy)
    local t = size/interval

    for i = 1, math.floor(length/size) do
        if i % interval == 0 then
            love.graphics.line(x1+t*(i-1)*(x2-x1), y1+t*(i-1)*(y2-y1),
                               x1+t*i*(x2-x1), y1*t*i*(y2-y1))
        end
    end
end

function spairs(t, order)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys 
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end

function math.clamp(low, n, high) return math.min(math.max(low, n), high) end
 
