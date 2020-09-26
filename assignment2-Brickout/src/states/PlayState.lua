--[[
    GD50
    Breakout Remake

    -- PlayState Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Represents the state of the game in which we are actively playing;
    player should control the paddle, with the ball actively bouncing between
    the bricks, walls, and the paddle. If the ball goes below the paddle, then
    the player should lose one point of health and be taken either to the Game
    Over screen if at 0 health or the Serve screen otherwise.
]]

PlayState = Class{__includes = BaseState}

--[[
    We initialize what's in our PlayState via a state table that we pass between
    states as we go from playing to serving.
]]
function PlayState:enter(params)
    self.paddle = params.paddle
    self.bricks = params.bricks
    self.health = params.health
    self.score = params.score
    self.highScores = params.highScores
    self.level = params.level

    self.recoverPoints = 500000 --was 5000

    --ADDED
    self.ballSet = params.ballSet
    
    --self.paddle.hasKey = false
    self.keyPowerUp = PowerUp("key")
    self.ballsPowerUp = PowerUp("balls")
    self.levelHasKeyBrick = false

    self.levelScore = 0

    for thisBall in pairs(self.ballSet) do   
        self.ballSet[thisBall].dx = math.random(-200, 200)
        self.ballSet[thisBall].dy = math.random(-50, -60)
    end
end

function PlayState:update(dt)
    if self.paused then
        if love.keyboard.wasPressed('space') then
            self.paused = false
            gSounds['pause']:play()
        else
            return
        end
    elseif love.keyboard.wasPressed('space') then
        self.paused = true
        gSounds['pause']:play()
        return
    end

    -- update positions based on velocity
    self.paddle:update(dt)

    
    for thisBall in pairs(self.ballSet) do
        if self.ballSet[thisBall].inPlay then
            self.ballSet[thisBall]:update(dt)
        end    
    end


    --ADDED
    if self.keyPowerUp.inPlay then
        self.keyPowerUp:update(dt)

        if self.keyPowerUp:collides(self.paddle) then
            gSounds['select']:play()
            self.powerUsed = true
            self.paddle.hasKey = true
            self.keyPowerUp:reset()
        end

    end


    if self.ballsPowerUp.inPlay then
        self.ballsPowerUp:update(dt)

        if self.ballsPowerUp:collides(self.paddle) then
            self.powerUsed = true
            self.ballSet[1].dx = math.random(-200, 200)
            self.ballSet[1].dy = math.random(-50, -60)
            self.ballSet[2].dx = math.random(-200, 200)
            self.ballSet[2].dy = math.random(-50, -60)

            self.ballSet[1].inPlay = true
            self.ballSet[2].inPlay = true

            self.ballsPowerUp:reset()
        end

    end


    
    --ADDED
    for thisBall in pairs(self.ballSet) do

        if self.ballSet[thisBall].inPlay and self.ballSet[thisBall]:collides(self.paddle) then
            -- raise ball above paddle in case it goes below it, then reverse dy
            self.ballSet[thisBall].y = self.paddle.y - 8
            self.ballSet[thisBall].dy = -self.ballSet[thisBall].dy

            --
            -- tweak angle of bounce based on where it hits the paddle
            --

            -- if we hit the paddle on its left side while moving left...
            if self.ballSet[thisBall].x < self.paddle.x + (self.paddle.width / 2) and self.paddle.dx < 0 then
                self.ballSet[thisBall].dx = -50 + -(8 * (self.paddle.x + self.paddle.width / 2 - self.ballSet[thisBall].x))
            
            -- else if we hit the paddle on its right side while moving right...
            elseif self.ballSet[thisBall].x > self.paddle.x + (self.paddle.width / 2) and self.paddle.dx > 0 then
                self.ballSet[thisBall].dx = 50 + (8 * math.abs(self.paddle.x + self.paddle.width / 2 - self.ballSet[thisBall].x))
            end

            gSounds['paddle-hit']:play()
        end
    


        -- detect collision across all bricks with the ball
        for k, brick in pairs(self.bricks) do

            -- only check collision if we're in play
            if brick.inPlay and self.ballSet[thisBall]:collides(brick) then

                if brick.isKeyBrick and not self.paddle.hasKey then

                    --Do nothing
                    --dont need to be its own but easier to read for me

                else
                    self.paddle.brickCount = self.paddle.brickCount + 1
                    -- add to score
                    self.score = self.score + (brick.tier * 200 + brick.color * 25)
                    self.levelScore = self.levelScore + (brick.tier * 200 + brick.color * 25)

        
                    --ADDED - larger paddle when x number of bricks are hit
                    if self.paddle.brickCount == self.paddle.brickCountChange then
                        self.paddle:changeSize("up")
                        self.paddle.brickCountChange = math.random(3, 10)
                        self.paddle.brickCount = 0
                    end


                    if not self.ballsPowerUp.powerUsed and self.levelScore >= 250 then
                        self.ballsPowerUp.inPlay = true
                        self.ballsPowerUp.powerUsed = true
                    end

                    if not self.paddle.hasKey and not self.keyPowerUp.powerUsed and self.levelScore >= 5000 and self.levelHasKeyBrick then
                        self.keyPowerUp.inPlay = true
                        self.keyPowerUp.powerUsed = true
                    end




                    -- trigger the brick's hit function, which removes it from play

                    brick:hit()

                    -- if we have enough points, recover a point of health
                    if self.score > self.recoverPoints then
                        -- can't go above 3 health
                        self.health = math.min(3, self.health + 1)

                        -- multiply recover points by 2
                        self.recoverPoints = math.min(100000, self.recoverPoints * 2) ---truned up for testing without it

                        -- play recover sound effect
                        gSounds['recover']:play()
                    end

                    -- go to our victory screen if there are no more bricks left
                    if self:checkVictory() then
                        gSounds['victory']:play()
                        self.paddle.hasKey = false
                        gStateMachine:change('victory', {
                            level = self.level,
                            paddle = self.paddle,
                            health = self.health,
                            score = self.score,
                            highScores = self.highScores,
                            ball = self.ballSet[thisBall],
                            recoverPoints = self.recoverPoints
                        })
                    end



                end


                    --
                -- collision code for bricks
                --
                -- we check to see if the opposite side of our velocity is outside of the brick;
                -- if it is, we trigger a collision on that side. else we're within the X + width of
                -- the brick and should check to see if the top or bottom edge is outside of the brick,
                -- colliding on the top or bottom accordingly 
                --

                -- left edge; only check if we're moving right, and offset the check by a couple of pixels
                -- so that flush corner hits register as Y flips, not X flips
                if self.ballSet[thisBall].x + 2 < brick.x and self.ballSet[thisBall].dx > 0 then
                    
                    -- flip x velocity and reset position outside of brick
                    self.ballSet[thisBall].dx = -self.ballSet[thisBall].dx
                    self.ballSet[thisBall].x = brick.x - 8
                
                -- right edge; only check if we're moving left, , and offset the check by a couple of pixels
                -- so that flush corner hits register as Y flips, not X flips
                elseif self.ballSet[thisBall].x + 6 > brick.x + brick.width and self.ballSet[thisBall].dx < 0 then
                    
                    -- flip x velocity and reset position outside of brick
                    self.ballSet[thisBall].dx = -self.ballSet[thisBall].dx
                    self.ballSet[thisBall].x = brick.x + 32
                
                -- top edge if no X collisions, always check
                elseif self.ballSet[thisBall].y < brick.y then
                    
                    -- flip y velocity and reset position outside of brick
                    self.ballSet[thisBall].dy = -self.ballSet[thisBall].dy
                    self.ballSet[thisBall].y = brick.y - 8
                
                -- bottom edge if no X collisions or top collision, last possibility
                else
                    
                    -- flip y velocity and reset position outside of brick
                    self.ballSet[thisBall].dy = -self.ballSet[thisBall].dy
                    self.ballSet[thisBall].y = brick.y + 16
                end

                -- slightly scale the y velocity to speed up the game, capping at +- 150
                if math.abs(self.ballSet[thisBall].dy) < 150 then
                    self.ballSet[thisBall].dy = self.ballSet[thisBall].dy * 1.02
                end

                -- only allow colliding with one brick, for corners
                break





                
            end
        end

        -- if ball goes below bounds, revert to serve state and decrease health
        
        --CHANGE - set play to false when goes off screen
        if self.ballSet[thisBall].y >= VIRTUAL_HEIGHT then
            self.ballSet[thisBall].inPlay = false
        end

        --[[       
            REMOVED - reused to test for more than just the main ball and placed outside a for loop

            Moved to be after the for loop
            self.health = self.health - 1
            gSounds['hurt']:play()

            if self.health == 0 then
                gStateMachine:change('game-over', {
                    score = self.score,
                    highScores = self.highScores
                })
            else
                gStateMachine:change('serve', {
                    paddle = self.paddle,
                    bricks = self.bricks,
                    health = self.health,
                    score = self.score,
                    highScores = self.highScores,
                    level = self.level,
                    recoverPoints = self.recoverPoints
                })
            end
        end
        ]]

        -- for rendering particle systems
        for k, brick in pairs(self.bricks) do
            brick:update(dt)
        
        end

        if love.keyboard.wasPressed('escape') then
            love.event.quit()
        end

        if love.keyboard.wasPressed('t') then
            local x = math.random(2)

            if x == 1 then
                self.keyPowerUp.inPlay = true
            elseif x == 2 then
                self.ballsPowerUp.inPlay = true
            end
        end
    end

    --ADDED - taken out of for loop to check all balls
    if self.ballSet[0].inPlay == false and self.ballSet[1].inPlay == false and self.ballSet[2].inPlay == false and self.ballSet[3].inPlay == false then            
        self.health = self.health - 1
        gSounds['hurt']:play()
        self.levelScore = 0

        if self.health == 0 then
            gStateMachine:change('game-over', {
                score = self.score,
                highScores = self.highScores
            })

        else
            self.paddle:changeSize("down")
            gStateMachine:change('serve', {
                paddle = self.paddle,
                bricks = self.bricks,
                health = self.health,
                score = self.score,
                highScores = self.highScores,
                level = self.level,
                recoverPoints = self.recoverPoints
            })
        end
    end
end



function PlayState:render()
    --ADDED
    if self.keyPowerUp.inPlay then
        self.keyPowerUp:render()
    end

    if self.ballsPowerUp.inPlay then
        self.ballsPowerUp:render()
    end

    self.levelHasKeyBrick = false
    -- render bricks
    for k, brick in pairs(self.bricks) do

        if brick.isKeyBrick then
            self.levelHasKeyBrick = true    
        end

        brick:render()
    end
    -- render all particle systems
    for k, brick in pairs(self.bricks) do
        brick:renderParticles()
    end

    --ADDED
    self.paddle:render()

    if self.paddle.hasKey then
        love.graphics.draw(gTextures['main'], gFrames['power'][10], 20, 180, 0, 1, 1)
    end

    
    -- using array and inplay
    for thisBall in pairs(self.ballSet) do
        if self.ballSet[thisBall].inPlay then
            self.ballSet[thisBall]:render()
        end
    end

    --self.ballSet[thisBall]:render()
    
    renderScore(self.score)
    renderHealth(self.health)

    -- pause text, if paused
    if self.paused then
        love.graphics.setFont(gFonts['large'])
        love.graphics.printf(self.bricks, 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH, 'center')
    end

    --ADDED - to see what the brickCount is for paddle change during testing
    --love.graphics.print(self.paddle.brickCountChange, 25, 55)
    --love.graphics.print(self.levelScore, 25, 75)
    -- love.graphics.print(self.totalBrickCount, 25, 105)



end

function PlayState:checkVictory()
    for k, brick in pairs(self.bricks) do
        if brick.inPlay then
            return false
        end 
    end

    return true
end