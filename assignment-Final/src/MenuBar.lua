MenuBar = Class{__includes = Entity}

function MenuBar:init(w, h)

    self.w = w
    self.h = h

    --love.graphics.draw(gTextures['menuBar'], w * TILE_SIZE , ( h + gap )* TILE_SIZE, 0)   
            



end

function MenuBar:update(dt)
    Entity.update(self, dt)

    if self.health > 6 then
        self.health = 6
    end
    
end

function MenuBar:collides(target)
end

function MenuBar:render()
    love.graphics.draw(gTextures['menuBar'], self.w, self.h, 0)   
        
end