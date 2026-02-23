---
name: janet
description: This skill should be used when the user asks to "write Janet code", "create a Janet script", "parse with PEG in Janet", "use Janet fibers", "write a Janet macro", or is working with .janet files, project.janet, or the Janet programming language in any capacity.
---

# Writing Correct Janet

Janet is a functional and imperative Lisp that compiles to bytecode and runs on a lightweight VM (<1MB). It has mutable/immutable variants of every collection, green threads (fibers), built-in PEGs, and an event loop.

## Syntax at a Glance

```janet
# Comments start with hash
nil true false                     # nil and booleans
42 3.14 0xff 2r1010 1_000          # numbers (IEEE 754 doubles)
"hello\n" ``raw string``           # strings (immutable byte arrays)
@"mutable" @``raw buffer``         # buffers (mutable strings)
:keyword                           # keywords (interned, used as keys)
my-symbol  my-mod/my-fn            # symbols (kebab-case convention)
(1 2 3)    [1 2 3]                 # tuples (immutable; [] = literal)
@(1 2 3)   @[1 2 3]               # arrays (mutable)
{:a 1 :b 2}                       # structs (immutable tables)
@{:a 1 :b 2}                      # tables (mutable)
```

**Reader macros:** `'x` quote, `~x` quasiquote, `,x` unquote, `;x` splice, `|(+ $ 1)` short-fn.

## Core Idioms

### Bindings and Mutation

```janet
(def x 10)                  # immutable binding
(var counter 0)              # mutable binding
(set counter (+ counter 1))  # update var with set
(++ counter)                 # shorthand increment
```

### Functions

```janet
(defn greet [name]
  (string "hello " name))

(defn add [a b &opt c]       # optional arg
  (default c 0)
  (+ a b c))

(defn sum [& xs]             # variadic
  (reduce + 0 xs))

(defn make [&named width height]  # named args
  @{:w width :h height})
(make :width 10 :height 20)
```

**Short-fn:** `|(+ $ 1)` is `(fn [x] (+ x 1))`. Use `$0 $1` for multiple args, `$&` for rest.

### Destructuring

```janet
(def [a b c] [1 2 3])
(def {:name name :age age} @{:name "Jo" :age 30})
(let [[x & rest] [1 2 3 4]]
  (print x rest))  # 1 (2 3 4)
```

### Control Flow

```janet
(if (> x 0) "pos" "non-pos")     # if (only nil/false are falsy)
(when condition (do-a) (do-b))    # when (no else, multiple body forms)
(cond
  (> x 0) "positive"
  (< x 0) "negative"
  "zero")                         # cond (else = last bare expr)
(case (type x)
  :string "str" :number "num"
  "other")                        # case (equality matching)
(match expr
  [:add a b] (+ a b)
  [:mul a b] (* a b)
  _ "unknown")                    # match (pattern matching)
```

**Gotcha:** `match` tuple patterns match *prefixes* — `[x y]` matches `[1 2 3]`. Order patterns most-specific first.

### Loops and Iteration

```janet
(for i 0 10 (print i))
(each x @[1 2 3] (print x))
(eachp [k v] @{:a 1 :b 2} (print k v))

(loop [x :in items
       :when (even? x)
       :let [y (* x 2)]]
  (print y))

# Comprehensions
(seq [x :range [0 5]] (* x x))       # => @[0 1 4 9 16]
(tabseq [x :in ["a" "b"]] x true)    # => @{"a" true "b" true}
(generate [x :range [0 5]] (* x x))  # lazy fiber
```

### Strings

```janet
(string "a" "b" "c")                   # concatenation
(string/format "%s is %d" "age" 30)    # printf-style
(string/find "needle" haystack)
(string/split "," "a,b,c")            # => @["a" "b" "c"]
(string/join @["a" "b"] ", ")          # => "a, b"
(string/replace-all "old" "new" text)
```

### Data Structures

All structures support `(get ds key)`, `(in ds key)`, `(length ds)`. Mutable ones support `(put ds key val)`.

```janet
(def t @{:x 1})
(put t :y 2)
(set (t :x) 10)        # set works as l-value for tables

(def a @[1 2])
(array/push a 3)
(array/pop a)

# Freezing: (freeze x) makes deep-immutable copy
# Equality: immutable = value equality; mutable = identity only
# Use (deep= a b) for structural comparison of mutables
```

### Error Handling

```janet
(try
  (error "boom")
  ([err] (print "caught: " err)))

(defer (cleanup)       # runs cleanup even on error/signal
  (risky-operation))

# Propagate with (propagate err fiber) or (error x)
```

### Modules

```janet
(import mymod)                      # mymod/function
(import mymod :as m)                # m/function
(import mymod :prefix "")           # function (no prefix)
(import ./local-mod)                # relative import

# In a module, use defn- / def- for private bindings
```

## Quick Decision Table

| Need | Use |
|------|-----|
| Immutable list | tuple `[1 2 3]` |
| Mutable list | array `@[1 2 3]` |
| Immutable map | struct `{:a 1}` |
| Mutable map | table `@{:a 1}` |
| Immutable text | string `"hi"` |
| Mutable text | buffer `@"hi"` |
| Parse text | PEG `(peg/match patt text)` |
| Async/coroutine | fiber `(fiber/new fn)` |
| Concurrent I/O | event loop `(ev/spawn ...)` |
| OOP-like dispatch | prototypes `(table/setproto obj proto)` |

## Common Pitfalls

1. **`nil` cannot be a table key or value** — setting a key to `nil` deletes it
2. **Only `nil` and `false` are falsy** — `0`, `""`, `[]`, `@[]` are all truthy
3. **Mutable equality is identity** — `(= @[1] @[1])` is `false`; use `(deep= a b)`
4. **`match` does prefix matching** — `[a b]` matches any sequence with 2+ elements
5. **Macros evaluate args multiple times** — use `with-syms` + `let` to cache
6. **`splice` (`;`) only works in calls/constructors** — `(+ ;@[1 2 3])` => 6
7. **`file/` module blocks the event loop** — use `ev/` equivalents for async

## Detailed References

Read these files for comprehensive coverage of each topic:

- **`references/syntax-and-types.md`** — All literals, number formats, string escapes, data structure details, equality semantics
- **`references/functions-and-macros.md`** — Function forms, destructuring, `&opt`/`&named`/`&keys`, closures, defmacro, quasiquote, hygiene, `with-syms`
- **`references/control-flow-and-loops.md`** — `if`/`when`/`cond`/`case`/`match`, `loop` verbs and modifiers, comprehensions, `break`/`prompt`/`label`
- **`references/peg-patterns.md`** — All PEG combinators, captures, grammars, built-in aliases, practical examples (IP validator, string replacer)
- **`references/fibers-and-errors.md`** — Fibers, signals, `try`/`defer`/`protect`, event loop, `ev/spawn`, channels, streams, supervisor trees
- **`references/modules-and-projects.md`** — `import`, module resolution, `jpm`, `project.janet`, private bindings, custom loaders
- **`references/tables-and-oop.md`** — Prototypes, method dispatch with `:method` syntax, operator overloading, polymorphism patterns
