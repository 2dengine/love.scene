local mapw, maph = 64, 64
local view, root, img, cam

function love.load()
  -- setup the scene
  love.scene = require("scene.init")
  view = love.scene.newView()
  view:setBackground(1, 0, 0)
  root = love.scene.newLayer(0, 0)
  img = love.graphics.newImage("block.png")
  for x = 1, mapw do
    for y = 1, maph do
      local s = root:newSprite(x*16, y*16)
      s:setGraphic(img)
    end
  end
  local w, h = love.graphics.getDimensions()
  cam = root:newCamera(w/2, h/2)
  view:setCamera(cam)
end

function love.update(dt)
  -- center the scene
  local x, y = cam:getPosition()
  if love.keyboard.isDown("left") then
    x = x - 100*dt
  elseif love.keyboard.isDown("right") then
    x = x + 100*dt
  end
  if love.keyboard.isDown("up") then
    y = y - 100*dt
  elseif love.keyboard.isDown("down") then
    y = y + 100*dt
  end
  cam:setPosition(x, y)
end

function love.resize(w, h)
  -- resize the scene
  cam:setRange(w, h)
end

function love.draw()
  -- redraw the scene
  view:draw()
  love.graphics.setColor(1, 1, 1)
  love.graphics.print("FPS: "..love.timer.getFPS(), 10, 10)
  love.graphics.print("Sprites: "..mapw*maph, 10, 30)
end