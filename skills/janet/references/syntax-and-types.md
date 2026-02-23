# Janet Syntax and Types Reference

## Literals

### Nil and Booleans
```janet
nil       # the absent value
true      # boolean true
false     # boolean false
```

### Numbers
All numbers are IEEE 754 64-bit floating point.

```janet
0  12  -65912                  # integers
4.98  1.3e18  1.3E18           # floats
0xff  0xFF                     # hex (base 16)
0b1010                         # binary (base 2)
0o777                          # octal (base 8)
16r10                          # arbitrary base: 16 in base 16 = 22
4r100                          # 4 in base 4 = 16
36rZZZ                         # base 36
1_000_000                      # digit grouping with underscores
```

Bases 2-36 are supported via the `Nr` prefix where N is the base.

### Strings
Immutable byte arrays delimited by double quotes:

```janet
"hello world"
"contains \"quotes\""
"line1\nline2"
"hex byte: \x41"       # => "A"
"unicode: \u0041"      # => "A" (4-digit UTF-8)
"unicode: \U000041"    # => "A" (6-digit UTF-8)
```

**Escape sequences:** `\n` `\t` `\r` `\0` `\z` `\f` `\e` `\"` `\\` `\xHH` `\uxxxx` `\Uxxxxxx`

**Long strings** (backtick-delimited) — no escape processing:
```janet
`single line raw string`
``can contain ` backticks``
```multiple
lines with
no escaping```
```

### Buffers
Mutable strings prefixed with `@`:

```janet
@"mutable string"
@``raw mutable buffer``
```

### Keywords
Prefixed with `:`, used as keys in tables/structs and for enum-like values:

```janet
:keyword
:my-key
:some-long-name
```

### Symbols
Identifiers that resolve to values. Convention is kebab-case:

```janet
my-var
my-module/my-function
+  -  *  /                     # operators are symbols
!  @  $  %  ^  &  _  =  <  >  # valid in symbol names
```

## Collections

### Tuples (Immutable Sequences)

Two syntactic forms, both create tuples:

```janet
(1 2 3)           # parenthesized tuple (also function call form)
[1 2 3]           # bracketed tuple (literal constructor, never a call)
```

The bracketed form `[...]` is preferred for data literals to distinguish from function calls.

```janet
(def coords [10 20 30])
(get coords 0)          # => 10
(length coords)         # => 3
```

### Arrays (Mutable Sequences)

```janet
@(1 2 3)          # parenthesized
@[1 2 3]          # bracketed (preferred for data)
(array 1 2 3)     # function call

(def a @[1 2])
(array/push a 3)          # a is now @[1 2 3]
(array/pop a)              # => 3, a is @[1 2]
(array/insert a 0 99)     # insert 99 at index 0
(array/remove a 0)        # remove at index 0
(array/concat a @[4 5])   # append elements
(put a 0 :x)              # set index 0
(sort a)                   # in-place sort
(sorted a)                 # return sorted copy
```

### Structs (Immutable Tables)

```janet
{:key "value" :another 42}
(struct :a 1 :b 2)

# Keys can be any non-nil, non-NaN value
{1 "one" 2 "two" "key" "val"}
```

Nil keys and values are silently dropped.

### Tables (Mutable Tables)

```janet
@{:key "value" :another 42}
(table :a 1 :b 2)

(def t @{:x 1})
(put t :y 2)                # add/update key
(put t :x nil)              # delete key
(set (t :x) 10)             # alternative update via set
(get t :x)                  # => 10
(in t :x)                   # => 10 (raises on bad indexed access)
(get t :missing :default)   # => :default
(keys t)                    # => @[:y :x]
(values t)                  # => @[2 10]
(pairs t)                   # => @[(:y 2) (:x 10)]
(table/clone t)             # shallow copy
```

## Common Operations Across All Structures

```janet
(get ds key)                # get with nil default
(get ds key default)        # get with explicit default
(in ds key)                 # like get but errors on invalid indexed access
(length ds)                 # element count
(empty? ds)                 # (= 0 (length ds))
(freeze ds)                 # deep-convert to immutable equivalent
(thaw ds)                   # deep-convert to mutable equivalent
```

### Splicing

Unpack a sequence into a function call or constructor:

```janet
(+ ;@[1 2 3 4])             # => 10
[;(range 5)]                # => [0 1 2 3 4]
(string/join ;args)          # splice args tuple
```

## Equality and Comparison

**Immutable types have value semantics:**
```janet
(= [1 2 3] [1 2 3])         # => true
(= {:a 1} {:a 1})           # => true
(= "hello" "hello")         # => true
```

**Mutable types have identity semantics:**
```janet
(= @[1 2 3] @[1 2 3])       # => false (different objects)
(def a @[1])
(= a a)                     # => true (same object)
(deep= @[1 2] @[1 2])       # => true (structural comparison)
```

## Truthiness

Only `nil` and `false` are falsy. Everything else is truthy:

```janet
(truthy? 0)          # => true
(truthy? "")         # => true
(truthy? [])         # => true
(truthy? @[])        # => true
(truthy? nil)        # => false
(truthy? false)      # => false
```

## Type Checking

```janet
(type x)             # returns keyword: :number :string :array :tuple :table :struct etc.
(number? x)
(string? x)
(keyword? x)
(symbol? x)
(array? x)
(tuple? x)
(table? x)
(struct? x)
(buffer? x)
(fiber? x)
(function? x)
(nil? x)
(boolean? x)
(indexed? x)         # array or tuple
(dictionary? x)      # table or struct
(bytes? x)           # string, buffer, keyword, or symbol
```
