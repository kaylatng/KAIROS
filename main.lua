-- Main

io.stdout:setvbuf("no")

require "card"
require "selector"
require "pile"
require "game"
local Constants = require("constants")

local background = {0.38, 0.5, 0.47, 0.8} -- Dark green
local font

function love.load()
  love.window.setMode(Constants.WINDOW_WIDTH, Constants.WINDOW_HEIGHT)
  love.window.setTitle("Kairos")
  love.graphics.setBackgroundColor(background)

  font = love.graphics.newFont("assets/slkscr.ttf", 18)
  love.graphics.setFont(font)

  bgm = love.audio.newSource("assets/sfx/bgm.wav", "stream")
  bgm:setVolume(0.8)
  bgm:setLooping(true)

  if not bgm:isPlaying() then
    love.audio.play(bgm)
  end

  math.randomseed(os.time())
  
  game = GameManager:new()
  game:initialize()
end

function love.update(dt)
  game:update(dt)
end

function love.draw()
  game:draw()
end

function love.mousepressed(x, y, button)
  game:mousePressed(x, y, button)
end

function love.mousereleased(x, y, button)
  game:mouseReleased(x, y, button)
end

function love.keypressed(key)
  if key == "q" or key == "escape" then
    -- Quit game
    love.audio.play(bgm)
    love.event.quit()
  elseif key == "r" then
    -- Restart game
    game = GameManager:new()
    love.audio.play(bgm)
    game:initialize()
  end
end
