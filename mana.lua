-- Mana

require "vector"
local Constants = require("constants")

ManaClass = {}

function ManaClass:new(xPos, yPos, owner)
  local mana = {}
  local metadata = {__index = ManaClass}
  setmetatable(mana, metadata)

  mana.position = Vector(xPos, yPos)
  mana.size = Vector(50, 50)
  mana.owner = owner or "player"

  mana.bonusMana = 0
  mana.mp = 1

  return mana
end

function ManaClass:update(dt)

end

function ManaClass:draw()
  love.graphics.setColor(0.2, 0.7, 1, 0.8)
  love.graphics.circle("fill",
    self.position.x, self.position.y,
    self.size.x, self.size.y)
  love.graphics.setColor(0, 0, 0, 1)
  love.graphics.printf(tostring(self.mp), Constants.BUTTON_X, self.position.y - 9, Constants.BUTTON_X + self.size.x, "center")
end

function ManaClass:setMana(value)
  self.mp = value
end

function ManaClass:useMana(amount)
  self.mp = math.max(0, self.mp - amount)
end

function ManaClass:addBonusMana(amount)
  self.bonusMana = (self.bonusMana or 0) + amount
end

function ManaClass:resetBonusMana()
  self.bonusMana = 0
end