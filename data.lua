
data:extend{{
    type = "custom-input",
    name = "red-calc-toggle",
    key_sequence = "CONTROL + SHIFT + C",
    action = "lua",
},
{
    type = "shortcut",
    name = "red-calc-toggle",
    order = "zzz",
    action = "lua",
    localised_name = {"red-calc.shortcut-name"},
    associated_control_input = "red-calc-toggle",
    icon = "__red-calc__/toggle-red-calc-x56.png",
    icon_size = 56,
    small_icon = "__red-calc__/toggle-red-calc-x24.png",
    small_icon_size = 24,
    toggleable = true,
},
{
    type = "font",
    name = "red-calc-big",
    from = "default",
    size = 18,
},
{
    type = "font",
    name = "red-calc-mono",
    from = "default-mono",
    size = 16,
},
{
    type = "font",
    name = "red-calc-display",
    from = "default-mono",
    size = 14,
}}



data.raw["gui-style"]["default"]["red-calc-display"] = {
    type = "label_style",
    parent = "label",
    font = "red-calc-display",
}

data.raw["gui-style"]["default"]["red-calc_green_button"] = {
    type = "button_style",
    parent = "green_button",
    left_click_sound = "__core__/sound/gui-click.ogg",
    tooltip = "",
}

data.raw["gui-style"]["default"]["red-calc_number_button"] = {
    type = "button_style",
    parent = "button",
    left_click_sound = "__core__/sound/gui-square-button.ogg",
}

data.raw["gui-style"]["default"]["red-calc_blue_button"] = {
    type = "button_style",
    parent = "tool_button_blue",
    left_click_sound = "__core__/sound/gui-click.ogg",
}

data.raw["gui-style"]["default"]["red-calc_blue_button_2"] = {
    type = "button_style",
    parent = "tool_button_blue",
    left_click_sound = "__core__/sound/gui-tool-button.ogg",
}

data.raw["gui-style"]["default"]["red-calc_settings_table"] = {
    type = "table_style",
    parent = "table",
    column_widths = {width=80},
    --column_alignments = {{column=1, alignment="center"}},
}

data.raw["gui-style"]["default"]["red-calc_packed_flow"] = {
    type = "vertical_flow_style",
    parent = "vertical_flow",
    vertical_spacing = 0,
    horizontal_align = "center",
}