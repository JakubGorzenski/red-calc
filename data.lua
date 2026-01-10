
data:extend{{
    type = "shortcut",
    name = "red-calc",
    order = "zzz",
--  localised_description = "advanced-calculator.shortcut-description",

    action = "lua",
    icon = "__core__/graphics/icons/mip/editor-tick-sixty-icon.png",
    icon_size = 32,
    small_icon = "__core__/graphics/icons/mip/editor-tick-sixty-icon.png",
    small_icon_size=32,
    toggleable = true,
--  associated_control_input = "",
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