# telescope-last-positions.nvim

Remembers the last position where you left insert / visual / replace or any other mode!

This plugins requires [SmoothCursor.nvim](https://github.com/gen740/SmoothCursor.nvim) 
as this plugin implements the actual functionality.

## Showcase

https://github.com/Myzel394/telescope-last-positions.nvim/assets/50424412/98704b7d-73dc-4a7d-bf6f-ef62a80b3182

## Requirements

* [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)
* [SmoothCursor.nvim](https://github.com/gen740/SmoothCursor.nvim)

## Usage

```command
:Telescope last_positions
```

Setting a keymap is recommended:

```lua
vim.api.nvim_set_keymap("n", "<leader>l", "<Cmd>Telescope last_positions<CR>", { desc = "Open Last Positions" })
```

## Installation

This is a [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) plugin, make sure you have it installed.

1. Make sure `SmoothCursor.nvim` is installed and **show_last_positions is enabled**.

```lua
require"smoothcursor".setup {
  show_last_positions = "leave" -- or "enter"
}
```

2. Install `Myzel394/telescope-last-positions.nvim` with your favorite plugin manager.

```lua
"Myzel394/telescope-last-positions.nvim",
```

3. Load extension

```lua
require("telescope").load_extension("last_positions")
```

## Configuration

Configure the extension like any other Telescope extension.
The example below show all available configuration options and
their default values.

```lua
require("telescope").setup {
    extensions = {
        last_positions = {
            -- What modes should be tracked
            whitelisted_modes = { "v", "V", "i", "R" },
            -- Maps mode to the icon shown in the preview's indicator
            mode_icon_map = {
                v = " ",
                V = "",
                i = "",
                R = "󰊄",
            },
            -- Maps mode to the name shown next to the actual filename
            mode_name_map = {
                v = "Visual",
                V = "V·Line",
                i = "Insert",
                R = "Replace",
            }
        }
    }
}
```
