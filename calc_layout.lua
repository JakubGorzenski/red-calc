--  contains calculator layout, and layout accessors

function access_player_display(player_index)
    return game.players[player_index].gui.screen.red_calc.dp_frame.display
end


function create_red_calc(screen, scale)
    local s = screen
    local temp

    local rc = s.add{type="frame", name="red_calc", direction="vertical"}
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

        local dp = temp.add{type="flow", name="display", style="packed_horizontal_flow"}
        dp.style.vertical_align = "center"
        dp.style.minimal_height = 45
--    dp.style.padding = 0
--    dp.style.horizontal_spacing = 0

--    temp.style.font="red-calc-big"

        local sb = rc.add{type="table", style="red-calc_settings_table", column_count=2}
        
            sb.add{type="switch", name="!prec", allow_none_state=true, tooltip="Set rounding precision. (2/4/8)", left_label_caption="2", right_label_caption="8"}
--      sb.add{type="checkbox", name="!help", tooltip="Change button captions to reflect what they will do.", state=false, caption="Help"}

        local bs = rc.add{type="table", column_count=6}
        bs.style.horizontal_spacing = 0
        bs.style.vertical_spacing = 0
            local button_captions = {
                "Sel", "7" , "8" , "9" ,"DEL","CLR",
                 "C" , "4" , "5" , "6" , "×" , "÷" ,
                 "B" , "1" , "2" , "3" , "+" , "−" ,
                "Ans","frc", "0" , "." , "(" , "=" ,
            }
            local buttons = {
                "sb", "7d","8d","9d", "DR","Cr",
                "cb", "4d","5d","6d", "*g","/g",
                "bb", "1d","2d","3d", "+g","~g",
                "ab", "fd","0d",".d", "(g","=g",
            }
            for i,v in ipairs(buttons) do
                temp = bs.add{type="button", name="!"..v:sub(1,1)}
                temp.caption = button_captions[i]

                local col = v:sub(2,2)

                if(col == "d") then
                    temp.style = "red-calc_number_button"
                elseif(col == "r") then
                    temp.style = "tool_button_red"
                elseif(col == "R") then
                    temp.style = "red_button"
                elseif(col == "g") then
                    temp.style = "red-calc_green_button"
                elseif(col == "G") then
                    temp.style = "red-calc_green_button"
                elseif(col == "b") then
                    temp.style = "red-calc_blue_button"
                elseif(col == "B") then
                    temp.style = "red-calc_blue_button"
                elseif(col == "S") then
                    temp.style = "red-calc_blue_button-2"
                end

                temp.style.margin = 1
                temp.style.padding = 0
                temp.style.width = 40 * scale
                temp.style.height = 30 * scale
                --temp.style.font = "default-bold"

                if(col == "S" or col == "B") then
                    temp.style.width = 80
                elseif(col == "G" or col == "g") then
                    temp.style.font = "red-calc-mono"
                end
            end
end