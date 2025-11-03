--[[
This file is part of the "love.scene" library.
https://2dengine.com/doc/scene.html

MIT License

Copyright (c) 2020 2dengine LLC

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]]

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

--- Creates a new node object.
-- This is an internal function.
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

--- Makes a shallow copy of the node's properties.
-- This is an internal function.
-- @tparam node src Source node
-- @tparam node dest Destination node
function scene.copy(src, dest)
  for k, v in pairs(src) do
    dest[k] = v
  end
end

--- Removes a node from the live pool.
-- This is an internal function.
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

-- nodes
local path = (...)
path = path:gsub('%.init$', '')
require(path..".node")
require(path..".sprite")
require(path..".layer")
require(path..".camera")
require(path..".view")

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