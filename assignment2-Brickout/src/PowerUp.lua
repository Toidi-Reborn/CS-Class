PowerUp = Class{}

function PowerUp:init(power)
    --ADDED
    self.width = 16
    self.height = 16
    --self.skin = skin
    self.inPlay = false
    self.trigger = 0
    self.powerUsed = false

    self.power = power

    self.x = math.random((VIRTUAL_WIDTH * 0.15), (VIRTUAL_WIDTH * 0.85))
    self.y = 10
    self.dy = math.random(25, 175)
end


function PowerUp:collides(target)
    if self.x > target.x + target.width or target.x > self.x + self.width then
        return false
    end

    if self.y > target.y + target.height or target.y > self.y + self.height then
        return false
    end 

    return true
end

function PowerUp:reset()
    self.x = 0
    self.y = -50
    self.dx = 0
    self.dy = 0
    self.powerUsed = false
end

function PowerUp:update(dt)
    self.y = self.y + self.dy * dt

    if self.y >= VIRTUAL_HEIGHT then
        self.dy = 0
        self.y = 50
    end
end

function PowerUp:render()

    if self.power == "key" then
        love.graphics.draw(gTextures['main'], gFrames['power'][10], self.x, self.y, 0)

    elseif self.power == "balls" then
        love.graphics.draw(gTextures['main'], gFrames['power'][7], self.x, self.y, 0)
    end


end
