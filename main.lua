-- maaz's pbong

--GLOBAL CONFIGS
Class = require 'class'
push = require 'push'
require 'Ball'
require 'Paddle'

WINDOW_WIDTH = 1152
WINDOW_HEIGHT = 648

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200
MAX_SCORE = 3

--LOVE FUNCTIONS
---------------------------------------------------------

function love.load()
  love.window.setTitle("Maaz's Pong")
  love.graphics.setDefaultFilter("nearest", "nearest")
  math.randomseed(os.time())

  push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
    fullscreen = false,
    resizable = true,
    vsync = true,
    canvas = false
  })

  sounds = {
    ["paddle_hit"] = love.audio.newSource("sounds/paddle_hit.wav", "static"),
    ["wall_hit"] = love.audio.newSource("sounds/wall_hit.wav", "static")
  }

  smallFont = love.graphics.newFont("font.ttf", 8)
  medFont = love.graphics.newFont("font.ttf", 32)

  ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)
  player1 = Paddle(10, 30, 5, 20)
  player2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20)

  p1Score = 0
  p2Score = 0
  winner = nil
  moveTimer = 0

  gameState = "start"
end

----------------------------------------------------

function love.update(dt)

  --controls
  -- if love.keyboard.isDown("w") then
  --   player1.dy = -PADDLE_SPEED
  -- elseif love.keyboard.isDown("s") then
  --   player1.dy = PADDLE_SPEED
  -- else
  --   player1.dy = 0
  -- end

  if love.keyboard.isDown("up") then
    player2.dy = -PADDLE_SPEED
  elseif love.keyboard.isDown("down") then
    player2.dy = PADDLE_SPEED
  else
    player2.dy = 0
  end

  --serve and ball direction
  if gameState == "start" then
    serving = math.random(1, 2)

  elseif gameState == "serve" then
    ball.dy = math.random(-50, 50)
    if serving == 1 then
      ball.dx = -math.random(140, 200)
    else
      ball.dx = math.random(140, 200)
    end

  elseif gameState == "play" then
    ball:update(dt)

    --ai stuff
    if player1.y > ball.y - 2 then
      player1.dy = -PADDLE_SPEED
    elseif player1.y < ball.y + 2 then
      player1.dy = PADDLE_SPEED
    end

    --wall collisions
    if ball.y <= 0 then
      ball.y = 0
      ball.dy = -ball.dy
      sounds["wall_hit"]:play()
    end

    if ball.y >= VIRTUAL_HEIGHT - 4 then
      ball.y = VIRTUAL_HEIGHT - 4
      ball.dy = -ball.dy
      sounds["wall_hit"]:play()
    end

    --paddle collisions
    if ball:collides(player1) then
      ball.dx = -ball.dx * 1.03
      ball.x = player1.x + 5

      if ball.dy < 0 then
        ball.dy = -math.random(10, 150)
      else
        ball.dy = math.random(10, 150)
      end

      sounds["paddle_hit"]:play()
    end

    if ball:collides(player2) then
      ball.dx = -ball.dx * 1.03
      ball.x = player2.x - 5

      if ball.dy < 0 then
        ball.dy = -math.random(10, 150)
      else
        ball.dy = math.random(10, 150)
      end

      sounds["paddle_hit"]:play()
    end

    --point scoring
    if ball.x < 0 then
      serving = 1
      p2Score = p2Score + 1
      sounds["wall_hit"]:play()

      if p2Score == MAX_SCORE then
        winner = 2
        gameState = "done"
      else
        gameState = "serve"
        ball:reset()
      end
    end

    if ball.x > VIRTUAL_WIDTH then
      serving = 2
      p1Score = p1Score + 1
      sounds["wall_hit"]:play()

      if p1Score == MAX_SCORE then
        winner = 1
        gameState = "done"
      else
        gameState = "serve"
        ball:reset()
      end
    end

  elseif gameState == "done" then
    --done state actions take place in love.keypressed
  end

  player1:update(dt)
  player2:update(dt)
end

----------------------------------------------------

function love.keypressed(key)
  if key == "escape" then
    love.event.quit()

  elseif key == "enter" or key == "return" then
    if gameState == "start" then
      gameState = "serve"

    elseif gameState == "serve" then
      gameState = "play"

    elseif gameState == "done" then
      p1Score = 0
      p2Score = 0
      ball:reset()
      gameState = "start"
    end


  elseif key == "p" or key == "P" then
    gameState = "start"
    ball:reset()
  end
end

----------------------------------------------------

function love.draw()
  push:start()
  love.graphics.clear(0.098, 0, 0.204, 1)

  if gameState == "start" or gameState == "serve" or gameState == "play" then
    displayHeader()
    love.graphics.print("AMADEUS KURISU", VIRTUAL_WIDTH * 0.22, VIRTUAL_HEIGHT / 2 - 2)
    love.graphics.print("EYAD THE SIMPER", VIRTUAL_WIDTH * 0.63, VIRTUAL_HEIGHT / 2 - 2)
    -- love.graphics.printf("AMADEUS KURISU", VIRTUAL_WIDTH / 4, VIRTUAL_HEIGHT / 2 - 2, 100, "center")
    -- love.graphics.printf("PLEB", VIRTUAL_WIDTH * 0.75, VIRTUAL_HEIGHT / 2 - 2, 100, "left")
  end

  if gameState == "done" then
    displayHeader()
    love.graphics.setColor(1, 1, 0, 1)
    love.graphics.setFont(medFont)
    -- love.graphics.printf("PLAYER " .. tostring(winner) .. " WINS", 0, 120, VIRTUAL_WIDTH, "center")

    if winner == 1 then
      love.graphics.printf("KURISU WINS", 0, 120, VIRTUAL_WIDTH, "center")
    else
      love.graphics.printf("PLEB WINS", 0, 120, VIRTUAL_WIDTH, "center")
    end

  end

  love.graphics.setColor(0, 1, 0, 1)
  player1:render()
  player2:render()
  ball:render()

  displayScore()
  displayDetails()
  push:finish()
end

----------------------------------------------------

function love.resize(w, h)
  push:resize(w, h)
end

function displayHeader()
  love.graphics.setFont(smallFont)
  love.graphics.setColor(1, 1, 0, 1)
  love.graphics.printf("MAAZ'S PONG", 0, 10, VIRTUAL_WIDTH, "center")
  love.graphics.printf("GAME STATE: " .. tostring(gameState), 0, 20, VIRTUAL_WIDTH, "center")
end

function displayScore()
  love.graphics.setFont(medFont)
  love.graphics.print(tostring(p1Score), VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
  love.graphics.print(tostring(p2Score), VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3)
end

function displayDetails()
  love.graphics.setFont(smallFont)
  love.graphics.setColor(1, 1, 0, 1)
  love.graphics.print("FPS: " .. tostring(love.timer.getFPS()), 10, 10)

  if gameState ~= "start" then
    love.graphics.print("SERVING: " .. tostring(serving), 10, 20)
  end
end
