--- This is the main module of the scene graph library.
-- The scene. module is used to create new nodes.
-- @module scene
-- @alias scene
local scene = {}
scene.cache = 5000
scene.count = 0

local reg = debug.getregistry()
reg.Scene = scene

local _insert = table.insert
local _remove = table.remove
local pool = { Sprite = {}, Layer = {}, Camera = {}, View = {} }
local live = {}

--- This is an internal function
-- @tparam node t Existing node
-- @tparam arguments ... Constructor arguments
-- @treturn node New node object
-- @see scene.newSprite
-- @see scene.newCamera
-- @see scene.newLayer
-- @see scene.newView
function scene.new(t, ...)
  local c = _remove(pool[t])
  if c then
    c:reset(...)
  else
    c = reg[t].construct(...)
    c.managed = true
  end
  live[c] = true
  scene.count = scene.count + 1
  return c
end
local _scene_new = scene.new

--- This is an internal function
-- @tparam node src Source node
-- @tparam node dest Destination node
function scene.copy(src, dest)
  for k, v in pairs(src) do
    dest[k] = v
  end
end

--- This is an internal function
-- @tparam node t Existing node
-- @see node:destroy
function scene.destroy(n)
  if live[n] then
    live[n] = nil
    scene.count = scene.count - 1
    if scene.count <= scene.cache and n.managed then
      _insert(pool[n.stype], n)
      return
    end
    n:deconstruct()
  end
end

-- nodes
local path = (...)
path = path:gsub('%.init$', '')
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
  return _scene_new("Sprite", x, y)
end

--- Creates a new @{layer} object.
-- Alternatively, you can use @{layer:newLayer}.
-- @function scene.newLayer(x,y)
-- @tparam number x X coordinate
-- @tparam number y Y coordinate
-- @treturn layer New layer object
-- @see layer:newLayer
function scene.newLayer(x, y)
  return _scene_new("Layer", x, y)
end

--- Creates a new @{camera} object.
-- Alternatively, you can use @{layer:newCamera}.
-- @function scene.newCamera(x,y)
-- @tparam number x X coordinate
-- @tparam number y Y coordinatex
-- @treturn camera New camera object
-- @see layer:newCamera
function scene.newCamera(x, y)
  return _scene_new("Camera", x, y)
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