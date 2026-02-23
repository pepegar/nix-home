# Janet PEG (Parsing Expression Grammars) Reference

Janet has PEGs built into the core library. Use `peg/match` to match patterns and extract captures from text.

## Core Functions

```janet
(peg/match pattern text &opt start &args)
# Returns array of captures, or nil on no match

(peg/compile pattern)
# Pre-compile a pattern for reuse (optional — peg/match compiles internally)

(peg/find pattern text &opt start limit)
# Find first match location

(peg/find-all pattern text &opt start limit)
# Find all match locations

(peg/replace pattern subst text &opt start limit)
# Replace first match

(peg/replace-all pattern subst text &opt start limit)
# Replace all matches
```

## Primitive Patterns

| Pattern | Matches |
|---------|---------|
| `"literal"` | Exact string |
| `N` (positive int) | Exactly N characters |
| `-N` (negative int) | Succeeds if fewer than N chars remain |
| `true` | Always succeeds, consumes nothing |
| `false` | Always fails |
| `(range "az")` | One char in range a-z |
| `(range "az" "AZ")` | Multiple ranges |
| `(set "aeiou")` | One char from set |

## Combinators

### Choice and Sequence

```janet
(choice a b c)    # or (+): try each in order, first match wins
(sequence a b c)  # or (*): match all in order
```

Shorthand: `(+ a b c)` for choice, `(* a b c)` for sequence.

### Repetition

```janet
(any patt)            # 0 or more (greedy)
(some patt)           # 1 or more
(opt patt)            # or (?): 0 or 1
(between min max patt) # min to max repetitions
(at-least n patt)     # n or more
(at-most n patt)      # 0 to n
(repeat n patt)       # exactly n
```

### Lookahead and Conditionals

```janet
(not patt)            # or (!): negative lookahead (no consume)
(if cond patt)        # match patt only if cond matches (cond doesn't consume)
(if-not cond patt)    # match patt only if cond fails
(look offset patt)    # or (>): match at fixed offset from current pos
```

### Text Navigation

```janet
(to patt)             # consume up to (but not including) patt
(thru patt)           # consume through (including) patt
(sub window patt)     # match patt within the substring matched by window
(split sep patt)      # split on sep, match each piece against patt
```

## Captures

Captures are values extracted from matched text and returned in the result array.

```janet
(capture patt)        # or (<-): capture matched text as string
(group patt)          # capture all sub-captures as an array
(replace patt subst)  # or (/): transform capture(s) via table/function/string
(constant value)      # push a constant value (no consumption)
(position)            # or ($): capture current byte index
(column)              # capture current column number
(line)                # capture current line number
(accumulate patt)     # or (%): concatenate all sub-captures into one string
(cmt patt fun)        # apply function to captures, push result
(backref tag)         # or (->): re-push a tagged capture
(number patt)         # parse matched text as a Janet number
(int num-bytes)       # parse bytes as integer (little-endian)
(uint num-bytes)      # parse bytes as unsigned integer
(drop patt)           # match but discard captures
(nth index patt)      # keep only the nth capture
(unref patt)          # scope tagged captures (prevent leaking)
(error patt)          # throw parse error if matched
```

### Tagged Captures

Many capture forms accept an optional tag for use with `backref`:

```janet
(peg/match
  ~(sequence (capture (some (range "az")) :word)
             " "
             (backref :word))
  "hello hello")
# => @["hello"]
```

## Built-in Aliases

| Alias | Expands To | Meaning |
|-------|-----------|---------|
| `:d` | `(range "09")` | digit |
| `:a` | `(range "az" "AZ")` | letter |
| `:w` | `(range "az" "AZ" "09")` | alphanumeric |
| `:s` | `(set " \t\r\n\f\v\0")` | whitespace |
| `:h` | `(range "09" "af" "AF")` | hex digit |
| `:D` `:A` `:W` `:S` `:H` | negations | non-digit, etc. |
| `:d+` `:a+` `:w+` `:s+` `:h+` | `(some ...)` | one or more |
| `:d*` `:a*` `:w*` `:s*` `:h*` | `(any ...)` | zero or more |

## Grammars (Recursive Patterns)

Use a struct with keyword-named rules. `:main` is the entry point:

```janet
(def balanced-parens
  '{:open (* "(" (any :inner) ")")
    :inner (+ :open (if-not ")" 1))
    :main :open})

(peg/match balanced-parens "((()))")   # => @[]
(peg/match balanced-parens "(()")      # => nil
```

## Practical Examples

### Match an IP Address

```janet
(def ip-address
  '{:dig (range "09")
    :byte (choice
            (* "25" (range "05"))
            (* "2" (range "04") :dig)
            (* "1" :dig :dig)
            (between 1 2 :dig))
    :main (* :byte "." :byte "." :byte "." :byte)})

(peg/match ip-address "192.168.1.1")      # => @[]
(peg/match ip-address "999.999.999.999")  # => nil
```

### Find All Positions of a Substring

```janet
(defn find-all [needle haystack]
  (peg/match
    ~(any (+ (* ($) ,needle) 1))
    haystack))

(find-all "dog" "dog dog cat dog")  # => @[0 4 12]
```

### Replace All Occurrences

```janet
(defn replace-all [patt subst text]
  (first
    (peg/match
      ~(% (any (+ (/ (<- ,patt) ,subst) (<- 1))))
      text)))

(replace-all "cat" "dog" "my cat and your cat")
# => "my dog and your dog"
```

### Parse Key-Value Pairs

```janet
(def kv-parser
  ~{:key (<- (some (if-not (set "= \t\n") 1)))
    :val (<- (some (if-not (set "\n") 1)))
    :pair (* :key "=" :val)
    :sep (some (set " \t\n"))
    :main (some (* :pair (? :sep)))})

(peg/match kv-parser "name=Alice\nage=30")
# => @["name" "Alice" "age" "30"]
```

### Parse CSV

```janet
(def csv-parser
  ~{:field (+ (* `"` (<- (any (+ (/ `""` `"`) (if-not `"` 1)))) `"`)
              (<- (any (if-not (set ",\n") 1))))
    :row (group (* :field (any (* "," :field))))
    :main (some (* :row (? "\n")))})
```

### Extract Numbers from Text

```janet
(peg/match
  ~(any (+ (* (<- :d+) (? (* "." (<- :d+)))) 1))
  "price is 42.50 and qty is 3")
# => @["42" "50" "3"]
```

### Using cmt for Computed Captures

```janet
(peg/match
  ~(cmt (* (<- :d+) "+" (<- :d+))
        ,(fn [a b] (+ (scan-number a) (scan-number b))))
  "12+34")
# => @[46]
```

## Tips

- Prefer PEGs over string functions for anything beyond simple find/replace
- Use `'` (quote) with grammar structs to prevent evaluation: `'{:main ...}`
- Use `~` (quasiquote) when you need to splice Janet values into patterns: `~(* ,my-prefix :d+)`
- `(any 1)` matches the rest of the input
- `(to -1)` also matches to end of input
- PEGs are compiled to bytecode internally and are efficient for repeated use
- Use `(peg/compile patt)` if matching the same pattern many times
