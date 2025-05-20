local ls = require 'luasnip'
local fmt = require('luasnip.extras.fmt').fmt
local d = require('luasnip.extras').d

local today = os.date("%Y-%m-%d")
local yesterday = os.date("%Y/%Y-%m-%d", os.time() - 86400)
local tomorrow = os.date("%Y/%Y-%m-%d", os.time() + 86400)

return {
    ls.sn(
        { trig = 'daily', dscr = 'Create a daily note template' },
        fmt(
            [[
---
title: {}
created: {}
clarinet: false
tkd: false
meditate: false
tags:
  - daily
---
# {}

## Navigation
[Yesterday]({}) <-> [Tomorrow]({}) 

## Tasks

## Notes
]],
            {
                today,
                today,
                today,
                yesterday,
                tomorrow,
            }
        )
    ),
}
