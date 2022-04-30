local width = 15
local height = 30
local size = 64
local spriteSheet
local sprites = {}
local halfpi = math.pi / 2
local mower = {x = 0, y = 0, r = 0, m = false}
local targetMower = {x = 0, y = 0, r = 0}

function love.load()
  spriteSheet = love.graphics.newImage('assets/sprite.png', nil)

  sprites['grass'] = love.graphics.newQuad(0, 0, size, size, spriteSheet:getDimensions())
  sprites['mower'] = love.graphics.newQuad(size * 3, 0, size, size, spriteSheet:getDimensions())

  width = math.floor(love.graphics.getWidth() / size)
  height = math.floor(love.graphics.getHeight() / size)
end

function love.keypressed(key)
  if key == "up" or key == "w" then
    targetMower.y = mower.y - 1
    mower.r = -halfpi
  elseif key == "down" or key == "s" then
    targetMower.y = mower.y + 1
    mower.r = halfpi
  end
  
  if key == "left" or key == "a" then
    targetMower.x = mower.x - 1
    mower.m = true
    mower.r = 0
  elseif key == "right" or key == "d" then
    targetMower.x = mower.x + 1
    mower.m = false
    mower.r = 0
  end
end

function love.draw()
  local edge = size - 1

  for x = 1, width do
    for y = 1, height do
      love.graphics.draw(spriteSheet, sprites.grass, (x - 1) * size, (y - 1) * size)
    end
  end

  love.graphics.push()
  love.graphics.translate( mower.x * size, mower.y * size)

  local flip = 1
  if mower.m then flip = -1 end

  love.graphics.draw(spriteSheet, sprites.mower, size / 2, size / 2, mower.r, flip, 1, size / 2, size / 2 )

  love.graphics.pop()
end

function love.update(dt)
  mower.x = quad_in_out(targetMower.x, mower.x, dt * 100)
  mower.y = quad_in_out(targetMower.y, mower.y, dt * 100)
end

function lerp(a,b,t) return a * (1-t) + b * t end
function quadin(a, b, t) return lerp(a, b, t * t) end
function quad_in_out(a, b, t)
  if t <= 0.5 then
    return quadin(a, b, t*2) - (b-a)/2 -- scale by 2/0.5
  else
    return quadin(a, b, (1 - t)*2) + (b-a)/2 -- reverse and offset by 0.5
  end
end
