local finders = require "telescope.finders"
local make_entry = require "telescope.make_entry"
local Path = require "plenary.path"
local pickers = require "telescope.pickers"
local last_positions = require"smoothcursor.last_positions"
local entry_display = require "telescope.pickers.entry_display"
local utils = require "telescope.utils"
local strings = require "plenary.strings"

local conf = require("telescope.config").values

local DEFAULT_MODE_ICON_MAP = {
    v = " ",
    V = "",
    i = "",
    R = "󰊄",
}
local DEFAULT_MODE_NAME_MAP = {
    v = "Visual",
    V = "V·Line",
    i = "Insert",
    R = "Replace",
}
local DEFAULT_WHITELISTED_MODES = {
    "v", "V", "i", "R"
}

-- Makes sure aliased options are set correctly
local function apply_cwd_only_aliases(opts)
  local has_cwd_only = opts.cwd_only ~= nil
  local has_only_cwd = opts.only_cwd ~= nil

  if has_only_cwd and not has_cwd_only then
    -- Internally, use cwd_only
    opts.cwd_only = opts.only_cwd
    opts.only_cwd = nil
  end

  return opts
end

return require"telescope".register_extension {
    setup = function() end,
    exports = {
        last_positions = function(opts)
            opts = apply_cwd_only_aliases(opts)
            local iconMap = opts.mode_icon_map or DEFAULT_MODE_ICON_MAP
            local nameMap = opts.mode_name_map or DEFAULT_MODE_NAME_MAP
            local whitelist = opts.whitelisted_modes or DEFAULT_WHITELISTED_MODES
            local results = {}

            for buffer_raw, last_positions_for_buffer in pairs(last_positions.last_positions) do
                local buffer = tonumber(buffer_raw)

                local info = vim.fn.getbufinfo(buffer)[1]
                for mode, pos in pairs(last_positions_for_buffer) do
                    if vim.tbl_contains(whitelist, mode) then
                        local line = pos[1]

                        local element = {
                            bufnr = buffer,
                            info = info,
                            indicator = iconMap[mode] or mode,
                            lnum = line,
                            mode = mode,
                        }

                        table.insert(results, element)
                    end
                end
            end

            if not opts.bufnr_width then
                local max_bufnr = math.max(
                    unpack(
                        vim.tbl_map(
                            function (buffer) return buffer.bufnr end,
                            results
                        )
                    )
                )
                opts.bufnr_width = #tostring(max_bufnr)
            end

            -- Adapted from https://github.com/nvim-telescope/telescope.nvim/blob/da8b3d485975a8727bea127518b65c980521ae22/lua/telescope/make_entry.lua#L574
            local disable_devicons = opts.disable_devicons

            local icon_width = 0
            if not disable_devicons then
                local icon, _ = utils.get_devicons("fname", disable_devicons)
                icon_width = strings.strdisplaywidth(icon)
            end

            local displayer = entry_display.create {
                separator = " ",
                items = {
                    { width = opts.bufnr_width },
                    { width = 4 },
                    { width = icon_width },
                    { remaining = true },
                },
            }

            local cwd = vim.fn.expand(opts.cwd or vim.loop.cwd())

            local make_display = function(entry)
                opts.__prefix = opts.bufnr_width + 4 + icon_width + 3 + 1 + #tostring(entry.lnum)
                local display_bufname = utils.transform_path(opts, entry.filename)
                local icon, hl_group = utils.get_devicons(entry.filename, disable_devicons)

                return displayer {
                    { entry.bufnr, "TelescopeResultsNumber" },
                    { entry.indicator, "TelescopeResultsComment" },
                    { icon, hl_group },
                    display_bufname .. ":" .. entry.lnum .. " - " .. (nameMap[entry.extra] or entry.extra),
                }
            end

            pickers
            .new(opts, {
                prompt_title = "Last Positions",
                finder = finders.new_table {
                    results = results,
                    entry_maker = function(entry)
                        local bufname = entry.info.name ~= "" and entry.info.name or "[No Name]"
                        -- if bufname is inside the cwd, trim that part of the string
                        bufname = Path:new(bufname):normalize(cwd)

                        return make_entry.set_default_entry_mt({
                            value = bufname,
                            ordinal = entry.bufnr .. " : " .. bufname,
                            display = make_display,

                            bufnr = entry.bufnr,
                            filename = bufname,
                            lnum = entry.lnum,
                            indicator = entry.indicator,
                            extra = entry.mode,
                        }, opts)
                    end
                },
                previewer = conf.grep_previewer(opts),
                sorter = conf.generic_sorter(opts),
            }):find()
        end
    }
}
