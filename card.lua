-- Card

require "vector"
local Constants = require("constants")

CardClass = {}

CARD_STATE = {
  IDLE = 0,
  MOUSE_OVER = 1,
  SELECTED = 2,
}

TYPE = {
  "vanilla",
  "reveal",
  "reactive",
  "end-turn",
  "discard"
}

SPRITESHEET_ROWS = 3
SPRITESHEET_COLUMNS = 5

local font

local cardSpritesheet, spritesheet = nil

function CardClass:new(name, cardType, cost, power, text, id, xPos, yPos, faceUp, inPlay)
  local card = {}
  local metadata = {__index = CardClass}
  setmetatable(card, metadata)
  
  card.name = name
  card.type = cardType
  card.cost = cost
  card.power = power
  card.text = text
  card.id = id

  card.position = Vector(xPos, yPos)
  card.targetPosition = Vector(xPos, yPos)
  card.basePosition = Vector(xPos, yPos)
  card.size = Vector(Constants.CARD_WIDTH, Constants.CARD_HEIGHT)

  card.faceUp = faceUp or false
  card.inPlay = inPlay or false
  card.wasPlaced = false
  card.active = false
  card.hasTriggered = false
  card.basePower = power

  card.state = CARD_STATE.IDLE
  card.hoverOffset = 15
  card.selectOffset = 15
  card.zOrder = 0

  return card
end

function CardClass:update(dt)
  local x, y = love.mouse.getPosition()
  
  if self.state ~= CARD_STATE.SELECTED then
    if self:containsPoint(x, y) then
      self.state = CARD_STATE.MOUSE_OVER
    else
      self.state = CARD_STATE.IDLE
    end
    
    -- Update target position based on hover state
    if self.state == CARD_STATE.MOUSE_OVER and self.faceUp then
      self.targetPosition = Vector(self.basePosition.x, self.basePosition.y - self.hoverOffset)
    else
      self.targetPosition = Vector(self.basePosition.x, self.basePosition.y)
    end
  else
    -- When selected, keep elevated position
    self.targetPosition = Vector(self.basePosition.x, self.basePosition.y - self.selectOffset)
  end

  -- Smooth movement animation
  local distance = self.targetPosition - self.position
  if distance:length() > 1 then
    self.position = self.position + distance * 10 * dt
  else
    self.position = Vector(self.targetPosition.x, self.targetPosition.y)
  end
end

function CardClass:loadSpritesheet()
  if not cardSpritesheet then
    cardSpritesheet = love.graphics.newImage("assets/cards.png")
  end
  return cardSpritesheet
end

function CardClass:draw()
  spritesheet = self:loadSpritesheet()
  local text = false
  
  -- Draw drop shadow and selection glow
  if self.state ~= CARD_STATE.IDLE then
    love.graphics.setColor(0, 0, 0, 0.5)
    local offset = 4 * (self.state == CARD_STATE.SELECTED and 2 or 1)
    love.graphics.rectangle("fill", self.position.x + offset, self.position.y + offset, self.size.x, self.size.y, Constants.CARD_RADIUS, Constants.CARD_RADIUS)

    -- Selection glow effect
    if self.state == CARD_STATE.SELECTED then
      love.graphics.setColor(0.2, 0.8, 1, 0.6) -- Blue glow
      love.graphics.setLineWidth(4)
      love.graphics.rectangle("line", self.position.x - 2, self.position.y - 2, self.size.x + 4, self.size.y + 4, Constants.CARD_RADIUS, Constants.CARD_RADIUS)
      if self.faceUp then
        font = love.graphics.newFont("assets/slkscr.ttf", 20)
        love.graphics.setFont(font)
        text = true
      end
    end
  end
  
  love.graphics.setColor(1, 1, 1, 1)
  
  local quad
  local x

  if self.faceUp then
    local col = (self.id) % SPRITESHEET_COLUMNS
    local row = math.floor((self.id) / SPRITESHEET_COLUMNS)
    local x = col * Constants.CARD_WIDTH
    local y = row * Constants.CARD_HEIGHT
    quad = love.graphics.newQuad(x, y, Constants.CARD_WIDTH, Constants.CARD_HEIGHT, spritesheet:getDimensions())
  else
    -- Back img at [0, 0]
    local x = 0 * Constants.CARD_WIDTH
    local y = 0 * Constants.CARD_HEIGHT
    quad = love.graphics.newQuad(x, y, Constants.CARD_WIDTH, Constants.CARD_HEIGHT, spritesheet:getDimensions())
  end
  
  love.graphics.draw(spritesheet, quad, self.position.x, self.position.y)

  if self.state == CARD_STATE.SELECTED and self.faceUp then
    self:drawEnlargedCard()
  end

  love.graphics.setColor(0, 0, 0, 1)

  font = love.graphics.newFont("assets/slkscr.ttf", 20)
  love.graphics.setFont(font)
  
  -- Debug info
  if self.state == CARD_STATE.SELECTED then
    love.graphics.setColor(0.2, 0.8, 1, 1)
    love.graphics.print("SELECTED", self.position.x + 5, self.position.y - 30)
  end
  love.graphics.setColor(0, 0, 0, 1)
end

function CardClass:drawEnlargedCard()
  local scale = 2.5
  local enlargedWidth = Constants.CARD_WIDTH * scale
  local enlargedHeight = Constants.CARD_HEIGHT * scale
  
  local enlargedX = Constants.WINDOW_WIDTH / 2 - 600
  local enlargedY = (Constants.WINDOW_HEIGHT - enlargedHeight) / 2
  
  -- Draw selection glow
  love.graphics.setColor(0.2, 0.8, 1, 0.8) -- Blue glow
  love.graphics.setLineWidth(6)
  love.graphics.rectangle("line", enlargedX - 10, enlargedY - 10, enlargedWidth + 20, enlargedHeight + 20, Constants.CARD_RADIUS * scale, Constants.CARD_RADIUS * scale)
  
  -- Draw enlarged card
  love.graphics.setColor(1, 1, 1, 1)
  local col = (self.id) % SPRITESHEET_COLUMNS
  local row = math.floor((self.id) / SPRITESHEET_COLUMNS)
  local x = col * Constants.CARD_WIDTH
  local y = row * Constants.CARD_HEIGHT
  local quad = love.graphics.newQuad(x, y, Constants.CARD_WIDTH, Constants.CARD_HEIGHT, spritesheet:getDimensions())
  
  love.graphics.draw(spritesheet, quad, enlargedX, enlargedY, 0, scale, scale)

  self:drawCardInfo(enlargedX, enlargedY, enlargedWidth, enlargedHeight)
end

function CardClass:drawCardInfo(cardX, cardY, cardWidth, cardHeight)
  local titleFont = love.graphics.newFont("assets/slkscr.ttf", 24)
  local infoFont = love.graphics.newFont("assets/slkscr.ttf", 18)
  local descFont = love.graphics.newFont("assets/slkscr.ttf", 16)
  
  local textX = cardX
  local textY = cardY + cardHeight + 30
  local textWidth = cardWidth
  
  -- Card name
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.setFont(titleFont)
  love.graphics.printf(self.name, textX, textY, textWidth, "center")
  textY = textY + 30
  
  -- Card stats (cost, power, type)
  love.graphics.setFont(infoFont)
  love.graphics.setColor(0.2, 0.8, 1, 1) -- Blue glow
  local statsText = string.format("Cost: %d  |  Base Power: %d Type: %s", self.cost, self.basePower, self.type)
  love.graphics.printf(statsText, textX, textY, textWidth, "center")
  textY = textY + 45

  -- Current power
  love.graphics.setColor(1, 0.8, 0.2, 1) -- Gold
  love.graphics.printf(string.format("Current Power: %d", self.power), textX, textY, textWidth, "center")
  textY = textY + 30

  -- Card description
  love.graphics.setFont(descFont)
  love.graphics.setColor(0.9, 0.9, 0.9, 1)
  love.graphics.printf(self.text, textX + 10, textY, textWidth - 20, "left")
end

function CardClass:setFaceUp()
  self.faceUp = true
end

function CardClass:setFaceDown()
  self.faceUp = false
end

function CardClass:containsPoint(x, y)
  return x > self.position.x and
  x < self.position.x + self.size.x and
  y > self.position.y and
  y < self.position.y + self.size.y
end

function CardClass:select()
  self.state = CARD_STATE.SELECTED
  self.zOrder = 100 -- Bring to front when selected
end

function CardClass:deselect()
  self.state = CARD_STATE.IDLE
  self.zOrder = 0
end

function CardClass:isSelected()
  return self.state == CARD_STATE.SELECTED
end

function CardClass:setBasePosition(x, y)
  self.basePosition = Vector(x, y)
  if self.state == CARD_STATE.IDLE then
    self.targetPosition = Vector(x, y)
  elseif self.state == CARD_STATE.MOUSE_OVER then
    self.targetPosition = Vector(x, y - self.hoverOffset)
  elseif self.state == CARD_STATE.SELECTED then
    self.targetPosition = Vector(x, y - self.selectOffset)
  end
end

function findIndex(table, value)
  for i, v in ipairs(table) do
    if v == value then
      return i
    end
  end
  return nil
end

-- Card Type Specific Functions

function CardClass:onReveal(gameManager, boardPile)
  if self.type ~= "reveal" or self.hasTriggered then return end
  
  self.hasTriggered = true
  
  -- Card-specific reveal effects
  if self.name == "Daedalus" then
    self:daedalusEffect(gameManager)
  elseif self.name == "Hephaestus" then
    self:hephaestusEffect(gameManager)
  elseif self.name == "Demeter" then
    self:demeterEffect(gameManager)
  elseif self.name == "Persephone" then
    self:persephoneEffect(gameManager)
  elseif self.name == "Aphrodite" then
    self:aphroditeEffect(gameManager, boardPile)
  elseif self.name == "Ares" then
    self:aresEffect(gameManager, boardPile)
  elseif self.name == "Apollo" then
    self:apolloEffect(gameManager)
  end
end

-- NEED TO FIX
function CardClass:onCardPlayed(gameManager, boardPile)
  if self.type ~= "reactive" or self.hasTriggered then return end
  
  if self.name == "Athena" then
    self:athenaEffect(gameManager, boardPile)
  elseif self.name == "Medusa" then
    self:medusaEffect(gameManager, boardPile)
  end
end

function CardClass:onEndTurn(gameManager)
  if self.type ~= "end-turn" then return false end
  
  if self.name == "Icarus" then
    return self:icarusEffect()
  end

  if self.name == "Helios" then
    return self:heliosEffect()
  end
  
  return false
end

-- Specific card effects
function CardClass:daedalusEffect(gameManager)
  -- Add a Wooden Cow to each other location
  local currentBoardPile = nil
  local boardPiles = {}
  
  -- Find current board pile and collect all board piles
  for _, pile in ipairs(gameManager.piles) do
    if pile.type == "board" then
      table.insert(boardPiles, pile)
      for _, card in ipairs(pile.cards) do
        if card == self then
          currentBoardPile = pile
          break
        end
      end
    end
  end
  
  -- Add wooden cow to other locations of the same owner
  for _, pile in ipairs(boardPiles) do
    if pile ~= currentBoardPile and pile.owner == currentBoardPile.owner then
      local woodenCow = CardClass:new("Wooden Cow", "vanilla", 1, 1, "Vanilla", 9, 0, 0, true, true)
      woodenCow.wasPlaced = true
      pile:addCard(woodenCow)
    end
  end
end

function CardClass:hephaestusEffect(gameManager)
  -- Lower the cost of 2 cards in your hand by 1 (BOTTOM 2)
  local handPile = nil
  local owner = self:getOwner(gameManager)
  
  for _, pile in ipairs(gameManager.piles) do
    if pile.type == "hand" and pile.owner == owner then
      handPile = pile
      break
    end
  end
  
  if handPile then
    local cardsReduced = 0
    for _, card in ipairs(handPile.cards) do
      if cardsReduced < 2 and card.cost > 0 then
        print("REDUCING " .. tostring(card.name))
        card.cost = card.cost - 1
        cardsReduced = cardsReduced + 1
      end
    end
  end
end

function CardClass:demeterEffect(gameManager)
  -- Both players draw a card
  gameManager:drawCardFor("player")
  gameManager:drawCardFor("ai")
end

function CardClass:persephoneEffect(gameManager)
  -- Discard the lowest power card in your hand
  local handPile, discardPile = nil
  local owner = self:getOwner(gameManager)
  
  for _, pile in ipairs(gameManager.piles) do
    if pile.type == "hand" and pile.owner == owner then
      handPile = pile
    elseif pile.type == "discard" and pile.owner == owner then
      discardPile = pile
    end
  end
  
  if handPile and #handPile.cards > 0 then
    local lowestCard = handPile.cards[1]
    for _, card in ipairs(handPile.cards) do
      if card.power < lowestCard.power then
        lowestCard = card
      end
    end
    handPile:removeCard(lowestCard)
    -- discardPile:addCard(lowestCard)
  end
end

function CardClass:aphroditeEffect(gameManager, boardPile)
  -- Lower the power of each enemy card here by 1
  local owner = self:getOwner(gameManager)
  local enemyOwner
  if owner == "player" then
    enemyOwner = "ai"
  else
    enemyOwner = "player"
  end

  for _, pile in ipairs(gameManager.piles) do
    if pile.type == "board" and pile.owner == enemyOwner and pile.index == boardPile.index then
      for _, card in ipairs(pile.cards) do
        if card.power > 0 then
          card.power = card.power - 1
        end
      end
      break
    end
  end
end

function CardClass:aresEffect(gameManager, boardPile)
  -- Gain +2 power for each enemy card here
  local owner = self:getOwner(gameManager)
  local enemyOwner = (owner == "player") and "ai" or "player"
  local enemyCardCount = 0
  
  for _, pile in ipairs(gameManager.piles) do
    if pile.type == "board" and pile.owner == enemyOwner and pile.index == boardPile.index then
      enemyCardCount = #pile.cards
      break
    end
  end
  
  self.power = self.power + (enemyCardCount * 2)
end

function CardClass:apolloEffect(gameManager)
  -- Gain +1 mana next turn
  local owner = self:getOwner(gameManager)
  
  for _, mana in ipairs(gameManager.manas) do
    if mana.owner == owner then
      mana:addBonusMana(1)
      break
    end
  end
end

function CardClass:athenaEffect(gameManager, boardPile)
  -- Gain +1 power when you play another card here
  local owner = self:getOwner(gameManager)
  local isAtCorrectPile = false

  for _, pile in ipairs(gameManager.piles) do
    if pile.type == "board" and pile.owner == owner and pile.index == boardPile.index then
      isAtCorrectPile = true
       if #pile.cards > 1 then
        self.power = self.basePower + 1
        self.hasTriggered = true
      else
        self.power = self.basePower
      end
    end
  end

  if not isAtCorrectPile then
    self.power = self.basePower
  end
end

function CardClass:medusaEffect(gameManager, boardPile)
  -- When ANY other card is played here, lower that card's power by 1
  local owner = self:getOwner(gameManager)
  local isAtCorrectPile = false

  for _, pile in ipairs(gameManager.piles) do
    if pile.type == "board" and pile.owner == owner and pile.index == boardPile.index then
      isAtCorrectPile = true
       if #pile.cards > 1 then
        self.power = self.basePower - 1
        self.hasTriggered = true
      else
        self.power = self.basePower
      end
    end
  end

  if not isAtCorrectPile then
    self.power = self.basePower
  end
end

function CardClass:icarusEffect()
  -- Gains +1 power, but is discarded when its power is greater than 7
  self.power = self.power + 1
  
  if self.power > 7 then
    return true
  end
  
  return false
end

function CardClass:heliosEffect()
  -- End of Turn: Discard this.
  return true
end

function CardClass:getOwner(gameManager)
  for _, pile in ipairs(gameManager.piles) do
    for _, card in ipairs(pile.cards) do
      if card == self then
        return pile.owner
      end
    end
  end
  return "player"
end
