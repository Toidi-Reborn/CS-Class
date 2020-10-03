
MenuState = Class{__includes = BaseState}

function MenuState:init()

    self.menus = {}

    for w = 2.5, 5.5 do
        local gap = 0.25
        for h = 2.5, 7.5 do
            local bar = MenuBar( w * TILE_SIZE ,  ( h + gap )* TILE_SIZE )
            --love.graphics.draw(gTextures['menuBar'], w * TILE_SIZE , ( h + gap )* TILE_SIZE, 0)   
            gap = gap + 0.5


        end
    end


end

function MenuState:enter(params)

end

function MenuState:update(dt)
    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end

    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        gStateMachine:change('play')
    end
end

function MenuState:render()
    love.graphics.draw(gTextures['background'], 0, 0, 0, 
        VIRTUAL_WIDTH / gTextures['background']:getWidth(),
        VIRTUAL_HEIGHT / gTextures['background']:getHeight())

    for w = 2, 6 do
        for h = 2, 11 do
        love.graphics.draw(gTextures['menuBackground'], w * TILE_SIZE , h * TILE_SIZE, 0)   
        end
    end






    -- love.graphics.setFont(gFonts['gothic-medium'])
    -- love.graphics.printf('Legend of', 0, VIRTUAL_HEIGHT / 2 - 32, VIRTUAL_WIDTH, 'center')

    -- love.graphics.setFont(gFonts['gothic-large'])
    -- love.graphics.printf('50', 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH, 'center')

    love.graphics.setFont(gFonts['zelda'])
    love.graphics.setColor(34, 34, 34, 255)
    love.graphics.printf('Space Flight', 2, VIRTUAL_HEIGHT / 2 - 30, VIRTUAL_WIDTH, 'center')

    love.graphics.setColor(175, 53, 42, 255)
    love.graphics.printf('Space Flight', 0, VIRTUAL_HEIGHT / 2 - 32, VIRTUAL_WIDTH, 'center')

    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.setFont(gFonts['zelda-small'])
    love.graphics.printf("sadsdsadsa", 0, VIRTUAL_HEIGHT / 2 + 64, VIRTUAL_WIDTH, 'center')
end