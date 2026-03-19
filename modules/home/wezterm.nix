{ pkgs, ... }:

{
  programs.wezterm = {
    enable = true;
    extraConfig = ''
      local wezterm = require("wezterm")
      local config = wezterm.config_builder()

      -- Font
      config.font = wezterm.font("JetBrainsMono Nerd Font")
      config.font_size = 12.0

      -- Window
      config.window_padding = { left = 8, right = 8, top = 8, bottom = 8 }
      config.window_decorations = "NONE"
      config.window_background_opacity = 0.85

      -- Wayland
      config.enable_wayland = true

      -- matugen dynamic colors (graceful fallback if file not yet generated)
      local colors_file = os.getenv("HOME") .. "/.cache/matugen/wezterm-colors.lua"
      local ok, colors = pcall(dofile, colors_file)
      if ok then config.colors = colors end
      -- Watch the colors file so WezTerm reloads when matugen regenerates it
      wezterm.add_to_config_reload_watch_list(colors_file)

      -- Re-enable tab bar for multiplexing
      config.enable_tab_bar = true
      config.hide_tab_bar_if_only_one_tab = true

      -- Keybindings (CTRL+SHIFT based to avoid ALT/$mod conflict)
      config.keys = {
        -- Splits
        { key = "i", mods = "CTRL|SHIFT", action = wezterm.action.SplitHorizontal { domain = "CurrentPaneDomain" } },
        { key = "o", mods = "CTRL|SHIFT", action = wezterm.action.SplitVertical   { domain = "CurrentPaneDomain" } },

        -- Pane navigation
        { key = "LeftArrow",  mods = "CTRL|SHIFT", action = wezterm.action.ActivatePaneDirection("Left")  },
        { key = "RightArrow", mods = "CTRL|SHIFT", action = wezterm.action.ActivatePaneDirection("Right") },
        { key = "UpArrow",    mods = "CTRL|SHIFT", action = wezterm.action.ActivatePaneDirection("Up")    },
        { key = "DownArrow",  mods = "CTRL|SHIFT", action = wezterm.action.ActivatePaneDirection("Down")  },

        -- Close pane
        { key = "W", mods = "CTRL|SHIFT", action = wezterm.action.CloseCurrentPane { confirm = false } },

        -- Tabs
        { key = "T", mods = "CTRL|SHIFT", action = wezterm.action.SpawnTab "CurrentPaneDomain" },
        { key = "Tab", mods = "CTRL",       action = wezterm.action.ActivateTabRelative(1)  },
        { key = "Tab", mods = "CTRL|SHIFT", action = wezterm.action.ActivateTabRelative(-1) },
      }

      return config
    '';
  };
}
