--  contains functions for displaying numbers


local op_t = {
    ["*"] = "×", ["^"] = "^",
    ["/"] = "÷", [","] = ",",
    ["+"] = "+", ["A"] = "A",
    ["~"] = "−", ["S"] = "S",
}
function op_format(prefix, op)
    return op == "" and "" or prefix..op:gsub("[*/+~,^AS]", op_t)
end


function display(player_index, input)
    local dp = access_player_display(player_index)

    dp:clear()

    dp.add{type="label", caption=input.."<"..(state)..">", style="red-calc-display"}

    local op1,                      op2,          num,          op3 = input:match(
        "([*/+~,^AS(]*)[-%d.fsabc]-([*/+~,^AS(]*)([-%d.fsabc]*)([*/+~,^AS(]*)$")

    op1 = op_format(":", op1)
    op2 = op_format(":", op2)
    op3 = op_format("",  op3)
    --  using : as … bc sub(-4) interprets wchars as chars
    local op_pre = ("    " .. op1 .. op2):sub(-4):gsub(":", "…")

    dp.add{type="label", caption=op_pre..num..op3, style="red-calc-display"}
end

function display_old(dp, mp_num)
    local temp
    dp:clear()

    dp.add{type="label", caption=input.."<"..(state)..">", style="red-calc-display"}
    --dp.add{type="label", caption="…+(", style="red-calc-display"}

    mp_num = {}

    dp.add{type="label", caption=mp_num.whole, style="red-calc-display"}
    
    local numer = mp_num.numer or ""
    local denom = mp_num.denom or ""
    local line_len = math.max(numer:len(), denom:len()) or 0

    if line_len > 0 then
        temp = dp.add{type="flow", style="red-calc_packed_flow", direction="vertical"}
        temp.style.padding = 0
        temp.style.margin = 0

        temp.add{type="label", caption=numer, style="red-calc-display"}

        temp.add{type="label", caption=string.rep("_", line_len), style="red-calc-display"}
            .style.margin = {-20, 0, -6, 0}

        temp.add{type="label", caption=denom, style="red-calc-display"}
    end

    local prefix = mp_num.prefix or 0
    if prefix > 0 then
        prefix = string.sub("kMGTPEZYR", prefix % 10, prefix % 10)
                    .. string.rep("Q", math.floor(prefix / 10))
    else
        prefix = string.sub("ryzafpnum", prefix % 10, prefix % 10)
                    .. string.rep("q", math.floor(prefix / -10))
    end
    dp.add{type="label", caption=prefix, style="red-calc-display"}

    local t = { ["*"] = "×", ["^"] = "^",
                ["/"] = "÷", [","] = ",",
                ["+"] = "+", ["A"] = "+",
                ["-"] = "−", ["S"] = "−"}
    dp.add{type="label", caption=t[mp_num.op_sel], style="red-calc-display"}

    dp.add{type="empty-widget"}.style.horizontally_stretchable = true

    dp.add{type="label", caption=mp_num.q_mark, style="red-calc-display"}
end

--[[  … - ...

         5*
    …* 10
    …*(10^
    (…^3
    …*(1000+
    (…+22
    …* 1022
         5110

    if(mp_num.is_decimal) then
        dp.add{type="label", caption=string.format(prec, mp_num.numer / mp_num.denom)}
    else
        if mp_num.is_proper then
            local whole = math.floor(mp_num.numer / mp_num.denom)
            mp_num.numer = mp_num.numer - whole * mp_num.denom
            dp.add{type="label", caption=string.format("-(...+%d", whole)}
        end

        local numer = string.format("%d", mp_num.numer)
        if numer == "0" then goto end_number_draw end

        local denom = string.format("%d", mp_num.denom)
        local line_len = math.floor(math.max(numer:len(), denom:len()) / 2 + .5)

        temp = dp.add{type="flow", style="red-calc_packed_flow", direction="vertical"}
        temp.style.padding = 0
        temp.add{type="label", caption=string.format("%d", numer)}
        temp.add{type="label", caption=string.rep("─", line_len)}.style.margin = {-12, 0, -12, 0}
        temp.add{type="label", caption=string.format("%d", denom)}
    end
::end_number_draw::
    dp.add{type="label", caption=mp_num.letter}
]]

--[[
    dp.add{type="label", caption="1"}
    temp = dp.add{type="flow", style="red-calc_packed_flow", direction="vertical"}
    temp.style.padding = 0
    temp.add{type="label", caption="4"}
    temp.add{type="label", caption="─────"}.style.margin = -12
    temp.add{type="label", caption="123456789"}

    temp = dp.add{type="label", caption="×−+÷"}
    temp.style.font="red-calc-mono"
]]--