function love.load()
  -- setup the scene
  love.scene = require("scene.init")
  view = love.scene.newView()
  local root = view:newLayer(0, 0)
  local img = love.graphics.newImage("mega.png")
  local w, h = view:getDimensions()
  sprites = {}
  for i = 1, 2000 do
    local x = math.random(w)
    local y = math.random(h)
    local s = root:newSprite(x, y)
    s:setGraphic(img)
    s:setColor(math.random(), math.random(), math.random())
    s.dx = math.random(-200, 200)
    s.dy = math.random(-200, 200)
    sprites[i] = s
  end
  root:setPosition(-w/2, -h/2)
end

function love.update(dt)
  -- animate the scene
  local w, h = view:getDimensions()
  for i, s in ipairs(sprites) do
    local x, y = s:getPosition()
    local dx, dy = s.dx, s.dy
    if (dx < 0 and x < 0) or (dx > 0 and x > w) then
      s.dx = -dx
    end
    if (dy < 0 and y < 0) or (dy > 0 and y > h) then
      s.dy = -dy
    end
    s:setPosition(x + dx*dt, y + dy*dt)
  end
end

function love.draw()
  -- redraw the scene
  view:draw()
  love.graphics.setColor(1, 1, 1)
  love.graphics.print("FPS: "..love.timer.getFPS(), 10, 10)
  love.graphics.print("Sprites: "..#sprites, 10, 30)
end