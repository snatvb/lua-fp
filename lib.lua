--[==[
  @name dirtyClone
  @sig {n1, ..., n} -> {n1, ..., n}
  @desc
    Клонирование таблицы (в один уровень) быстрым способом,
    но клонируются только числовые ключи,
    отлично подходит для копирования массивов
  @example
    local arr = {1, 2, 3}
    local arrCopy = dirtyClone(arr) -- arrCopy is new table
]==]
local function dirtyClone(org)
  return {table.unpack(org)}
end

--[==[
  @name shallowCopy
  @sig {k1, ..., k} -> {k1, ..., k}
  @desc
    Копирование таблицы в один уровень,
    медленнее чем dirtyClone, но копирует
    все ключи
  @example
    local t = { foo = "bar" }
    local t2 = shallowCopy(t) -- t2 is new table
]==]
local function shallowCopy(org)
    local result = {}
    for k, v in pairs(org) do
        result[k] = v
    end
    return result
end

--[==[
  @name repeatStr
  @sig String -> String
  @desc
    Повторение строки и ее склеивание в единую новую строку
  @example
    local str = "test"
    repeatStr(str, 3) -- "testetstest"
]==]
local function repeatStr(str, count)
    local result = ""
    for i = 1, count do
        result = result .. str
    end
    return result
end

--[==[
  @name toString
  @sig (*, number) -> String
  @desc
    Преобразование данных в строку (так же разворачивает таблицу)
  @example
    local t = { foo: "bar" }
    toString(t) -- "{ foo = [string] => bar }""
]==]
local function toString(value, maxDepth, depth)
    if type(value) ~= "table" then
        return "[" .. type(value) .. "] => " .. tostring(value)
    end

    if depth == nil then depth = 0 end
    if depth == nil then maxDepth = 8 end

    if maxDepth == depth then return "[[Depth overflow]]" end

    local closeTab = repeatStr("  ", depth)
    local tab = closeTab .. "  "
    local str = "{"
    for k, v in pairs(value) do
        str = str .. "\n" .. tab .. k .. " = " .. toString(v, maxDepth, depth + 1) .. ","
    end
    return str .. "\n" .. closeTab .. "}"
end


function printAsString(data)
    print(toString(data))
end

--[==[
  @name curry2
  @sig (Function) -> Function -> Function -> *
  @desc
    Каррирование функции с двумя аргументами
  @example
    local sum = function(a, b)
      return a + b
    end
    local add = curry2(sum)
    local add3 = add(3)
    add3(2) -- 5
    add3(7) -- 10
]==]
local function curry2(f)
    return function(...)
        local args = table.pack(...)
        if #args == 2 then return f(...) end
        if #args == 1 then
            local a = args[1]
            return function(b) return f(a, b) end
        end
    end
end

--[==[
  @name curryN
  @sig (Number, Function) -> Function -> ... -> Function -> *
  @desc
    Каррирование функции с произвольным количеством аргументов
  @example
    local multiSum = function(a, b, c)
      return a + b + c
    end
    local multiSumCarried = curryN(3, multiSum)
    local sumWith10 = multiSumCarried(10)
    sumWith10(5, 5) -- 20

    local add15 = sumWith10(5)
    add15(1) -- 16
    multiSumCarried(1)(2)(3) -- 6
    multiSumCarried(1)(2, 3) -- 6
    multiSumCarried(1, 2, 3) -- 6
    multiSumCarried(1, 2)(3) -- 6
]==]
local function curryN(n, f)
    local wait
    wait = function(rdc, rd)
        return function(...)
            local receivedCount = rdc
            local received = dirtyClone(rd)
            local args = table.pack(...)
            for i = 1, #args do
                local realIndex = i + receivedCount
                received[realIndex] = args[i]
            end
            receivedCount = receivedCount + #args
            if receivedCount >= n then
                return f(table.unpack(received))
            else
                return wait(receivedCount, received)
            end
        end
    end

    return wait(0, {})
end

--[==[
  @name tap
  @sig (Function) -> (Function(*)) -> *
  @desc
    Добавляет возможность пропустить через себя какой-то аргумент и
    создать сайд-эффек, фукнция всегда будет возвращать
    пришедший аргумент
  @example
    local t = { foo: "bar" }
    local log = tap(print)
    log(t) -- returned { foo: "bar" } and printed log the argument
]==]
local tap = function(f)
    return function(data)
        f(data)
        return data
    end
end

--[==[
  @name assoc
  @sig (table) -> table
  @desc
    Принимает таблицу, создает ее копию и перезаписывает поле.

    Изменяет поле не путирая оригинальную таблицу.
  @example
    local t = { foo: "bar" }
    local t2 = assoc("foo", "baz", t)
    print(t2.foo) -- "baz"
    print(t.foo) -- "bar"
]==]
local assoc = curryN(3, function(key, value, t)
    local result = shallowCopy(t)
    result[key] = value
    return result
end)

--[==[
  @name assocPath
  @sig (table) -> table
  @desc
    Тоже самое что и assoc, только может менять вложенные ключи

    Если ключа нет, он будет создан
  @example
    local t = { foo: "bar" }
    local t2 = assocPath({"foo", "bar", "baz"}, "hi", t)
    print(t2.foo.bar.baz) -- "hi"
    print(t.foo) -- "bar"
]==]
local assocPath = curryN(3, function (keys, val, t)
    local p = dirtyClone(keys)
    local function acp(p, val, t)
        local result = type(t) == "table" and t or {}
        local key = p[1]
        if #p == 1 then
            result[key] = val
            return result
        end
        table.remove(p, 1)
        if result[key] == nil then
            result[key] = acp(p, val, {})
        else
            result[key] = acp(p, val, result[key])
        end
        return result
    end
    return acp(p, val, shallowCopy(t))
end)


local dissoc = curry2(function(key, t)
    local result = shallowCopy(t)
    result[key] = nil
    return result
end)


local map = curry2(function(f, list)
    local result = {}
    local i = 1
    for k, v in pairs(list) do
        result[k] = f(v, k, i)
        i = i + 1
    end
    return result
end)


local filter = curry2(function(pf, list)
    local result = {}
    local i = 1
    for k, v in pairs(list) do
        local p = pf(v, k, i)
        if p ~= false then result[k] = v end
        i = i + 1
    end
    return result
end)


local reject = curry2(function(pf, list)
    local result = {}
    local i = 1
    for k, v in pairs(list) do
        local p = pf(v, k, i)
        if not (p ~= false) then result[k] = v end
        i = i + 1
    end
    return result
end)


local partition = curry2(function(pf, list)
    local resultFiltered = {}
    local resultRejected = {}
    local i = 1
    for k, v in pairs(list) do
        local p = pf(v, k, i)
        if (p ~= false) then resultFiltered[k] = v end
        if not (p ~= false) then resultRejected[k] = v end
        i = i + 1
    end
    return { resultFiltered, resultRejected }
end)


local reduce = curryN(3, function(f, acc, list)
    local result = shallowCopy(acc)
    local i = 1
    for k, v in pairs(list) do
        result[k] = f(result, v, k, i)
        i = i + 1
    end
    return result
end)


local merge = curry2(function(t1, t2)
    local result = shallowCopy(t1)
    for k, v in pairs(t2) do
        result[k] = v
    end
    return result
end)

local reverse = function(arr)
    local result = {}
    for i = #arr, 1, -1 do
        table.insert(result, arr[i])
    end
    return result
end


local slice = curryN(3, function(from, to, t)
    if from < 0 then from = #t + from + 1 end
    if to < 0 then
        to = #t + to + 1
    elseif to == 0 then
        to = #t + 1
    end
    local result = {}
    for i = from, to - 1 do
        table.insert(result, t[i])
    end
    return result
end)


local compose = function(...)
    local functions = table.pack(...)
    --print(toString(functions, 2))
    return function(data)
        local fLength = #functions
        local result = functions[fLength](data)
        for i = fLength - 1, 1, -1 do
            result = functions[i](result)
        end
        return result
    end
end
