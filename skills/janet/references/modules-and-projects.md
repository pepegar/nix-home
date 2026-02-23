# Janet Modules and Project Management Reference

## Module System

### Importing Modules

```janet
(import mymod)                  # prefix: mymod/
(import mymod :as m)            # prefix: m/
(import mymod :prefix "")       # no prefix (use sparingly)
(import ./local)                # relative to current file
(import /from-cwd)              # relative to working directory (1.14.1+)
```

### Module Resolution Order

When `(import foo)` is called, Janet searches:

1. `foo.jimage` — pre-compiled image
2. `foo.janet` — source file
3. `foo/init.janet` — directory module
4. `foo.<native>` — native module (.so/.dylib/.dll)

The first match wins. Search paths are configured via `module/paths`.

### Writing Modules

Any `.janet` file is a module. Top-level `def`/`defn`/`var`/`defmacro` bindings are exported by default.

```janet
# mymod.janet

(def api-constant
  "Documented constant."
  1000)

(def- private-const :abc)        # not exported

(var *mutable-state*
  "Exported mutable binding."
  nil)

(var *internal* :private 123)    # not exported

(defn api-fn
  "Public function."
  [x]
  (+ x (helper x)))

(defn- helper
  "Private helper."
  [x]
  (* x 2))

(defmacro api-macro
  "Public macro."
  [& body]
  ~(do ,;body))
```

**Convention:** Use `*earmuffs*` for mutable module-level vars.

### Using a Module

```janet
(import mymod)

mymod/api-constant              # => 1000
(mymod/api-fn 10)               # => 30
mymod/*mutable-state*           # => nil
(set mymod/*mutable-state* 42)

# These fail:
mymod/private-const             # error
(mymod/helper 10)               # error
```

### Pre-loading Modules

Bypass the file system by adding to `module/cache`:

```janet
(put module/cache "mymod" (dofile "some/path.janet"))
(import mymod)
```

### Custom Module Loaders

```janet
# Add URL loading support
(defn- load-url [url args]
  (def p (os/spawn ["curl" url "-s"] :p {:out :pipe}))
  (def res (dofile (p :out) :source url ;args))
  (:wait p)
  res)

(defn- check-http [path]
  (if (string/has-prefix? "https://" path) path))

(array/push module/paths [check-http :janet-http])
(put module/loaders :janet-http load-url)

# Now works:
(import https://example.com/lib.janet)
```

---

## Dynamic Bindings

Thread-local / fiber-local variables set with `setdyn` / `dyn`:

```janet
(setdyn :my-config {:debug true})
(dyn :my-config)                    # => {:debug true}
```

Common built-in dynamic bindings:
- `*args*` — command-line arguments
- `*current-file*` — current source file path
- `*syspath*` — Janet system module path
- `*out*` — standard output
- `*err*` — standard error

Dynamic bindings are inherited by child fibers and can be overridden:

```janet
(setdyn :level :info)
(ev/spawn
  (setdyn :level :debug)     # override in this task only
  (print (dyn :level)))       # => :debug
(print (dyn :level))          # => :info
```

---

## jpm (Janet Project Manager)

### Installation

```bash
# Install jpm itself
sudo janet -e '(import jpm) (jpm/install "jpm")'

# Or from source
git clone https://github.com/janet-lang/jpm
cd jpm && janet bootstrap.janet
```

### project.janet

Every Janet project has a `project.janet` file:

```janet
(declare-project
  :name "my-project"
  :description "A Janet project"
  :dependencies ["https://github.com/janet-lang/spork.git"])

# Declare an executable
(declare-executable
  :name "my-app"
  :entry "src/main.janet")

# Declare a library (installable module)
(declare-source
  :source ["src/mylib.janet"])

# Declare a native module
(declare-native
  :name "my-native"
  :source ["src/native.c"])
```

### Common jpm Commands

```bash
jpm deps              # install dependencies
jpm build             # compile executables/natives
jpm test              # run test/ directory
jpm install           # install project globally
jpm clean             # remove build artifacts
jpm run rule          # run a custom rule
jpm quickbin main.janet output  # quick compile to binary
```

### Project Structure Convention

```
my-project/
├── project.janet
├── src/
│   ├── main.janet          # entry point
│   └── mylib.janet         # library module
├── test/
│   ├── test-basic.janet    # tests (run by jpm test)
│   └── test-advanced.janet
└── README.md
```

### Dependencies

```janet
(declare-project
  :dependencies [
    "https://github.com/janet-lang/spork.git"
    "https://github.com/andrewchambers/janet-sh.git"
  ])
```

Install with `jpm deps`. Dependencies are installed globally to `JANET_MODPATH`.

### Building Standalone Executables

```bash
# Quick single-file compile
jpm quickbin script.janet my-app

# Via project.janet
jpm build
# Output in build/ directory
```

The resulting binary is statically linked and self-contained.

### Testing

Tests are `.janet` files in the `test/` directory. They run top-to-bottom; a non-zero exit code indicates failure.

```janet
# test/test-math.janet
(import ../src/mylib)

(assert (= (mylib/add 1 2) 3) "addition works")
(assert (= (mylib/mul 3 4) 12) "multiplication works")
```

For snapshot testing, use the `judge` library:

```janet
(use judge)

(test (mylib/add 1 2) 3)
(test-stdout (mylib/greet "world") `
  Hello, world!
`)
```

---

## Compilation and Images

Janet can compile source to `.jimage` files (serialized environments):

```bash
janet -c source.janet output.jimage
janet output.jimage   # run the image
```

Top-level code runs at compile time; `main` runs at load time:

```janet
# Embed file contents at compile time
(def data (slurp "big-file.txt"))

(defn main [& args]
  (print (length data) " bytes loaded"))
```

### Marshaling

Values serialized into images must be marshalable. Most values are, except:
- Open file handles (`core/file`)
- Some abstract C types

Use scoped bindings to keep non-marshalable values out of the environment:

```janet
(def contents
  (with [f (file/open "data.txt")]
    (file/read f :all)))
# f is not in the top-level environment; contents (a string) is marshalable
```

---

## Scripting

### Shebang Scripts

```janet
#!/usr/bin/env janet

(defn main [& args]
  (each arg args
    (print arg)))
```

### Command-Line Arguments

```janet
(defn main [& args]
  (print "program: " (first args))
  (print "args: " (string/join (drop 1 args) " ")))
```

Or use `*args*` dynamic binding at top level.

### Shell Commands

```janet
# os/execute — run and wait
(os/execute ["ls" "-la"] :p)

# os/spawn — run async
(def proc (os/spawn ["long-task"] :p {:out :pipe}))
(def output (ev/read (proc :out) :all))
(:wait proc)
```

For richer shell scripting, install the `sh` library:

```bash
jpm install sh
```

```janet
(import sh)

(sh/$ echo "hello" | tr "a-z" "A-Z")
(def output (sh/$< ls -la))
(when (sh/$? test -f "file.txt")
  (print "exists"))
```

### Environment Variables

```janet
(os/getenv "HOME")
(os/setenv "MY_VAR" "value")
```

### File System

```janet
(os/stat "file.txt")             # file info or nil
(os/dir ".")                     # directory listing
(os/mkdir "new-dir")
(os/rename "old" "new")
(os/rm "file.txt")
(slurp "file.txt")               # read entire file as string
(spit "file.txt" "contents")     # write entire file
```
