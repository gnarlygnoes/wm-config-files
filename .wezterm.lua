local wezterm = require("wezterm")
local mykeys = {
        { key = "p",         mods = "CTRL|SHIFT", action = wezterm.action.ShowLauncher },
        { key = "UpArrow",   mods = "CTRL",       action = wezterm.action.PaneSelect },
        { key = "DownArrow", mods = "CTRL",       action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }) },
        {
                key = "RightArrow",
                mods = "CTRL",
                action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
        },
        { key = "w", mods = "CTRL", action = wezterm.action.CloseCurrentPane({ confirm = true }) },
}

for i = 1, 8 do
        -- ALT + number to move to that position
        table.insert(mykeys, {
                key = tostring(i),
                mods = "ALT",
                action = wezterm.action.ActivateTab(i - 1),
        })
end

return {
        window_background_opacity = 0.9,
        -- window_background_image = '/home/ystyle/Pictures/壁纸/wallhaven-gp2q77.jpg',
        window_background_image_hsb = {
                brightness = 0.07,
        },
        initial_cols = 120,
        initial_rows = 30,
        hide_tab_bar_if_only_one_tab = true,
        tab_max_width = 40,
        font = wezterm.font_with_fallback({
                -- /usr/share/fonts/TTF/JetBrainsMono-Regular.ttf, FontConfig
                { family = "JetBrains Mono" },
                -- "Source Han Serif CN",
                { family = "Source Han Serif CN", weight = "Light" },
                -- { family = "Source Han Sans CN", weight = "Light" },
                -- /usr/share/fonts/noto/NotoColorEmoji.ttf, FontConfig
                -- Assumed to have Emoji Presentation
                -- Pixel sizes: [128]
                "Noto Color Emoji",

                -- /usr/share/fonts/TTF/SymbolsNerdFontMono-Regular.ttf, FontConfig
                "Symbols Nerd Font Mono",
        }),
        -- color_scheme = "AdventureTime",
        -- color_scheme = "AlienBlood",
				color_scheme = "rose-pine",
        default_cursor_style = "SteadyBar",
        -- window_decorations = "NONE",
        warn_about_missing_glyphs = false,
        alternate_buffer_wheel_scroll_speed = 1,
        enable_wayland = false,
				-- front_end = "WebGpu",
				max_fps = 180,
        keys = mykeys,
}
