
  # Utrix Library for functional programming in lua

  Данная библотека призвана собрать в себе основные функции для функционального программирвоания на Lua

  ---
## dirtyClone

Клонирование таблицы (в один уровень) быстрым способом, но клонируются только числовые ключи, отлично подходит для копирования массивов

######*{n1, ..., n} -> {n1, ..., n}*

```lua
  local arr = {1, 2, 3}
  local arrCopy = dirtyClone(arr) -- arrCopy is new table
```

---

## shallowCopy

Копирование таблицы в один уровень, медленнее чем dirtyClone, но копирует все ключи

######*{k1, ..., k} -> {k1, ..., k}*

```lua
  local t = { foo = "bar" }
  local t2 = shallowCopy(t) -- t2 is new table
```