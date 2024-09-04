-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

-- For example, changing the color scheme:
config.color_scheme = 'Alacritty'
config.font = wezterm.font 'JetBrainsMono Nerd Font'
-- config.default_prog = { 'wsl.exe' }
config.wsl_domains = {
  {
    -- The name of this specific domain.  Must be unique amonst all types
    -- of domain in the configuration file.
    name = 'WSL:Ubuntu',

    -- The name of the distribution.  This identifies the WSL distribution.
    -- It must match a valid distribution from your `wsl -l -v` output in
    -- order for the domain to be useful.
    distribution = 'Ubuntu',
  },
}
config.default_domain = 'WSL:Ubuntu'

config.color_schemes = {
  ['Alacritty'] = {
    background = '#181818',
    foreground = '#d8d8d8',
    ansi = {
      "#181818",
      "#ac4242",
      "#90a959",
      "#f4bf75",
      "#6a9fb5",
      "#aa759f",
      "#75b5aa",
      "#d8d8d8",
    },
    brights = {
      "#6b6b6b",
      "#c55555",
      "#aac474",
      "#feca88",
      "#82b8c8",
      "#c28cb8",
      "#93d3c3",
      "#f8f8f8",
    },
  },
}

-- and finally, return the configuration to wezterm
return config