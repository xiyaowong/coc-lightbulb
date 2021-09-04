# coc-lightbulb

VSCode 💡 for coc.nvim. Inspired by [nvim-lightbulb](https://github.com/kosayoda/nvim-lightbulb)

![GIF](https://user-images.githubusercontent.com/47070852/128601281-c322901c-2198-4595-9e35-dff3d10369fc.gif)

**You can use extension [coc-lightbulb](https://github.com/xiyaowong/coc-lightbulb-) instead of this plugin**

## Requirements

neovim 0.5+

## Introduction

The plugin shows a lightbulb in the sign column whenever a textDocument/codeAction is available at the current cursor position.

## Configuration

All available options by default

```lua
require('coc-lightbulb').setup {
  -- enable this plugin
  enable = true,
  -- Disable this plugin in these filetypes. As some servers provide code actions everywhere...
  disabled_filetyps = {},
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
  float = { -- Tips: you can click the float window to run CocAction
    -- The diagnostic window may be broken
    enabled = false,
    text = '💡',
  },
}
```

- sign name: `LightBulbSign`
- virtual text highlight: `LightBulbVirtualText`
- statusline integration: `b:lightbulb_status_text` or `require'coc-lightbulb'.get_status()`
- float window highlight: `LightBulbFloatWin`
