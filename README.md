
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
  local t = { foo = "bar" }
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
  local t = { foo = "bar" }
  local log = tap(print)
  log(t) -- returned { foo = "bar" } and printed log the argument
```

---

## assoc

###### _(table) -> table_

Принимает таблицу, создает ее копию и перезаписывает поле. 
 Изменяет поле не мутирая оригинальную таблицу.

```lua
  local t = { foo = "bar" }
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
  local t = { foo = "bar" }
  local t2 = assocPath({"foo", "bar", "baz"}, "hi", t)
  print(t2.foo.bar.baz) -- "hi"
  print(t.foo) -- "bar"
```

---

## dissoc

###### _(table) -> table_

Удаляет поле из таблицы не мутирая оригинал, возвращая новую табилцу

```lua
  local t = { foo = "bar" }
  local t2 = dissoc("foo", "baz", t)
  print(t2.foo) -- nil
  print(t.foo) -- "bar"
```

---

## map

###### _(Function, table) -> table_

Принимает на вход функцию и таблицу, проходит по таблице, вызывая функцию для изменения текущего поля, в поле будет установлено значение полученное из переданной функции. В функцию передается (значение, ключ, индекс) 
 **Не мутирует оригинал**

```lua
  local t = { foo = "bar", bar = "baz", baz = "foo" }
  local t2 = map(function(v, k)
    return v .. " " .. k
  end, t)
  t2 -- { foo = "bar foo", bar = "baz bar", baz = "foo baz" }
  print(t.foo) -- "bar"
```

---

## filter

###### _(Function, table) -> table_

Принимает на вход функцию-предикат и таблицу, проходит по таблице, вызывая функцию для фильтрации данных. Если функция-предикат вернет true, элемент попадет в новый  массив 
 **Не мутирует оригинал**

```lua
  local t = { 1, 2, 3, 4, 5, 6, 7, 8, 9 }
  local t2 = filter(function(v)
    return v > 5
  end, t)
  t2 -- { 6, 7, 8, 9 }
  t -- { 1, 2, 3, 4, 5, 6, 7, 8, 9 }
```

---

## reject

###### _(Function, table) -> table_

Тоже самое что и fitler, но работает наоборот. Принимает на вход функцию-предикат и таблицу, проходит по таблице, вызывая функцию для фильтрации данных. Если функция-предикат вернет true, элемент **не** попадет в новый  массив 
 **Не мутирует оригинал**

```lua
  local t = { 1, 2, 3, 4, 5, 6, 7, 8, 9 }
  local t2 = reject(function(v)
    return v > 5
  end, t)
  t2 -- { 1, 2, 3, 4, 5 }
  t -- { 1, 2, 3, 4, 5, 6, 7, 8, 9 }
```

---

## partition

###### _(Function, table) -> { table, table }_

Расширенная версия _filter_/_reject_ Принимает на вход функцию-предикат и таблицу, проходит по таблице, вызывая функцию для фильтрации данных. Если функция-предикат вернет true, элемент попадет в первый список, иначе во второй 
 **Не мутирует оригинал**

```lua
  local t = { 1, 2, 3, 4, 5, 6, 7, 8, 9 }
  local t2 = partition(function(v)
    return v > 5
  end, t)
  t2[1] -- { 6, 7, 8, 9 }
  t2[2] -- { 1, 2, 3, 4, 5 }
  t -- { 1, 2, 3, 4, 5, 6, 7, 8, 9 }
```

---

## reduce

###### _(Function, *, table) -> *_

Принимает на вход функцию, аккумулятор, таблицу, итерирует ее, в функцию попадает предыдущий результат, ткущий элемент(занчение), ключ, индекс. В итоге отдает конечный зельтат аккумулятора 
 **Не мутирует оригинал**

```lua
  local t = { 1, 2, 3, 4, 5, 6, 7, 8, 9 }
  local sum = reduce(function(acc, v)
    return acc + v
  end, 0, t)
  sum -- 1 + 2 + 3 + 4 + 5 + 6 + 7 + 8 + 9 = 45
  t -- { 1, 2, 3, 4, 5, 6, 7, 8, 9 }
```

---

## merge

###### _(table, table) -> table_

Склеивает две таблицы и возвращает новую. Приоритет отдается второй. 
 **Не мутирует оригинал**

```lua
  local t1 = { foo = "bar" }
  local t2 = { bar = "baz" }
  local t3 = merge(t1, t2)
  t1 -- { foo = "bar" }
  t2 -- { bar = "baz" }
  t3 -- { foo = "bar", bar = "baz" }
```

```lua
  local t1 = { foo = "bar", bar = "baz", baz = "foo" }
  local t2 = { bar = "hi" }
  local t3 = merge(t1, t2)
  t1 -- { foo = "bar", bar = "baz", baz = "foo" }
  t2 -- { bar = "hi" }
  t3 -- { foo = "bar", bar = "hi", baz = "foo" }
```

---

## reverse

###### _(table) -> table_

Разворачивает массив 
 **Не мутирует оригинал**

```lua
  local t1 = { 1, 2, 3 }
  local t2 = reverse(t1)
  t1 -- { 1, 2, 3 }
  t2 -- { 3, 2, 1 }
```

---

## slice

###### _(number, number, table) -> table_

Вырезает часть массива. Указываются индексы от(включительно) и до(не включительно) 
 **Не мутирует оригинал**

```lua
  local t1 = { 1, 2, 3, 4, 5, 6, 7, 8, 9 }
  local t2 = slice(-2, 0, t1)
  local t3 = slice(2, 4, t1)
  t1 -- { 1, 2, 3, 4, 5, 6, 7, 8, 9 }
  t2 -- { 8, 9 }
  t3 -- { 2, 3 }
```

---

## compose

###### _(Function, Function, ..., Function) -> (*) -> *_

Компазиционная функция. Служит для полследовательно выполенния функций. 
 f1(f2(f3(f4()))) 
 **Не мутирует оригинал**

```lua
  local t1 = { 1, 2, 3, 4, 5, 6, 7, 8, 9 }
  local t2 = compose(
    assoc("foo", "bar"),
    assoc("bar", "baz"),
    fitler(function(v)
      return v > 4
    end)
  )(t1)
  t1 -- { 1, 2, 3, 4, 5, 6, 7, 8, 9 }
  t2 -- { 5, 6, 7, 8, 9, foo = "bar", bar = "baz" }
```