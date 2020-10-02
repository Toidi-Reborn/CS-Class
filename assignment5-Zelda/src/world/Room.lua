--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

Room = Class{}

function Room:init(player)
    self.width = MAP_WIDTH
    self.height = MAP_HEIGHT

    self.tiles = {}
    self:generateWallsAndFloors()

    -- entities in the room
    self.entities = {}
    self:generateEntities()

    -- game objects in the room
    self.objects = {}
    self:generateObjects()

    -- doorways that lead to other dungeon rooms
    self.doorways = {}
    table.insert(self.doorways, Doorway('top', false, self))
    table.insert(self.doorways, Doorway('bottom', false, self))
    table.insert(self.doorways, Doorway('left', false, self))
    table.insert(self.doorways, Doorway('right', false, self))

    -- reference to player for collisions, etc.
    self.player = player

    -- used for centering the dungeon rendering
    self.renderOffsetX = MAP_RENDER_OFFSET_X
    self.renderOffsetY = MAP_RENDER_OFFSET_Y

    -- used for drawing when this room is the next room, adjacent to the active
    self.adjacentOffsetX = 0
    self.adjacentOffsetY = 0
end

--[[
    Randomly creates an assortment of enemies for the player to fight.
]]
function Room:generateEntities()
    local types = {'skeleton', 'slime', 'bat', 'ghost', 'spider'}

    for i = 1, 10 do
        local type = types[math.random(#types)]
       


        table.insert(self.entities, Entity {
            animations = ENTITY_DEFS[type].animations,
            walkSpeed = ENTITY_DEFS[type].walkSpeed or 20,

            -- ensure X and Y are within bounds of the map
            x = math.random(MAP_RENDER_OFFSET_X + TILE_SIZE,
                VIRTUAL_WIDTH - TILE_SIZE * 2 - 16),
            y = math.random(MAP_RENDER_OFFSET_Y + TILE_SIZE,
                VIRTUAL_HEIGHT - (VIRTUAL_HEIGHT - MAP_HEIGHT * TILE_SIZE) + MAP_RENDER_OFFSET_Y - TILE_SIZE - 16),
            
            width = 16,
            height = 16,

            health = 1,
            hasHeart = true,

            
        })

        

        self.entities[i].stateMachine = StateMachine {
            ['walk'] = function() return EntityWalkState(self.entities[i]) end,
            ['idle'] = function() return EntityIdleState(self.entities[i]) end
        }

        self.entities[i]:changeState('walk')



    end
end

--[[
    Randomly creates an assortment of obstacles for the player to navigate around.
]]
function Room:generateObjects()
    table.insert(self.objects, GameObject(
        GAME_OBJECT_DEFS['switch'],
        math.random(MAP_RENDER_OFFSET_X + TILE_SIZE,
                    VIRTUAL_WIDTH - TILE_SIZE * 2 - 16),
        math.random(MAP_RENDER_OFFSET_Y + TILE_SIZE,
                    VIRTUAL_HEIGHT - (VIRTUAL_HEIGHT - MAP_HEIGHT * TILE_SIZE) + MAP_RENDER_OFFSET_Y - TILE_SIZE - 16)
    ))

    -- get a reference to the switch
    local switch = self.objects[1]

    -- define a function for the switch that will open all doors in the room
    switch.onCollide = function()
        if switch.state == 'unpressed' then
            switch.state = 'pressed'
            
            -- open every door in the room if we press the switch
            for k, doorway in pairs(self.doorways) do
                doorway.open = true
            end

            gSounds['door']:play()
        end
    end


    --ADDED
    for i = 2, 4 do
        table.insert(self.objects, GameObject(
            GAME_OBJECT_DEFS['pot'],
            math.random(MAP_RENDER_OFFSET_X + TILE_SIZE,
                        VIRTUAL_WIDTH - TILE_SIZE * 2 - 16),
            math.random(MAP_RENDER_OFFSET_Y + TILE_SIZE,
                        VIRTUAL_HEIGHT - (VIRTUAL_HEIGHT - MAP_HEIGHT * TILE_SIZE) + MAP_RENDER_OFFSET_Y - TILE_SIZE - 16)
        ))

        local pot = self.objects[i]
        pot.timeOut = 0


    end

end

--[[
    Generates the walls and floors of the room, randomizing the various varieties
    of said tiles for visual variety.
]]
function Room:generateWallsAndFloors()
    for y = 1, self.height do
        table.insert(self.tiles, {})

        for x = 1, self.width do
            local id = TILE_EMPTY

            if x == 1 and y == 1 then
                id = TILE_TOP_LEFT_CORNER
            elseif x == 1 and y == self.height then
                id = TILE_BOTTOM_LEFT_CORNER
            elseif x == self.width and y == 1 then
                id = TILE_TOP_RIGHT_CORNER
            elseif x == self.width and y == self.height then
                id = TILE_BOTTOM_RIGHT_CORNER
            
            -- random left-hand walls, right walls, top, bottom, and floors
            elseif x == 1 then
                id = TILE_LEFT_WALLS[math.random(#TILE_LEFT_WALLS)]
            elseif x == self.width then
                id = TILE_RIGHT_WALLS[math.random(#TILE_RIGHT_WALLS)]
            elseif y == 1 then
                id = TILE_TOP_WALLS[math.random(#TILE_TOP_WALLS)]
            elseif y == self.height then
                id = TILE_BOTTOM_WALLS[math.random(#TILE_BOTTOM_WALLS)]
            else
                id = TILE_FLOORS[math.random(#TILE_FLOORS)]
            end
            
            table.insert(self.tiles[y], {
                id = id
            })
        end
    end
end






function Room:update(dt)
    -- don't update anything if we are sliding to another room (we have offsets)
    if self.adjacentOffsetX ~= 0 or self.adjacentOffsetY ~= 0 then return end

    self.player:update(dt)

    for i = 2, 4 do
        local pot = self.objects[i]

    
        pot.onCollide = function()
     
            if pot.state == "floor" and love.keyboard.wasPressed('s') then
                pot.state = "player"
                pot.pickedUp = true
                pot.solid = false
                pot.x = self.player.x
                pot.y = self.player.y
                --table.remove(self.objects, 2)
            end
    
        end

        if pot.state == 'player' then
            pot.x = self.player.x
            pot.y = self.player.y - 10
            self.player.hasPot = true

            if pot.pickedUp and love.keyboard.wasPressed('s') then

                if self.player.direction == "left" then
                    pot.xFinish = pot.x - TILE_SIZE * 4
                elseif self.player.direction == "right" then
                    pot.xFinish = pot.x + TILE_SIZE * 4
                elseif self.player.direction == "up" then
                    pot.yFinish = pot.y - TILE_SIZE * 4
                else
                    pot.yFinish = pot.y + TILE_SIZE * 4      
                end
                self.player.hasPot = false
                pot.state = "thrown"

            end

        end


        if pot.state == "thrown" then
            pot.pickedUp = false

            -- makes it 4 tiles?
            if self.player.direction == "left" then
                if pot.x > pot.xFinish then
                    pot.x = pot.x - 3
                elseif pot.x <= pot.xFinish then
                    pot.state = "crash"
                end
                
            elseif self.player.direction == "right" then
                if pot.x < pot.xFinish then
                    pot.x = pot.x + 3
                elseif pot.x >= pot.xFinish then
                    pot.state = "crash"
                end

            elseif self.player.direction == "up" then
                if pot.y > pot.yFinish then
                    pot.y = pot.y - 3
                elseif pot.y <= pot.yFinish then
                    pot.state = "crash"
                end

            else
                if pot.y < pot.yFinish then
                    pot.y = pot.y + 3
                elseif pot.y >= pot.yFinish then
                    pot.state = "crash"
                end
            end


            --hits bad guy
            for i = #self.entities, 1, -1 do
                local entity = self.entities[i]


                if entity:collides(pot) then
                    pot.x = entity.x
                    pot.y = entity.y
                    pot.state = "crash"
                    entity:damage(1)
                    gSounds['hit-enemy']:play()
                end


            end

            -- Hits wall
            if self.player.direction == 'left' then
                if pot.x <= MAP_RENDER_OFFSET_X + TILE_SIZE then 
                    pot.state = "crash"
                end
            elseif self.player.direction == 'right' then
                if pot.x >= pot.width + VIRTUAL_WIDTH - TILE_SIZE * 4 then
                    pot.state = "crash"
                end
            elseif self.player.direction == 'up' then
                if pot.y <= MAP_RENDER_OFFSET_Y + TILE_SIZE - pot.height / 2 then 
                   pot.state = "crash"
                end
            elseif self.player.direction == 'down' then
                local bottomEdge = VIRTUAL_HEIGHT - (VIRTUAL_HEIGHT - MAP_HEIGHT * TILE_SIZE) 
                    + MAP_RENDER_OFFSET_Y - TILE_SIZE
        
                if pot.y + pot.height >= bottomEdge then
                    pot.state = "crash"
                end
            end

        end

        if pot.state == "crash" then
            pot.timeOut = pot.timeOut + 1

            if pot.timeOut >= 50 then
                Timer.tween(.005, {
                [pot] = {y = (-50)}
                })
            end
    
        end

    end


    for i = #self.entities, 1, -1 do
        local entity = self.entities[i]

        -- remove entity from the table if health is <= 0
        if entity.health <= 0 then
                   
            if entity.hasHeart then

                local heart = GameObject(GAME_OBJECT_DEFS['heart'], entity.x, entity.y - 15)
                
                entity.hasHeart = false

                heart.onCollide = function()

                    self.player.health = self.player.health + 2

                    Timer.tween(.005, {
                        [heart] = {y = (-50)}
                    })
                    
                end                
                table.insert(self.objects, heart)

            end
            entity.dead = true
            

        elseif not entity.dead then
            entity:processAI({room = self}, dt)
            entity:update(dt)
        end

        -- collision between the player and entities in the room
        if not entity.dead and self.player:collides(entity) and not self.player.invulnerable then
            gSounds['hit-player']:play()
            self.player:damage(1)
            self.player:goInvulnerable(1.5)

            if self.player.health == 0 then
                gStateMachine:change('game-over')
            end
        end
    end

    
    for k, object in pairs(self.objects) do
        object:update(dt)

        -- trigger collision callback on object
        if self.player:collides(object) then


            if object.solid then
                if self.player.direction == 'left' then

                    self.player.x = self.player.x + PLAYER_WALK_SPEED * dt
                        
                elseif self.player.direction == 'right' then
                    
                    self.player.x = self.player.x - PLAYER_WALK_SPEED * dt
                    
                elseif self.player.direction == 'up' then
                    
                    self.player.y = self.player.y + PLAYER_WALK_SPEED * dt
                    
                else
                    self.player.y = self.player.y - PLAYER_WALK_SPEED * dt
                    
                end
            end
                
        object:onCollide()
        end
        
    end
end

function Room:render()
    for y = 1, self.height do
        for x = 1, self.width do
            local tile = self.tiles[y][x]
            love.graphics.draw(gTextures['tiles'], gFrames['tiles'][tile.id],
                (x - 1) * TILE_SIZE + self.renderOffsetX + self.adjacentOffsetX, 
                (y - 1) * TILE_SIZE + self.renderOffsetY + self.adjacentOffsetY)
        end
    end

    -- render doorways; stencils are placed where the arches are after so the player can
    -- move through them convincingly
    for k, doorway in pairs(self.doorways) do
        doorway:render(self.adjacentOffsetX, self.adjacentOffsetY)
    end

    for k, object in pairs(self.objects) do
        object:render(self.adjacentOffsetX, self.adjacentOffsetY)
    end

    for k, entity in pairs(self.entities) do
        if not entity.dead then entity:render(self.adjacentOffsetX, self.adjacentOffsetY) end
    end

    -- stencil out the door arches so it looks like the player is going through
    love.graphics.stencil(function()
        -- left
        love.graphics.rectangle('fill', -TILE_SIZE - 6, MAP_RENDER_OFFSET_Y + (MAP_HEIGHT / 2) * TILE_SIZE - TILE_SIZE,
            TILE_SIZE * 2 + 6, TILE_SIZE * 2)
        
        -- right
        love.graphics.rectangle('fill', MAP_RENDER_OFFSET_X + (MAP_WIDTH * TILE_SIZE) - 6,
            MAP_RENDER_OFFSET_Y + (MAP_HEIGHT / 2) * TILE_SIZE - TILE_SIZE, TILE_SIZE * 2 + 6, TILE_SIZE * 2)
        
        -- top
        love.graphics.rectangle('fill', MAP_RENDER_OFFSET_X + (MAP_WIDTH / 2) * TILE_SIZE - TILE_SIZE,
            -TILE_SIZE - 6, TILE_SIZE * 2, TILE_SIZE * 2 + 12)
    
        --bottom
        love.graphics.rectangle('fill', MAP_RENDER_OFFSET_X + (MAP_WIDTH / 2) * TILE_SIZE - TILE_SIZE,
            VIRTUAL_HEIGHT - TILE_SIZE - 6, TILE_SIZE * 2, TILE_SIZE * 2 + 12)
    
        --ADDED
        --above player

        for i = 2, 4 do

            if self.objects[i].pickedUp then
                love.graphics.rectangle('fill', self.player.x, self.player.y - 12, 16 , 16)
            end
        end

            
    end, 'replace', 1)

    love.graphics.setStencilTest('less', 1)
    
    if self.player then
        self.player:render()
    end

    love.graphics.setStencilTest()
end