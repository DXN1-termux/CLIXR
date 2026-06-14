# Writing a clixr plugin

A plugin is just an executable script in `plugins/<category>/<name>`. The
dispatcher (`bin/clixr`) discovers it automatically — no registration needed.

## Categories

| Dir | Purpose |
|-----|---------|
| `net/`  | Networking & recon |
| `sec/`  | Security & crypto |
| `sys/`  | System management |
| `dev/`  | Developer productivity |
| `web/`  | Web & downloads |
| `rice/` | Customization & visuals |
| `fun/`  | Easter eggs |

## Template

```bash
#!/usr/bin/env bash
set -uo pipefail
: "${CLIXR_ROOT:=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
export CLIXR_LIB="$CLIXR_ROOT/lib"
. "$CLIXR_LIB/colors.sh"; . "$CLIXR_LIB/ui.sh"; . "$CLIXR_LIB/platform.sh"
. "$CLIXR_LIB/utils.sh"; . "$CLIXR_LIB/network.sh"; . "$CLIXR_LIB/crypto.sh"
# desc: One-line description shown in `clixr list`

# your logic here
ui_header "my tool"
ui_ok "it works"
```

## Rules

- The `# desc:` comment is what `clixr list` displays.
- Use the UI helpers (`ui_ok`, `ui_err`, `ui_box`, `ui_header`, `ui_progress`,
  `ui_spin_start`/`ui_spin_stop`, `ui_menu`, `ui_confirm`) for a consistent look.
- Validate dependencies with `require_cmd <cmd>` — it prints an install hint.
- Keep it POSIX-friendly where possible; the shebang is bash for arrays.
- Make the file executable: `chmod +x plugins/<cat>/<name>`.

## Running

```bash
clixr <name> [args]      # name is unique across categories
```
