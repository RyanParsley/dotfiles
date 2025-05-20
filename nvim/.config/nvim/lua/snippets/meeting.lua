local ls = require 'luasnip'
local fmt = require('luasnip.extras.fmt').fmt

local function date(format_str)
    return os.date(format_str)
end

return {
    ls.sn(
        { trig = 'meeting', dscr = 'Create a meeting note template' },
        fmt(
            [[
---
aliases: []
tags: []
---

# {}

## Attendees

- 

## Agenda

- 

## Action Items

- 

## Notes
]],
            {
                date("%Y-%m-%d"),
            }
        )
    ),
}
