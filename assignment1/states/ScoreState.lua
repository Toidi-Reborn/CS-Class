--[[
    ScoreState Class
    Author: Colton Ogden
    cogden@cs50.harvard.edu

    A simple state used to display the player's score before they
    transition back into the play state. Transitioned to from the
    PlayState when they collide with a Pipe.
]]

ScoreState = Class{__includes = BaseState}

--ADDED
-- vars set for medal level for easy change
local goldM = love.graphics.newImage('images/gold.png')
local silverM = love.graphics.newImage('images/silver.png')
local bronzeM = love.graphics.newImage('images/bronze.png')
local medalScaler = 0.20
local goldScore = 5
local silverScore = 3
local bronzeScore = 1



--[[
    When we enter the score state, we expect to receive the score
    from the play state so we know what to render to the State.
]]
function ScoreState:enter(params)
    self.score = params.score
    gameStarted = false
end

function ScoreState:update(dt)
    -- go back to play if enter is pressed
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        gStateMachine:change('countdown')
    end
end

function ScoreState:render()


    --ADDED
    if self.score >= goldScore then
        love.graphics.draw(goldM, (VIRTUAL_WIDTH / 2) -  ((goldM:getWidth() * medalScaler) / 2), VIRTUAL_HEIGHT / 3, 0, medalScaler, medalScaler)
    elseif self.score >= silverScore then
        love.graphics.draw(silverM, (VIRTUAL_WIDTH / 2) -  ((silverM:getWidth() * medalScaler) / 2), VIRTUAL_HEIGHT / 3, 0, medalScaler, medalScaler)
    elseif self.score >= bronzeScore then
        love.graphics.draw(bronzeM, (VIRTUAL_WIDTH / 2) -  ((bronzeM:getWidth() * medalScaler) / 2), VIRTUAL_HEIGHT / 3, 0, medalScaler, medalScaler)
    end

    

    -- simply render the score to the middle of the screen
    love.graphics.setFont(flappyFont)
    love.graphics.printf('Oof! You lost!', 0, 64, VIRTUAL_WIDTH, 'center')

    love.graphics.setFont(mediumFont)
    love.graphics.printf('Score: ' .. tostring(self.score), 0, 100, VIRTUAL_WIDTH, 'center')

    love.graphics.printf('Press Enter to Play Again!', 0, 160, VIRTUAL_WIDTH, 'center')


    --ADDED
    -- medal requirements   
    love.graphics.printf('Requirements', 5, 5, 100)
    love.graphics.draw(goldM, 30, 25, 0, medalScaler / 4, medalScaler / 4)
    love.graphics.printf('- ' .. tostring(goldScore), 50, 35, VIRTUAL_WIDTH)
    love.graphics.draw(silverM, 30, 65, 0, medalScaler / 4, medalScaler / 4)
    love.graphics.printf('- ' .. tostring(silverScore), 50, 75, VIRTUAL_WIDTH)
    love.graphics.draw(bronzeM, 30, 105, 0, medalScaler / 4, medalScaler / 4)
    love.graphics.printf('- ' .. tostring(bronzeScore), 50, 115, VIRTUAL_WIDTH)
    
end