--  number conversion and calculation

--[[

decimal, rq_denominator = input:match("([-%d]*%.[%d]+)f(%d*)")

w, n, d = input:match("([-%d.]*)f?(%d*)f?(%d*)")

if n ~= "" and d == "" then
    w, n, d = 0, w, n
end

r = d ~= "" and w+n/d or n ~= "" and w/n or w


12          w   V
12 f 3      wn  V
12 f 3 f 4  wnd V
.2          w   V
.2 f        w   V
.2 f 34     wn  V


get_number()
->  frc for calc
->  w n/d for display

1f3 + 1f3 =
.666666666666_f
]]

function frc_core(f, i)
    if i == 0 then return 1, math.floor(1/f) end

    local n, d = frc_core(1/f %1, i-1)

    n = n + math.floor(1/f) * d

    return d, n
end

function frc(f, p)
    local n, d
    local i = 0

    repeat
        n, d = frc_core(f, i)
        i = i + 1
    until math.floor(n/d *p) == math.floor(f*p)

    return n, d
end

function get_number(input, prec, frc_for_calc)
    local neg, w, gen, f, n, d = input:match("(-?)([%d.]*)(_?)(f?)([%d]*)f?([%d]*)$")

    if w:find("%.") then
        if gen == "" then
            prec = 10^#(w:match("%d*$"))
        end

        if n ~= "" then
            w, n, d = "", math.floor(w*n +0.5), n
        elseif f == "f" then
            w, n, d = "", frc(w, prec)
        else
            w, n, d = math.floor(w*prec) / prec, "", ""
        end
    elseif n ~= "" and d == "" then
        w, n, d = "", w, n
    end

    if frc_for_calc then
        if n == "" then
            n, d = 0, 1
        end

        w = w == "" and 0 or w
        return neg..(w + n/d), f == "f"
    else
        return neg..w, n, d
    end
end

local op_t = {
    ["*"] = function(a, b) return a * b end,
    ["/"] = function(a, b) return a / b end,
    ["+"] = function(a, b) return a + b end,
    ["~"] = function(a, b) return a - b end,
    ["^"] = function(a, b) return a ^ b end,
    [","] = function(a, b) return b end,
    ["A"] = function(a, b) return a end,
    ["S"] = function(a, b) return a end,
}

function do_calc_once(input, prec)
    prec = prec or 100000000

    local  pre,br,  a,               op,          b,             post, eq = input:match
        ("^(.-)(%(?)([-%d.fsabc_]+)=-([*/+~^,AS=])([-%d.fsabc_]+)((=*).-)$")

print(input)
print(pre, br, a, op, b, eq, post)

    if a == nil or post == "" then
        return input, true
    elseif op == "=" then
        return b..post, false
    end

    a, af = get_number(a, prec, true)
    b, bf = get_number(b, prec, true)

    local f = (af or bf) and "_f" or "_"

    local op = op_t[op]
    local result = op(a, b)
    
    
    
    if #eq > 0 then
        if br == "(" then
            br = ""
            post = post:sub(2, -1)
        else
            for i = 2, #eq do
                result = op(result, b)
            end
            post = post:gsub("^=*", "=")
        end
    end
    
    prec = 10^math.floor(math.log10(result) + 14)
    result = math.floor(result * prec + 0.5) / prec

    return pre..br..result..f..post, false
end

function do_calc(input)
    local lp
    repeat
        input, lp = do_calc_once(input)
    until lp
    return input
end

--print(">", do_calc(io.read()))
