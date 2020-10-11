--[[
    GD50
    Super Mario Bros. Remake

    -- LevelMaker Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

LevelMaker = Class{}

function LevelMaker.generate(width, height)
    local tiles = {}
    local entities = {}
    local objects = {}

    local tileID = TILE_ID_GROUND
    
    -- whether we should draw our tiles with toppers
    local topper = true
    local tileset = math.random(20)
    local topperset = math.random(20)
    
    --ADDED
    local keyset = math.random(4)
    local keyDrawn = false
    local keyCollected = false
    local lockDrawn = false
    local keyInBox = false
    local flagDrawn = false
    playerWins = false

    local flagY = 0
    local flagX = 0


    -- insert blank tables into tiles for later access
    for x = 1, height do
        table.insert(tiles, {})
    end

    -- column by column generation instead of row; sometimes better for platformers
    for x = 1, width do
        local tileID = TILE_ID_EMPTY
        
        -- lay out the empty space
        for y = 1, 6 do
                table.insert(tiles[y],
                Tile(x, y, tileID, nil, tileset, topperset))
        end

        -- chance to just be emptiness
        if math.random(7) == 1 and x < (width - 10) then -------------------------flat land for finish
            
            for y = 7, height do
                table.insert(tiles[y],
                    Tile(x, y, tileID, nil, tileset, topperset))
            end

        else
            tileID = TILE_ID_GROUND

            local blockHeight = 4

            for y = 7, height do
                table.insert(tiles[y],
                    Tile(x, y, tileID, y == 7 and topper or nil, tileset, topperset))
            end

            -- chance to generate a pillar
            if math.random(20) == 1 and x < (width - 10) then
                blockHeight = 2
                
                -- chance to generate bush on pillar
                if math.random(8) == 1 then
                    table.insert(objects,
                        GameObject {
                            texture = 'bushes',
                            x = (x - 1) * TILE_SIZE,
                            y = (4 - 1) * TILE_SIZE,
                            width = 16,
                            height = 16,
                            
                            -- select random frame from bush_ids whitelist, then random row for variance
                            frame = BUSH_IDS[math.random(#BUSH_IDS)] + (math.random(4) - 1) * 7
                        }
                    )
                end
                
                -- pillar tiles
                tiles[5][x] = Tile(x, 5, tileID, topper, tileset, topperset)
                tiles[6][x] = Tile(x, 6, tileID, nil, tileset, topperset)
                tiles[7][x].topper = nil
            
            -- chance to generate bushes
            elseif math.random(8) == 1 then
                table.insert(objects,
                    GameObject {
                        texture = 'bushes',
                        x = (x - 1) * TILE_SIZE,
                        y = (6 - 1) * TILE_SIZE,
                        width = 16,
                        height = 16,
                        frame = BUSH_IDS[math.random(#BUSH_IDS)] + (math.random(4) - 1) * 7,
                        collidable = true,
                    }
                )
            
            end

         
            -- chance to spawn a block
            if math.random(10) == 1 and x < (width - 10) then  --No boxes at finish area

                
                table.insert(objects,

                    -- jump block
                    GameObject {
                        texture = 'jump-blocks',
                        x = (x - 1) * TILE_SIZE,
                        y = (blockHeight - 1) * TILE_SIZE,
                        width = 16,
                        height = 16,

                        -- make it a random variant
                        frame = math.random(#JUMP_BLOCKS),
                        collidable = true,
                        hit = false,
                        solid = true,

                        -- collision function takes itself
                        onCollide = function(obj)

                            -- spawn a gem if we haven't already hit the block
                            if not obj.hit then

                                --CHANGED
                                if math.random(3) == 1 then
                                
                                    -- maintain reference so we can set it to nil
                                    local gem = GameObject {
                                        texture = 'gems',
                                        x = (x - 1) * TILE_SIZE,
                                        y = (blockHeight - 1) * TILE_SIZE - 4,
                                        width = 16,
                                        height = 16,
                                        frame = math.random(#GEMS),
                                        collidable = true,
                                        consumable = true,
                                        solid = false,

                                        -- gem has its own function to add to the player's score
                                        onConsume = function(player, object)
                                            gSounds['pickup']:play()
                                            player.score = player.score + 100
                                        end
                                    }
                                    
                                    -- make the gem move up from the block and play a sound
                                    Timer.tween(0.1, {
                                        [gem] = {y = (blockHeight - 2) * TILE_SIZE}
                                    })
                                    gSounds['powerup-reveal']:play()

                                    table.insert(objects, gem)                                                                
                                end

                                obj.hit = true

                            end

                            gSounds['empty-block']:play()
                        end
                    }
                )
            



            
                --ADDED - chance to spawn key block
               
            elseif not keyDrawn and (math.random(25) == 1 or x > width-25) then
                keyDrawn = true

                table.insert(objects,

                    -- jump block
                    GameObject {
                        texture = 'jump-blocks',
                        x = (x - 1) * TILE_SIZE,
                        y = (blockHeight - 1) * TILE_SIZE,
                        width = 16,
                        height = 16,

                        -- make it a random variant
                        frame = math.random(#JUMP_BLOCKS),
                        collidable = true,
                        hit = false,
                        solid = true,

                        -- collision function takes itself
                        onCollide = function(obj)

                            -- spawn a gem if we haven't already hit the block
                            if not obj.hit then

                                -- maintain reference so we can set it to nil
                                local key = GameObject {
                                    texture = 'keys',
                                    x = (x - 1) * TILE_SIZE,
                                    y = (blockHeight - 1) * TILE_SIZE - 4,
                                    width = 16,
                                    height = 16,
                                    frame = keyset,
                                    collidable = true,
                                    consumable = true,
                                    solid = false,

                                    -- gem has its own function to add to the player's score
                                    onConsume = function(player, object)
                                        gSounds['pickup']:play()
                                        player.keyColor = keyset
                                        player.hasKey = true
                                        keyCollected = true
                                        player.score = player.score + 100
                                    end
                                }

                                -- make the key move up from the block and play a sound
                                Timer.tween(0.1, {
                                    [key] = {y = (blockHeight - 2) * TILE_SIZE}
                                })
                                gSounds['powerup-reveal']:play()

                                table.insert(objects, key)

                            end
                            
                            obj.hit = true


                            gSounds['empty-block']:play()
                        end
                    }
                )
            



                --end of block draw

            
            
            
            --elseif not lockDrawn and (x > width - 10) then

            elseif not lockDrawn and (x > width - 9) then
                
                lockDrawn = true
                table.insert(objects,

                -- jump block
                GameObject {
                    texture = 'keys',
                    x = (x - 1) * TILE_SIZE,
                    y = (blockHeight - 1) * TILE_SIZE,
                    width = 16,
                    height = 16,

                    -- make it a random variant
                    frame = keyset + 4,
                    collidable = true,
                    hit = false,
                    solid = true,
                    lock = true,

                    -- collision function takes itself
                    onCollide = function(obj)

                        -- spawn a gem if we haven't already hit the block
                        if keyCollected and not obj.hit then
                                                                            
                            Timer.tween(0.5, {
                              [obj] = {y = (blockHeight - 20) * TILE_SIZE}
                            })
                            gSounds['powerup-reveal']:play()
                                            
                            

                            obj.hit = true


                            --pole
                            table.insert(objects,

                            GameObject {
                                texture = 'pole',  
                                x = ((width - 5) * TILE_SIZE),
                                y = (3 * TILE_SIZE) + 1,
                                width = 16,
                                height = 16 * 3,
                                frame = 1,
                                collidable = true,
                                consumable = true,
                                hit = false,
                                solid = false,


                                onConsume = function(obj) --collide with pole
                                    
                                    if not obj.hit then
                                    

                                        table.insert(objects,
                                    
                                            GameObject {
                                                texture = 'pole',  
                                                x = ((width - 5) * TILE_SIZE),
                                                y = (3 * TILE_SIZE) + 1,
                                                width = 16,
                                                height = 16,
                                                frame = 1,
                                                collidable = false,
                                                consumable = false,
                                                hit = false,
                                                solid = false,
                                            
                                            }

                                        )
                                
                                        

                                        local flag = GameObject {
                                            texture = 'pole',  
                                            x = ((width - 5) * TILE_SIZE) + 7,  -- plus 7 for pole offset   was -4
                                            y = (5 * TILE_SIZE) + 1,
                                            width = 16,
                                            height = 16,
                                            frame = 4,
                                            collidable = false,
                                            consumable = false,
                                            hit = false,
                                            solid = false,
                                            isFlag = true,
                                                
                                                
                                            }

                                            Timer.tween(1.5, {
                                                [flag] = {y =  (blockHeight - 1) * TILE_SIZE}
                                            })


                                            table.insert(objects, flag)

                                            
                                           

                                        obj.hit = true   
                                    end




                                end
                            }
                            
                            )    



                        end

                        gSounds['empty-block']:play()
                    end
                   
                }
            )



            end




--[[
            --ADDED Final Flag
            if x == width - 90 then
                    
                table.insert(objects,

                -- jump block
                GameObject {
                    texture = 'pole',
                    x = (x - 1) * TILE_SIZE,
                    y = ((blockHeight - 1) * TILE_SIZE) + 1,
                    width = 7,
                    height = 47,

                    -- make it a random variant
                    frame = 1,
                    collidable = true,
                    hit = false,
                    solid = true,
                    active = false,

                    -- collision function takes itself
                    onCollide = function(obj)

                        -- spawn a gem if we haven't already hit the block
                        if keyCollected and not obj.hit then
                        
                            onConsume = function(player, obj)
                                gSounds['pickup']:play()
                            end
                            
                            -- make the gem move up from the block and play a sound
                            Timer.tween(0.1, {
                                [obj] = {y = (blockHeight - 20) * TILE_SIZE}
                            })
                            gSounds['powerup-reveal']:play()
                                                
                            obj.hit = true

                        end

                        gSounds['empty-block']:play()
                    end
                }
            )

            end
]]
            

        end
    end

    local map = TileMap(width, height)
    map.tiles = tiles
    
    return GameLevel(entities, objects, map)
end