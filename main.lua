local width = 15
local height = 30
local size = 64
local spriteSheet
local sprites = {}
function love.load()
  spriteSheet = love.graphics.newImage('assets/sprite.png', nil)

  sprites['grass'] = love.graphics.newQuad(0, 0, 64, 64, spriteSheet:getDimensions())

  width = math.floor(love.graphics.getWidth() / size)
  height = math.floor(love.graphics.getHeight() / size)
end

function love.draw()
  local edge = size - 1

  for x = 1, width do
    for y = 1, height do
      love.graphics.setColor(.2, .9, .3)
      love.graphics.draw(spriteSheet, sprites.grass, (x - 1) * size, (y - 1) * size)
    end
  end
end

function love.update(dt)

end
