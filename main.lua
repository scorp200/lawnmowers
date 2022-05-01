local width = 15
local height = 30
local size = 64
local spriteSheet
local sprites = {}
local halfpi = math.pi / 2

local mower = {x = 0, y = 0, r = 0, m = false}
local queMower = {x = 0, y = 0, r = 0}
local targetMower = {x = 0, y = 0, r = 0}

local easeFunction = .3
local grid = {}
local grassCollection = {totalWeight = 0, collection = {}}
local keyDelay = .1
local keyTime = keyDelay

local mowePower = 100
local growFactor = .01

local offsetX
local offsetY

function love.load()
  love.graphics.setDefaultFilter( "nearest", "nearest")
  spriteSheet = love.graphics.newImage('assets/sprite.png', nil)

  sprites['grass'] = love.graphics.newQuad(0, 0, size, size, spriteSheet:getDimensions())
  sprites['grass_flowers'] = love.graphics.newQuad(size, 0, size, size, spriteSheet:getDimensions())
  sprites['grass_dirt'] = love.graphics.newQuad(size * 2, 0, size, size, spriteSheet:getDimensions())
  sprites['grass_dirt_skull'] = love.graphics.newQuad(0, size, size, size, spriteSheet:getDimensions())
  sprites['grass_dying'] = love.graphics.newQuad(size, size, size, size, spriteSheet:getDimensions())
  sprites['grass_grassy'] = love.graphics.newQuad(size * 2, size, size, size, spriteSheet:getDimensions())
  sprites['mower'] = love.graphics.newQuad(size * 3, 0, size, size, spriteSheet:getDimensions())
  sprites['fence_front'] = love.graphics.newQuad(size * 7, size, size, size, spriteSheet:getDimensions())
  sprites['fence_right'] = love.graphics.newQuad(size * 8, size, size, size, spriteSheet:getDimensions())
  sprites['fence_left'] = love.graphics.newQuad(size * 9, size, size, size, spriteSheet:getDimensions())

  addToCollection(grassCollection, sprites.grass, 100)
  addToCollection(grassCollection, sprites.grass_flowers, 100)
  addToCollection(grassCollection, sprites.grass_grassy, 90)
  addToCollection(grassCollection, sprites.grass_dying, 60)
  addToCollection(grassCollection, sprites.grass_dirt, 3)
  addToCollection(grassCollection, sprites.grass_dirt_skull, 1)

  width = math.floor(love.graphics.getWidth() / size)
  height = math.floor(love.graphics.getHeight() / size)

  offsetX = love.graphics.getWidth() / 2 - (width * size) / 2
  offsetY = love.graphics.getHeight() / 2 - (height * size) / 2

  mower.x =  math.floor(width / 2)
  targetMower.x = mower.x
  queMower.x = mower.x
  mower.y =  math.floor(height / 2)
  targetMower.y = mower.y
  queMower.y = mower.y

  for x = 0, width + 1 do
    grid[x] = {}
    for y = 0, height + 1 do
      local fence = nil

      if y == 1 and x > 0 and x <= width then fence = sprites.fence_front
      elseif x == 1 and y > 1 and y < width then fence = sprites.fence_left
      elseif x == width and y > 1 and y < width then fence = sprites.fence_right end

      grid[x][y] = {
        tall = love.math.random(5, 10),
        age = 0,
        sprite = getRandomLoot(grassCollection),
        fence = fence
      }
    end
  end
end

function love.keypressed(key)
  if key == 'escape' then love.event.quit() end
end

function love.draw()
  love.graphics.push()
  love.graphics.translate(offsetX, offsetY)

  for x = 0, width + 1 do
    for y = 0, height + 1 do
      local grass = grid[x][y].sprite
      local dark = math.max(1 - math.ldexp(grid[x][y].tall, -7), .7)
      love.graphics.setColor(dark, dark, dark)
      love.graphics.draw(spriteSheet, grass, (x - 1) * size, (y - 1) * size)
      love.graphics.print(string.format('%.2f', grid[x][y].tall), (x - 1) * size, (y - 1) * size)
      
      if grid[x][y].fence ~= nil then 
        love.graphics.draw(spriteSheet, grid[x][y].fence, (x - 1) * size, (y - 1) * size)
      end
    end

    love.graphics.setColor(1, 1, 1)
  end

  love.graphics.push()
  love.graphics.translate( math.floor(mower.x * size), math.floor(mower.y * size))

  love.graphics.draw(spriteSheet, sprites.mower, size / 2, size / 2, mower.r, 1, 1, size / 2, size / 2 )

  love.graphics.pop()
  love.graphics.pop()
end

function love.update(dt)
  keyTime = keyTime + dt

  if love.keyboard.isDown("up", "w") and canMove(targetMower.x, targetMower.y - 1) then
    queMower.x = targetMower.x
    queMower.y = targetMower.y - 1
    queMower.r = -halfpi
  elseif love.keyboard.isDown("down", "s") and canMove(targetMower.x, targetMower.y + 1) then
    queMower.x = targetMower.x
    queMower.y = targetMower.y + 1
    queMower.r = halfpi
  end

  if love.keyboard.isDown("left", "a") and canMove(targetMower.x - 1, targetMower.y) then
    queMower.x = targetMower.x - 1
    queMower.y = targetMower.y
    queMower.r = math.pi
  elseif love.keyboard.isDown("right", "d") and canMove(targetMower.x + 1, targetMower.y) then
    queMower.x = targetMower.x + 1
    queMower.y = targetMower.y
    queMower.r = 0
  end

  if grid[targetMower.x + 1][targetMower.y + 1].tall == 0 and keyTime >= keyDelay then
    keyTime = 0
    targetMower.x = queMower.x
    targetMower.y = queMower.y
    targetMower.r = queMower.r
  end

  targetMower.x = clamp(targetMower.x, 0, width - 1)
  targetMower.y = clamp(targetMower.y, 0, height - 1)

  local easeDT = 1 - easeFunction ^ (dt * 20)
  mower.x = lerp(mower.x, targetMower.x, easeInOut(easeDT))
  mower.y = lerp(mower.y, targetMower.y, easeInOut(easeDT))
  mower.r = targetMower.r --lerp(mower.r, targetMower.r, easeInOut(easeDT))

  for x = 1, width do
    for y = 1, height do
      if (targetMower.x + 1 ~= x or targetMower.y + 1 ~= y) and grid[x][y].fence ~= sprites.fence_front then grid[x][y].tall = grid[x][y].tall + (grid[x][y].age * growFactor) * dt end
      grid[x][y].age = grid[x][y].age + dt
    end
  end

  grid[targetMower.x + 1][targetMower.y + 1].tall = math.max(grid[targetMower.x + 1][targetMower.y + 1].tall - mowePower * dt, 0)
end

function canMove(x, y)
  if x < 0 or
    x > width or
    y < 1 or
    y > height then
      return false
    end
  return true
end

function lerp(a,b,t) return a + (b - a) * t end
function easeIn(t) return t * t end
function flip(x) return 1 - x end
function easeOut(t) return flip(flip(t)^2) end
function easeInOut(t) return lerp(easeIn(t), easeOut(t), t) end
function clamp(a, min, max) return math.max(min, math.min(a, max)) end

function addToCollection(t, item, weight)
  t.totalWeight = t.totalWeight + weight
  table.insert(t.collection, {item = item, accumulatedWeight = t.totalWeight})
end

function getRandomLoot(t)
  local r = love.math.random(t.totalWeight)
  for x = 1, #t.collection do
    if t.collection[x].accumulatedWeight >= r then return t.collection[x].item end
  end
  return nil
end
