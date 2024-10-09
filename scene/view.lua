--- View is a clipped rectangular area inside the application window where the scene is rendered.
-- Views can be transformed, drawn and shaded.
-- @module view
-- @alias view
-- @inherit layer
local view = {}

local reg = debug.getregistry()
reg.View = view

view.stype = "View"

local _cos = math.cos
local _sin = math.sin
local _lg_origin, _lg_setBlendMode, _lg_setCanvas, _lg_newCanvas, _lg_clear,
  _lg_setScissor, _lg_setColor, _lg_rectangle, _lg_push, _lg_translate,
  _lg_scale, _lg_rotate, _lg_pop, _lg_reset, _lg_setShader, _lg_getDimensions, _lg_draw
local lg = love.graphics
if lg then
  _lg_origin = lg.origin
  _lg_setBlendMode = lg.setBlendMode
  _lg_setCanvas = lg.setCanvas
  _lg_newCanvas = lg.newCanvas
  _lg_clear = lg.clear
  _lg_setScissor = lg.setScissor
  _lg_setColor = lg.setColor
  _lg_rectangle = lg.rectangle
  _lg_push = lg.push
  _lg_translate = lg.translate
  _lg_scale = lg.scale
  _lg_rotate = lg.rotate
  _lg_pop = lg.pop
  _lg_reset = lg.reset
  _lg_setShader = lg.setShader
  _lg_getDimensions = lg.getDimensions
  _lg_draw = lg.draw
end
local _Scene_copy = reg.Scene.copy

--- This is an internal function
-- Please use @{scene.newView} instead.
-- @tparam[opt] number x X-position in pixels
-- @tparam[opt] number y Y-position in pixels
-- @tparam[opt] number width Width in pixels
-- @tparam[opt] number height Height in pixels
-- @treturn view New view object
-- @see scene.newView
function view.construct(vx, vy, vw, vh)
  if vx == nil then
    vx, vy = 0, 0
    vw, vh = 0, 0
    if _lg_getDimensions then
      vw, vh = _lg_getDimensions()
    end
  end
  local t = reg.Layer.construct(0, 0)
  _Scene_copy(view, t)
  t.vx, t.vy = vx, vy
  t.vw, t.vh = vw, vh
  t.ox, t.oy = 0.5, 0.5
  t.background = { 0, 0, 0, 1 }
  t.camera = reg.Scene.newCamera(0, 0)
  return t
end

--- This is an internal function
-- @see node:destroy
function view:deconstruct()
  self.camera = nil
  self.background = nil
  reg.Layer.deconstruct(self)
end

--- This is an internal function
-- @tparam number x X-position in pixels
-- @tparam number y Y-position in pixels
-- @tparam number width Width in pixels
-- @tparam number height Height in pixels
function view:reset(vx, vy, vw, vh)
  self.vx, self.vy = vx, vy
  self.vw, self.vh = vw, vh
  self.ox, self.oy = 0.5, 0.5
  local c = self.background
  c[1], c[2], c[3], c[4] = 0, 0, 0, 1
  self.camera = reg.Scene.newCamera(0, 0)
  reg.Layer.reset(self, 0, 0)
end

--- Sets the position of the view inside the application window.
-- @tparam number x X-position in pixels
-- @tparam number y Y-position in pixels
function view:setPosition(vx, vy)
  self.vx, self.vy = vx, vy
end

--- Gets the position of the view inside the application window.
-- @treturn number X-position in pixels
-- @treturn number Y-position in pixels
function view:getPosition()
  return self.vx, self.vy
end

--- Gets the dimensions of the view inside the game window.
-- @treturn number Width in pixels
-- @treturn number Height in pixels
-- @see view:setDimensions
function view:getDimensions()
  return self.vw, self.vh
end

--- Sets the dimensions of the view inside the game window.
-- @tparam number width Width in pixels
-- @tparam number height Height in pixels
-- @see view:getDimensions
function view:setDimensions(vw, vh)
  vw = math.ceil(vw)
  vh = math.ceil(vh)
  if self.vw == vw and self.vh == vh then
    return
  end
  self.vw, self.vh = vw, vh
  if self.canvas then
    local ok, canvas = pcall(_lg_newCanvas, vw, vh)
    self.canvas = ok and canvas
  end
end

--- Sets the background color.
-- @tparam number red Red value (0-1)
-- @tparam number green Green value (0-1)
-- @tparam number blue Blue value (0-1)
-- @tparam[opt] number alpha Alpha value (0-1)
-- @see view:getBackground
function view:setBackground(r, g, b, a)
  if type(r) == "table" then
    r, g, b, a = unpack(r)
  end
  a = a or 1
  local bg = self.background
  bg[1], bg[2], bg[3], bg[4] = r, g, b, a
end

--- Gets the background color.
-- @treturn number Red value (0-1)
-- @treturn number Green value (0-1)
-- @treturn number Blue value (0-1)
-- @treturn number Alpha value (0-1)
-- @see view:setBackground
function view:getBackground()
  local bg = self.background
  return bg[1], bg[2], bg[3], bg[4]
end

--- Sets the pixel shader.
-- @tparam[opt] userdata shader Pixel shader object
-- @see view:getShader
function view:setShader(shader)
  if self.shader == shader then
    return
  end
  self.shader = shader
  if shader and not self.canvas then
    local ok, canvas = pcall(_lg_newCanvas, self.vw, self.vh)
    self.canvas = ok and canvas
  end
end

--- Gets the pixel shader.
-- @treturn userdata Pixel shader object
-- @see view:setShader
function view:getShader()
  return self.shader
end

--- By default, this function draws the view and all of its visible child nodes.
function view:draw()
  if not self.visible then
    return
  end

  local canvas = self.canvas
  local shader = self.shader

  local vx, vy = self.vx, self.vy
  local vw, vh = self.vw, self.vh
  _lg_origin()
  _lg_setBlendMode("alpha", "alphamultiply")
  if canvas and shader then
    _lg_setCanvas(canvas)
    _lg_clear(self.background)
  else
    _lg_setScissor(vx, vy, vw, vh)
    _lg_setColor(self.background)
    _lg_rectangle("fill", vx, vy, vw, vh)
  end
  
  _lg_push("transform")
  if not canvas then
    _lg_translate(vx, vy)
  end
  _lg_translate(self.ox*vw, self.oy*vh)
  _lg_rotate(self.r)
  _lg_scale(self.sx, self.sy)
  _lg_translate(-self.x, self.y)

  if self.camera then
    self.camera:render(self)
  end
  for _, v in ipairs(self.list) do
    v:draw()
  end

  _lg_pop()

  if canvas and shader then
    _lg_setCanvas()
    _lg_reset()
    _lg_setShader(shader)
    _lg_draw(canvas, vx, vy)
    _lg_setShader()
  else
    _lg_setScissor()
  end
end

--- Converts a position from local to scene coordinates.
-- The origin of the scene is the center of the root @{layer}.
-- @tparam number x Local X-coordinate
-- @tparam number y Local Y-coordinate
-- @treturn number Scene X-coordinate
-- @treturn number Scene Y-coordinate
-- @see view:rootToLocal
function view:localToRoot(x, y)
  return x, y
end

--- Converts a position from scene to local coordinates.
-- The origin of the scene is the center of the root @{layer}.
-- @tparam number x Scene X-coordinate
-- @tparam number y Scene Y-coordinate
-- @treturn number Local X-coordinate
-- @treturn number Local Y-coordinate
-- @see view:localToRoot
function view:rootToLocal(x, y)
  return x, y
end

--- Sets the origin of the view object based ratio values,
-- where 0, 0 is the top-left corner and 1, 1 is the bottom right.
-- The default origin of the view is the center or 0.5, 0.5.
-- @tparam number ox X-ratio from 0 to 1
-- @tparam number oy Y-ratio from 0 to 1
-- @see view:getOrigin
function view:setOrigin(ox, oy)
  self.ox = ox
  self.oy = oy
end

--- Gets the origin of the view object as ratio values,
-- where 0, 0 is the top-left corner and 1, 1 is the bottom right.
-- The origin of the view is the center or 0.5, 0.5.
-- @treturn number X-ratio from 0 to 1
-- @treturn number Y-ratio from 0 to 1
-- @see view:setOrigin
function view:getOrigin()
  return self.ox, self.oy
end

--- Converts a position from window to scene coordinates.
-- The origin of the scene is the center of the root @{layer}.
-- @tparam number x X-position in pixels
-- @tparam number y Y-position in pixels
-- @treturn number X scene coordinate
-- @treturn number Y scene coordinate
-- @see view:localToWindow
function view:windowToLocal(x, y)
  -- origin
  local ox = self.vx + self.vw*self.ox
  local oy = self.vy + self.vh*self.oy
  x = x - ox
  y = y - oy
  -- flip (y-axis increases up)
  --y = -y
  -- transform
  --x, y = self:localToParent(x, y)
  x, y = self:parentToLocal(x, y)
  return x, y
end

--- Converts a position from scene to window coordinates.
-- The origin of the scene is the center of the root @{layer}.
-- @tparam number x X scene coordinate
-- @tparam number y Y scene coordinate
-- @treturn number X-position in pixels
-- @treturn number Y-position in pixels
-- @see view:windowToLocal
function view:localToWindow(x, y)
  -- transform
  x, y = self:localToParent(x, y)
  -- flip (y-axis increases down)
  --y = -y
  -- origin
  local ox = self.vx + self.vw*self.ox
  local oy = self.vy + self.vh*self.oy
  x = x + ox
  y = y + oy
  return x, y
end

--- Converts window coordinates to scene coordinates.
-- This function works in conjunction with the currently associated camera.
-- @tparam number x X-position in pixels
-- @tparam number y Y-position in pixels
-- @treturn number X scene coordinate
-- @treturn number Y scene coordinate
-- @see view:windowToLocal
function view:windowToRoot(x, y)
  x, y = self:windowToLocal(x, y)
  local cam = self.camera
  -- zoom/range
  local vw, vh = self.vw, self.vh
  local rw, rh = cam.rw, cam.rh
  local sx, sy = cam.sx, cam.sy
  if rw > 0 and rh > 0 then
    sx, sy = vw/rw, vh/rh
  end
  x = x/sx
  y = y/sy
  -- rotate
  local r = -cam.r
  local c = _cos(r)
  local s = _sin(r)
  local rx = c*x - s*y
  local ry = s*x + c*y
  x, y = rx, ry
  -- translate
  x = x + cam.x
  y = y + cam.y
  -- hierarchy
  if cam.parent then
    x, y = cam.parent:localToRoot(x, y)
  end
  return x, y
end

--- Converts scene coordinates to window coordinates.
-- This function works in conjunction with the currently associated camera.
-- @tparam number x X scene coordinate
-- @tparam number y Y scene coordinate
-- @treturn number X-position in pixels
-- @treturn number Y-position in pixels
-- @see view:windowToLocal
function view:rootToWindow(x, y)
  local cam = self.camera
  if cam.parent then
    x, y = cam.parent:rootToLocal(x, y)
  end
  -- translate
  x = x - cam.x
  y = y - cam.y
  -- rotate
  local r = cam.r
  local c = _cos(r)
  local s = _sin(r)
  local rx = c*x - s*y
  local ry = s*x + c*y
  x, y = rx, ry
  -- zoom/range
  local vw, vh = self.vw, self.vh
  local rw, rh = cam.rw, cam.rh
  local sx, sy = cam.sx, cam.sy
  if rw > 0 and rh > 0 then
    sx, sy = vw/rw, vh/rh
  end
  x = x*sx
  y = y*sy
  x, y = self:localToWindow(x, y)
  return x, y
end

--- Gets the camera associated with the view.
-- @treturn camera camera Camera object
-- @see view:setCamera
function view:getCamera()
  return self.camera
end

--- Sets the camera for the view.
-- @tparam camera camera Camera object
-- @see view:getCamera
function view:setCamera(camera)
  self.camera = camera
end

return view.new
