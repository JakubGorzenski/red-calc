function display(C, line_1, greyed_out, line_2)
    C.Display:clear()
    C.Display.add{type="label", caption=line_1, style="red-calc-display"}
    local l2_style = C.Display.add{type="label", caption=line_2, style="red-calc-display"}.style
    if greyed_out then
        l2_style.font_color = {1, 1, 1, 0.5}
    end
end

require "core"

function create_red_calc(player_index, scale)
    local C = storage[player_index]
    local p = game.players[player_index]
    local s = p.gui.screen
    local temp

    p.set_shortcut_toggled("red-calc-toggle", false)
    if s.red_calc then
        s.red_calc.destroy()
    end

    local rc = s.add{type="frame", name="red_calc", direction="vertical"}
        rc.visible = false
        --  top bar
        local tb = rc.add{type="flow", style="frame_header_flow"}
        tb.style.horizontal_spacing=8
        tb.drag_target=rc

            tb.add{type="label", caption="Red Calculator", style="frame_title", ignored_by_interaction=true}

            temp = tb.add{type="empty-widget", style="draggable_space_header", ignored_by_interaction=true}
            temp.style.height = 24
            temp.style.horizontally_stretchable = true
            temp.style.right_margin = 4

            tb.add{type="sprite-button", name="!close", sprite="utility.close", style="close_button"}

        temp = rc.add{type="frame", name="dp_frame", style="inside_shallow_frame_with_padding", direction="vertical"}
        temp.style.padding = {0, 5, 0, 5}

        -- display
        C.Display = temp.add{type="flow", name="display", direction="vertical"}
            C.Display.style.vertical_align = "center"
            C.Display.style.minimal_height = 45

        -- switch bar
        local sb = rc.add{type="flow"}
        sb.style.horizontal_spacing = 16
        
            sb.add{type="switch", name="!prec", allow_none_state=true, tooltip={"red-calc.tt_precision"}, left_label_caption="2", right_label_caption="8"}
            sb.add{type="switch", name="!frac", tooltip={"red-calc.tt_fraction"}, left_label_caption="1/2", right_label_caption="3/2"}
            --sb.add{type="switch", name="!keyboard", allow_none_state=true, tooltip={"red-calc.tt_keyboard"}, left_label_caption="M", right_label_caption="K"}

        --  button space
        local bs = rc.add{type="table", column_count=6}
            bs.style.horizontal_spacing = 0
            bs.style.vertical_spacing = 0
            local button_captions = {
                "Sel", "7" , "8" , "9" ,"DEL","CLR",
                 "C" , "4" , "5" , "6" , "×" , "÷" ,
                 "B" , "1" , "2" , "3" , "+" , "−" ,
                "Ans", "/" , "0" , "." , "(" , "=" ,
            }
            local button_colors = {
                "b", "d","d","d", "r","R",
                "b", "d","d","d", "g","g",
                "b", "d","d","d", "g","g",
                "b", "d","d","d", "g","g",
            }
            for i,v in ipairs(button_captions) do
                temp = bs.add{type="button", name="!"..v}
                if v == "Sel" then
                    temp.tooltip = {"red-calc.tt_Sel"}
                end
                temp.caption = v

                local col = button_colors[i]

                if     col == "d" then
                    temp.style = "red-calc_number_button"
                elseif col == "r" then
                    temp.style = "tool_button_red"
                elseif col == "R" then
                    temp.style = "red_button"
                elseif col == "g" then
                    temp.style = "red-calc_green_button"
                    temp.style.font = "red-calc-mono"
                elseif col == "b" then
                    temp.style = "red-calc_blue_button"
                end

                temp.style.margin = 1
                temp.style.padding = 0
                temp.style.width = 40 * scale
                temp.style.height = 30 * scale
                --temp.style.font = "default-bold"
            end
end

function toggle_red_calc(player_index)
    local p = game.players[player_index]
    local s = p.gui.screen
    local C = storage[player_index]

    local state = not p.is_shortcut_toggled("red-calc-toggle")
    p.set_shortcut_toggled("red-calc-toggle", state)

    C.Display:clear()
    C.Full_clear_on_button_press = true

    s.red_calc.visible = state
end

function gui_handler(event)
    local button = event.element

    if button.get_mod() ~= "red-calc" or button.name:sub(1,1) ~= "!" then
        return
    end

    if button.name == "!close" then
        toggle_red_calc(event.player_index)
        return
    elseif button.name == "!Sel" and settings.global["red-calc-debug"] then
        game.reload_mods()
        create_red_calc(event.player_index, 1.1)
        toggle_red_calc(event.player_index)
        return
    end

    local C = storage[event.player_index]

    if button.name == "!prec" then
        switch_precision(C, button.switch_state)
    elseif button.name == "!frac" then
        switch_fraction(C, button.switch_state)
    elseif button.name == "!keyboard" then
        -- nothing
    else
        handle_button_press(C, button.name:sub(2))
    end
end


script.on_event(defines.events.on_player_created, function(event)
    storage[event.player_index] = Context()
    create_red_calc(event.player_index, 1.1)
end)
script.on_configuration_changed(function(_)
    for p_id, _ in pairs(game.players) do
        create_red_calc(p_id, 1.1)
    end
end)

script.on_event(defines.events.on_lua_shortcut, function(event)
    if event.prototype_name == "red-calc-toggle" then
        toggle_red_calc(event.player_index)
    end
end)
script.on_event("red-calc-toggle", function(event)
    toggle_red_calc(event.player_index)
end)

script.on_event(defines.events.on_gui_click, gui_handler)
script.on_event(defines.events.on_gui_switch_state_changed, gui_handler)