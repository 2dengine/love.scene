--- View is a clipped rectangular area where the scene is rendered.
-- Views can be transformed, drawn and easily shaded.
-- @module view
-- @alias view
-- @inherit layer
local view = {}
local viewMT = { __index = view }

local reg = debug.getregistry()
reg.View = view

setmetatable(view, { __index = reg.Layer })
view.stype = "View"

local lg = love.graphics
local lg_origin = lg.origin
local lg_setBlendMode = lg.setBlendMode
local lg_setCanvas = lg.setCanvas
local lg_newCanvas = lg.newCanvas
local lg_clear = lg.clear
local lg_setScissor = lg.setScissor
local lg_setColor = lg.setColor
local lg_rectangle = lg.rectangle
local lg_push = lg.push
local lg_translate = lg.translate
local lg_scale = lg.scale
local lg_rotate = lg.rotate
local lg_pop = lg.pop
local lg_reset = lg.reset
local lg_setShader = lg.setShader
local lg_getDimensions = lg.getDimensions
local lg_draw = lg.draw

--- This is an internal function.
-- Please use @{scene.newView} instead.
-- @tparam[opt] number x X-position in pixels
-- @tparam[opt] number y Y-position in pixels
-- @tparam[opt] number width Width in pixels
-- @tparam[opt] number height Height in pixels
-- @tparam[opt] table mt Metatable of base object
-- @treturn view New view object
-- @see scene.newView
function view.construct(vx, vy, vw, vh, mt)
  if vx == nil then
    vx, vy = 0, 0
    vw, vh = lg_getDimensions()
  end
  local t = reg.Layer.construct(0, 0, mt or viewMT)
  t.vx, t.vy = vx, vy
  t.vw, t.vh = vw, vh
  t.background = { 0, 0, 0, 1 }
  return t
end

--- This is an internal function.
-- @see node:destroy
function view:deconstruct()
  self.background = nil
  reg.Layer.deconstruct(self)
end

--- This is an internal function.
-- @tparam number x X-position in pixels
-- @tparam number y Y-position in pixels
-- @tparam number width Width in pixels
-- @tparam number height Height in pixels
function view:reset(vx, vy, vw, vh)
  self.vx, self.vy = vx, vy
  self.vw, self.vh = vw, vh
  local c = self.background
  c[1], c[2], c[3], c[4] = 0, 0, 0, 1
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
    local ok, canvas = pcall(lg_newCanvas, vw, vh)
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
    local ok, canvas = pcall(lg_newCanvas, self.vw, self.vh)
    self.canvas = ok and canvas
  end
end

--- Gets the pixel shader.
-- @treturn userdata Pixel shader object
-- @see view:setShader
function view:getShader()
  return self.shader
end

--- Gets the camera associated with the view.
-- @treturn camera camera Camera object
-- @see view:setCamera
function view:getCamera()
  return self.camera
end

--- Sets the camera for the view.
-- @tparam[opt] camera camera Camera object
-- @see view:getCamera
function view:setCamera(camera)
  self.camera = camera
end

--- By default, this function draws the view and all of its visible child nodes.
-- If the optional camera parameter is provided,
-- this function renders the viewing range of the camera inside the view.
-- @tparam[opt] camera camera Camera object
function view:draw(camera)
  if not self.visible then
    return
  end

  local vx, vy = self.vx, self.vy
  local canvas = self.canvas
  local shader = self.shader

  local vw, vh = self.vw, self.vh
  lg_origin()
  lg_setBlendMode("alpha", "alphamultiply")
  if canvas and shader then
    lg_setCanvas(canvas)
    lg_clear(self.background)
  else
    lg_setScissor(vx, vy, vw, vh)
    lg_setColor(self.background)
    lg_rectangle("fill", vx, vy, vw, vh)
  end
  
  lg_push("transform")
  if not canvas then
    lg_translate(vx, vy)
  end
  lg_translate(vw/2, vh/2)
  lg_scale(self.sx, self.sy)
  lg_rotate(self.r)
  lg_translate(-self.x, self.y)

  if camera then
    camera:render(self)
  else
    for _, v in ipairs(self.list) do
      v:draw()
    end
  end

  lg_pop()

  if canvas and shader then
    lg_setCanvas()
    lg_reset()
    lg_setShader(shader)
    lg_draw(canvas, vx, vy)
    lg_setShader()
  else
    lg_setScissor()
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

--- Converts a position from window to scene coordinates.
-- The origin of the scene is the center of the root @{layer}.
-- @tparam number x X window coordinate
-- @tparam number y Y window coordinate
-- @treturn number X scene coordinate
-- @treturn number Y scene coordinate
-- @see view:localToWindow
function view:windowToLocal(x, y)
  -- origin (center of the viewport)
  x = x - self.vx - self.vw/2
  y = y - self.vy - self.vh/2
  -- flip (y-axis increases up)
  --y = -y
  -- transform
  x, y = self:localToParent(x, y)
  return x, y
end

--- Converts a position from scene to window coordinates.
-- The origin of the scene is the center of the root @{layer}.
-- @tparam number x X scene coordinate
-- @tparam number y Y scene coordinate
-- @treturn number X window coordinate
-- @treturn number Y window coordinate
-- @see view:windowToLocal
function view:localToWindow(x, y)
  -- transform
  x, y = self:parentToLocal(x, y)
  -- flip (y-axis increases down)
  --y = -y
  -- origin (top left of the window)
  x = self.vx + self.vw/2 + x
  y = self.vy + self.vh/2 + y
  return x, y
end

return view.new