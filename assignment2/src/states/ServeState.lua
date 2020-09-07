--[[
    GD50
    Breakout Remake

    -- ServeState Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    The state in which we are waiting to serve the ball; here, we are
    basically just moving the paddle left and right with the ball until we
    press Enter, though everything in the actual game now should render in
    preparation for the serve, including our current health and score, as
    well as the level we're on.
]]

ServeState = Class{__includes = BaseState}

function ServeState:enter(params)
    -- grab game state from params
    self.paddle = params.paddle
    self.bricks = params.bricks
    self.health = params.health
    self.score = params.score
    self.highScores = params.highScores
    self.level = params.level
    self.recoverPoints = params.recoverPoints

    -- init new ball (random color for fun)

    self.ball = Ball()
    self.ball2 = Ball()
    self.ball3 = Ball()
    --self.ball.skin = math.random(7)
    self.ball.skin = 1
    self.ball2.skin = 4
    self.ball3.skin = 5

    self.ballSet = {}
    self.ballSet[0] = self.ball
    self.ballSet[1] = self.ball2

end

function ServeState:update(dt)
    -- have the ball track the player
    self.paddle:update(dt)


    --ADDED
    for thisBall in pairs(self.ballSet) do
        self.ballSet[thisBall].x = self.paddle.x + (self.paddle.width / 2) - 4
        self.ballSet[thisBall].y = self.paddle.y - 8
    end




    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        -- pass in all important state info to the PlayState
        gStateMachine:change('play', {
            paddle = self.paddle,
            bricks = self.bricks,
            health = self.health,
            score = self.score,
            highScores = self.highScores,
            ballSet = self.ballSet,
            
            --ball = self.ball,
            --ball2 = self.ball2,
            --ball3 = self.ball3,
            level = self.level,
            recoverPoints = self.recoverPoints,



        })
    end

    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
end

function ServeState:render()
    self.paddle:render()
    self.ball:render()

    for k, brick in pairs(self.bricks) do
        brick:render()
    end

    renderScore(self.score)
    renderHealth(self.health)

    love.graphics.setFont(gFonts['large'])
    love.graphics.printf('Level ' .. tostring(self.level), 0, VIRTUAL_HEIGHT / 3,
        VIRTUAL_WIDTH, 'center')

    love.graphics.setFont(gFonts['medium'])
    love.graphics.printf('Press Enter to serve!', 0, VIRTUAL_HEIGHT / 2,
        VIRTUAL_WIDTH, 'center')
end