function love.load()
    clrBlack = {0, 0, 0}
    clrWhite = {255, 255, 255}
    clrGreen = {32, 128, 32}
    clrOrange = {128, 128, 32}
    clrRed = {128, 32, 32}

    w = love.graphics.getWidth()
    h = love.graphics.getHeight()

    cell_w = w / 20
    cell_h = h / 20

    snake = {
        {2, 0},
        {1, 0},
        {0, 0}
    }
    tail = 0
    apple = nil
    controls = {1, 0}

    time = 0
    delay = 0.75

    cond1 = false
    cond2 = false
end

function love.draw()
    draw_snake(snake)

    if apple ~= nil then
        draw_apple(apple)
    end

    if cond1 or cond2 then
        level = (1 - delay - 0.24) * 100
        love.graphics.setColor(clrWhite)
        love.graphics.print("Game Over: ".. level, 280, 300)
    end
end

function love.keypressed(key, unicode)
    if key == 'escape' then
        r = love.event.quit()
    elseif key == 'w' or key == 'up' then
        controls = {0, -1}
    elseif key == 'a' or key == 'left' then
        controls = {-1, 0}
    elseif key == 'd' or key == 'right' then
        controls = {1, 0}
    elseif key == 's' or key == 'down' then
        controls = {0, 1}
    end
end

function love.update(dt)
    cond1 = is_out(snake[1])
    cond2 = is_self_crossing()

    if not cond1 and not cond2 then
        if apple == nil then
            apple = spawn_apple()
        end
        if time > (delay * delay) then
            snake = do_move(snake)
            if is_apple(snake[1]) then
                tail = tail + 1
                apple = nil
            end
            time = 0
        end
        time = time + dt
    end
end

-- ----------------

function is_apple(head)
    xpos, ypos = unpack(head)
    if xpos == apple[1] and ypos == apple[2] then
        return true
    end
end

function spawn_apple()
    xpos, ypos = unpack(get_random_coords())
    while is_occupied(xpos, ypos) do
        xpos, ypos = unpack(get_random_coords())
    end
    return {xpos, ypos}
end

function get_random_coords()
    xpos = love.math.random(0, (w / cell_w) - 1)
    ypos = love.math.random(0, (h / cell_h) - 1)

    return {xpos, ypos}
end

function is_occupied(xpos, ypos)
    for i = 1, #snake do
        xpos_a, ypos_a = unpack(snake[i])
        if xpos_a == xpos and ypos_a == ypos then
            return true
        end
    end
    return false
end

function is_self_crossing()
    xpos_1, ypos_1 = unpack(snake[1])
    for i=2, #snake do
        xpos_a, ypos_a = unpack(snake[i])
        if xpos_a == xpos_1 and ypos_a == ypos_1 then
            return true
        end
    end
    return false
end

function is_out(head_coordinates)
    x, y = unpack(head_coordinates)
    if x < 0 or x >= w / cell_w then
        return true
    end
    if y < 0 or y >= h / cell_h then
        return true
    end
    return false
end

function do_move(snake)
    dx, dy = unpack(controls)
    i = #snake
    while i > 0 do
        if i == 1 then
            xpos, ypos = unpack(snake[i])
            xpos = xpos + dx
            ypos = ypos + dy
            snake[1] = {xpos, ypos}
        else
            if i == #snake and tail > 0 then
                snake[i+1] = snake[i]
                tail = tail - 1
                delay = delay - 0.01
            end
            snake[i] = snake[i-1]
        end
        i = i - 1
    end

    return snake
end

function draw_apple(apple)
    draw_cell(apple, clrGreen)
end

function draw_snake(snake)
    for i, cell in ipairs(snake) do
        if i == 1 then
            draw_cell(cell, clrRed)
        else
            draw_cell(cell, clrOrange)
        end
    end
end

function draw_cell(coordinates, color)
    x, y = unpack(coordinates)
    love.graphics.setColor(color)
    love.graphics.rectangle('fill', x * cell_w, y * cell_h, cell_w, cell_h)
end
