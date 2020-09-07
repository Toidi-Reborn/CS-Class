--[[
    ScoreState Class
    Author: Colton Ogden
    cogden@cs50.harvard.edu

    A simple state used to display the player's score before they
    transition back into the play state. Transitioned to from the
    PlayState when they collide with a Pipe.
]]

PauseState = Class{__includes = BaseState}

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
function PauseState:enter(params)
    self.score = params.score
end

function PauseState:update(dt)
    -- go back to play if enter is pressed
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        gStateMachine:change('play')
    end
end

function PauseState:render()


    -- simply render the score to the middle of the screen
    love.graphics.setFont(flappyFont)
    love.graphics.printf('Oof! You lost!', 0, 64, VIRTUAL_WIDTH, 'center')

    love.graphics.printf('- ' .. tostring(bronzeScore), 50, 115, VIRTUAL_WIDTH)
    
end