--- Layers are basically groups of nodes, containing either sprites or other nested layers. Layers are helpful in ordering nodes along the Z-axis.
-- Layers are used to build things like parallax, huds, minimaps and so on.
-- @module layer
-- @alias layer
-- @inherit node
local layer = {}
local layerMT = { __index = layer }

local reg = debug.getregistry()
reg.Layer = layer

setmetatable(layer, { __index = reg.Node })
layer.stype = "Layer"

local tinsert = table.insert
local tremove = table.remove
local tsort = table.sort
local lg = love.graphics
local lg_push = lg.push
local lg_applyTransform = lg.applyTransform
local lg_pop = lg.pop
local Transform_setTransformation = reg.Transform.setTransformation
local Node_construct = reg.Node.construct
local Node_deconstruct = reg.Node.deconstruct
local Node_reset = reg.Node.reset
local Scene_new = reg.Scene.new

--- This is an internal function.
-- Please use @{scene.newLayer} or @{layer.newLayer} instead.
-- @tparam number x X coordinate
-- @tparam number y Y coordinate
-- @tparam[opt] table mt Metatable of base object
-- @treturn layer New layer
-- @see layer:newLayer
-- @see scene.newLayer
function layer.construct(x, y, mt)
  local t = Node_construct(x, y, mt or layerMT)
  t.list = {}
  return t
end

--- This is an internal function.
-- @see node:destroy
function layer:deconstruct()
  self:destroyChildren()
  self.list = nil
  Node_deconstruct(self)
end

--- Destroys all of the child nodes.
function layer:destroyChildren()
  local list = self.list
  if list then
    for i = #list, 1, -1 do
      local v = list[i]
      v.parent = nil
      v:destroy()
      list[i] = nil
    end
  end
end

--- This is an internal function.
-- @tparam number x X-coordinate
-- @tparam number y Y-coordinate
function layer:reset(x, y)
  self:removeChildren()
  Node_reset(self, x, y)
end

--- Removes all child nodes without destroying them.
function layer:removeChildren()
  local list = self.list
  for i = #list, 1, -1 do
    list[i].parent = nil
    list[i] = nil
  end
end

--- This is an internal function.
-- Removes an existing child node from the layer.
-- @tparam node child Child node
function layer:removeChild(c)
  local list = self.list
  for i = 1, #list do
    if c == list[i] then
      c.parent = nil
      tremove(list, i)
      break
    end
  end
end
local Layer_removeChild = reg.Layer.removeChild

--- This is an internal function.
-- Adds a new child node to the layer.
-- @tparam node child Child node
function layer:insertChild(c)
  local p = c.parent
  if p then
    Layer_removeChild(p, c)
  end
  c.parent = self
  tinsert(self.list, c)
end
local Layer_insertChild = reg.Layer.insertChild

--- Creates a new sprite at the given position.
-- Sets the parent of the new sprite to the current node.
-- @tparam number x X-coordinate
-- @tparam number y Y-coordinate
-- @treturn sprite New sprite object
function layer:newSprite(x, y)
  local c = Scene_new("Sprite", x, y)
  Layer_insertChild(self, c)
  return c
end

--- Creates a new layer at the given position.
-- Sets the parent of the new layer to the current node.
-- @tparam number x X-coordinate
-- @tparam number y Y-coordinate
-- @treturn layer New layer object
function layer:newLayer(x, y)
  local c = Scene_new("Layer", x, y)
  Layer_insertChild(self, c)
  return c
end

--- Creates a new camera at the given position.
-- Sets the parent of the new camera to the current node.
-- @tparam number x X-coordinate
-- @tparam number y Y-coordinate
-- @treturn camera New camera object
function layer:newCamera(x, y)
  local c = Scene_new("Camera", x, y)
  Layer_insertChild(self, c)
  return c
end

--- Returns a child node based on depth index (could be negative).
-- @tparam number index Depth index
function layer:getChild(i)
  i = (i - 1)%#self.list + 1
  return self.list[i]
end

--- Gets the depth index of a child node.
-- @tparam node child Child node
-- @treturn number Depth index
function layer:getChildDepth(c)
  local list = self.list
  for i = 1, #list do
    if list[i] == c then
      return i
    end
  end
end
local Layer_getChildDepth = reg.Layer.getChildDepth

--- Sets the depth index of a child node.
-- This depth index may shift as node are added, removed or sorted.
-- @tparam node child Child node
-- @tparam number index Depth index (could be negative)
function layer:setChildDepth(c, i)
  local j = Layer_getChildDepth(self, c)
  if not j then
    return
  end
  local list = self.list
  i = (i - 1)%#list + 1
  if i == j then
    return
  end
  tremove(list, j)
  tinsert(list, i, c)
end

--- Sorts the child nodes based on a comparison function.
-- If no comparison function is specified, nodes are sorted based on their Y-coordinates.
-- This is useful in isometric or overhead games.
-- @tparam[opt] function func Comparison function
function layer:sort(func)
  tsort(self.list, func or self.compareDepth)
end

--- This is an internal function.
-- @see view:draw
function layer:draw()
  if not self.visible then
    return
  end
  local trans = self.transform
  if self.changed then
    Transform_setTransformation(trans, self.x, self.y, self.r, self.sx, self.sy)
    self.changed = nil
  end
  lg_push("transform")
  lg_applyTransform(trans)
  for _, v in ipairs(self.list) do
    v:draw()
  end
  lg_pop()
end

return layer.new