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
function view.new(vx, vy, vw, vh, mt)
  if vx == nil then
    vx, vy = 0, 0
    vw, vh = lg_getDimensions()
  end
  local t = reg.Layer.new(0, 0, mt or viewMT)
  t.vx, t.vy = vx, vy
  t.vw, t.vh = vw, vh
  t.cx, t.cy = vw/2, vh/2
  t.background = { 0, 0, 0, 1 }
  return t
end

--- Destroys the view and all of its children.
function view:destroy()
  self.background = nil
  reg.Layer.destroy(self)
end

--- Sets the position and dimensions of the view inside the game window.
-- @tparam number x X-position in pixels
-- @tparam number y Y-position in pixels
-- @tparam number width Width in pixels
-- @tparam number height Height in pixels
-- @see view:getBounds
function view:setBounds(vx, vy, vw, vh)
  self.vx, self.vy = vx, vy
  vw = math.ceil(vw)
  vh = math.ceil(vh)
  if self.vw == vw and self.vh == vh then
    return
  end
  self.vw, self.vh = vw, vh
  self.cx, self.cy = vw/2, vh/2 
  if self.canvas then
    local ok, canvas = pcall(lg_newCanvas, vw, vh)
    self.canvas = ok and canvas
  end
end

--- Gets the position and dimensions of the view inside the game window.
-- @treturn number X-position in pixels
-- @treturn number Y-position in pixels
-- @treturn number Width in pixels
-- @treturn number Height in pixels
-- @see view:setBounds
function view:getBounds()
  return self.vx, self.vy, self.vw, self.vh
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
  self:setBounds(self.vx, self.vy, vw, vh)
end

--- Sets the visible range in scene coordinates.
-- The specified position will be drawn in the center of the view.
-- @tparam number x Scene X-coordinate
-- @tparam number y Scene Y-coordinate
-- @tparam[opt] number width Range width
-- @tparam[opt] number height Range height
-- @see view:getScene
function view:setScene(x, y, w, h)
  self.x = x
  self.y = y
  if w and h then
    self.sx = self.vw/w
    self.sy = self.vh/h
  end
end

--- Gets the visible range in scene coordinates.
-- The returned position is drawn in the center of the view.
-- @treturn number Scene X-coordinate
-- @treturn number Scene Y-coordinate
-- @treturn[opt] number Range width
-- @treturn[opt] number Range height
-- @see view:setScene
function view:getScene()
  local w, h = self.vw/self.sx, self.vh/self.sy
  return self.x, self.y, w, h
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

--- Draws the view and all of its visible child nodes.
function view:draw()
  if not self.visible then
    return
  end

  local vx, vy, vw, vh = self:getBounds()
  local canvas = self.canvas
  local shader = self.shader

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
  lg_translate(self.cx, self.cy)
  lg_scale(self.sx, self.sy)
  lg_rotate(self.r)
  lg_translate(-self.x, self.y)
  for _, v in ipairs(self.list) do
    v:draw()
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
-- @see view:sceneToLocal
function view:localToScene(x, y)
  return x, y
end

--- Converts a position from scene to local coordinates.
-- The origin of the scene is the center of the root @{layer}.
-- @tparam number x Scene X-coordinate
-- @tparam number y Scene Y-coordinate
-- @treturn number Local X-coordinate
-- @treturn number Local Y-coordinate
-- @see view:localToScene
function view:sceneToLocal(x, y)
  return x, y
end

--- Converts a position from window to scene coordinates.
-- The origin of the scene is the center of the root @{layer}.
-- @tparam number x X window coordinate
-- @tparam number y Y window coordinate
-- @treturn number X scene coordinate
-- @treturn number Y scene coordinate
-- @see view:sceneToWindow
function view:windowToScene(x, y)
  -- origin (center of the viewport)
  x = x - self.cx
  y = y - self.cy
  -- flip (y-axis increases up)
  y = -y
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
-- @see view:windowToScene
function view:sceneToWindow(x, y)
  -- transform
  x, y = self:parentToLocal(x, y)
  -- flip (y-axis increases down)
  y = -y
  -- origin (top left of the window)
  x = self.cx + x
  y = self.cy + y
  return x, y
end

return view.new