--- Cameras can be placed in the scene and transformed like regular nodes.
-- Cameras can also render contents onto a @{view:draw} object.
-- @module camera
-- @alias camera
-- @inherit node
local camera = {}
local cameraMT = { __index = camera }

local lg = love.graphics
local lg_push = lg.push
local lg_applyTransform = lg.applyTransform
local lg_scale = lg.scale
local lg_pop = lg.pop

local reg = debug.getregistry()
reg.Camera = camera

setmetatable(camera, { __index = reg.Node })
camera.stype = "Camera"

--- This is an internal function.
-- Please use @{scene.newCamera} or @{layer.newCamera} instead.
-- @tparam number x X coordinate
-- @tparam number y Y coordinate
-- @tparam[opt] table mt Metatable of base object
-- @treturn camera New camera
-- @see layer:newCamera
-- @see scene.newCamera
function camera.construct(x, y, mt)
  local t = reg.Node.construct(x, y, mt or cameraMT)
  t.rw = 0
  t.rh = 0
  return t
end

--- This is an internal function.
function camera:reset(x, y)
  self.rw = 0
  self.rh = 0
  reg.Node.reset(self, x, y)
end

--- Sets the viewing range of the camera in scene units.
-- The camera node's scale is ignored upon setting a non-zero range.
-- When the viewing range is set to zero,
-- the rendered area is determined by the
-- camera's scale and the dimensions of the view object.
-- @tparam number width Range width in scene units
-- @tparam number height Range height in scene units
-- @see view:getRange
function camera:setRange(w, h)
  self.rw = w
  self.rh = h
end

--- Gets the viewing range of the camera in scene units.
-- Returns zero if no range is specified.
-- @treturn number Range width in scene units
-- @treturn number Range height in scene units
-- @see view:setRange
function camera:getRange()
  return self.rw, self.rh
end

--- This is an internal function.
-- @tparam node view View object
-- @see view:draw
function camera:render(view)
  local root = self:getRoot()
  if not self.visible or not root then
    return
  end
  local trans = self.transform
  if self.changed then
    trans:setTransformation(0, 0, self.r, 1, 1, self.x, self.y)
    self.changed = nil
  end

  local vw, vh = view:getDimensions()
  local rw, rh = self.rw, self.rh
  local sx, sy = self.sx, self.sy
  if rw > 0 and rh > 0 then
    sx, sy = vw/rw, vh/rh
  end
  lg_push("transform")
  lg_scale(sx, sy)
  lg_applyTransform(trans)

  reg.Layer.draw(root)
  lg_pop()
end

--- This is an internal function.
function camera:draw()
end

return camera.new