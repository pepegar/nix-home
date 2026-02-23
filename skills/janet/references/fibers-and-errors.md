# Janet Fibers, Error Handling, and Concurrency Reference

## Fibers (Coroutines)

Fibers are Janet's coroutines — pausable call stacks that enable cooperative multitasking.

### Creating and Using Fibers

```janet
(def f (fiber/new (fn []
                    (yield 1)
                    (yield 2)
                    3)))

(resume f)           # => 1
(resume f)           # => 2
(resume f)           # => 3
(fiber/status f)     # => :dead
```

### Fiber Status

| Status | Meaning |
|--------|---------|
| `:new` | Created but never resumed |
| `:pending` | Yielded, waiting to resume |
| `:alive` | Currently running |
| `:dead` | Finished normally |
| `:error` | Terminated with error |
| `:debug` | Suspended in debugger |
| `:user0` - `:user9` | Custom signal states |

### Passing Values In and Out

```janet
(def f (fiber/new (fn []
                    (def x (yield :hello))
                    (print "got " x)
                    :done)))

(resume f)           # => :hello
(resume f :world)    # prints "got world", => :done
```

### Fiber Flags

Flags control which signals a fiber traps vs propagates:

```janet
(fiber/new fn :e)    # trap errors
(fiber/new fn :t)    # trap all (debug) signals
(fiber/new fn :p)    # trap all non-error signals
(fiber/new fn :i)    # trap interrupts
(fiber/new fn :tp)   # combine flags
```

---

## Error Handling

### error / try

```janet
(error "something went wrong")
(error {:type :validation :msg "bad input"})  # any value as error

(try
  (do-risky-thing)
  ([err]
    (print "error: " err)))

(try
  (do-risky-thing)
  ([err fib]                    # also capture the fiber
    (print "error: " err)
    (debug/stacktrace fib)))
```

### protect

Like `try` but returns `[flag result]`:

```janet
(def [ok? result] (protect (do-risky-thing)))
(if ok?
  (print "success: " result)
  (print "error: " result))
```

### defer

Ensures cleanup code runs regardless of how the scope exits:

```janet
(defer (print "cleanup!")
  (risky-operation))

# Practical: file cleanup
(defer (:close conn)
  (query conn "SELECT ..."))
```

`defer` catches all signals (including errors) and re-propagates after cleanup.

### with

Resource management (like Python's `with`):

```janet
(with [f (file/open "data.txt")]
  (file/read f :all))
# f is automatically closed
```

### propagate

Re-raise a caught error or signal:

```janet
(try
  (something)
  ([err fib]
    (log err)
    (propagate err fib)))    # re-raise
```

### Custom Signals

```janet
(signal :user0 "custom payload")

# Catch with fiber flags
(def f (fiber/new
         (fn [] (signal :user4 :data))
         :u))  # :u flag = trap user signals
(resume f)     # => :data
(fiber/status f)  # => :user4
```

---

## Event Loop

Janet's event loop enables concurrent I/O within a single thread via cooperative scheduling.

### ev/spawn

```janet
(ev/spawn
  (print "task 1 start")
  (ev/sleep 1)
  (print "task 1 done"))

(ev/spawn
  (print "task 2 start")
  (ev/sleep 0.5)
  (print "task 2 done"))

# Both run concurrently on the event loop
```

### ev/go

Lower-level than `ev/spawn` — takes a fiber directly:

```janet
(ev/go (fiber/new (fn []
                    (ev/sleep 1)
                    (print "done"))))
```

### ev/sleep

```janet
(ev/sleep 1)         # sleep 1 second (yields to event loop)
(ev/sleep 0)         # yield to other tasks
```

**Warning:** `os/sleep` blocks the entire thread. Always use `ev/sleep` in async code.

### Channels

FIFO queues for inter-task communication within a thread:

```janet
(def ch (ev/chan 10))   # buffered channel (capacity 10)
(def ch (ev/chan))       # unbuffered

# Producer
(ev/spawn
  (for i 0 10
    (ev/give ch i)
    (ev/sleep 0.1)))

# Consumer
(ev/spawn
  (forever
    (def item (ev/take ch))
    (print "got: " item)))
```

- `ev/give` blocks when channel is full (backpressure)
- `ev/take` blocks when channel is empty
- Channels work within a single thread only

### ev/select

Wait on multiple channels:

```janet
(def [which value] (ev/select ch1 ch2 ch3))
```

### Streams (Async I/O)

```janet
(ev/read stream n)          # read up to n bytes
(ev/chunk stream n)         # read exactly n bytes
(ev/write stream data)      # write bytes
(:read stream n)            # method syntax
(:write stream data)
```

### Networking

```janet
# TCP server
(def server (net/listen "127.0.0.1" "8080"))
(forever
  (def conn (net/accept server))
  (ev/spawn
    (defer (:close conn)
      (def data (ev/read conn 1024))
      (ev/write conn "HTTP/1.1 200 OK\r\n\r\nHello"))))

# TCP client
(with [conn (net/connect "127.0.0.1" "8080")]
  (ev/write conn "GET / HTTP/1.1\r\n\r\n")
  (print (ev/read conn 4096)))
```

### Cancellation

```janet
(def task (ev/spawn (ev/sleep 10000)))
(ev/sleep 2)
(ev/cancel task "timed out")
```

### Supervisor Channels

Monitor task completion/failure:

```janet
(def supervisor (ev/chan))

(ev/go (fiber/new
         (fn [] (error "boom"))
         :tp)
       nil
       supervisor)

(def [status fiber] (ev/take supervisor))
(print "task ended with: " status)
```

### Event Loop Pitfalls

1. **`file/` module blocks** — use `ev/read`/`ev/write` with streams instead
2. **`os/sleep` blocks** — use `ev/sleep`
3. **CPU-heavy loops block all tasks** — insert `(ev/sleep 0)` to yield
4. **`getline` blocks** — use `spork/netrepl` for interactive work with event loop
5. **Channels are single-thread only** — use `thread/` for cross-thread communication

### Threads

True OS threads for CPU-bound work:

```janet
(def t (thread/new (fn [parent]
                     # runs in separate OS thread
                     (thread/send parent :done))))

(thread/receive)  # => :done
```

Cross-thread communication uses `thread/send` and `thread/receive` (marshaling values).
