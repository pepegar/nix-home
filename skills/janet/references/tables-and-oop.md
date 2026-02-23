# Janet Tables, Prototypes, and Polymorphism Reference

## Table Fundamentals

Tables are Janet's mutable associative data structure, similar to JavaScript objects or Lua tables.

### Key Rules

- **Keys can be any value** except `nil` and `NaN`
- **Values cannot be `nil`** — setting a value to `nil` deletes the key
- No `has?` function needed: `(nil? (t :key))` indicates absence
- Keys are compared with value semantics for immutable types, identity for mutable types

```janet
(def t @{:name "Alice" :age 30 42 "number key"})
(t :name)                   # => "Alice"
(get t :missing :default)   # => :default
(put t :name "Bob")         # mutate
(put t :age nil)            # delete :age key
(keys t)                    # => @[:name 42]
(kvs t)                     # flat key-value array
```

### Table Operations

```janet
(table/clone t)              # shallow copy
(table/to-struct t)          # convert to immutable struct
(merge-into t other)         # merge other into t
(merge t1 t2)                # return new merged table
(table/rawget t key)         # bypass prototype chain
(table/getproto t)           # get prototype
(table/setproto t proto)     # set prototype
```

---

## Prototypes

Tables have an optional prototype — another table consulted when a key is not found.

### Basic Prototype Chain

```janet
(def animal-proto
  @{:speak (fn [self] (print (self :name) " says " (self :sound)))
    :type :animal})

(def dog (table/setproto
           @{:name "Rex" :sound "woof"}
           animal-proto))

(dog :type)                  # => :animal (from prototype)
(dog :name)                  # => "Rex" (from own table)
(:speak dog)                 # prints "Rex says woof"
```

### How Lookup Works

1. Check the table for the key
2. If not found and prototype exists, check prototype
3. Recurse up the chain (max ~1000 levels)
4. Return `nil` if not found anywhere

**`table/rawget`** bypasses the prototype chain:
```janet
(table/rawget dog :type)     # => nil (not on dog itself)
(dog :type)                  # => :animal (found via prototype)
```

**`next`** only enumerates the table's own keys, not prototype keys.

---

## Method Dispatch

The `:method` call syntax provides OOP-style method invocation:

```janet
(:method object arg1 arg2)
# Expands to: ((object :method) object arg1 arg2)
```

The object is looked up for the `:method` key (following prototypes), then the found function is called with the object as the first argument.

```janet
(def proto
  @{:greet (fn [self]
             (string "Hello, I'm " (self :name)))
    :set-name (fn [self name]
                (put self :name name)
                self)})

(def obj (table/setproto @{:name "Alice"} proto))

(:greet obj)                 # => "Hello, I'm Alice"
(:set-name obj "Bob")        # returns obj, now name is "Bob"
```

---

## OOP Patterns

### Pattern 1: Separate Prototype and Constructor

```janet
(def Dog-proto
  @{:speak (fn [self] (print (self :name) ": Woof!"))
    :fetch (fn [self item] (print (self :name) " fetches " item))})

(defn new-dog [name breed]
  (table/setproto @{:name name :breed breed} Dog-proto))

(def rex (new-dog "Rex" "Lab"))
(:speak rex)
```

### Pattern 2: Closure-Based (Encapsulation)

```janet
(defn make-counter [&opt start]
  (default start 0)
  (var n start)
  @{:inc (fn [self] (++ n))
    :dec (fn [self] (-- n))
    :value (fn [self] n)})

(def c (make-counter 10))
(:inc c)
(:value c)                   # => 11
```

### Pattern 3: Class Object

```janet
(def Dog
  @{:proto @{:speak (fn [self] (print (self :name) ": Woof!"))
             :type "Dog"}
    :new (fn [self name]
           (table/setproto @{:name name} (self :proto)))})

(def rex (:new Dog "Rex"))
(:speak rex)                 # prints "Rex: Woof!"
(rex :type)                  # => "Dog"
```

### Pattern 4: Inheritance

```janet
(def Animal-proto
  @{:describe (fn [self]
                (string (self :type) " named " (self :name)))})

(def Dog-proto
  (table/setproto
    @{:speak (fn [self] (print "Woof!"))
      :type "Dog"}
    Animal-proto))

(def Puppy-proto
  (table/setproto
    @{:play (fn [self] (print (self :name) " plays!"))
      :type "Puppy"}
    Dog-proto))

(def spot (table/setproto @{:name "Spot"} Puppy-proto))
(:describe spot)             # => "Puppy named Spot" (from Animal-proto)
(:speak spot)                # prints "Woof!" (from Dog-proto)
(:play spot)                 # prints "Spot plays!" (from Puppy-proto)
```

---

## Operator Overloading

Tables can override arithmetic and comparison operators via prototype methods:

### Supported Operators

| Operation | Method Key |
|-----------|-----------|
| `+` | `:+` |
| `-` | `:-` |
| `*` | `:*` |
| `/` | `:/` |
| `%` | `:%` |
| Unary `-` | `:-` (single arg) |
| `<` `>` `<=` `>=` | `:compare` |
| Polymorphic `=` | `:compare` (return 0) |

```janet
(def Vec2-proto
  @{:+ (fn [a b]
         (table/setproto
           @{:x (+ (a :x) (b :x))
             :y (+ (a :y) (b :y))}
           Vec2-proto))
    :- (fn [a b]
         (table/setproto
           @{:x (- (a :x) (b :x))
             :y (- (a :y) (b :y))}
           Vec2-proto))
    :compare (fn [a b]
               (compare (+ (a :x) (a :y))
                        (+ (b :x) (b :y))))})

(defn vec2 [x y]
  (table/setproto @{:x x :y y} Vec2-proto))

(def v (+ (vec2 1 2) (vec2 3 4)))
(v :x)                       # => 4
(v :y)                       # => 6
```

### Comparison Functions

Standard `=`, `<`, `>` do NOT use `:compare`. Use the polymorphic variants:

```janet
(compare= a b)    # polymorphic equality
(compare< a b)    # polymorphic less-than
(compare<= a b)   # polymorphic less-or-equal
(compare> a b)
(compare>= a b)
(compare a b)     # returns -1, 0, or 1
```

### Limitations

Cannot override on tables:
- `length`
- `next` (iteration)
- String conversion (`describe` / `string`)
- Standard comparison operators (`=`, `<`, `>`)

For full control over these, use abstract types (C API).

---

## Struct Prototypes

Immutable structs also support prototypes:

```janet
(def base (struct/with-proto {:type "base"} :extra true))
(base :type)                 # => "base"

# Useful for creating immutable "class instances"
(def proto {:greet |(string "Hi, " ($ :name))})
(def alice (struct/with-proto proto :name "Alice"))
(:greet alice)               # => "Hi, Alice"
```

---

## Polymorphism Tips

1. **Prefer plain functions over methods** — Janet's design favors `(operation data)` over `(:method data)`
2. **Use prototypes when you need shared behavior** across many similar tables
3. **Use `:method` syntax for OOP-style dispatch** — it's concise and prototype-aware
4. **Abstract types via C are more powerful** for custom types that need full operator/iteration support
5. **`table/rawget`** is useful to check if a method is defined directly on an object vs inherited
