--  any gui whose name start with '!', and belongs to "red-calc" will be treated as interactible



require "calc_layout"
require "calc_input"
require "calc_display"

function toggle_red_calc(event)
    local p = game.players[event.player_index]
    local s = p.gui.screen

    -- make button toggleable
    local state = not p.is_shortcut_toggled("red-calc-toggle")
    p.set_shortcut_toggled("red-calc-toggle", state)

    
    if(s.red_calc ~= nil) then
        s.red_calc.destroy()
    end

    create_red_calc(s, p.mod_settings["red-calc-gui-scale"].value)

    s.red_calc.visible = state

    if(state == false) then
        game.reload_mods()
    end
end

prec = "%.2f"
function button_handler(event)
    local button = event.element

    if(button.get_mod() ~= "red-calc" or button.name:sub(1,1) ~= "!") then
        return
    end

    if(button.name == "!close") then
        toggle_red_calc(event)
        return
    end

    if button.type == "switch" then
        prec = ({left="%.2f", none="%.4f", right="%.8f"})[button.switch_state]
    end

    on_key_press(event.player_index, button.name:sub(2, 3))
end


script.on_event(defines.events.on_player_created,
    function(event) storage[event.player_index] = {} end)

script.on_event(defines.events.on_lua_shortcut,
    function(event) if event.prototype_name == "red-calc-toggle" then toggle_red_calc(event) end end)

script.on_event("red-calc-toggle", toggle_red_calc)
script.on_event(defines.events.on_gui_click, button_handler)
