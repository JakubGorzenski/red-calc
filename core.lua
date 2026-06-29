function OperationEntry(arg)
    arg.number     = arg.number     or ""
    arg.rq_op      = arg.rq_op      or " "
    arg.bracket    = arg.bracket    or " "
    arg.calculated = arg.calculated or false
    arg.stub       = arg.stub       or false
    return arg
end
function Context()
    local C = {}
    C.operation_stack = {}
    C.number_memory   = { A = {"0.00000000"}, B = {"0.00000000"}, C = {"0.00000000"} }
    C.greyed_out      = false
    C.precision       = 2
    C.fraction_style  = 1
    C.question_mark   = " "
    return C
end

function sign(x)
    return (x > 0 and 1) or (x < 0 and -1) or 0
end
function at(array, index, default)
    if index < 0 then
        index = #array + index + 1
    end
    if type(array) == "table" then
        return array[index] or default
    elseif index <= #array then
        return array:sub(index, index)
    end
    return default
end
function current_operation(C)
    if C.operation_stack[1] == nil then
        C.operation_stack[1] = OperationEntry{}
    end
    return at(C.operation_stack, -1)
end
function previous_operation(C, go_further_back_by)
    return at(C.operation_stack, -2 - (go_further_back_by or 0), OperationEntry{stub = true})
end
function is_current_valid(C)
    local number = current_operation(C).number
    local p_char = at(number, -1)

    if     number:find("^[ABC]") then
        return true
    elseif p_char == "." or number:find("^-?$") then
        return false
    elseif p_char == "/" and not number:find("[.]") then
        return false
    end
    return true
end

function to_fraction(decimal_part)
    function frc(f, i)
        if i == 0 then
            return 1, math.floor(1/f)
        end

        local n, d = frc(1 / f % 1, i - 1)
        n = n + math.floor(1 / f) * d
        return d, n
    end

    local f = tonumber("0." .. decimal_part)
    local p = #decimal_part + 2
    local i = 0

    if f == 0.0 then
        return 0, 1
    end

    repeat
        local n, d = frc(f, i)
        i = i + 1
        if ("%.9f"):format(n/d):sub(3, p) == decimal_part then
            return n, d
        end
    until(i > 15)
    return 0, 840
end
function string_round(arg)
    local C          = arg[1]
    local string     = arg[2].number
    local calculated = arg[2].calculated
    local _, _, ABC, idx, append = string:find("([ABC])(%d?)(/?)")

    if ABC then
        calculated = true
        if idx and idx ~= "" then
            idx = idx + 2
        else
            idx = 1
        end
        string = (C.number_memory[ABC][idx] .. append):gsub("//$", "")
    end

    local separator = "/"
    local ch_sign = ""
    if arg.visual then
        separator = " "
        ch_sign = " "
    end

    local sign = 1
    if string:find("-") then
        string = string:sub(2)
        ch_sign = "-"
        sign = -1
    end

    local fraction = table.pack(select(3, string:find("^([^/]*)/?([^/]*)/?([^/]*)")))
    local _, _, whole, decimal_part = fraction[1]:find("^([^.]*)[.]([^.]*)")
    for i = 1, 3 do
        fraction[i] = fraction[i] ~= "" and fraction[i] or nil
    end
    fraction.n = select(2, string:gsub("/", "")) + 1

    local ret_string
    local ret_float

    if decimal_part then
        whole = tonumber(whole)

        if calculated then
            decimal_part = decimal_part:sub(1, C.precision)
        end
        if     fraction.n == 1 then
            ret_string = ("%s.%s"):format(whole or "", decimal_part)
            ret_float = tonumber(ret_string)
        elseif fraction.n == 2 then
            if whole == 0 then
                whole = nil
            end
            local n, d
            if fraction[2] then
                n = math.ceil(fraction[2] * ("0."..decimal_part))
                d = fraction[2]
            else
                n, d = to_fraction(decimal_part)
            end
            if C.fraction_style == 2 then
                n = n + (whole or 0) * d
                whole = nil
            end
            if n == 0 then
                ret_string = tostring(whole or "0")
            else
                ret_string = ("%s%s/%s"):format(whole and whole .. separator or "", n, d)
            end
            ret_float = (whole or 0) + n / d
        end

    elseif fraction.n == 1 then
        ret_string = string
        ret_float  = fraction[1] or 0
    elseif fraction.n == 2 then
        ret_string = ("%s/%s"):format(fraction[1] and fraction[1] or "1", fraction[2] or "")
        ret_float  = (fraction[1] or 1) / (fraction[2] or 1)
    elseif fraction.n == 3 then
        ret_string = ("%s%s%s/%s"):format(fraction[1] or "1", separator, fraction[2] or "1", fraction[3] or "")
        ret_float  = (fraction[1] or 1) + (fraction[2] or 1) / (fraction[3] or 1)
    end

    if arg.to_float then
        if arg.check_if_fraction then
            return ret_float * sign, fraction.n > 1 and 2 or ret_float % 1 == 0 and 1 or 0
        else
            return ret_float * sign
        end
    else
        return ch_sign .. ret_string
    end
end
function insert_number_memory(C, equals, bracket, number)
    local selected_array = (not equals and "C") or (bracket == "(" and "B") or "A"

    if C.number_memory[selected_array][0] ~= number then
        table.insert(C.number_memory[selected_array], 1, number)
        C.number_memory[selected_array][12] = nil
    end
end

function calculate(arg)
    local C = arg[1]
    local curr = current_operation(C)
    local prev = previous_operation(C)

    if prev.stub or prev.bracket == "(" then
        if arg.equals then
            if curr.rq_op ~= " " then
                C.question_mark = "?"
                return nil
            end
            curr.number, cn_frc = string_round{C, curr, to_float=true, check_if_fraction=true}
            curr.number = ("%.9f"):format(curr.number)
            curr.calculated = true
            insert_number_memory(C, arg.equals, prev.bracket, curr.number .. (cn_frc >= 2 and "/" or ""))
            return curr
        end
        return nil
    end

    local a, a_frc = string_round{C, prev, to_float=true, check_if_fraction=true}
    local op = prev.rq_op
    local b, b_frc = string_round{C, curr, to_float=true, check_if_fraction=true}

    local frc = a_frc + b_frc > 2 and "/" or ""
    local result = nil

    if     op == "+" then
        result = a + b
    elseif op == "−" then
        result = a - b
    elseif op == "×" then
        result = a * b
    elseif op == "^" then
        result = a ^ b
    elseif op == "÷" or op == "\\" then
        if op == "\\" then
            a, b = b, a
        end

        if b ~= 0.0 then
            result = a / b
        else
            result = sign(a)
        end
    end

    if arg.return_result then
        prev = OperationEntry{}
    end
    prev.number = ("%.9f%s"):format(result, frc)
    prev.calculated = true

    if not arg.return_result then
        insert_number_memory(C, arg.equals, previous_operation(C, 1).bracket, prev.number)
    end

    if not C.greyed_out then
        prev.rq_op   = curr.rq_op
        prev.bracket = curr.bracket
        if not arg.return_result then
            C.operation_stack[#C.operation_stack] = nil
        end
    end

    return prev
end
function update_display(C, is_test)
    if C.Full_clear_on_button_press then
        return
    end

    local prev2 = previous_operation(C, 1)
    local prev  = previous_operation(C)
    local curr  = current_operation(C)

    local line_3 = curr.rq_op .. curr.bracket .. "                           " -- space for alignment
    local line_2 = "NOT ASSIGNED!"
    local line_1 = "NOT ASSIGNED!"

    if line_3 ~= "                             " then
        local calc = calculate{C, return_result=true}
        if calc then
            line_1 = ("%s%s%-25s%s"):format(prev2.rq_op, prev2.bracket, string_round{C, calc, visual=true}, C.question_mark)
        else
            line_1 = ("%s%s%-25s%s"):format(prev.rq_op, prev.bracket, string_round{C, curr, visual=true}, C.question_mark)
        end
        line_2 = line_3
    else
        local memory_location = "    "
        if at(curr.number, 1, ""):find("^[ABC]") then
            memory_location = ("[%-2s]"):format(curr.number:gsub("/", ""))
        end
        line_1 = ("%s%s%-25s%s"):format(prev2.rq_op, prev2.bracket, string_round{C, prev, visual=true}, C.question_mark)
        line_2 = ("%s%s%-23s%s") :format(prev.rq_op,  prev.bracket,  string_round{C, curr, visual=true}, memory_location)
    end
    
    if is_test then
        return line_1 .. " \n" .. line_2
    end

    --testing externally requires disabling
    display(C, line_1, C.greyed_out, line_2)
end


function handle_equals_button(C)
    local prev = previous_operation(C)

    if not is_current_valid(C) then
        C.question_mark = "?"
        return
    end

    if #C.operation_stack == 2 and prev.bracket == " " then
        C.greyed_out = true
    end

    if calculate{C, equals=true} then
        previous_operation(C).bracket = " "
    end
end
function handle_del_button(C)
    if C.greyed_out then
        C.greyed_out = false
        return
    end

    local curr = current_operation(C)

    if     curr.bracket ~= " " then
        curr.bracket = " "
    elseif curr.rq_op ~= " " then
        curr.rq_op = " "
    else
        if curr.calculated then
            curr.number = string_round{C, curr}
            curr.calculated = false
        end
        curr.number = curr.number:sub(1, -2)

        if curr.number == "" then
            C.operation_stack[#C.operation_stack] = nil
        end
    end
end
function handle_clr_button(C)
    C.operation_stack[#C.operation_stack] = nil
end
function handle_number_button(C, append)
    local curr = current_operation(C)
    append = append:sub(1, 1)

    if     C.greyed_out and append == "/" then
        curr.rq_op = " "
    elseif curr.rq_op ~= " " then
        calculate{C}
        C.operation_stack[#C.operation_stack + 1] = OperationEntry{}
        curr = current_operation(C)
    end

    if curr.calculated and append ~= "/" then
        curr.number = string_round{C, curr}
        curr.calculated = false
    end

    local f_char = at(curr.number, 1)
    local p_char = at(curr.number, -1)

    if     append == "/" and p_char == "/" and (f_char:find("[ABC]") or curr.number:find("[.]"))then
        curr.number = curr.number:sub(1, -2)
    elseif curr.number:find("^[ABC]") then
        local last_num_mem = #C.number_memory[f_char] - 1

        if     f_char == append then
            local next_id = at(curr.number, 2)
            next_id = (tonumber(next_id) or -1) + 1
            if next_id >= last_num_mem then
                C.question_mark = "?"
                return
            end
            curr.number = f_char .. next_id
        elseif append:find("[ABC]") then
            curr.number = append
        elseif append:find("%d") then
            if tonumber(append) >= last_num_mem then
                C.question_mark = "?"
                return
            end
            curr.number = f_char .. append
        elseif append == "/" then
            curr.number = curr.number .. "/"
        else
            C.question_mark = "?"
        end

    elseif append:find("[./]") then
        local count = select(2, curr.number:gsub("[./]", ""))

        if     append == "." and count < 1 then
            curr.number = curr.number .. "."
        elseif append == "/" and count < 2 then
            curr.number = curr.number .. "/"
        else
            C.question_mark = "?"
        end
    elseif p_char == "/" and append == "0" then
        C.question_mark = "?"
    elseif curr.number == "" or append:find("%d") then
        curr.number = curr.number .. append
    else
        C.question_mark = "?"
    end
end
function handle_operation_button(C, op)
    local curr = current_operation(C)

    if     (curr.rq_op == " " and is_current_valid(C)) or C.greyed_out then
        curr.rq_op = op
    elseif op == "−" then
        handle_number_button(C, "-")
    elseif curr.rq_op == op then
        if     op == "×" then
            curr.rq_op = "^"
        elseif op == "÷" then
            curr.rq_op = "\\"
        else
            C.question_mark = "?"
        end
    else
        C.question_mark = "?"
    end
end
function handle_bracket_button(C)
    local curr = current_operation(C)
    local prev = previous_operation(C)

    if curr.rq_op ~= " " then
        curr.bracket = curr.bracket == " " and "(" or " "
    else
        if prev.stub then
            C.question_mark = "?"
        else
            prev.bracket = prev.bracket == " " and "(" or " "
        end
    end
end


function handle_button_press(C, text)
    C.question_mark = " "

    if C.Full_clear_on_button_press then
        C.Full_clear_on_button_press = false
        if text == "CLR" then
            update_display(C)
            return
        else
            C.operation_stack = {}
            C.greyed_out      = false
        end
    end

    if     text == "="   then
        handle_equals_button(C)
    elseif text == "DEL" then
        handle_del_button(C)
    else
        local handle_button_fn = ({
            ["CLR"] = handle_clr_button,
            ["0"]   = handle_number_button,
            ["1"]   = handle_number_button,
            ["2"]   = handle_number_button,
            ["3"]   = handle_number_button,
            ["4"]   = handle_number_button,
            ["5"]   = handle_number_button,
            ["6"]   = handle_number_button,
            ["7"]   = handle_number_button,
            ["8"]   = handle_number_button,
            ["9"]   = handle_number_button,
            ["/"]   = handle_number_button,
            ["."]   = handle_number_button,
            ["Ans"] = handle_number_button,
            ["B"]   = handle_number_button,
            ["C"]   = handle_number_button,
            ["+"]   = handle_operation_button,
            ["−"]   = handle_operation_button,
            ["×"]   = handle_operation_button,
            ["÷"]   = handle_operation_button,
            ["("]   = handle_bracket_button,
        })[text]
        
        if handle_button_fn then
            if C.greyed_out then
                handle_clr_button(C)
            end
            handle_button_fn(C, text)
            C.greyed_out = false
        else
            C.question_mark = "?"
        end
    end

    update_display(C)
end
function switch_precision(C, switch)
    C.precision = ({left=2, none=4, right=8})[switch]
    update_display(C)
end
function switch_fraction(C, switch)
    C.fraction_style = ({left=1, right=2})[switch]
    update_display(C)
end

function run_tests()
    local test_result = "["
    function test(in_sequence, output)
        local TC = Context()

        if pcall(function()
            for i = 1, #in_sequence do
                local key = in_sequence:sub(i, i)
                if     key:find("[!@#$]") then
                    switch_precision(TC, ({["!"]="left", ["@"]="none", ["#"]="right", ["$"]="right"})[key])
                elseif key:find("[%%^]") then
                    switch_fraction(TC, ({["%"]="left", ["^"]="right"})[key])
                elseif key:find("[-Sdc*:A]") then
                    key = ({["-"]="−", ["S"]="Sel", ["d"]="DEL", ["c"]="CLR", ["*"]="×", [":"]="÷", ["A"]="Ans"})[key]
                    handle_button_press(TC, key)
                else
                    handle_button_press(TC, key)
                end
            end
            result = update_display(TC, true)
            if result == output then
                test_result = test_result .. "-"
            else
                test_result = test_result .. "/"
                print("Fail \""..in_sequence.."\":")
                print(result:gsub(" ", "`"))
                print("Expected:")
                print(output:gsub(" ", "`"))
                print("")
            end
        end) then
        else
            test_result = test_result .. "!"
            print("Fail \""..in_sequence.."\":")
            print("Expected:")
            print(output:gsub(" ", "`"))
            print("")
        end
    end
--  change \\ to sth else ?
    test("",                "                             \n                             ")
    test("1+23dddd",        "                             \n                             ")
    test("$/6=",            "                             \n   0.16666666                ")
    test("$/6=/",           "                             \n   1/6                       ")
    test("$1:6=/",          "                             \n   1/6                       ")
    test("%/3=/",           "                             \n   1/3                       ")
    test("/2+0=",           "   1/2                       \n+  0                         ")
    test("/2+0=cA/",        "                             \n   0.50                  [A ]")
    test("A5",              "                           ? \n   0.00                  [A ]")
    test("/2=cA",           "                             \n   1/2                   [A ]")
    test(".6900/",          "                             \n   69/100                    ")
    test("$.00000001/=",    "                             \n   0.00000001                ")
    test("1+(2*",           "+( 2                         \n×                            ")
    test("1:0+",            "   1.00                      \n+                            ")
    test("%2=/",            "                             \n   2                         ")
    test("@1.33//",         "                             \n   1.33                      ")
    test("@1/3=//",         "                             \n   0.3333                    ")
    test("0=/",             "                             \n   0                         ")
    test("A+",              "   0.00                      \n+                            ")
    test("@1:(0.0001=+!",   "   1.00                      \n+                            ")
    test("A.",              "                           ? \n   0.00                  [A ]")
    test(".01/101",         "                             \n   2/101                     ")
    test("00.1/",           "                             \n   1/10                      ")
    test("1+(2*3+B",        "+( 6.00                      \n+  0.00                  [B ]")
    test("2+2=S",           "   4.00                    ? \n+  2                         ")
    test("^1.2/3",          "                             \n   4/3                       ")
    test("//2",             "                             \n   1 1/2                     ")
    test("///",             "                           ? \n   1 1/                      ")
    test("1+2-3",           "   3.00                      \n−  3                         ")
    test("12*//2",          "   18                        \n+  1 1/2                     ")

    print(test_result .. "]")
end

run_tests()