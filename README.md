# coc-lightbulb

VSCode 💡 for coc.nvim. Inspired by [nvim-lightbulb](https://github.com/kosayoda/nvim-lightbulb)

## Introduction

The plugin shows a lightbulb in the sign column whenever a textDocument/codeAction is available at the current cursor position.

## Configuration

All available options by default

```lua
require('coc-lightbulb').setup {
  -- enable this plugin
  enable = true,
  sign = {
    enabled = true,
    -- Priority of the sign
    priority = 10,
  },
  virtual_text = {
    enabled = false,
    -- text to show
    text = '💡',
  },
  status_text = {
    enabled = false,
    -- text to show
    text = '💡',
  },
}
```

- sign name: `LightBulbSign`
- virtual text highlight: `LightBulbVirtualText`
- statusline integration: `b:lightbulb_status_text` or `require'coc-lightbulb'.get_status()`
