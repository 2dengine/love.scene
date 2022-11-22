--- This is the main module of the scene graph library.
-- @module scene
-- @alias scene
local scene = {}

-- nodes
local path = (...)
require(path..".node")

--- Creates a new @{sprite} object.
-- Alternatively, you can use @{layer:newSprite}.
-- @function scene.newSprite(x,y)
-- @tparam number x X coordinate
-- @tparam number y Y coordinate
-- @treturn sprite New sprite object
-- @see layer:newSprite
scene.newSprite = require(path..".sprite")

--- Creates a new @{layer} object.
-- Alternatively, you can use @{layer:newLayer}.
-- @function scene.newLayer(x,y)
-- @tparam number x X coordinate
-- @tparam number y Y coordinate
-- @treturn layer New layer object
-- @see layer:newLayer
scene.newLayer = require(path..".layer")

--- Creates a new @{camera} object.
-- Alternatively, you can use @{layer:newCamera}.
-- @function scene.newCamera(x,y)
-- @tparam number x X coordinate
-- @tparam number y Y coordinatex
-- @treturn camera New camera object
-- @see layer:newCamera
scene.newCamera = require(path..".camera")

--- Creates a new @{view} object.
-- If no parameters are supplied, the view takes on the dimensions of the window.
-- @function scene.newView(x,y,width,height)
-- @tparam[opt] number x X-position in pixels
-- @tparam[opt] number y Y-position in pixels
-- @tparam[opt] number width Width in pixels
-- @tparam[opt] number height Height in pixels
-- @treturn view New view object
scene.newView = require(path..".view")

return scene