--  calculator code

input = ""

mp_num = {}
--  op_cur = ""
--  whole = "",
--  numer = "",
--  denom = "",
--  prefix = 0, --  qryzafpnum kMGTPEZYRQ
--  op_sel = "",--            ^ at 0
--  q_mark = "",

function del_from(from_char)
    input = string.gsub(input, "["..from_char.."].-$", "")
end

function mem_sel(key)
    input = input:gsub("([s]?)[%d.]-([scbaAS])[%d.f]-([%d.]?)$", "%1%2%3")
end

function append_bracket()
    input = input:gsub("(%(?)([%d.f]*)%(", function(a, b) return (a == "(" and "" or "(") .. b end)

end
function append_dot()
    mp_num.whole = mp_num.whole and mp_num.whole .. '.' or "0."
end
function append_whole(key)
    mp_num.whole = mp_num.whole or ""
    local prefix_rq = key:find("[scba]")
    if prefix_rq then 
        input = input:gsub("([scba])([%d%.f]*)([scba])$", function(a, b, c) return b .. (a ~= c and c or "") end)
        mp_num.prefix = prefix_rq
    elseif key:find("[-%d]") then
        mp_num.whole = mp_num.whole .. key
    end
end
function append_denom(key)
    mp_num.denom = mp_num.denom or ""
    local prefix_rq = ("scba"):find(key, 1, true)
    if prefix_rq then 
        input = input:gsub("([scba])([%d%.f]*)([scba])$", function(a, b, c) return b .. (a ~= c and c or "") end)
        mp_num.prefix = prefix_rq
    elseif key:find("%d") then
        mp_num.denom = mp_num.denom .. key
    end
end

local oper_t = {["*"] = "^", ["/"] = ",", ["+"] = "A", ["-"] = "S"}
function operation(key)
    input = input:gsub("[*/+-]([*/+-])", function(a) return oper_t[a] end)
end

function on_key_press(key)
    if key == "D" then
        input = input:sub(1, -2)
        debug_name = ""
        state = state_t["first"]

        for i in input:gmatch(".") do
            next_state(i)
        end
    else
        local fn = next_state(key)
        if fn then
            input = input .. key
            if type(fn) == "function" then
                fn(key)
            end
        end
    end
end

function next_state(key)
    for i = 1, #state, 1 do
        local st = state[i]
        if st[1]:find(key, 1, true) then
            debug_name = st[2]
            state = state_t[st[2]]
            if state.recursive then
                return next_state(key)
            end
            return st[3] or true
        end
    end
    return false
end



state_t = {
    first = {
        {"-1234567890.sabc","value"},
        {"(",               "first",        append_bracket},
        {"f*/+^,AS",        "operation"}},
    value = { recursive = true,
        {"-",               "minus",        append_whole},
        {"1234567890",      "number",       append_whole},
        {".",               "decimal",      append_dot},
        {"sabc",            "memory"}},
--
    minus = {
        {"1234567890",      "number",       append_whole},
        {".",               "decimal",      append_dot}},
    number = {
        {"12345677890sabc", "number",       append_whole},
        {"f",               "fraction",     function() mp_num.numer, mp_num.whole = mp_num.whole, nil end},
        {".",               "decimal",      append_dot},
        {"(",               "number",       append_bracket},
        {"*/+-^,AS=",       "operation"}},
    fraction = {
        {"12345677890sabc", "fraction",     append_denom},
        {"f",               "fraction_2",   function() mp_num.denom, mp_num.whole, mp_num.numer = mp_num.whole, mp_num.numer, mp_num.denom end},
        {"(",               "fraction",     append_bracket},
        {"*/+-^,AS=",       "operation"}},
    fraction_2 = {
        {"12345677890sabc", "fraction_2",   append_denom},
        {"(",               "fraction_2",   append_bracket},
        {"*/+-^,AS=",       "operation"}},
    decimal = {
        {"12345677890sabc", "decimal",      append_whole},
        {"(",               "decimal",      append_bracket},
        {"f*/+-^,AS=",      "operation"}},
--
    select = {
        {"1234567890f.",    "select",       mem_sel},
        {"s",               "set"},
        {"abc",             "macro"},
        {"*/+-^,AS=",       "operation"}},
    macro = {
        {"1234567890f.",    "select"},
        {"s",               "record"},
        {"abc",             "macro"},
        {"(",               "first"}},
    set = {
        {"1234567890f.",    "set",          mem_sel},
        {"s",               "select"},
        {"abc",             "record"}},
    record = {
        {"1234567890f.",    "set"},
        {"s",               "macro"},
        {"abc",             "record"},
        {"(",               "first"}},
--
    memory = { recursive = true,
        {"s",               "select"},
        {"a",               "mem_a"},
        {"b",               "mem_b"},
        {"c",               "mem_c"}},
    mem_c = {
        {"1234567890f.c",   "mem_c",        mem_sel},
        {"*/+-^,AS=",       "operation"}},
    mem_b = {
        {"1234567890f.b",   "mem_b",        mem_sel},
        {"*/+-^,AS=",       "operation"}},
    mem_a = {
        {"1234567890f.a",   "mem_a",        mem_sel},
        {"*/+-^,AS=",       "operation"}},
--
    operation = { recursive = true,
        {"^,",              "op_ext"},
        {"AS",              "op_mod_s"},
        {"*",               "op_mul"},
        {"/",               "op_div"},
        {"+",               "op_add"},
        {"-",               "op_sub"},
        {"f",               "op_frac"},
        {"=",               "first"}},
    op_mul = {
        {"*",               "op_ext",       operation},
        {"(",               "first",        append_bracket},
        {"-1234567890.sabc","value"}},
    op_div = {
        {"/",               "op_ext",       operation},
        {"(",               "first",        append_bracket},
        {"-1234567890.sabc","value"}},
    op_add = {
        {"+",               "op_mod_s",     operation},
        {"(",               "first",        append_bracket},
        {"-1234567890.sabc","value"}},
    op_sub = {
        {"-",               "op_mod_s",     operation},
        {"(",               "first",        append_bracket},
        {"1234567890.sabc", "value"}},
    op_ext = {
        {"(",               "first",        append_bracket},
        {"-1234567890.sabc","value"}},
    op_mod_s = {
        {"1234567890f.",    "op_mod_s",     mem_sel},
        {"=",               "first"}},
    op_frac = {
        {"*/+-",            "operation"},
        {"f",               "op_frac_del",  del_from},
        {"=",               "first"},
        {"1234567890",      "op_frac"}},
    op_frac_del = {
        {"*/+-",            "operation"},
        {"f",               "op_frac",}},
}
state = state_t["first"]
