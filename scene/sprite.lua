--- Sprites are nodes in the scene which can be translated, scaled or rotated.
-- Each sprite is assigned a "drawable" graphic, usually an image, quad or text.
-- Sprites can also be modulated by changing their color, alpha value and blending mode.
-- @module sprite
-- @alias sprite
-- @inherit node
local sprite = {}
local reg = debug.getregistry()
reg.Sprite = sprite

local _lg_setColor, _lg_setBlendMode, _lg_setShader, _lg_draw
local lg = love.graphics
if lg then
  _lg_setColor = lg.setColor
  _lg_setBlendMode = lg.setBlendMode
  _lg_setShader = lg.setShader
  _lg_draw = lg.draw
end
local _love_math_newTransform = love.math.newTransform
local _Node_construct = reg.Node.construct
local _Node_deconstruct = reg.Node.deconstruct
local _Node_reset = reg.Node.reset
local _Transform_setTransformation = reg.Transform.setTransformation
local _Transform_apply = reg.Transform.apply
local _Scene_copy = reg.Scene.copy

sprite.stype = "Sprite"

--- This is an internal function
-- Please use @{scene.newSprite} or @{layer.newSprite} instead.
-- @tparam number x X coordinate
-- @tparam number y Y coordinate
-- @treturn sprite New sprite
-- @see layer:newSprite
-- @see scene.newSprite
function sprite.construct(x, y)
  local t = _Node_construct(x, y)
  _Scene_copy(sprite, t)
  t.graphic = _love_math_newTransform()
  t.color = { 1, 1, 1, 1 }
  t.mode = "alpha"
  return t
end

--- This is an internal function
-- @see node:destroy
function sprite:deconstruct()
  self.graphic = nil
  self.color = nil
  self.img = nil
  self.quad = nil
  _Node_deconstruct(self)
end

--- Resets the node to its initial state.
-- @tparam number x X-coordinate
-- @tparam number y Y-coordinate
function sprite:reset(x, y)
  local c = self.color
  c[1], c[2], c[3], c[4] = 1, 1, 1, 1
  self.img = nil
  self.quad = nil
  self.shader = nil
  self.mode = "alpha"
  _Node_reset(self, x, y)
end

--- Sets a "drawable" graphic or a quad for the sprite.
-- This could be an image, text, mesh, canvas, etc.
-- The "drawable" graphic can be transformed relative to the sprite's origin.
-- @tparam userdata drawable Drawable graphic
-- @tparam[opt] userdata quad Optional quad
-- @tparam[opt=0] number x X coordinate
-- @tparam[opt=0] number y Y coordinate
-- @tparam[opt=0] number angle Angle in radians
-- @tparam[opt=1] number sx X axis scale
-- @tparam[opt=1] number sy Y axis scale
-- @tparam[opt=0] number ox X axis offset
-- @tparam[opt=0] number oy Y axis offset
-- @tparam[opt=0] number kx X axis shearing
-- @tparam[opt=0] number ky Y axis shearing 
-- @see sprite:getGraphic 
function sprite:setGraphic(img, a,b,c,d,e,f,g,h,i,j)
  self.img = img
  local graph = self.graphic
  if type(a) == "userdata" then
    self.quad = a
    _Transform_setTransformation(graph, b,c,d,e,f,g,h,i,j)
  else
    self.quad = nil
    _Transform_setTransformation(graph, a,b,c,d,e,f,g,h,i)
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
    r, g, b = r[1], r[2], r[3]
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

--- This is an internal function
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
    _Transform_setTransformation(trans, self.x, self.y, self.r, self.sx, self.sy)
    _Transform_apply(trans, self.graphic)
    self.changed = nil
  end
  _lg_setColor(self.color)
  _lg_setBlendMode(self.mode)
  local quad = self.quad
  local shade = self.shader
  if shade then
    _lg_setShader(shade)
    if quad then
      _lg_draw(img, quad, trans)
    else
      _lg_draw(img, trans)
    end
    _lg_setShader()
  else
    if quad then
      _lg_draw(img, quad, trans)
    else
      _lg_draw(img, trans)
    end
  end
end

return sprite.new
