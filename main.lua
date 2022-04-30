local width = 15
local height = 30
local size = 64
local spriteSheet
local sprites = {}
local halfpi = math.pi / 2
local mower = {x = 0, y = 0, r = 0, m = false}
local targetMower = {x = 0, y = 0, r = 0}
local tempDT = 0
local easeFunction = .3
local seed = 0

function love.load()
  love.graphics.setDefaultFilter( "nearest", "nearest")
  love.math.setRandomSeed(os.time() * 1000)
  seed = love.math.random() * 1000
  spriteSheet = love.graphics.newImage('assets/sprite.png', nil)

  sprites['grass'] = love.graphics.newQuad(0, 0, size, size, spriteSheet:getDimensions())
  sprites['grass_flowers'] = love.graphics.newQuad(size, 0, size, size, spriteSheet:getDimensions())
  sprites['mower'] = love.graphics.newQuad(size * 3, 0, size, size, spriteSheet:getDimensions())

  width = math.floor(love.graphics.getWidth() / size)
  height = math.floor(love.graphics.getHeight() / size)
end

function love.keypressed(key)
  if key == "up" or key == "w" then
    targetMower.y = targetMower.y - 1
    targetMower.r = -halfpi
    mower.m = false
  elseif key == "down" or key == "s" then
    targetMower.y = targetMower.y + 1
    targetMower.r = halfpi
    mower.m = false
  end
  
  if key == "left" or key == "a" then
    targetMower.x = targetMower.x - 1
    --mower.m = true
    targetMower.r = math.pi
  elseif key == "right" or key == "d" then
    targetMower.x = targetMower.x + 1
    mower.m = false
    targetMower.r = 0
  end
end

function love.draw()
  for x = 1, width do
    for y = 1, height do
      local grass
      if love.math.noise(x / 10, y / 10, seed) > .6 then grass = sprites.grass_flowers
      else grass = sprites.grass end
      love.graphics.draw(spriteSheet, grass, (x - 1) * size, (y - 1) * size)
    end
  end

  love.graphics.push()
  love.graphics.translate( math.floor(mower.x * size), math.floor(mower.y * size))

  love.graphics.draw(spriteSheet, sprites.mower, size / 2, size / 2, mower.r, 1, 1, size / 2, size / 2 )

  love.graphics.pop()
  love.graphics.print(os.time())
end

function love.update(dt)
  local easeDT = 1 - easeFunction ^ (dt * 20)
  tempDT = easeDT
  mower.x = lerp(mower.x, targetMower.x, easeInOut(easeDT))
  mower.y = lerp(mower.y, targetMower.y, easeInOut(easeDT))
  mower.r = targetMower.r --lerp(mower.r, targetMower.r, easeInOut(easeDT))
end

function lerp(a,b,t) return a + (b - a) * t end
function easeIn(t) return t * t end
function flip(x) return 1 - x end
function easeOut(t) return flip(flip(t)^2) end
function easeInOut(t) return lerp(easeIn(t), easeOut(t), t) end
