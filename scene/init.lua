--- This is the main module of the scene graph library.
-- @module scene
-- @alias scene
local scene = {}

-- nodes
local path = (...)
require(path..".node")
require(path..".sprite")
require(path..".layer")
require(path..".view")
local reg = debug.getregistry()

--- Creates a new @{sprite} object.
-- Alternatively, you can use @{layer:newSprite} or @{view:newSprite}.
-- @function scene.newSprite(x,y)
-- @tparam node parent Parent node
-- @tparam number x X coordinate
-- @tparam number y Y coordinate
-- @treturn sprite New sprite object
-- @see layer:newSprite
-- @see view:newSprite
scene.newSprite = reg.Layer.newSprite

--- Creates a new @{layer} object.
-- Alternatively, you can use @{layer:newLayer} or @{view:newLayer}.
-- @function scene.newLayer(x,y)
-- @tparam node parent Parent node
-- @tparam number x X coordinate
-- @tparam number y Y coordinate
-- @treturn layer New layer object
-- @see layer:newLayer
-- @see view:newLayer
scene.newLayer = reg.Layer.newLayer

--- Creates a new @{view} object.
-- If no parameters are supplied, the view takes on the dimensions of the window.
-- @function scene.newView(x,y,width,height)s
-- @tparam[opt] number x X-position in pixels
-- @tparam[opt] number y Y-position in pixels
-- @tparam[opt] number width Width in pixels
-- @tparam[opt] number height Height in pixels
-- @treturn view New view object
scene.newView = reg.View.new

return scene