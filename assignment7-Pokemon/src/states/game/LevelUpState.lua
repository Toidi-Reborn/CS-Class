

LevelUpState = Class{__includes = BaseState}

function LevelUpState:init(battleState)
    self.battleState = battleState

    
    self.battleMenu = Menu {

        arrow = true,
        font = gFonts['smaller'],
        x = VIRTUAL_WIDTH - 164,
        y = VIRTUAL_HEIGHT - 64,
        width = 164,
        height = 64,
        items = {
            {
                text = 'dfhjdfvhj',
                onSelect = function()
                    --BaTTLEmENu
                    gStateStack:pop()
                    
                    gStateStack:pop()
                    gStateStack:pop() 
                    gStateStack:push(FadeOutState({
                        r = 255, g = 255, b = 255
                    }, 1, function()
                    end))                   
                end
            },
            {
                text =  ' >>> ' ,
                onSelect = function()
                    --BaTTLEmENu
                    gStateStack:pop()
                    
                    gStateStack:pop()
                    gStateStack:pop() 
                    gStateStack:push(FadeOutState({
                        r = 255, g = 255, b = 255
                    }, 1, function()
                    end))                   
                end
            },
            {
                text = 'dfhjdfvhj',
                onSelect = function()
                    --BaTTLEmENu
                    gStateStack:pop()
                    
                    gStateStack:pop()
                    gStateStack:pop() 
                    gStateStack:push(FadeOutState({
                        r = 255, g = 255, b = 255
                    }, 1, function()
                    end))                   
                end
            },
            {
                text = 'dfhjdfvhj',
                onSelect = function()
                    --BaTTLEmENu
                    gStateStack:pop()
                    
                    gStateStack:pop()
                    gStateStack:pop() 
                    gStateStack:push(FadeOutState({
                        r = 255, g = 255, b = 255
                    }, 1, function()
                    end))                   
                end
            },

        }
    }
end

function LevelUpState:update(dt)
    self.battleMenu:update(dt)
end

function LevelUpState:render()
    self.battleMenu:render()
end