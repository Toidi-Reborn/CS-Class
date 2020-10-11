MenuBar = Class{__includes = Entity}

function MenuBar:init(x, y, text)
    self.x = x
    self.y = y
    self.text = text
    self.top = 0
    self.bottom = 0
    self.options = false 

   --love.graphics.draw(gTextures['menuBar'], w * TILE_SIZE , ( h + gap )* TILE_SIZE, 0)   


end

function MenuBar:update(dt)



    
end

function MenuBar:collides(target)
end

function MenuBar:render()

    love.graphics.setFont(gFonts['small'])

    
    if self.selected and self.options then
        
        love.graphics.setColor(255, 0, 0, 255)
        
        love.graphics.rectangle('fill', self.x + (4 * TILE_SIZE), self.y - 1, TILE_SIZE, TILE_SIZE + 2)
        love.graphics.rectangle('fill', self.x - 1, self.y -1, 4 * TILE_SIZE + 2, TILE_SIZE + 2)
        love.graphics.rectangle('fill', (self.x + (5 * TILE_SIZE)) - 1, (2.75 * TILE_SIZE) - 1, (4 * TILE_SIZE) + 2, (8.5 * TILE_SIZE) + 2)
    
        love.graphics.setColor(255, 255, 255, 255)
        love.graphics.draw(gTextures['menuBar'], self.x + (4 * TILE_SIZE), self.y, 0, 1, 1)
        love.graphics.draw(gTextures['menuBar'], self.x + (5 * TILE_SIZE), 2.75 * TILE_SIZE, 0, 4, 8.5)



        love.graphics.printf("xcxvsdvdsvs", 0, VIRTUAL_HEIGHT / 2 + 64, VIRTUAL_WIDTH, 'center')



    end




    if not self.options then
        love.graphics.setColor(255, 255, 255, 255)
        love.graphics.draw(gTextures['menuBar'], self.x, self.y, 0, 4, 1)
    end
    




    if self.selected then
        love.graphics.setColor(0, 0, 255, 255)
    end

    love.graphics.printf(self.text, self.x, self.y + 4, 4* TILE_SIZE,  'center')

end