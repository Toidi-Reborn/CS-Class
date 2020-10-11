
MenuState = Class{__includes = BaseState}

function MenuState:init()
    self.menus = {}
    self.menus[0] = {}
    self.menus[1] = {}
    self.menus[2] = {}
    self.menus[3] = {}
    self.menus[4] = {}
    self.menus[5] = {}
    self.menus[6] = {}
    self.menus[7] = {}

    self.inSub = false
    --[[

    for w = 2.5, 5.5 do
        local gap = 0.25
        for h = 2.5, 7.5 do
            local bar = MenuBar( w * TILE_SIZE ,  ( h + gap )* TILE_SIZE )
            --love.graphics.draw(gTextures['menuBar'], w * TILE_SIZE , ( h + gap )* TILE_SIZE, 0)   
            gap = gap + 0.5
            table.insert(self.menus, bar)
        end
    end
]]

    local gap = 0.25
    local h = 2.5


    local menuTitles = {"ONE", "Mode", "Speed", "Difficulty", "ur mom", "why just why", "Play" }
    local subMenu = {}
    subMenu[1] = {"Null"}
    subMenu[2] = {"d", "asdsadas", "asdsadsa"}
    subMenu[3] = {"e", "asddas", "asddsa"}
    subMenu[4] = {"f", "asdsadas", "asdsadsa"}
    subMenu[5] = {"g", "asdadas", "asdsadsa"}
    subMenu[6] = {"h", "asdsadas", "asdsa"}
    subMenu[7] = {"i", "asas", "asadsa"}
    
--    for button = 1, 7 do
    for button = #menuTitles, 1, -1 do
        local bar = MenuBar(2.5 * TILE_SIZE, (h + gap) * TILE_SIZE, menuTitles[button])
        
        local gap2 = 0.25
        local h2 = 2.5
        --Generate sub menus

        if #subMenu[button] > 1 then
            for i = #subMenu[button], 1, -1 do
                local sub = MenuBar(7.5 * TILE_SIZE, (h2 + gap2) * TILE_SIZE, subMenu[button][i])
                gap2 = gap2 + 0.25
                h2 = h2 + 1                    
                table.insert(self.menus[button], sub)
            end        
        end

        gap = gap + 0.25
        h = h + 1
        table.insert(self.menus[0], bar)
    end



    self.curButton = 2
    self.menus[0][self.curButton].selected = true

end

function MenuState:enter(params)

end






function MenuState:update(dt)
    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end


    if not self.inSub then

        if love.keyboard.wasPressed('up') then
            if self.curButton > 1 then    
                self.menus[0][self.curButton].selected = false
                self.curButton = self.curButton - 1
                self.menus[0][self.curButton].selected = true
            end

        end

        if love.keyboard.wasPressed('down') then
            if self.curButton < 7 then    
                self.menus[0][self.curButton].selected = false
                self.curButton = self.curButton + 1
                self.menus[0][self.curButton].selected = true
            end
        end

        if love.keyboard.wasPressed('right') and #self.menus[self.curButton] > 1 then
            self.inSub = true
            self.menus[0][self.curButton].options = true
            self.curSubButton = 1
            self.menus[self.curButton][self.curSubButton].selected = true
        end
 


    else

        if love.keyboard.wasPressed('left') then
            self.inSub = false
            self.menus[0][self.curButton].options = false
            self.curSubButton = 1
        end

        if love.keyboard.wasPressed('up') then
            if self.curSubButton > 1 then    
                self.menus[self.curButton][self.curSubButton].selected = false
                self.curSubButton = self.curSubButton - 1
                self.menus[self.curButton][self.curSubButton].selected = true
            end

        end

        if love.keyboard.wasPressed('down') then
            if self.curSubButton < 3 then    
                self.menus[self.curButton][self.curSubButton].selected = false
                self.curSubButton = self.curSubButton + 1
                self.menus[self.curButton][self.curSubButton].selected = true
            end
        end




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


    for i = #self.menus[0], 1, -1 do
        local option = self.menus[0][i]
        option:render()
    end


    if self.inSub then

        for i = #self.menus[self.curButton], 1, -1 do
            local option = self.menus[self.curButton][i]
            option:render()
        end

        
    end

    -- love.graphics.setFont(gFonts['gothic-medium'])
    -- love.graphics.printf('Legend of', 0, VIRTUAL_HEIGHT / 2 - 32, VIRTUAL_WIDTH, 'center')

    -- love.graphics.setFont(gFonts['gothic-large'])
    -- love.graphics.printf('50', 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH, 'center')

    love.graphics.setFont(gFonts['small'])
    love.graphics.setColor(34, 34, 34, 255)
    --love.graphics.printf('Space Flight', 2, VIRTUAL_HEIGHT / 2 - 30, VIRTUAL_WIDTH, 'center')

    love.graphics.setColor(175, 53, 42, 255)
    --love.graphics.printf('Space Flight', 0, VIRTUAL_HEIGHT / 2 - 32, VIRTUAL_WIDTH, 'center')

    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.setFont(gFonts['zelda-small'])
    love.graphics.printf(#self.menus, 0, VIRTUAL_HEIGHT / 2 + 64, VIRTUAL_WIDTH, 'center')



end