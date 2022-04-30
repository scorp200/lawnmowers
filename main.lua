local width = 15
local height = 30
local size = 64

function love.load()
  width = math.floor(love.graphics.getWidth() / size)
  height = math.floor(love.graphics.getHeight() / size)
end

function love.draw()
  local edge = size - 1

  for x = 1, width do
    for y = 1, height do
      love.graphics.setColor(.2, .9, .3)
      love.graphics.rectangle('fill', (x - 1) * size, (y - 1) * size, edge, edge)
    end
  end
end

function love.update(dt)

end
