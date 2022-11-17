--- Abstract scene graph node.
-- @module node
-- @alias node
local node = {}
local nodeMT = { __index = node }

local reg = debug.getregistry()
reg.Node = node

node.stype = "Node"

--- This is an internal function.
-- @tparam number x X-coordinate
-- @tparam number y Y-coordinate
-- @tparam[opt] table mt Metatable of base object
-- @treturn node New node
function node.new(x, y, mt)
  --assert(x and y)
  local t = { x = x, y = y, r = 0, sx = 1, sy = 1 }
  t.transform = love.math.newTransform(x, y)
  t.visible = true
  t.changed = true
  return setmetatable(t, mt or nodeMT)
end

--- Destroys the node removing it from its parent @{layer}.
function node:destroy()
  local p = self.parent
  if p then
    p:removeChild(self)
  end
  self.transform = nil
end

--- Returns the node type as a string ("Sprite", "Layer" or "View").
-- @treturn string Node type
function node:type()
  return self.stype
end

--- Returns the top ancestor or the root @{layer} of the node.
-- @treturn layer Root layer
function node:getRoot()
  local p = self.parent
  if not p then
    return self
  end
  return p:getRoot()
end

--- Sets the parent @{layer} of the node.
-- One node cannot have multiple parents.
-- @tparam layer parent New parent layer
function node:setParent(p2)
  local p1 = self.parent
  if p1 then
    p1:removeChild(self)
  end
  p2:insertChild(self)
end

--- Gets the depth index relative to other nodes in the parent @{layer}.
-- @treturn number Depth index
-- @see node:setDepth
function node:getDepth()
  local p = self.parent
  return p and p:getChildDepth(self)
end

--- Sets the depth index relative to other nodes in the parent @{layer}.
-- Setting the depth to 1 will draw the node first, before all others.
-- Setting the depth to 0 will draw the node last, after all others.
-- This depth index may shift as node are added, removed or sorted.
-- @tparam number index Depth index (could be negative)
-- @see node:getDepth
-- @see layer:sort
function node:setDepth(i)
  local p = self.parent
  return p and p:setChildDepth(self, i)
end

--- Compares the depth of two nodes, based on their Y-coordinates.
-- @tparam node other Other other
-- @treturn boolean True if this node is in front of the other
function node:compareDepth(other)
  if self.y == other.y then
    return self.x < other.x
  end
  return self.y < other.y
end

--- Gets the position of the node.
-- @treturn number X-coordinate
-- @treturn number Y-coordinate
-- @see node:setPosition
function node:getPosition()
  return self.x, self.y
end

--- Sets the position of the node.
-- @tparam number x X-coordinate
-- @tparam number y Y-coordinate
-- @see node:getPosition
function node:setPosition(x, y)
  self.x = x
  self.y = y
  self.changed = true
end

--- Gets the rotation of the node.
-- @treturn number Angle in radians
-- @see node:setRotation
function node:getRotation()
  return self.r
end

--- Sets the rotation of the node.
-- @tparam number angle Angle in radians
-- @see node:getRotation
function node:setRotation(r)
  self.r = r
  self.changed = true
end

--- Gets the scale of the node.
-- @treturn number X-axis scale
-- @treturn number Y-axis scale
-- @see node:setScale
function node:getScale()
  return self.sx, self.sy
end

--- Sets the scale of the node.
-- @tparam number sx X-axis scale
-- @tparam number sy Y-axis scale
-- @see node:getScale
function node:setScale(sx, sy)
  self.sx = sx
  self.sy = sy
  self.changed = true
end

--- Gets the position and rotation of the node.
-- @treturn number X-coordinate
-- @treturn number Y-coordinate
-- @treturn number Angle in radians
-- @see node:setTransform
function node:getTransform()
  return self.x, self.y, self.r
end

--- Sets the position and rotation of the node.
-- @tparam number x X-coordinate
-- @tparam number y Y-coordinate
-- @tparam number angle Angle in radians
-- @see node:getTransform
function node:setTransform(x, y, r)
  self.x = x
  self.y = y
  self.r = r
  self.changed = true
end

--- Gets the visibility of the node.
-- Non-visible nodes are not drawn at all.
-- @treturn boolean True if visible
-- @see node:setVisible
function node:getVisible()
  return self.visible
end

--- Sets the visibility of the node.
-- Non-visible nodes are not drawn at all.
-- @tparam boolean True if visible
-- @see node:getVisible
function node:setVisible(on)
  self.visible = (on == true)
end

--- Converts a position from window to local coordinates.
-- This is useful because the mouse cursor is also in windows coordinates.
-- The top left corner of the game window is its origin.
-- @tparam number x Window X-coordinate
-- @tparam number y Window Y-coordinate
-- @treturn number Local X-coordinate
-- @treturn number Local Y-coordinate
-- @see node:localToWindow
function node:windowToLocal(x, y)
  local r = self:getRoot()
  if r and r.windowToScene then
    x, y = r:windowToScene(x, y)
    return self:sceneToLocal(x, y)
  end
end

--- Converts a position from local to window coordinates.
-- This is useful because the mouse cursor is also in windows coordinates.
-- The top left corner of the game window is its origin.
-- @tparam number x Local X-coordinate
-- @tparam number y Local Y-coordinate
-- @treturn number Window X-coordinate
-- @treturn number Window Y-coordinate
-- @see node:windowToLocal
function node:localToWindow(x, y)
  local r = self:getRoot()
  if r and r.sceneToWindow then
    x, y = self:localToScene(x, y)
    return r:sceneToWindow(x, y)
  end
end

--- Converts a position from scene to local coordinates.
-- The origin of the scene is the center of the root @{layer}.
-- @tparam number x Scene X-coordinate
-- @tparam number y Scene Y-coordinate
-- @treturn number Local X-coordinate
-- @treturn number Local Y-coordinate
-- @see node:localToScene
function node:sceneToLocal(x, y)
  local p = self.parent
  if p then
    x, y = p:sceneToLocal(x, y)
  end
  return self:parentToLocal(x, y)
end

--- Converts a position from local to scene coordinates.
-- The origin of the scene is the center of the root @{layer}.
-- @tparam number x Local X-coordinate
-- @tparam number y Local Y-coordinate
-- @treturn number Scene X-coordinate
-- @treturn number Scene Y-coordinate
-- @see node:sceneToLocal
function node:localToScene(x, y)
  x, y = self:localToParent(x, y)
  local p = self.parent
  if p then
    x, y = p:localToScene(x, y)
  end
  return x, y
end

--- Converts a position from parent to local coordinates.
-- The center of the parent @{layer} is its origin.
-- @tparam number x Parent X-coordinate
-- @tparam number y Parent Y-coordinate
-- @treturn number Local X-coordinate
-- @treturn number Local Y-coordinate
-- @see node:localToParent
function node:parentToLocal(x, y)
  -- translate
  x = x - self.x
  y = y - self.y
  -- scale
  x = x*self.sx
  y = y*self.sy
  -- rotate
  local r = -self.r
  local c = math.cos(r)
  local s = math.sin(r)
  local rx = c*x - s*y
  local ry = s*x + c*y
  x, y = rx, ry
  return x, y
end

--- Converts a position from local to parent coordinates.
-- The center of the parent @{layer} is its origin.
-- @tparam number x Local X-coordinate
-- @tparam number y Local Y-coordinate
-- @treturn number Parent X-coordinate
-- @treturn number Parent Y-coordinate
-- @see node:parentToLocal
function node:localToParent(x, y)
  -- rotate
  local r = self.r
  local c = math.cos(r)
  local s = math.sin(r)
  local rx = c*x - s*y
  local ry = s*x + c*y
  x, y = rx, ry
  -- scale
  x = x/self.sx
  y = y/self.sy
  -- translate
  x = x + self.x
  y = y + self.y
  return x, y
end

return node.new