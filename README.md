
# <div align="center"> MADE WITH ❤️ BY DXN1
<!-- ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ -->
<div align="center">

```
   ██████╗██╗     ██╗██╗  ██╗██████╗
  ██╔════╝██║     ██║╚██╗██╔╝██╔══██╗
  ██║     ██║     ██║ ╚███╔╝ ██████╔╝
  ██║     ██║     ██║ ██╔██╗ ██╔══██╗
  ╚██████╗███████╗██║██╔╝ ██╗██║  ██║
   ╚═════╝╚══════╝╚═╝╚═╝  ╚═╝╚═╝  ╚═╝
```

### `one command. sixty-two tools. every terminal.`

**A single, beautiful CLI that swallows your junk-drawer of shell scripts whole —
networking, security, system, dev, web, and ricing tools that run the same on
your phone as they do on your laptop.**

<br/>

<p>
  <a href="#-install"><img src="https://img.shields.io/badge/⚡_INSTALL-1_command-00d9ff?style=for-the-badge&labelColor=0d1117" alt="install"></a>
  <a href="#-the-arsenal"><img src="https://img.shields.io/badge/🧰_TOOLS-62-ff2e97?style=for-the-badge&labelColor=0d1117" alt="tools"></a>
  <a href="#-write-your-own"><img src="https://img.shields.io/badge/🔌_PLUGINS-hackable-a371f7?style=for-the-badge&labelColor=0d1117" alt="plugins"></a>
</p>

<p>
  <img alt="platforms" src="https://img.shields.io/badge/Termux-000?style=flat-square&logo=android&logoColor=3ddc84">
  <img alt="macos" src="https://img.shields.io/badge/macOS-000?style=flat-square&logo=apple&logoColor=fff">
  <img alt="linux" src="https://img.shields.io/badge/Linux-000?style=flat-square&logo=linux&logoColor=fcc624">
  <img alt="wsl" src="https://img.shields.io/badge/WSL-000?style=flat-square&logo=windows&logoColor=0078d6">
  <img alt="bash" src="https://img.shields.io/badge/bash-000?style=flat-square&logo=gnubash&logoColor=4eaa25">
  <img alt="dependencies" src="https://img.shields.io/badge/deps-near_zero-000?style=flat-square">
  <img alt="license" src="https://img.shields.io/badge/license-MIT-000?style=flat-square">
  <img alt="version" src="https://img.shields.io/badge/version-0.2.0-000?style=flat-square">
  <img alt="prs" src="https://img.shields.io/badge/PRs-welcome-00d9ff?style=flat-square">
</p>

<sub>

[**Install**](#-install) · [**Why**](#-why-clixr-exists) · [**Arsenal**](#-the-arsenal) · [**Usage**](#-usage) · [**Recipes**](#-recipes) · [**Themes**](#-themes) · [**Plugins**](#-write-your-own) · [**Architecture**](#-architecture) · [**FAQ**](#-faq) · [**Contributing**](#-contributing)

</sub>

</div>

<!-- ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ -->
<br/>

> Every terminal jockey ends up with the same mess: a `~/bin` full of half-remembered
> scripts, a `.bashrc` that's 600 lines of aliases, and a Notes app full of one-liners
> you copy-paste and never quite recall. **clixr** is the cure. One command, one
> consistent look, one place for the stuff you reach for every day — and it travels
> with you from your laptop to a phone running Termux on a train.

<div align="center">

| | | |
|:--:|:--:|:--:|
| 🚀 **One install** | 🎨 **Actually pretty** | 🪶 **Featherweight** |
| Everything bundled. No per-tool setup, no package soup. | Boxes, gradients, spinners, 256-color, truecolor — consistent everywhere. | Pure bash + coreutils. Heavy extras are optional and auto-detected. |
| 🔌 **Modular** | 🌍 **Truly portable** | ♻️ **Self-updating** |
| Drop a file in `plugins/`, and it's a command. No registration. | Termux · macOS · Linux · WSL — same behavior, same keystrokes. | `clixr update` fast-forwards from git and shows you what changed. |

</div>

<!-- ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ -->
<br/>

## 💡 Why clixr exists

I live in the terminal — a lot of it on a phone over SSH or in Termux. Over the
years I collected dozens of little scripts: a port scanner here, a password
generator there, a JSON pretty-printer I rewrote four times. They were scattered,
inconsistent, and half of them broke the moment I switched machines because they
assumed `pbcopy` existed, or `python3`, or GNU `sed`.

clixr is the answer to a simple question: **what if all of that lived behind one
command, looked the same everywhere, and just worked on whatever box I happened to
be on?** No Node runtime to install. No Python virtualenv. No "works on my machine."
If `bash` is there, clixr is there.

It's intentionally boring under the hood — plain shell, no magic — so it's easy to
read, easy to fork, and easy to trust. The fun part is on the surface.

<!-- ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ -->
<br/>

## ⚡ Install

```bash
git clone https://github.com/DXN1-termux/clixr.git
cd clixr && bash install.sh
```

The installer figures out your platform, checks what's available, links `clixr`
onto your `PATH`, and (optionally) walks you through picking a theme and wiring up
shell completions. Thirty seconds, tops.

<details>
<summary><b>📱 Termux (Android)</b></summary>

```bash
pkg install git
git clone https://github.com/DXN1-termux/clixr.git
cd clixr && bash install.sh
```

Termux is a first-class target, not an afterthought — package install hints,
storage paths, and the binary directory are all detected correctly.
</details>

<details>
<summary><b>🍎 macOS &nbsp;·&nbsp; 🐧 Linux — one-liner</b></summary>

```bash
git clone https://github.com/DXN1-termux/clixr.git && cd clixr && bash install.sh
```

On macOS the BSD variants of `sed`, `awk`, and the hashing tools are handled, so
you don't need to `brew install coreutils` first.
</details>

<details>
<summary><b>🪟 Windows (WSL)</b></summary>

```powershell
wsl -e bash -c "git clone https://github.com/DXN1-termux/clixr.git && cd clixr && bash install.sh"
```
</details>

<details>
<summary><b>🎛️ Flags, updating &amp; removal</b></summary>

```bash
bash install.sh --full        # install everything, skip every prompt
bash install.sh --no-wizard   # install, but skip the theme/shell setup
bash install.sh --uninstall   # remove the clixr symlink (repo stays put)
clixr update                  # fast-forward from git + print the changelog
clixr doctor                  # sanity-check deps & environment
make check                    # syntax-check every script in the repo
```
</details>

What you'll see:

```
  ╭─────────────────────────────────────────────╮
  │ environment                                 │
  ├─────────────────────────────────────────────┤
  │ platform  termux (arm64)                    │
  │ shell     zsh                               │
  │ terminal  Termux                            │
  ╰─────────────────────────────────────────────╯

   net tools   ████████████████████████████  100%
   ...
  ╭─────────────────────────────────────────────╮
  │ ✨ clixr installed                          │
  │   clixr list      see all 62 tools          │
  │   clixr matrix    have fun                  │
  ╰─────────────────────────────────────────────╯
```

<!-- ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ -->
<br/>

## 🧰 The Arsenal

62 tools, 7 categories. `clixr list` shows them all; `clixr <category>` drills into one.

<details open>
<summary><b>🌐 net</b> — networking &amp; recon <code>(10)</code></summary>

| Tool | What it does |
|------|--------------|
| `portscan` | Fast TCP port scanner with service detection + live progress |
| `iplookup` | Geolocate any IP |
| `myip` | Your public IP, ISP, city, the works |
| `dns` | Forward / reverse DNS resolution |
| `ping-sweep` | Find live hosts across a /24 in parallel |
| `subdomain` | Enumerate subdomains from a wordlist |
| `ssl-check` | Inspect a site's TLS certificate & expiry |
| `banner-grab` | Pull a service banner off an open port |
| `http-headers` | Dump and inspect HTTP response headers |
| `traceroute` | Trace the path to a host |
</details>

<details>
<summary><b>🔐 sec</b> — security &amp; crypto <code>(9)</code></summary>

| Tool | What it does |
|------|--------------|
| `passgen` | Cryptographically strong passwords, any length/charset |
| `hash` | md5 / sha1 / sha256 / sha512 of a string or file |
| `encrypt` | AES-256 file encryption & decryption (openssl) |
| `b64` | Base64 encode / decode |
| `rot13` | The classic |
| `jwt` | Decode & pretty-print a JWT's header and payload |
| `wordlist` | Build a wordlist from base words (cases, years, symbols) |
| `vault` | A tiny encrypted note store |
| `wipe` | Multi-pass secure file shredding |
</details>

<details>
<summary><b>🖥️ sys</b> — system management <code>(9)</code></summary>

| Tool | What it does |
|------|--------------|
| `sysinfo` | A clean, full system report |
| `procs` | Top processes by CPU / memory |
| `cpu` | CPU & memory snapshot |
| `disk` | Disk usage at a glance |
| `ports` | What's listening, and who owns it |
| `clean` | Show (and optionally clear) caches & temp files |
| `logs` | Tail system logs with color |
| `watch` | Re-run any command on an interval |
| `env` | Searchable, readable environment variables |
</details>

<details>
<summary><b>🛠️ dev</b> — developer tools <code>(10)</code></summary>

| Tool | What it does |
|------|--------------|
| `serve` | Instant static HTTP server — prints a LAN URL for your phone |
| `json` | Pretty-print & validate JSON (jq or python, whichever's around) |
| `gitx` | Repo stats, one-shot commits, painless undo |
| `qr` | A QR code, right in the terminal |
| `regex` | Test a pattern against input, highlighted |
| `port` | Find what's holding a port — and kill it if you want |
| `diff` | A diff that's actually readable |
| `hex` | Hex dump a file or a string |
| `todo` | A persistent, no-nonsense task list |
| `ssh-keys` | List your keys, fingerprints, and configured hosts |
</details>

<details>
<summary><b>🕸️ web</b> — web &amp; downloads <code>(10)</code></summary>

| Tool | What it does |
|------|--------------|
| `curl` | **Fancy HTTP client** — methods, headers, JSON, status/timing/size |
| `ip` | Public + local IP, instantly |
| `dl` | Download with a real progress bar |
| `api` | Fire API requests with pretty JSON output |
| `whois` | Domain WHOIS lookup |
| `headers` | Grade a site's security headers |
| `speed` | Quick download-speed test |
| `cert` | Generate a self-signed TLS cert in one line |
| `rss` | Read an RSS feed without leaving the shell |
| `paste` | Pipe anything to a pastebin, get a URL back |
</details>

<details>
<summary><b>🎨 rice</b> — customization &amp; visuals <code>(7)</code></summary>

| Tool | What it does |
|------|--------------|
| `theme` | Switch between 8 hand-tuned palettes |
| `fetch` | A neofetch-style splash, but lighter |
| `colortest` | Every one of the 256 colors, laid out |
| `matrix` | Digital rain. Obviously. |
| `pipes` | The pipes screensaver, reborn |
| `clock` | A big, calm terminal clock |
| `banner` | Gradient text banners for scripts & MOTDs |
</details>

<details>
<summary><b>🎉 fun</b> — easter eggs <code>(7)</code></summary>

| Tool | What it does |
|------|--------------|
| `hack` | The Hollywood "I'm in" animation |
| `glitch` | Glitch-corrupt any text |
| `rainbow` | 🌈 |
| `cowsay` | A cow says your thing |
| `ascii` | Text → ASCII art banner |
| `fortune` | Hacker wisdom, served at random |
| `weather` | A tidy weather report via wttr.in |
</details>

<!-- ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ -->
<br/>

## 🚀 Usage

```bash
clixr <tool> [args]      # run a tool
clixr <category>         # browse one category (net, sec, sys, dev, web, rice, fun)
clixr list               # everything, grouped
clixr help               # the full help screen
```

<table>
<tr><th align="left">Command</th><th align="left">Result</th></tr>
<tr><td><code>clixr sysinfo</code></td><td>A clean system report</td></tr>
<tr><td><code>clixr portscan 192.168.1.1 1-1000</code></td><td>Scan a host with a live progress bar + results table</td></tr>
<tr><td><code>clixr passgen 32</code></td><td>A 32-char strong password</td></tr>
<tr><td><code>clixr hash sha256 file.txt</code></td><td>SHA-256 of a file</td></tr>
<tr><td><code>clixr serve 8080</code></td><td>Serve the current dir; prints a phone-ready LAN URL</td></tr>
<tr><td><code>clixr qr "https://x.com"</code></td><td>A scannable QR code in your terminal</td></tr>
<tr><td><code>clixr jwt &lt;token&gt;</code></td><td>Decode a JWT's header + payload as JSON</td></tr>
<tr><td><code>clixr theme cyberpunk</code></td><td>Repaint your prompt</td></tr>
<tr><td><code>clixr matrix</code></td><td>🟢 …wake up, Neo.</td></tr>
</table>

If you mistype, clixr guesses what you meant:

```
$ clixr passgne
 ✗ Unknown command: passgne
   did you mean: passgen paste
```

After sourcing the shell init, you also get `cx` (alias for `clixr`), `cxl`
(`clixr list`), `cxf` (`clixr fetch`), and tab-completion for every tool.

<!-- ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ -->
<br/>

## 🍳 Recipes

Real things people actually do with it.

**Audit a box you just SSH'd into**
```bash
clixr sysinfo && clixr ports && clixr procs 5
```

**Spin up a quick share to your phone**
```bash
clixr serve 8080        # then scan the LAN URL it prints with...
clixr qr "http://$(clixr ip | grep Local | awk '{print $NF}'):8080"
```

**Check a domain before you trust it**
```bash
clixr whois example.com
clixr ssl-check example.com
clixr headers https://example.com
```

**Lock something down**
```bash
clixr passgen 40 | clixr paste     # generate + stash a secret
clixr encrypt enc secrets.txt secrets.enc && clixr wipe secrets.txt
```

**Make your shell greet you**
```bash
# in ~/.bashrc
clixr fetch
clixr fortune
```

<!-- ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ -->
<br/>

## 🎨 Themes

Eight palettes, switchable in one command:

<div align="center">

`dracula` · `cyberpunk` · `nord` · `gruvbox` · `matrix` · `tokyonight` · `catppuccin` · `synthwave`

</div>

```bash
clixr theme              # list them + show your current pick
clixr theme synthwave    # set it
```

Your choice is remembered. If you let the installer wire up the shell init (or you
add `source /path/to/clixr/clixr.sh` to your rc yourself), the theme is applied to
your prompt automatically on every new shell.

<!-- ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ -->
<br/>

## 🔌 Write Your Own

This is the part I'm proudest of. A plugin is just an executable file dropped into
`plugins/<category>/<name>`. The dispatcher finds it automatically — there's nothing
to register, nothing to rebuild.

```bash
#!/usr/bin/env bash
set -uo pipefail
: "${CLIXR_ROOT:=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
export CLIXR_LIB="$CLIXR_ROOT/lib"
. "$CLIXR_LIB/colors.sh"; . "$CLIXR_LIB/ui.sh"
# desc: greet the world          ← this line shows up in `clixr list`

ui_header "hello"
ui_ok "it works, instantly"
```

```bash
chmod +x plugins/fun/hello && clixr hello
```

Every plugin can lean on the same UI kit the built-ins use — panels, tables,
spinners, gradients, prompts, progress bars — so your tool looks like it belongs.
The full helper reference is in [`docs/api.md`](docs/api.md), and a short authoring
guide lives in [`docs/plugins.md`](docs/plugins.md).

<!-- ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ -->
<br/>

## 🏗️ Architecture

```
clixr/
├── bin/clixr            ← the dispatcher: discovery, help, doctor, update
├── lib/                 ← the shared engine, sourced by every tool
│   ├── ui.sh            · panels, tables, spinners, bars, menus, prompts
│   ├── colors.sh        · 256-color, truecolor, rainbow, multi-stop gradients
│   ├── platform.sh      · OS / arch / shell detection + package hints
│   ├── utils.sh         · config store, dependency checks, helpers
│   ├── network.sh       · ip, tcp, dns primitives
│   └── crypto.sh        · hashing, base64, aes, password generation
├── plugins/             ← the 62 tools, grouped by category
│   └── net/ sec/ sys/ dev/ web/ rice/ fun/
├── themes/              ← 8 color schemes
├── docs/                ← api reference, plugin guide, gallery
├── install.sh           ← the animated installer + first-run wizard
├── uninstall.sh · update.sh
├── clixr.sh             ← shell init: aliases + bash/zsh completion
└── Makefile · VERSION · CHANGELOG.md
```

**A few principles it sticks to:**

- **One look, everywhere.** Every tool draws from the same UI library, so output is
  consistent whether you're scanning ports or reading the weather.
- **Degrade gracefully.** Missing `jq`? It falls back to `python`. No `dig`? It uses
  `getent`. Tools check their dependencies at runtime and tell you exactly what to
  install if something's absent.
- **Least surprise.** Nothing needs root by default. Destructive things (`wipe`,
  `clean --force`) always ask first.
- **Readable on purpose.** It's plain bash. You can open any file and understand it
  in a minute. That's a feature, not a limitation.

<!-- ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ -->
<br/>

## 🗺️ Roadmap

- [x] Core dispatcher + shared UI engine
- [x] 62 tools across 7 categories
- [x] Animated installer, first-run wizard, self-update
- [x] 8 themes + shell completions
- [ ] A plugin marketplace — `clixr market install <plugin>`
- [ ] Terminal games (snake, 2048, tetris) under `fun/`
- [ ] Docker / kubernetes shortcuts
- [ ] Config profiles you can sync between machines
- [ ] Optional truecolor theme engine for the tool output itself

Got an idea? [Open an issue](https://github.com/DXN1-termux/clixr/issues) — the
roadmap is a conversation, not a contract.

<!-- ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ -->
<br/>

## ❓ FAQ

<details>
<summary><b>Does this need root / sudo?</b></summary>

No. Everything installs to your user bin directory and runs as you. A handful of
tools (like reading certain system logs) will simply show less if they can't see
privileged data — they won't ask for a password.
</details>

<details>
<summary><b>Will it slow down my shell startup?</b></summary>

The shell init (`clixr.sh`) only sets a couple of aliases, registers completion,
and applies your theme. It does not load the whole toolkit — plugins are only read
when you actually run one.
</details>

<details>
<summary><b>I don't have <code>jq</code> / <code>dig</code> / <code>nc</code>. Is that a problem?</b></summary>

Not usually. Tools fall back to alternatives where they can (`python` for JSON,
`getent` for DNS, `/dev/tcp` for port checks). When a tool truly needs something,
it prints the exact install command for your platform.
</details>

<details>
<summary><b>Is the recon stuff legal to use?</b></summary>

The networking tools (`portscan`, `ping-sweep`, `subdomain`, `banner-grab`, …) are
for systems you own or are explicitly authorized to test. Point them at your own
boxes, your lab, or your CTF target — not someone else's network. Use responsibly.
</details>

<details>
<summary><b>How do I add my own tool?</b></summary>

Drop an executable script in <code>plugins/&lt;category&gt;/</code> with a
<code># desc:</code> line. That's the whole process — see
<a href="#-write-your-own">Write Your Own</a>.
</details>

<details>
<summary><b>How do I uninstall it cleanly?</b></summary>

<code>bash install.sh --uninstall</code> removes the symlink. Delete the cloned
folder and you're back to exactly where you started — clixr keeps its config in
<code>~/.config/clixr</code>, which you can remove too.
</details>

<!-- ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ -->
<br/>

## 🩺 Troubleshooting

| Symptom | Fix |
|---------|-----|
| `clixr: command not found` after install | Your bin dir isn't on `PATH`. The installer prints the exact `export PATH=…` line — add it to your rc. |
| Colors look like `\033[...` garbage | Your terminal isn't in a 256-color mode. Try `export TERM=xterm-256color`. |
| A tool says a dependency is missing | Run the install command it suggests, or `clixr doctor` to see the full picture. |
| Animations look choppy over SSH | That's latency, not clixr. The static views (`list`, `sysinfo`) are unaffected. |

<!-- ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ -->
<br/>

## 🤝 Contributing

Pull requests are genuinely welcome — especially new plugins. The bar is low on
purpose: if it's a useful little tool and it follows the template, it belongs here.

1. Fork & branch — `git checkout -b feat/my-tool`
2. Drop your script in `plugins/<category>/`, add a `# desc:` line, `chmod +x` it
3. Run `make check` to lint every script
4. Open a PR and tell us what it does

See [`CONTRIBUTING.md`](CONTRIBUTING.md) for the finer points, and
[`CHANGELOG.md`](CHANGELOG.md) for what's changed.

<!-- ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ -->
<br/>

## 🙏 Acknowledgements

Built on the shoulders of the usual giants — `bash`, `coreutils`, `openssl`,
`curl` — and inspired by the tools that made the terminal feel like home:
neofetch, ripgrep, fzf, and a hundred dotfiles repos I've lost in browser tabs.

## 📄 License

[MIT](LICENSE) — do whatever you like, just keep the notice.

<br/>

<div align="center">

### `built for people who never leave the terminal`

<sub>if it saved you a few keystrokes, drop a ⭐ — it genuinely helps.</sub>

</div>
