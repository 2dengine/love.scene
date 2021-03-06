--- Sprites are nodes in the scene which can be translated, scaled or rotated.
-- Each sprite is assigned a "drawable" graphic, usually an image, quad or text.
-- Sprites can also be assigned a specific color, alpha value and blending mode.
-- @module sprite
-- @alias sprite
-- @inherit node
local sprite = {}
local spriteMT = { __index = sprite }

local lg = love.graphics
local lg_setColor = lg.setColor
local lg_setBlendMode = lg.setBlendMode
local lg_setShader = lg.setShader
local lg_draw = lg.draw

local reg = debug.getregistry()
reg.Sprite = sprite

setmetatable(sprite, { __index = reg.Node })

--- This is an internal function.
-- Please use @{scene.newSprite} or @{layer.newSprite} instead.
-- @tparam number x X coordinate
-- @tparam number y Y coordinate
-- @tparam[opt] table mt Metatable of base object
-- @treturn sprite New sprite
-- @see layer:newSprite
-- @see scene.newSprite
function sprite.new(x, y, mt)
  local t = reg.Node.new(x, y, mt or spriteMT)
  t.graphic = love.math.newTransform()
  t.color = { 1, 1, 1, 1 }
  t.mode = "alpha"
  return t
end

--- Destroys the sprite and removes it from its parent node.
function sprite:destroy()
  self.graphic = nil
  self.color = nil
  self.mode = nil
  self.img = nil
  self.quad = nil
  reg.Node.destroy(self)
end

--- Sets a "drawable" graphic or a quad for the sprite.
-- This could be an image, text, mesh, canvas, etc.
-- The "drawable" graphic can be transformed relative to the sprite's origin.
-- @tparam userdata drawable Drawable graphic
-- @tparam[opt] userdata quad Optional quad
-- @tparam[opt=0] number x X coordinate
-- @tparam[opt=0] number y y coordinate
-- @tparam[opt=0] number angle Angle
-- @tparam[opt=1] number sx X axis scale
-- @tparam[opt=1] number sy Y axis scale
-- @tparam[opt=0] number ox X axis offset
-- @tparam[opt=0] number oy Y axis offset
-- @tparam[opt=0] number kx X axis shearing
-- @tparam[opt=0] number ky Y axis shearing 
-- @see sprite:getGraphic 
function sprite:setGraphic(img, quad, a,b,c,d,e,f,g,h,i)
  self.img = img
  local graph = self.graphic
  if type(quad) == "userdata" then
    self.quad = quad
    graph:setTransformation(a,b,c,d,e,f,g,h,i)
  else
    self.quad = nil
    graph:setTransformation(quad, a,b,c,d,e,f,g,h)
  end
  self.changed = true
end

--- Gets the "drawable" graphic and quad of the sprite.
-- @treturn userdata Drawable graphic
-- @treturn userdata Quad or nil
-- @see sprite:setGraphic
function sprite:getGraphic()
  return self.img, self.quad
end

--- Sets the blending mode.
-- @tparam string mode Blend mode: "alpha", "add", "subtract" or "multiply"
-- @see sprite:getMode
function sprite:setMode(mode)
  self.mode = mode
end

--- Gets the blending mode.
-- @treturn string mode Blend mode
-- @see sprite:setMode
function sprite:getMode()
  return self.mode
end

--- Gets the color.
-- @treturn number Red value (0-1)
-- @treturn number Green value (0-1)
-- @treturn number Blue value (0-1)
-- @see sprite:setColor
function sprite:getColor()
  local c = self.color
  return c[1], c[2], c[3]
end

--- Sets the color.
-- @tparam number red Red value (0-1)
-- @tparam number green Green value (0-1)
-- @tparam number blue Blue value (0-1)
-- @see sprite:getColor
function sprite:setColor(r, g, b)
  if type(r) == "table" then
    r, g, b = unpack(r)
  end
  local c = self.color
  c[1], c[2], c[3] = r, g, b
end

--- Gets the alpha value.
-- @treturn number Alpha value (0-1)
-- @see sprite:setAlpha
function sprite:getAlpha()
  return self.color[4]
end

--- Sets the alpha value.
-- @tparam number alpha Alpha value (0-1)
-- @see sprite:getAlpha
function sprite:setAlpha(a)
  self.color[4] = a
end

--- Sets the shader used when drawing the sprite.
-- @tparam userdata shader Shader object
-- @see sprite:getShader
function sprite:setShader(s)
  self.shader = s
end

--- Gets the shader used when drawing the sprite.
-- @treturn userdata Shader object
-- @see sprite:getShader
function sprite:getShader()
  return self.shader
end

--- This is an internal function.
-- @see view:draw
function sprite:draw()
  if not self.visible then
    return
  end
  local img = self.img
  if not img then
    return
  end
  local trans = self.transform
  if self.changed then
    trans:setTransformation(self.x, self.y, self.r, self.sx, self.sy)
    trans:apply(self.graphic)
    self.changed = nil
  end
  lg_setColor(self.color)
  lg_setBlendMode(self.mode)
  local quad = self.quad
  local shade = self.shader
  if shade then
    lg_setShader(shade)
    if quad then
      lg_draw(img, quad, trans)
    else
      lg_draw(img, trans)
    end
    lg_setShader()
  else
    if quad then
      lg_draw(img, quad, trans)
    else
      lg_draw(img, trans)
    end
  end
end

return sprite.new