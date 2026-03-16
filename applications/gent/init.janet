# Set claude-opus-4-6 as the default model
(import core/api :as api)
(api/set-model "claude-opus-4-6")

# Custom dark theme with darker edit_file styling
(import widgets/chat :as chat)
(import widgets/editor :as editor)
(import widgets/filepicker :as fp)
(import core/widget :as widget)
(import tui)

(chat/set-theme :dark)
(chat/set-colors @{
                   :diff-red-fg (tui/style :fg [:rgb 255 160 180] :bg [:rgb 40 20 25])
                   :diff-green-fg (tui/style :fg [:rgb 180 255 180] :bg [:rgb 15 40 25])
                   :tool-success-bg (tui/style :bg [:rgb 15 40 25])
                   :tool-error-bg (tui/style :bg [:rgb 40 20 25])})


# ── Git status filepicker ─────────────────────────────────────

(def goodnotes-root (string (os/getenv "HOME") "/projects/github.com/GoodNotes/GoodNotes-5/"))

(defn- open-file [item]
  "Open a file from git status output. Uses IntelliJ IDEA for GoodNotes files,
   $EDITOR in a Zellij floating pane if inside Zellij, or $EDITOR directly."
  # git status --short prefixes with 2-char status + space
  (def path (string/trim (string/slice item 3)))
  (def abs-path (string (os/cwd) "/" path))
  (cond
    # GoodNotes project → open in IntelliJ IDEA
    (string/has-prefix? goodnotes-root abs-path)
    (process/exec "open" ["-a" "IntelliJ IDEA" abs-path])

    # Inside Zellij → open in floating pane
    (os/getenv "ZELLIJ")
    (process/exec "zellij" ["run" "-f" "--" (os/getenv "EDITOR" "vi") path])

    # Fallback → open in $EDITOR directly
    (process/exec (os/getenv "EDITOR" "vi") [path])))

(widget/register
  (fp/create :name :git-status
             :title "Git Status"
             :source "git status --short"
             :on-enter open-file
             :refresh-ms 3000))

# Layout: chat on top, editor (60%) + git-status (40%) on bottom
(widget/set-layout-data
  @[{:constraint :fill
     :children [{:widget :chat :constraint :fill}]}
    {:constraint |(editor/get-height)
     :children [{:widget :editor :constraint 0.6}
                {:widget :git-status :constraint 0.4}]}])

# ── Orchestrator ──────────────────────────────────────────────

(import orchestrator)

(def- home (os/getenv "HOME"))

(orchestrator/register-worker :home-manager
  {:path (string home "/.config/home-manager") :port 7001})

(orchestrator/register-worker :math-vault
  {:path (string home "/Library/Mobile Documents/iCloud~md~obsidian/Documents/Math") :port 7002})

(orchestrator/register-worker :goodnotes-vault
  {:path (string home "/Library/Mobile Documents/iCloud~md~obsidian/Documents/Goodnotes") :port 7003})

(orchestrator/register-worker :goodnotes
  {:path (string home "/projects/github.com/GoodNotes/GoodNotes-5") :port 7004})

(orchestrator/register-worker :gent
  {:path (string home "/projects/github.com/pepegar/gent") :port 7005})
