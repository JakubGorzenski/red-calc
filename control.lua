--  any gui whose name start with '!', and belongs to "red-calc" will be treated as interactible

require "calc_layout"
require "calc_operation"
require "calc_display"

function toggle_red_calc(player)
    local p = player
    local s = p.gui.screen

    -- make button toggleable
    local state = not p.is_shortcut_toggled("red-calc")
    p.set_shortcut_toggled("red-calc", state)

    
    if(s.red_calc ~= nil) then
        s.red_calc.destroy()
    end

    create_red_calc(s, p.mod_settings["red-calc-gui-scale"].value)

    s.red_calc.visible = state

    if(state == false) then
        game.reload_mods()
    end
end



function shortcut_handler(event)
    -- is this my event
    if(event.prototype_name ~= "red-calc") then
        return
    end

    toggle_red_calc(game.players[event.player_index])
end

script.on_event(defines.events.on_lua_shortcut, shortcut_handler)


prec = "%.2f"
function button_handler(event)
    local button = event.element

    if(button.get_mod() ~= "red-calc" or button.name:sub(1,1) ~= "!") then
        return
    end

    if(button.name == "!close") then
        toggle_red_calc(game.players[event.player_index])
        return
    end

    local p = game.players[event.player_index]
    if button.type == "switch" then
        prec = ({left="%.2f", none="%.4f", right="%.8f"})[button.switch_state]
    end
    on_key_press(button.name:sub(2, 3))

    display(access_player_display(p), mp_num)
end

script.on_event(defines.events.on_gui_click, button_handler)