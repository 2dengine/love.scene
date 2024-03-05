--- Cameras can be placed in the scene and transformed like regular nodes.
-- Cameras can also render contents onto the @{view} object.
-- @module camera
-- @alias camera
-- @inherit node
local camera = {}

local reg = debug.getregistry()
reg.Camera = camera

local lg = love.graphics
local _lg_push, _lg_applyTransform, _lg_scale, _lg_pop
if lg then
  _lg_push = lg.push
  _lg_applyTransform = lg.applyTransform
  _lg_scale = lg.scale
  _lg_pop = lg.pop
end
local _Node_construct = reg.Node.construct
local _Node_reset = reg.Node.reset
local _Layer_draw = reg.Layer.draw
local _Transform_setTransformation = reg.Transform.setTransformation
local _Scene_copy = reg.Scene.copy

camera.stype = "Camera"

--- This is an internal function
-- Please use @{scene.newCamera} or @{layer.newCamera} instead.
-- @tparam number x X coordinate
-- @tparam number y Y coordinate
-- @treturn camera New camera
-- @see layer:newCamera
-- @see scene.newCamera
function camera.construct(x, y)
  local t = _Node_construct(x, y)
  t.rw = 0
  t.rh = 0
  _Scene_copy(camera, t)
  return t
end

--- This is an internal function
-- @tparam number x X-coordinate
-- @tparam number y Y-coordinate
function camera:reset(x, y)
  self.rw = 0
  self.rh = 0
  _Node_reset(self, x, y)
end

--- Sets the viewing range of the camera in scene units.
-- The camera node's scale is ignored upon setting a non-zero range.
-- When the viewing range is set to zero,
-- the rendered area is determined by the
-- camera's scale and the dimensions of the view object.
-- @tparam number width Range width in scene units
-- @tparam number height Range height in scene units
-- @see camera:getRange
function camera:setRange(w, h)
  self.rw = w
  self.rh = h
end

--- Gets the viewing range of the camera in scene units.
-- Returns zero if no range is specified.
-- @treturn number Range width in scene units
-- @treturn number Range height in scene units
-- @see camera:setRange
function camera:getRange()
  return self.rw, self.rh
end

--- This is an internal function
-- @tparam node view View object
-- @see view:draw
function camera:render(view)
  local root = self:getRoot()
  if not self.visible or not root then
    return
  end
  local trans = self.transform
  if self.changed then
    _Transform_setTransformation(trans, 0, 0, self.r, 1, 1, self.x, self.y)
    self.changed = nil
  end

  local vw, vh = view:getDimensions()
  local rw, rh = self.rw, self.rh
  local sx, sy = self.sx, self.sy
  if rw > 0 and rh > 0 then
    sx, sy = vw/rw, vh/rh
  end
  _lg_push("transform")
  _lg_scale(sx, sy)
  _lg_applyTransform(trans)

  _Layer_draw(root)
  _lg_pop()
end

--- This is an internal function
function camera:draw()
end

return camera.new
