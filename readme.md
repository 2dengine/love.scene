# Love2D Scene Graph
Small scene graph compatible with Love2D 11.3 and 11.4.

# Documentation
The complete documentation is available at: https://2dengine.com/?p=scene

# Installation
Copy the folder called "scene" to your game directory.
The scene graph can be included like so:
```lua
love.scene = require("scene")
```

# Usage
The scene graph is fairly minimal, relying on just four different objects.
Scene nodes are created using two different shortcuts:
```lua
local view = love.scene.newView()
-- object-oriented style
local s1 = view:newSprite(0, 0)
-- Love2D style
local s2 = love.scene.newSprite(0, 0)
s2:setParent(view)
```
Once the scene is setup, you can draw it like so:
```lua
function love.draw()
  view:draw()
end
```

# Nodes
## View
View is a clipped rectangular area where the scene is rendered.
Views can be transformed, drawn and easily shaded.
```lua
local view = love.scene.newView()
-- shading
local shader = love.graphics.newShader([[ vec4 effect( vec4 c, Image t, vec2 tc, vec2 sc ){
  vec4 p = Texel(t, tc );
  number a = (p.r+p.b+p.g)/3.0;
  number f = tc.x;
  p.r = p.r + (a - p.r)*f;
  p.g = p.g + (a - p.g)*f;
  p.b = p.b + (a - p.b)*f;
  return p;
} ]])
view:setShader(shader)

function love.draw()
  view:draw()
end
```

## Sprite
Sprites are nodes in the scene which can be translated, scaled or rotated.
Each sprite is assigned a "drawable" graphic, usually an image, quad or text.
Sprites can also be assigned a specific color, alpha value and blending mode.
```lua
local sprite = view:newSprite(0, 0)
-- transform
sprite:setPosition(100, 0)
sprite:setRotation(math.pi/2)
sprite:setScale(1, 2)
-- draw
local image = love.graphics.newImage("myimage.png")
sprite:setGraphic(image)
-- modulate
sprite:setColor(1, 0, 0)
sprite:setAlpha(0.5)
sprite:setMode("add")
```

## Layer
Layers are basically groups of nodes, containing either sprites or other nested layers.
Layers are helpful in ordering nodes along the Z-axis.
Layers are used to build things like parallax, huds, minimaps and so on.
```lua
local root = view:newLayer(0, 0)
local a = root:newSprite(0, 0)
local b = root:newSprite(0, 0)
a:setGraphic('under.png')
b:setGraphic('over.png')
-- modify drawing order
b:setDepth(1)
```

## Camera
Cameras can be transformed just like regular nodes and can also render their surroundings onto a view object.
```lua
local view = love.scene.newView()
local root = love.scene.newLayer(0, 0)
local cam = root:newCamera(100, 0)
cam:setRange(800, 400)
view:setCamera(cam)
```