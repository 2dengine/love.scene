--- This is the main module of the scene graph library.
-- @module scene
-- @alias scene
local scene = {}

local reg = debug.getregistry()
reg.Scene = scene

scene.cache = 3000
scene.count = 0

local tinsert = table.insert
local tremove = table.remove
local pool = { Sprite = {}, Layer = {}, Camera = {}, View = {} }
local live = { Sprite = {}, Layer = {}, Camera = {}, View = {} }

--- This is an internal function
-- @tparam node t Existing node
-- @tparam arg ... Constructor arguments
-- @treturn node New node object
-- @see scene.newSprite
-- @see scene.newCamera
-- @see scene.newLayer
-- @see scene.newView
function scene.new(t, ...)
  local c = tremove(pool[t])
  if c then
    c:reset(...)
  else
    c = reg[t].construct(...)
  end
  live[t][c] = true
  scene.count = scene.count + 1
  return c
end

--- This is an internal function
-- @tparam node t Existing node
-- @see node:destroy
function scene.destroy(n)
  local t = n.stype
  live[t][n] = nil
  scene.count = scene.count - 1
  if scene.count <= scene.cache then
    tinsert(pool[t], n)
  else
    n:deconstruct()
  end
end

-- nodes
local path = (...)
require(path..".node")
require(path..".sprite")
require(path..".layer")
require(path..".camera")
require(path..".view")

--- Creates a new @{sprite} object.
-- Alternatively, you can use @{layer:newSprite}.
-- @function scene.newSprite(x,y)
-- @tparam number x X coordinate
-- @tparam number y Y coordinate
-- @treturn sprite New sprite object
-- @see layer:newSprite
function scene.newSprite(x, y)
  return scene.new("Sprite", x, y)
end

--- Creates a new @{layer} object.
-- Alternatively, you can use @{layer:newLayer}.
-- @function scene.newLayer(x,y)
-- @tparam number x X coordinate
-- @tparam number y Y coordinate
-- @treturn layer New layer object
-- @see layer:newLayer
function scene.newLayer(x, y)
  return scene.new("Layer", x, y)
end

--- Creates a new @{camera} object.
-- Alternatively, you can use @{layer:newCamera}.
-- @function scene.newCamera(x,y)
-- @tparam number x X coordinate
-- @tparam number y Y coordinatex
-- @treturn camera New camera object
-- @see layer:newCamera
function scene.newCamera(x, y)
  return scene.new("Camera", x, y)
end

--- Creates a new @{view} object.
-- If no parameters are supplied, the view takes on the dimensions of the window.
-- @function scene.newView(x,y,width,height)
-- @tparam[opt] number x X-position in pixels
-- @tparam[opt] number y Y-position in pixels
-- @tparam[opt] number width Width in pixels
-- @tparam[opt] number height Height in pixels
-- @treturn view New view object
scene.newView = reg.View.construct

return scene