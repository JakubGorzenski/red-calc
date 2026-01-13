--  calculator code


local state_t



function on_key_press(player_index, key)
    --  global varibles created here!
    input = storage[player_index].input or ""
    state = storage[player_index].state or "first"

    local func = next_state(key)
    if func then
        input = input .. key
        func()
        
        storage[player_index].input = input
        storage[player_index].state = state

        display(player_index, input)
    end
end


function delete()
    input = input:gsub(".?_?.$", "")

    for i in input:gmatch(".") do
        next_state(i)
    end
end

function clear()
    input = input:gsub("%(?[-%d.fsabc]*[*/+~,^AS]?C$", "")

    for i in input:gmatch(".") do
        next_state(i)
    end
end

function varible_select()
    input = input:gsub("([sabcAS])[%d.abc]-f?([%d.abc]?)(s?)$", "%1%3%2")
end

function varible_increment()
    input = input:gsub("(%d?)[abc+~]$",
        function(a) return a == "9" and "" or (a == "" and -1 or a) + 1 end)
end

function remove_select()
    input = input:gsub("ss([%d.abc]?)s$", "s%1")
end

function append_number()
    input = input:gsub("([sabc]?)([sabc])([%d.f]?)$",
        function(a, b, c) return c .. (a ~= b and b or "") end)
end

function append_bracket()
    input = input:gsub("([*/+~,^AS]?)(%(?)([%d.f]*)%($",
        function(a, b, c) return a .. ((b == "(" or a == "") and "" or "(") .. c end)
end

function change_operation()
    input = input:gsub("[*/+~]([*/+~])$",
        {["*"] = "^", ["/"] = ",", ["+"] = "A", ["~"] = "S"})
end

function next_state(key)
    for i = 1, #state_t[state], 1 do
        local st = state_t[state][i]
        if key:find(st[1]) then
            state = st[2]
            if state_t[state].recursive then
                return next_state(key)
            end
            return st[3] or function() end
        end
    end
    return nil
end

state_t = {
    first = {
        {"%(",          "first",    delete},
        {"[-~%d.sabc]", "value"}},
    value = { recursive = true,
        {"[-~]",        "negative", function() input = input:gsub("~$", "-") end},
        {"%d",          "number"},
        {"%.",          "number_1"},
        {"[sabc]",      "memory"}},
--  all number states
    negative = {
        {"%(",          "negative", append_bracket},
        {"[sabc]",      "negative", append_number},
        {"%d",          "number",   append_number},
        {"%.",          "number_1", append_number}},
    number = {
        {"%(",          "number",   append_bracket},
        {"[%dsabc]",    "number",   append_number},
        {"[.f]",        "number_1", append_number},
        {"[*/+~^,AS=]", "operation"}},
    number_1 = {
        {"%(",          "number_1", append_bracket},
        {"[%dsabc]",    "number_2", append_number}},
    number_2 = {
        {"%(",          "number_2", append_bracket},
        {"[%dsabc]",    "number_2", append_number},
        {"f",           "number_3", append_number},
        {"[*/+~^,AS=]", "operation"}},
    number_3 = {
        {"%(",          "number_3", append_bracket},
        {"[%dsabc]",    "number_4", append_number}},
    number_4 = {
        {"%(",          "number_4", append_bracket},
        {"[%dsabc]",    "number_4", append_number},
        {"[*/+~^,AS=]", "operation"}},
--  a, b and c memory reads
    memory = { recursive = true,
        {"s",           "select"},
        {"a",           "mem_a"},
        {"b",           "mem_b"},
        {"c",           "mem_c"}},
    mem_a = {
        {"[%d.f]",      "mem_a",    varible_select},
        {"a",           "mem_a",    varible_increment},
        {"%(",          "mem_a",    append_bracket},
        {"[*/+~^,AS=]", "operation"}},
    mem_b = {
        {"[%d.f]",      "mem_b",    varible_select},
        {"b",           "mem_b",    varible_increment},
        {"%(",          "mem_b",    append_bracket},
        {"[*/+~^,AS=]", "operation"}},
    mem_c = {
        {"[%d.f]",      "mem_c",    varible_select},
        {"c",           "mem_c",    varible_increment},
        {"%(",          "mem_c",    append_bracket},
        {"[*/+~^,AS=]", "operation"}},
--  all select operations
    select = {
        {"[%d.f]",      "select",   varible_select},
        {"s",           "set",      varible_select},
        {"[abc]",       "call",     varible_select},
        {"%(",          "select",   append_bracket},
        {"[*/+~^,AS=]", "operation"}},
    set = {
        {"[%d.f]",      "set",      varible_select},
        {"s",           "select",   remove_select},
        {"[abc]",       "record",   varible_select},
        {"=",           "first"}},
    call = {
        {"[%d.f]",      "select",   varible_select},
        {"s",           "record",   varible_select},
        {"[abc]",       "call",     varible_select}},
    record = {
        {"[%d.f]",      "set",      varible_select},
        {"s",           "call",     remove_select},
        {"[abc]",       "record",   varible_select}},
--  all operation states
    operation = { recursive = true,
        {"*",           "op_mul"},
        {"/",           "op_div"},
        {"+",           "op_add"},
        {"~",           "op_sub"},
        {"[%^,]",       "op_extra"},
        {"[AS]",        "op_mod_s"},
        {"=",           "result_d"}},
    op_mul = {
        {"*",           "op_extra", change_operation},
        {"%(",          "first"},
        {"[-~%d.sabc]", "value"}},
    op_div = {
        {"/",           "op_extra", change_operation},
        {"%(",          "first"},
        {"[-~%d.sabc]", "value"}},
    op_add = {
        {"+",           "op_mod_s", change_operation},
        {"%(",          "first"},
        {"[-~%d.sabc]", "value"}},
    op_sub = {
        {"~",           "op_mod_s", change_operation},
        {"%(",          "first"},
        {"[-~%d.sabc]", "value"}},
    op_extra = {
        {"%(",          "first"},
        {"[-~%d.sabc]", "value"}},
    op_mod_s = {
        {"[%d.f]",          "op_mod_s",     varible_select},
        {"[+~]",            "op_mod_s",     varible_increment},
        {"=",               "first"}},
--  all result states
    result_d = {
        {"[-%d.sabc]",  "value"},
        {"[*/+~^,AS=]", "operation"},
        {"f",           "result_f"}},
    result_f = {
        {"[-%d.sabc]",  "value"},
        {"[*/+~^,AS=]", "operation"},
        {"f",           "result_d"}},
}

for _, state in pairs(state_t) do
    table.insert(state, {"D", "first", delete})
    table.insert(state, {"C", "first", clear})
end
