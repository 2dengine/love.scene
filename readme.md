# Introduction
love.scene is a two-dimensional scene graph library written for the [LÖVE](https://love2d.org) game framework (compatible with LÖVE 11.3, 11.4 and 11.5).
To install the scene graph, copy the "scene" folder to your game directory and use require:
```lua
love.scene = require("scene")
```

The source code is available on [GitHub](https://github.com/2dengine/love.scene) and the official documentation is hosted on [2dengine.com](https://2dengine.com/doc/scene.html)

# Usage
The scene graph is fairly minimal, relying on just four different types of objects.
Scene nodes are created using two different methods:
```lua
local view = love.scene.newView()
-- object-oriented style
local s1 = view:newSprite(0, 0)
-- Love2D style
local s2 = love.scene.newSprite(0, 0)
s2:setParent(view)
```
Images, text and other types of [drawable](https://www.love2d.org/wiki/Drawable) graphics are rendered as follows:
```lua
-- image
local image = love.graphics.newImage("mytexture.png")
s1:setGraphic(image)
-- text
local font = love.graphics.getFont()
local text = love.graphics.newText(font, "Hello world")
s2:setGraphic(text)

function love.draw()
  view:draw()
end
```

# Nodes
## Sprite
Sprites are nodes in the scene which can be translated, scaled or rotated.
Each sprite is assigned a "drawable" graphic, usually an image, quad or text.
Sprites can also be modulated by changing their color, alpha value and blending mode.
```lua
local sprite = view:newSprite(0, 0)
-- draw
local image = love.graphics.newImage("myimage.png")
sprite:setGraphic(image)
-- transform
sprite:setPosition(100, 0)
sprite:setRotation(math.pi/2)
sprite:setScale(1, 2)
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
a:setGraphic(love.graphics.newImage('background.png'))
b:setGraphic(love.graphics.newImage('foreground.png'))
-- modify drawing order
b:setDepth(1)
```

## View
View is a clipped rectangular area inside the application window where the scene is rendered.
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

## Camera
Cameras can be transformed just like regular nodes and can also render their surroundings onto a view object.
```lua
local view = love.scene.newView()
local root = love.scene.newLayer(0, 0)
local cam = root:newCamera(100, 0)
cam:setRange(800, 400)
view:setCamera(cam)
```
