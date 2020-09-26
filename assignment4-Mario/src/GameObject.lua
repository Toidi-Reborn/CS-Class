--[[
    GD50
    -- Super Mario Bros. Remake --

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

GameObject = Class{}

function GameObject:init(def)
    self.x = def.x
    self.y = def.y
    self.texture = def.texture
    self.width = def.width
    self.height = def.height
    self.frame = def.frame
    self.solid = def.solid
    self.collidable = def.collidable
    self.consumable = def.consumable
    self.onCollide = def.onCollide
    self.onConsume = def.onConsume
    self.hit = def.hit
    --ADDED for flag
    self.hidden = def.hidden
    self.isFlag = def.isFlag
    flagTrigger = 8
end

function GameObject:collides(target)
    return not (target.x > self.x + self.width or self.x > target.x + target.width or
            target.y > self.y + self.height or self.y > target.y + target.height)
end


--ADDED for flag
function GameObject:update(dt)
    if self.isFlag and self.y <= 3 * TILE_SIZE then
        if flagTrigger == 48 then --8
            self.frame = 2
        elseif flagTrigger == 76 then  --16
            self.frame = 3
        end
        flagTrigger = flagTrigger + 1 --17
        if flagTrigger >= 100 then
            flagTrigger = 0
            GAME_WON = true
        end

    end

end




function GameObject:render()
    if not self.hidden then
        love.graphics.draw(gTextures[self.texture], gFrames[self.texture][self.frame], self.x, self.y)
    end

end