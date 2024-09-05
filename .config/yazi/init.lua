-- Show git status in list
require("git"):setup()

-- Add fancy border around TUI
require("full-border"):setup {
    -- Available values: ui.Border.PLAIN, ui.Border.ROUNDED
    type = ui.Border.ROUNDED,
}


-- Add filesize and modified time on same line
-- For folders show number of files plus modified time
function Linemode:size_and_mtime()
    local year = os.date("%Y")
    local time = (self._file.cha.modified or 0) // 1

    if time > 0 and os.date("%Y", time) == year then
        time = os.date("%b %d %H:%M", time)
    else
        time = time and os.date("%b %d  %Y", time) or ""
    end

    local size = self._file:size()
    if size then
        size = ya.readable_size(size)
    else
        local folder = cx.active:history(self._file.url)
        size = folder and tostring(#folder.files) or ""
        -- print(size)
        --return ui.Line(folder and tostring(#folder.files) or "")
    end
    return ui.Line(string.format(" %s %s ", size or "-", time))
end


-- Add user:group before perms in status bar
Status:children_add(function()
    local h = cx.active.current.hovered
    if h == nil or ya.target_family() ~= "unix" then
        return ui.Line {}
    end

    return ui.Line {
        ui.Span(ya.user_name(h.cha.uid) or tostring(h.cha.uid)):fg("magenta"),
        ui.Span(":"),
        ui.Span(ya.group_name(h.cha.gid) or tostring(h.cha.gid)):fg("magenta"),
        ui.Span(" "),
    }   
end, 500, Status.RIGHT)


-- Add username and hostname to TUI header
-- i.e. zack@pc:~/path/to/cwd
Header:children_add(function()
    if ya.target_family() ~= "unix" then
        return ui.Line {}
    end
    return ui.Span(ya.user_name() .. "@" .. ya.host_name() .. ":"):fg("blue")
end, 500, Header.LEFT)


-- Show symlink location in status bar
function Status:name()
    local h = self._tab.current.hovered
    if not h then
        return ui.Line {}
    end

    local linked = ""
    if h.link_to ~= nil then
        linked = " -> " .. tostring(h.link_to)
    end

    return ui.Line(" " .. h.name .. linked)
end




-- Yatline config
require("yatline"):setup({
    section_separator = { open = "", close = "" },
    part_separator = { open = "", close = "" },
    inverse_separator = { open = "", close = "" },
    -- section_separator = { open = "sso", close = "ssc" },
    -- part_separator = { open = "pso", close = "psc" },
    -- inverse_separator = { open = "iso", close = "isc" },

    style_a = {
        fg = "black",
        bg_mode = {
            normal = "blue",
            select = "lightcyan",
            un_set = "cyan"
        }
    },
    style_b = { bg = "green", fg = "#303030" },
    style_c = { bg = "#303030", fg = "gray" },

    permissions_t_fg = "green",
    permissions_r_fg = "yellow",
    permissions_w_fg = "red",
    permissions_x_fg = "cyan",
    permissions_s_fg = "darkgray",

    tab_width = 20,
    tab_use_inverse = false,

    selected = { icon = "󰻭", fg = "yellow" },
    copied = { icon = "", fg = "green" },
    cut = { icon = "", fg = "red" },

    total = { icon = "󰮍", fg = "yellow" },
    succ = { icon = "", fg = "green" },
    fail = { icon = "", fg = "red" },
    found = { icon = "󰮕", fg = "blue" },
    processed = { icon = "󰐍", fg = "green" },

    show_background = false,

    display_header_line = true,
    display_status_line = true,

    header_line = {
        left = {
            section_a = {
                {type = "string", custom = false, name = "tab_path"},
            },
            section_b = {

            },
            section_c = {
               {type = "coloreds", custom = false, name = "githead"},
            }
        },
        right = {
            section_a = {
                 {type = "line", custom = false, name = "tabs", params = {"right"}},
            },
            section_b = {

            },
            section_c = {
                -- {type = "string", custom = false, name = "date", params = {"%A, %d %B %Y"}},
                -- {type = "string", custom = false, name = "date", params = {"%X"}},
            }
        }
    },

    status_line = {
        left = {
            section_a = {
                {type = "string", custom = false, name = "tab_mode"},
            },
            section_b = {
                {type = "string", custom = false, name = "hovered_size"},
            },
            section_c = {
                {type = "string", custom = false, name = "symlink"},
                {type = "coloreds", custom = false, name = "count"},
            }
        },
        right = {
            section_a = {
                {type = "string", custom = false, name = "cursor_position"},
            },
            section_b = {
                {type = "string", custom = false, name = "cursor_percentage"},
            },
            section_c = {
                {type = "string", custom = false, name = "hovered_file_extension", params = {true}},
                {type = "coloreds", custom = false, name = "permissions"},
                {type = "string", custom = false, name = "usergroup"},
            }
        }
    },
})

-- Add githead after yatline so it will add to it if installed
require("yatline-githead"):setup()

-- Add our usergroup function to yatline if it is installed
-- Also add our symlink display
if Yatline ~= nil then
    function Yatline.string.get:usergroup()
        local h = cx.active.current.hovered
        if h == nil or ya.target_family() ~= "unix" then
            return ""
        end

        return (ya.user_name(h.cha.uid) or tostring(h.cha.uid)) .. ":" .. (ya.group_name(h.cha.gid) or tostring(h.cha.gid)) 
    end

    function Yatline.string.get:symlink()
        local h = cx.active.current.hovered
        if not h then
            return ""
        end
    
        local linked = ""
        if h.link_to ~= nil then
            linked = " -> " .. tostring(h.link_to)
        end
    
        return h.name .. linked
    end
end
