--  Float Codeed Decimal
--      combines 4 floats to create 28 digit, fixed point numbers,
--      and implements basic arithmetic for them

function fcd(from)
    if     type(from) == "number" then
        from = ("%.14f"):format(from)
    elseif type(from) == "table" then
        return from
    end

    if type(from) == "string" and from:find("^%d*[.]?%d*$") then
        local a, b = from:match("^(%d*)[.]?(%d*)$")
        b = b .. "000000"
        return {
            tonumber(b:sub(  8,  14)) or 0,
            tonumber(b:sub(  0,   7)) or 0,
            tonumber(a:sub( -7,  -1)) or 0,
            tonumber(a:sub(-14,  -8)) or 0
            --tonumber(a:sub(  0, -15)) or 0
        }
    else
        return {0, 0, 0, 0, 0}
    end
end

fcd_ZERO = fcd("0")
fcd_ONE = fcd("1")
fcd_TWO = fcd("2")
fcd_MAX = {9999999, 9999999, 9999999, 9999999, exceeded=true}
fcd_MIN = {0, 0, 0, 0, exceeded=true}

function fcd_to_string(a)
    return ("%07d%07d.%07d%07d"):format(a[4], a[3], a[2], a[1]):gsub("^0*(%d)", "%1")
end

function fcd_cmp(a, b)
    if     a[4] ~= b[4] then return a[4] > b[4] and 1 or -1
    elseif a[3] ~= b[3] then return a[3] > b[3] and 1 or -1
    elseif a[2] ~= b[2] then return a[2] > b[2] and 1 or -1
    elseif a[1] ~= b[1] then return a[1] > b[1] and 1 or -1
    else                     return 0
    end
end

function fcd_shift_right(a)
    local ret = a[3] % 2 ~= 0
    a[3] = (a[3] + a[4] % 2 * 10000000) // 2
    a[4] =  a[4] // 2
    return ret
end

function fcd_div_by_2(a)
    local ret = a[1] % 2 ~= 0
    a[1] = (a[1] + a[2] % 2 * 10000000) // 2
    a[2] = (a[2] + a[3] % 2 * 10000000) // 2
    a[3] = (a[3] + a[4] % 2 * 10000000) // 2
    a[4] =  a[4]                        // 2
    return ret
end

function fcd_is_int(a)
    return a[3] == 0 and a[4] == 0
end


function fcd_add(a, b)
    local r1 = a[1]+b[1]
    local r2 = a[2]+b[2]+math.floor(r1 / 10000000)
    local r3 = a[3]+b[3]+math.floor(r2 / 10000000)
    local r4 = a[4]+b[4]+math.floor(r3 / 10000000)

    if r4 >= 10000000 then
        return fcd_MAX
    end

    return {
        r1 % 10000000,
        r2 % 10000000,
        r3 % 10000000,
        r4
    }
end

function fcd_sub(a, b)
    local r1 = a[1]-b[1]
    local r2 = a[2]-b[2]+math.floor(r1 / 10000000)
    local r3 = a[3]-b[3]+math.floor(r2 / 10000000)
    local r4 = a[4]-b[4]+math.floor(r3 / 10000000)

    if r4 < 0 then
        return fcd_MIN
    end

    return {
        r1 % 10000000,
        r2 % 10000000,
        r3 % 10000000,
        r4
    }
end


function fcd_mul(a, b)
    local mf = math.floor
    local a1, a2, a3, a4 = a[1], a[2], a[3], a[4]
    local b1, b2, b3, b4 = b[1], b[2], b[3], b[4]

    local r1 =       a3*b1+a2*b2+a1*b3 + mf((a1*b1/10000000+a2*b1+a1*b2)/10000000)
    local r2 = a4*b1+a3*b2+a2*b3+a1*b4 + mf(r1 / 10000000)
    local r3 = a4*b2+a3*b3+a2*b4       + mf(r2 / 10000000)
    local r4 = a4*b3+a3*b4             + mf(r3 / 10000000)

    if r4/10000000+a4*b3+a3*b4+a4*b4 > 0 then
        return fcd_MAX
    end

    return {
        r1 % 10000000,
        r2 % 10000000,
        r3 % 10000000,
        r4
    }
end

function fcd_div(a, b)
    local test = {8355328, 4073748, 1, 0}
    local ret = fcd_ZERO

    while fcd_cmp(fcd_mul(test, b), a) < 0 do
        test = fcd_mul(test, fcd_TWO)
    end

    repeat
        ret = fcd_add(ret, test)
        local cmp_mul_a = fcd_cmp(fcd_mul(ret, b), a)
        if cmp_mul_a >= 0 then
            if cmp_mul_a == 0 then
                return ret
            else
                ret = fcd_sub(ret, test)
            end
        end
    until fcd_div_by_2(test)

    return ret
end

function fcd_pow(a, b)
    local ret = fcd_ONE
    local b = {0, 0, select(3, table.unpack(b))}

    while not a.exceeded and fcd_cmp(b, fcd_ONE) > 0 do
        if fcd_shift_right(b) then
            ret = fcd_mul(ret, a)
        end
        a = fcd_mul(a, a)
    end

    return fcd_mul(ret, a)
end

function fcd_root(a, b)
    local test = {8355328, 4073748, 1, 0}
    local ret = fcd_ZERO

    while fcd_cmp(fcd_pow(test, b), a) < 0 do
        test = fcd_mul(test, fcd_TWO)
    end

    repeat
        ret = fcd_add(ret, test)
        local cmp_pow_a = fcd_cmp(fcd_pow(ret, b), a)
        if cmp_pow_a >= 0 then
            if cmp_pow_a == 0 then
                return ret
            else
                ret = fcd_sub(ret, test)
            end
        end
    until fcd_div_by_2(test)

    return ret
end

--a, b = fcd("13"), fcd("100000000")
--
--start = os.clock()
--for i = 1, 100 do
--    c = fcd_root(a, b)
--    c = fcd_root(a, b)
--    c = fcd_root(a, b)
--    c = fcd_root(a, b)
--    c = fcd_root(a, b)
--    c = fcd_root(a, b)
--    c = fcd_root(a, b)
--    c = fcd_root(a, b)
--    c = fcd_root(a, b)
--    c = fcd_root(a, b)
--end
--print(("%f"):format((os.clock() - start)/1000))
--print(fcd_to_string(c))