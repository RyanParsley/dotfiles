local ls = require 'luasnip'
local fmt = require('luasnip.extras.fmt').fmt
local d = require('luasnip.extras').d

return {
    ls.sn(
        { trig = 'meeting', dscr = 'Create a meeting note template' },
        fmt(
            [[
---
aliases: []
tags: []
---

# {date("%Y-%m-%d")}

## Attendees

- 

## Agenda

- 

## Action Items

- 

## Notes
]],
            { date = os.date }
        )
    ),
}
