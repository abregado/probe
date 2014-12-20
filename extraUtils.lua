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
