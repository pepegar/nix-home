# Janet Functions and Macros Reference

## Function Definition

### defn

```janet
(defn function-name
  "Optional docstring."
  [param1 param2]
  (body))
```

`defn` is a macro expanding to `(def name (fn name [params] body))`.

### fn (Anonymous Functions)

```janet
(fn [x y] (+ x y))              # anonymous
(fn my-name [x] x)              # named (for recursion and stack traces)
((fn [x] (* x x)) 5)           # immediately invoked
```

### Short-fn Syntax

The `|` reader macro creates compact anonymous functions:

```janet
|(+ $ 1)                         # (fn [x] (+ x 1))
|(+ $0 $1)                       # (fn [a b] (+ a b))
|(string $0 " " $1 " " $2)     # three args
|(map inc $&)                    # $& = rest args as tuple
|[:pair $]                       # returns [:pair arg]
```

- `$` or `$0` — first argument
- `$1`, `$2`, ... — subsequent arguments
- `$&` — all remaining arguments as tuple

## Parameter Types

### Required Parameters

```janet
(defn add [x y] (+ x y))
```

### Optional Parameters (`&opt`)

```janet
(defn greet [name &opt greeting]
  (default greeting "Hello")
  (string greeting ", " name "!"))

(greet "Alice")             # => "Hello, Alice!"
(greet "Alice" "Hey")       # => "Hey, Alice!"
```

Unspecified optional params are `nil`. Use `(default var value)` to assign defaults.

### Variadic Parameters (`&`)

```janet
(defn log [level & messages]
  (print level ": " (string/join messages " ")))

(log :info "server" "started")  # => "info: server started"
```

The `&` gathers all remaining args into a tuple.

### Ignore Extra Arguments

```janet
(defn first-only [x &]
  x)
(first-only 1 2 3 4)           # => 1
```

### Named Parameters (`&named`)

```janet
(defn rect [&named width height color]
  (default color :black)
  @{:w width :h height :c color})

(rect :width 10 :height 20)
(rect :width 10 :height 20 :color :red)
```

Functions with `&named` are implicitly variadic and silently accept extra named args.

### Keyword Arguments (`&keys`)

```janet
# With struct destructuring
(defn make-recipe [&keys {:flour flour :sugar sugar}]
  [flour sugar])
(make-recipe :flour 2 :sugar 1)

# With single symbol (collects all as struct)
(defn count-animals [&keys animals]
  (length animals))
(count-animals :cat 3 :dog 2)   # => 2
```

## Destructuring

Works in `def`, `var`, `let`, `if-let`, `when-let`, and function parameters.

### Sequential Destructuring

```janet
(def [a b c] [10 20 30])
(def [head & tail] [1 2 3 4])       # head=1, tail=(2 3 4)
```

### Table/Struct Destructuring

```janet
(def {:name name :age age} {:name "Jo" :age 30})
(let [{:x x :y y} point]
  (+ x y))
```

### Nested Destructuring

```janet
(def {:pos [x y] :name name} {:pos [10 20] :name "A"})
# x=10, y=20, name="A"
```

## Closures

Functions close over their lexical environment:

```janet
(defn make-counter []
  (var n 0)
  (fn [] (++ n) n))

(def c (make-counter))
(c)  # => 1
(c)  # => 2
```

## Multiple Return / Early Return

`break` inside a function returns early:

```janet
(defn find-first [pred items]
  (each item items
    (when (pred item)
      (break item))))
```

## Docstrings and Metadata

```janet
(defn my-fn
  "This function does X."
  [x]
  x)

(doc my-fn)                         # print docstring in REPL
```

Private functions (not exported from module):

```janet
(defn- helper [x] (* x 2))
```

---

## Macros

### defmacro

Macros run at compile time and transform code:

```janet
(defmacro unless [condition & body]
  ~(if (not ,condition) (do ,;body)))

(unless false
  (print "this runs"))
```

### Quasiquote, Unquote, Splice

- `~(...)` — quasiquote: template with holes
- `,expr` — unquote: evaluate and insert one value
- `,;expr` — unquote-splice: evaluate and splice sequence into parent

```janet
(defmacro my-when [cond & body]
  ~(if ,cond (do ,;body)))
```

### The Double-Evaluation Problem

Naive macros evaluate arguments multiple times:

```janet
# BAD: x and y evaluated twice
(defmacro bad-max [x y]
  ~(if (> ,x ,y) ,x ,y))
```

### Hygiene with gensym and with-syms

Generate unique symbols to avoid variable capture:

```janet
(defmacro safe-max [x y]
  (with-syms [$x $y]
    ~(let [,$x ,x ,$y ,y]
       (if (> ,$x ,$y) ,$x ,$y))))
```

`with-syms` is sugar for multiple `(gensym)` calls.

### Debugging Macros

```janet
(macex1 '(my-when true (print "hi")))   # one-level expansion
(macex '(my-when true (print "hi")))    # full expansion
```

### Macros vs Functions

Prefer functions unless:
- Custom control flow is needed (short-circuit, conditional eval)
- Compile-time code generation is required
- Syntax transformation is the goal

Functions are first-class values; macros are not. Use macros sparingly.

### Threading Macros

```janet
(-> x (f a) (g b))              # thread first: (g (f x a) b)
(->> x (f a) (g b))             # thread last:  (g a (f b x))  — actually (g b (f a x))
(-?> x (f) (g))                 # short-circuit on nil
(-?>> x (f) (g))                # short-circuit on nil (thread last)
(as-> x v (f v 1) (g 2 v))     # bind to named var
```

### upscope

Like `do` but bindings leak into the enclosing scope — useful in macros:

```janet
(defmacro my-def-pair [a b]
  ~(upscope
    (def ,a 1)
    (def ,b 2)))

(my-def-pair x y)
(+ x y)  # => 3
```
