# Plugins, Themes & Snippets

## Plugins

| Command | Description | Key options |
|---------|-------------|-------------|
| `plugins` | List plugins | `filter=core\|community`, `versions`, `format=json\|tsv\|csv` |
| `plugins:enabled` | List enabled plugins | same as above |
| `plugin` | Plugin info | `id=` (required) |
| `plugin:enable` | Enable plugin | `id=` (required) |
| `plugin:disable` | Disable plugin | `id=` (required) |
| `plugin:install` | Install community plugin | `id=` (required), `enable` |
| `plugin:uninstall` | Uninstall plugin | `id=` (required) |
| `plugin:reload` | Reload plugin (dev) | `id=` (required) |
| `plugins:restrict` | Toggle restricted mode | `on`, `off` |

## Themes

| Command | Description | Key options |
|---------|-------------|-------------|
| `themes` | List installed themes | `versions` |
| `theme` | Active theme info | `name=` |
| `theme:set` | Set theme | `name=` (required) |
| `theme:install` | Install theme | `name=` (required), `enable` |
| `theme:uninstall` | Uninstall theme | `name=` (required) |

## CSS Snippets

| Command | Description |
|---------|-------------|
| `snippets` | List CSS snippets |
| `snippets:enabled` | List enabled snippets |
| `snippet:enable` | Enable snippet (`name=`) |
| `snippet:disable` | Disable snippet (`name=`) |
