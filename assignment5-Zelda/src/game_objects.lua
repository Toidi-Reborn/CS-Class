--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

GAME_OBJECT_DEFS = {
    ['switch'] = {
        type = 'switch',
        texture = 'switches',
        frame = 2,
        width = 16,
        height = 16,
        solid = false,
        defaultState = 'unpressed',
        states = {
            ['unpressed'] = {
                frame = 2
            },
            ['pressed'] = {
                frame = 1
            }
        }
    },
    ['pot'] = {
        type = 'tiles',
        texture = 'tiles',
        frame = 14,
        width = 12,
        height = 12,
        solid = true,
        defaultState = 'floor',
        states = {
            ['floor'] = {
                frame = 14,
            },
            ['player'] = {
                frame = 14,
                solid = false,
            },
            ['thrown'] = {
                frame = 14,
            },
            ['crash'] = {
                frame = 52,
                solid = true,
            },
            ['dead'] = {

            }

        },
  



        -- TODO
    },
    ['heart'] = {
        type = 'hearts',
        texture = 'hearts',
        width = 16,
        height = 16,
        frame = 5,
        defaultState = 'one',
        states = {
            ['one'] = {
                frame = 5
            }

        }



    }
}