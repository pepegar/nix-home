# Janet Control Flow and Loops Reference

## Conditionals

### if

Two or three arguments. Only `nil` and `false` are falsy.

```janet
(if condition then-expr)
(if condition then-expr else-expr)
```

Only one expression per branch. Use `do` for multiple:

```janet
(if (> x 0)
  (do (print "positive") x)
  (do (print "non-positive") 0))
```

### when / unless

Multiple body forms, no else branch:

```janet
(when (connected?)
  (send-data)
  (log "sent"))

(unless (empty? items)
  (process items))
```

### cond

Chain of condition-expression pairs. The last bare expression is the default:

```janet
(cond
  (< x 0)  "negative"
  (= x 0)  "zero"
  (< x 10) "small"
  "large")                    # default
```

### case

Equality matching against a single value:

```janet
(case (type x)
  :string  (string/length x)
  :number  (math/abs x)
  :array   (length x)
  (error "unsupported"))      # default (last bare expr)
```

### match (Pattern Matching)

Matches data structures against patterns:

```janet
(match value
  nil "nothing"
  true "yes"
  42 "the answer"
  [x y] (+ x y)              # sequential destructuring
  {:name n} (string "hi " n) # table destructuring
  _ "anything else")          # _ matches without binding
```

**Important behaviors:**

1. **Tuple patterns match prefixes:** `[x y]` matches `[1 2 3]` — order patterns most-specific first
2. **Identifiers bind:** `x` in a pattern binds the matched value
3. **Use `(@ var)` to match a runtime value** instead of binding:
   ```janet
   (def target 42)
   (match x
     (@ target) "found it"
     _ "nope")
   ```
4. **Guard clauses:**
   ```janet
   (match [op x y]
     ([:div x y] (= y 0)) "division by zero"
     [:div x y] (/ x y)
     [:add x y] (+ x y))
   ```
5. **Nil in associative patterns:** `{:key nil}` equals `{}` — use sentinel values instead

### if-let / when-let

Bind and test in one step:

```janet
(if-let [x (find-item)]
  (process x)
  (print "not found"))

(when-let [x (find-item)
           y (find-other)]
  (combine x y))
```

All bindings must be truthy for the body to execute.

### if-with / when-with

Bind a resource and automatically clean it up:

```janet
(if-with [f (file/open "data.txt")]
  (file/read f :all)
  "file not found")
```

Calls `(:close f)` on the resource when done (regardless of which branch).

---

## Loops

### while

Primitive loop:

```janet
(var i 0)
(while (< i 10)
  (print i)
  (++ i))
```

Always returns `nil`.

### for

Integer range iteration:

```janet
(for i 0 10
  (print i))           # 0 through 9

(for i 10 0 -1
  (print i))           # 10 down to 1
```

### each / eachk / eachp

```janet
(each x @[1 2 3]
  (print x))                   # values

(eachk k @{:a 1 :b 2}
  (print k))                   # keys only

(eachp [k v] @{:a 1 :b 2}
  (print k " = " v))           # key-value pairs
```

`each` works on arrays, tuples, tables, structs, strings, buffers, and fibers.

### loop (The Flexible Loop)

The `loop` macro supports multiple verbs and modifiers, similar to Common Lisp's loop:

**Verbs:**
```janet
# :range — integer range
(loop [i :range [0 10]] (print i))
(loop [i :range [0 100 2]] (print i))    # step by 2

# :in — iterate values
(loop [x :in @[1 2 3]] (print x))

# :pairs — key-value pairs
(loop [[k v] :pairs @{:a 1}] (print k v))

# :keys — keys only
(loop [k :keys @{:a 1 :b 2}] (print k))

# :down — count down
(loop [i :down [10 0]] (print i))

# :iterate — custom iteration
(loop [x :iterate start next-fn] (print x))
```

**Modifiers:**
```janet
:when expr        # skip iteration when false
:while expr       # stop loop when false
:until expr       # stop loop when true
:let [bindings]   # introduce local bindings
:before expr      # run before each iteration
:after expr       # run after each iteration
:repeat n         # repeat n times
```

**Example with multiple verbs and modifiers:**
```janet
(loop [host :in hosts
       :when (host :online)
       service :in (host :services)
       :let [name (service :name)]]
  (print name))
```

### Comprehensions

```janet
# seq — collect into array
(seq [x :range [0 5]] (* x x))
# => @[0 1 4 9 16]

# tabseq — collect into table (body returns key then value)
(tabseq [x :in ["a" "b" "c"]
         :let [i (string/length x)]]
  x i)

# catseq — collect and concatenate arrays
(catseq [x :in [[1 2] [3 4]]] x)
# => @[1 2 3 4]

# generate — return lazy fiber iterator
(def g (generate [x :range [0 5]] (* x x)))
(resume g)   # => 0
(resume g)   # => 1
```

### break

Exits the innermost loop. Also works as early return in functions:

```janet
(each x items
  (when (= x :stop) (break))
  (print x))

(defn find [pred items]
  (each x items
    (when (pred x) (break x))))   # return value from break
```

### forever

Alias for `(while true ...)`:

```janet
(forever
  (def input (getline))
  (when (= input "quit") (break))
  (process input))
```

### prompt / label (Multi-Level Break)

```janet
(prompt :done
  (for i 0 100
    (for j 0 100
      (when (= (* i j) 42)
        (return :done [i j])))))
```

`label` is similar but scoped — the returned value becomes the label form's value.
