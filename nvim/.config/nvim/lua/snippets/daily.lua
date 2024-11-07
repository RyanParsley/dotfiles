local ls = require 'luasnip'
local fmt = require('luasnip.extras.fmt').fmt
local d = require('luasnip.extras').d

return {
    ls.sn(
        { trig = 'daily', dscr = 'Create a daily note template' },
        fmt(
            [[
---
title: {date("%Y-%m-%d")}
created: {date("%Y-%m-%d")}
clarinet: false
tkd: false
meditate: false
tags:
  - daily
---
# {date("%Y-%m-%d")}

## Navigation
[Yesterday]({{date("%Y/%Y-%m-%d", "yesterday")}}) <-> [Tomorrow]({{date("%Y/%Y-%m-%d", "tomorrow")}}) 

## Tasks

## Notes
]],
            {
                date = function(format_str, offset)
                    if offset == 'yesterday' then
                        return os.date(format_str, os.time() - 86400)
                    elseif offset == 'tomorrow' then
                        return os.date(format_str, os.time() + 86400)
                    else
                        return os.date(format_str)
                    end
                end,
            }
        )
    ),
}
