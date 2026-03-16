# orchestrator.janet — Coordinate multiple headless gent workers.
#
# Registers tools (list_workers, delegate, worker_status,
# worker_conversation) so the lead gent's LLM can dispatch tasks to
# headless worker gents running in other repos/worktrees.
#
# Usage in ~/.gent/init.janet:
#   (import orchestrator)
#   (orchestrator/register-worker :auth {:path "/abs/path/to/auth" :port 7001})
#   (orchestrator/register-worker :frontend {:path "/abs/path/to/frontend" :port 7002})

(import core/tools :as tools)
(import core/commands :as commands)

# ── RPC Client ───────────────────────────────────────────────
# net/connect returns a Janet :core/stream. We use :write/:read/:close
# on the stream directly, with a line buffer for reading JSON-RPC
# responses (one JSON object per line).

(defn- stream-write
  "Write a line (with trailing newline) to a stream."
  [stream data]
  (try
    (do (:write stream (string data "\n")) true)
    ([_] false)))

(defn- stream-close
  "Close a stream."
  [stream]
  (try (:close stream) ([_] nil)))

# Per-stream read buffer for line reassembly
(def- read-bufs @{})

(defn- stream-read-line
  "Read a complete line from a stream. Buffers partial reads.
   Returns string (without newline), nil (no data yet), or :closed."
  [stream &opt timeout-s]
  (default timeout-s 0.05)
  # Get or create the buffer for this stream
  (def buf (or (get read-bufs stream) @""))
  (put read-bufs stream buf)
  # Check if we already have a complete line buffered
  (def nl (string/find "\n" buf))
  (when nl
    (def line (string/slice buf 0 nl))
    (def rest (buffer/slice buf (+ nl 1)))
    (put read-bufs stream rest)
    (break (string/trimr line)))
  # Try to read more data from the stream
  (try
    (do
      (def chunk (:read stream 4096 timeout-s))
      (if (or (nil? chunk) (= 0 (length chunk)))
        nil
        (do
          (buffer/push buf chunk)
          # Check again for a complete line
          (def nl2 (string/find "\n" buf))
          (when nl2
            (def line (string/slice buf 0 nl2))
            (def rest (buffer/slice buf (+ nl2 1)))
            (put read-bufs stream rest)
            (break (string/trimr line)))
          nil)))
    ([_] :closed)))

(defn rpc-call
  "Send a JSON-RPC request and wait for the response.
   Skips notifications (no id). Returns parsed response or nil on timeout."
  [conn method params &opt timeout-ms]
  (default timeout-ms 5000)
  (when (nil? conn) (break nil))
  (def id (math/floor (* (math/random) 1000000)))
  (def req (json/encode @{:jsonrpc "2.0" :id id :method method :params (or params @{})}))
  (unless (stream-write conn req) (break nil))
  (def deadline (+ (os/clock) (/ timeout-ms 1000)))
  (while (< (os/clock) deadline)
    (def remaining (- deadline (os/clock)))
    (def line (stream-read-line conn (min 0.1 remaining)))
    (when (= :closed line) (break nil))
    (when (and (string? line) (not= "" line))
      (def parsed (try (json/decode line) ([_] nil)))
      (when (and parsed (= (get parsed :id) id))
        (break parsed)))
    (os/sleep 0.01))
  nil)

(defn rpc-drain-notifications
  "Read and return pending notifications without blocking."
  [conn]
  (def notes @[])
  (when (nil? conn) (break notes))
  (var line (stream-read-line conn 0.01))
  (while (and (string? line) (not= "" line))
    (def parsed (try (json/decode line) ([_] nil)))
    (when (and parsed (nil? (get parsed :id)))
      (array/push notes parsed))
    (set line (stream-read-line conn 0.01)))
  notes)

# ── Worker Registry ──────────────────────────────────────────

(def- workers @{})

(defn register-worker
  "Register a named worker. Config: {:path string :port number :host string?}"
  [name config]
  (put workers name
    @{:name name
      :path (config :path)
      :port (config :port)
      :host (or (config :host) "127.0.0.1")
      :conn-id nil
      :status :stopped}))

(defn get-workers
  "Return the worker registry table."
  []
  workers)

(defn get-worker
  "Look up a worker by name (keyword)."
  [name]
  (get workers name))

# ── Worker Lifecycle ─────────────────────────────────────────

(defn connect-worker
  "Connect to a running worker. Returns true on success."
  [name]
  (def w (get workers name))
  (when (nil? w) (error (string "Unknown worker: " name)))
  (def conn (net/connect (w :host) (w :port)))
  (when (nil? conn)
    (put w :status :error)
    (break false))
  (put w :conn-id conn)
  (put w :status :running)
  true)

(defn spawn-worker
  "Start a headless gent in the worker's directory, then connect."
  [name]
  (def w (get workers name))
  (when (nil? w) (error (string "Unknown worker: " name)))
  (when (= (w :status) :running)
    (break :already-running))
  (def port (w :port))
  (def path (w :path))
  # Clean up any stale connection from a previous run
  (when (w :conn-id)
    (stream-close (w :conn-id))
    (put w :conn-id nil))
  # Spawn gent --headless in background, fully detached.
  # Uses nohup + fd closing to prevent the child from inheriting
  # our TCP socket FDs (which cause CLOSE_WAIT zombies).
  # Quote path for shell safety (spaces in iCloud paths, etc.)
  (def quoted-path (string "'" (string/replace-all "'" "'\\''" path) "'"))
  (def cmd (string "cd " quoted-path
                   " && nohup gent --headless --port " port
                   " </dev/null >/dev/null 2>&1 &"))
  (os/execute ["sh" "-c" cmd] :p)
  # Wait for it to be ready (retry connect)
  (var connected false)
  (var attempts 0)
  (while (and (not connected) (< attempts 20))
    (os/sleep 0.25)
    (set connected (connect-worker name))
    (++ attempts))
  (if connected
    :ok
    (do
      (put w :status :error)
      (error (string "Failed to connect to worker " name
                     " on port " port " after " attempts " attempts")))))

(defn ensure-worker
  "Spawn if stopped, reconnect if disconnected."
  [name]
  (def w (get workers name))
  (when (nil? w) (error (string "Unknown worker: " name)))
  (when (= (w :status) :running)
    # Verify connection is alive with a status check
    (def status (rpc-call (w :conn-id) "agent.status" @{} 2000))
    (when status (break :ok))
    # Connection dead — close the stale stream and reset fully
    (when (w :conn-id)
      (stream-close (w :conn-id)))
    (put w :status :stopped)
    (put w :conn-id nil))
  (spawn-worker name))

(defn stop-worker
  "Shutdown a worker gracefully via RPC."
  [name]
  (def w (get workers name))
  (when (nil? w) (break nil))
  (when (w :conn-id)
    (try (rpc-call (w :conn-id) "shutdown" @{} 2000) ([_] nil))
    (stream-close (w :conn-id)))
  (put w :conn-id nil)
  (put w :status :stopped)
  :ok)

(defn stop-all-workers
  "Shutdown all running workers."
  []
  (eachk name workers
    (when (= :running ((get workers name) :status))
      (stop-worker name))))

# ── Delegation ───────────────────────────────────────────────

(defn- extract-assistant-text
  "Extract text content from the last assistant message."
  [messages]
  (var last-assistant nil)
  (each msg messages
    (when (= "assistant" (get msg :role))
      (set last-assistant msg)))
  (when (nil? last-assistant) (break nil))
  (def content (get last-assistant :content))
  (if (string? content)
    content
    (string/join
      (seq [block :in content
            :when (= "text" (get block :type))]
        (get block :text ""))
      "\n")))

(defn delegate
  "Send a task to a named worker. Blocks until idle. Returns the worker's response."
  [name task &opt timeout-s]
  (default timeout-s 300)
  (ensure-worker name)
  (def w (get workers name))
  (def conn (w :conn-id))
  (when (nil? conn)
    (break (string "Worker " name " is not connected")))
  # Submit the task
  (def submit-resp (rpc-call conn "chat.submit" @{:text task} 5000))
  (when (nil? submit-resp)
    (break "Worker did not acknowledge task submission."))
  # Poll until idle
  (def deadline (+ (os/clock) timeout-s))
  (var final-mode nil)
  (while (< (os/clock) deadline)
    (os/sleep 0.5)
    # Drain notifications to prevent read-buffer buildup
    (rpc-drain-notifications conn)
    (def status (rpc-call conn "agent.status" @{} 3000))
    (when status
      (def mode (get-in status [:result :mode]))
      (set final-mode mode)
      (when (= "idle" mode) (break))))
  (when (not= "idle" final-mode)
    (break (string "Worker " name " did not finish within "
                   timeout-s "s (last mode: " final-mode ")")))
  # Fetch conversation and extract last assistant message
  (def conv (rpc-call conn "conversation.get" @{} 5000))
  (when (nil? conv) (break "Worker did not respond to conversation.get."))
  (def messages (get-in conv [:result :messages]))
  (when (or (nil? messages) (empty? messages))
    (break "Worker produced no messages."))
  (or (extract-assistant-text messages)
      "Worker produced no text response."))

# ── Tools for the LLM ───────────────────────────────────────

(tools/register "list_workers"
  {:description "List all registered worker gents and their current status (running/stopped), port, and working directory."
   :schema {:type "object" :properties {}}
   :function (fn [_input]
               (def lines @[])
               (eachp [name w] workers
                 (array/push lines
                   (string/format "%-20s  status:%-8s  port:%-5d  %s"
                     (string name) (string (w :status)) (w :port) (w :path))))
               (if (empty? lines)
                 "No workers registered. Use orchestrator/register-worker in init.janet."
                 (string/join (sort lines) "\n")))})

(tools/register "delegate"
  {:description (string "Delegate a task to a named worker gent. The worker is a full "
                        "coding agent (with bash, file editing, etc.) running in its own "
                        "repo/worktree. This blocks until the worker completes the task "
                        "and returns its final response. Be specific in the task description — "
                        "include any context the worker needs since it has its own conversation. "
                        "Use list_workers first to see available workers.")
   :schema {:type "object"
            :properties {:worker {:type "string"
                                  :description "Name of the worker (from list_workers)"}
                         :task {:type "string"
                                :description "The task to delegate. Be specific and include context."}}
            :required ["worker" "task"]}
   :function (fn [input]
               (def name (keyword (get input :worker)))
               (def task (get input :task))
               (try
                 (delegate name task)
                 ([err] (string "Delegation failed: " err))))})

(tools/register "worker_status"
  {:description "Check the current status of a worker (idle/streaming), token usage, and message count."
   :schema {:type "object"
            :properties {:worker {:type "string"
                                  :description "Name of the worker"}}
            :required ["worker"]}
   :function (fn [input]
               (def name (keyword (get input :worker)))
               (def w (get workers name))
               (when (nil? w) (break (string "Unknown worker: " name)))
               (when (not= (w :status) :running)
                 (break (string/format "%s is %s (port %d, path %s)"
                          (string name) (string (w :status)) (w :port) (w :path))))
               (def status (rpc-call (w :conn-id) "agent.status" @{} 3000))
               (if status
                 (json/encode (get status :result))
                 "Could not reach worker."))})

(tools/register "worker_conversation"
  {:description "Get the full conversation history from a worker. Useful to review what a worker did in detail."
   :schema {:type "object"
            :properties {:worker {:type "string"
                                  :description "Name of the worker"}}
            :required ["worker"]}
   :function (fn [input]
               (def name (keyword (get input :worker)))
               (def w (get workers name))
               (when (nil? w) (break (string "Unknown worker: " name)))
               (when (not= (w :status) :running)
                 (break (string name " is " (string (w :status)))))
               (def conv (rpc-call (w :conn-id) "conversation.get" @{} 5000))
               (if conv
                 (json/encode (get conv :result))
                 "Could not reach worker."))})

# ── Slash Commands ───────────────────────────────────────────

(commands/register "workers"
  {:description "List registered workers and their status"
   :function (fn [_]
               (def lines @[])
               (eachp [name w] workers
                 (array/push lines
                   (string/format "%s  %s  port:%d  %s"
                     (string name) (string (w :status)) (w :port) (w :path))))
               (if (empty? lines)
                 "No workers registered."
                 (string/join (sort lines) "\n")))})

(commands/register "spawn"
  {:description "Spawn a worker: /spawn <name>"
   :function (fn [args]
               (if (= "" args)
                 "Usage: /spawn <worker-name>"
                 (try
                   (do (spawn-worker (keyword args))
                       (string "Spawned " args))
                   ([err] (string "Error: " err)))))})

(commands/register "stop-worker"
  {:description "Stop a worker: /stop-worker <name>"
   :function (fn [args]
               (if (= "" args)
                 "Usage: /stop-worker <worker-name>"
                 (do (stop-worker (keyword args))
                     (string "Stopped " args))))})

(commands/register "stop-all-workers"
  {:description "Stop all running workers"
   :function (fn [_]
               (stop-all-workers)
               "All workers stopped.")})