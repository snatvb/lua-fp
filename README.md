
  # Utrix Library for functional programming in lua

  Данная библотека призвана собрать в себе основные функции для функционального программирвоания на Lua

  ---
## dirtyClone

###### _{n1, ..., n} -> {n1, ..., n}_

Клонирование таблицы (в один уровень) быстрым способом, но клонируются только числовые ключи, отлично подходит для копирования массивов

```lua
  local arr = {1, 2, 3}
  local arrCopy = dirtyClone(arr) -- arrCopy is new table
```

---

## shallowCopy

###### _{k1, ..., k} -> {k1, ..., k}_

Копирование таблицы в один уровень, медленнее чем dirtyClone, но копирует все ключи

```lua
  local t = { foo = "bar" }
  local t2 = shallowCopy(t) -- t2 is new table
```

---

## repeatStr

###### _String -> String_

Повторение строки и ее склеивание в единую новую строку

```lua
  local str = "test"
  repeatStr(str, 3) -- "testetstest"
```

---

## toString

###### _(*, number) -> String_

Преобразование данных в строку (так же разворачивает таблицу)

```lua
  local t = { foo: "bar" }
  toString(t) -- "{ foo = [string] => bar }""
```

---

## curry2

###### _(Function) -> Function -> Function -> *_

Каррирование функции с двумя аргументами

```lua
  local sum = function(a, b)
    return a + b
  end
  local add = curry2(sum)
  local add3 = add(3)
  add3(2) -- 5
  add3(7) -- 10
```

---

## curryN

###### _(Number, Function) -> Function -> ... -> Function -> *_

Каррирование функции с произвольным количеством аргументов

```lua
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
```

---

## tap

###### _(Function) -> (Function(*)) -> *_

Добавляет возможность пропустить через себя какой-то аргумент и создать сайд-эффек, фукнция всегда будет возвращать пришедший аргумент

```lua
  local t = { foo: "bar" }
  local log = tap(print)
  log(t) -- returned { foo: "bar" } and printed log the argument
```

---

## assoc

###### _(table) -> table_

Принимает таблицу, создает ее копию и перезаписывает поле. 
 Изменяет поле не путирая оригинальную таблицу.

```lua
  local t = { foo: "bar" }
  local t2 = assoc("foo", "baz", t)
  print(t2.foo) -- "baz"
  print(t.foo) -- "bar"
```

---

## assocPath

###### _(table) -> table_

Тоже самое что и assoc, только может менять вложенные ключи 
 Если ключа нет, он будет создан

```lua
  local t = { foo: "bar" }
  local t2 = assocPath({"foo", "bar", "baz"}, "hi", t)
  print(t2.foo.bar.baz) -- "hi"
  print(t.foo) -- "bar"
```