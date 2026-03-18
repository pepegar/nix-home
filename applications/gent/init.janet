(import core/api :as api)
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
     :children [{:widget :editor :constraint 0.65}
                {:widget :git-status :constraint 0.35}]}])
