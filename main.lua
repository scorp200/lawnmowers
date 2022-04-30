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
local grid = {}

local mowePower = 100

function love.load()
  love.graphics.setDefaultFilter( "nearest", "nearest")
  spriteSheet = love.graphics.newImage('assets/sprite.png', nil)

  sprites['grass'] = love.graphics.newQuad(0, 0, size, size, spriteSheet:getDimensions())
  sprites['grass_flowers'] = love.graphics.newQuad(size, 0, size, size, spriteSheet:getDimensions())
  sprites['mower'] = love.graphics.newQuad(size * 3, 0, size, size, spriteSheet:getDimensions())

  local grassTypes = {sprites.grass, sprites.grass_flowers}

  width = math.floor(love.graphics.getWidth() / size)
  height = math.floor(love.graphics.getHeight() / size)

  for x = 1, width do
    grid[x] = {}
    for y = 1, height do
      local index = love.math.random(#grassTypes)
      grid[x][y] = {
        tall = love.math.random(5, 10),
        age = 0,
        sprite = grassTypes[index]
      }
    end
  end
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

  targetMower.x = clamp(targetMower.x, 0, width - 1)
  targetMower.y = clamp(targetMower.y, 0, height - 1)
end

function love.draw()
  for x = 1, width do
    for y = 1, height do
      local grass = grid[x][y].sprite
      local dark = 1 - math.ldexp(grid[x][y].tall, -5)
      love.graphics.setColor(dark, dark, dark)
      love.graphics.draw(spriteSheet, grass, (x - 1) * size, (y - 1) * size)
      love.graphics.print(string.format('%.2f', grid[x][y].tall), (x - 1) * size, (y - 1) * size)
    end
    
    love.graphics.reset()
  end

  love.graphics.push()
  love.graphics.translate( math.floor(mower.x * size), math.floor(mower.y * size))

  love.graphics.draw(spriteSheet, sprites.mower, size / 2, size / 2, mower.r, 1, 1, size / 2, size / 2 )

  love.graphics.pop()
end

function love.update(dt)
  local easeDT = 1 - easeFunction ^ (dt * 20)
  mower.x = lerp(mower.x, targetMower.x, easeInOut(easeDT))
  mower.y = lerp(mower.y, targetMower.y, easeInOut(easeDT))
  mower.r = targetMower.r --lerp(mower.r, targetMower.r, easeInOut(easeDT))

  for x = 1, width do
    for y = 1, height do
      grid[x][y].tall = grid[x][y].tall + (grid[x][y].age / 100) * dt
      grid[x][y].age = grid[x][y].age + dt
    end
  end

  grid[targetMower.x + 1][targetMower.y + 1].tall = math.max(grid[targetMower.x + 1][targetMower.y + 1].tall - mowePower * dt, 0)
end

function lerp(a,b,t) return a + (b - a) * t end
function easeIn(t) return t * t end
function flip(x) return 1 - x end
function easeOut(t) return flip(flip(t)^2) end
function easeInOut(t) return lerp(easeIn(t), easeOut(t), t) end
function clamp(a, min, max) return math.max(min, math.min(a, max)) end
