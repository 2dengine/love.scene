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
function camera.new(x, y, mt)
  return reg.Node.new(x, y, mt or cameraMT)
end

--- Sets the viewing range of the camera in scene units.
-- If no range is specified the rendered area is determined by the dimensions of the view object.
-- @tparam[opt] number width Range width in scene units
-- @tparam[opt] number height Range height in scene units
-- @see view:getRange
function camera:setRange(w, h)
  self.rw = w
  self.rh = h
end

--- Gets the viewing range of the camera in scene units.
-- Returns nil if no range is specified.
-- @treturn[opt] number Range width in scene units
-- @treturn[opt] number Range height in scene units
-- @see view:setRange
function camera:getRange()
  return self.vw/self.sx, self.vh/self.sy
end

--- This is an internal function.
-- @tparam node view View object
-- @see view:draw
function camera:render(view)
  local root = self.getRoot()
  if not self.visible or not root then
    return
  end
  local trans = self.transform
  if self.changed then
    trans:setTransformation(self.x, self.y, self.r, self.sx, self.sy)
    self.changed = nil
  end
  lg_push("transform")
  lg_applyTransform(trans)
  local vw, vh = view:getDimensions()
  local rw, rh = self.rw, self.rh
  lg_scale(vw/rw, vh/rh)
  root:draw()
  lg_pop()
end

return camera.new