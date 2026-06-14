# clixr library API

All helpers live in `lib/` and are sourced by every plugin.

## colors.sh
- Variables: `RED GREEN YELLOW BLUE MAGENTA CYAN WHITE GRAY` + bright `B*` + `BG_*` + styles `BOLD DIM ITALIC UNDERLINE REVERSE` + `RESET`
- `fg256 <0-255>` / `bg256 <0-255>` — 256-color
- `fgrgb <r> <g> <b>` / `bgrgb <r> <g> <b>` — truecolor
- `rainbow "text"` — rainbow output
- `gradient "text" <start256> <end256>` — gradient output
- `supports_color` — returns 0 if color is supported

## ui.sh
- Badges: `ui_ok ui_err ui_warn ui_info ui_step`
- `ui_box "title" "line" ...` — bordered box
- `ui_rule [label]` — horizontal divider
- `ui_header "text"` — gradient section header
- `ui_progress <cur> <total> [label]` — progress bar
- `ui_spin_start "msg"` / `ui_spin_stop "msg"` — spinner
- `ui_type "text" [delay]` — typewriter effect
- `ui_confirm "Question?"` — Y/n prompt (returns 0/1)
- `ui_menu "prompt" opt1 opt2 ...` — arrow-key menu (echoes index)

## platform.sh
- `detect_os` → termux|macos|linux|wsl|windows|unknown
- `detect_arch` `detect_shell` `detect_term`
- `has_cmd <cmd>` — existence check
- `pkg_install_cmd <pkg>` — platform install command
- `bin_install_dir` — where to symlink binaries

## utils.sh
- `require_cmd <cmd>` — dependency check with install hint
- `config_get <key>` / `config_set <key> <val>` — `~/.config/clixr/config`
- `human_bytes <n>` — pretty byte sizes
- `die "msg"` — error and exit

## network.sh
- `get_public_ip` `get_local_ip`
- `tcp_open <host> <port> [timeout]`
- `resolve_host <host>`
- `port_service <port>` — common port → name

## crypto.sh
- `hash_str <algo> <string>` / `hash_file <algo> <path>` (md5|sha1|sha256|sha512)
- `b64_encode` / `b64_decode`
- `rot13 <string>`
- `aes_encrypt <in> <out>` / `aes_decrypt <in> <out>`
- `gen_pass <length> [charset]`
