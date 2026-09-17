# Full Repository Review — AdeoTEK Dotfiles

- **Date:** 2026-09-16
- **Fix pass:** 2026-09-16 — every `fix`/`manual fix` row below has been applied and re-verified; statuses updated accordingly. §G items remain rejected. Follow-up issues discovered during the fix pass are listed in §H.
- **Scope:** entire repo (`setup.sh`, `unattended_setup.sh`, `update.sh`, `_scripts/**`, all stowed config dirs, `tools/`, `win-tools/`, `opencode/`, `claude-code/`, `hermes/`, `headroom/`, `herdr/`, nvim lua, docs). Vendored code (`tmux/.config/tmux/plugins/**`) reviewed only for how the repo uses it.
- **Method:** 5 parallel review passes (entry points/helpers, install scripts, setup/deploy scripts, configs, non-shell tooling) + an over-engineering scan + shellcheck/bash -n baseline. High-severity findings re-verified by hand before publication.
- **Baseline:** `bash -n` clean on all 183 `.sh` files. `shellcheck -x`: **zero error/warning-level findings in `_scripts/`**; all error/warning output is either vendored tmux plugins or dialect false-positives (see §7).

## Legend

| Field | Values |
|---|---|
| Action | `fix` (apply the suggested change) · `manual fix` (needs a decision or manual testing first) · `do not fix` (intentional / false positive) |
| Status | `to do` · `in progress` · `done` · `rejected` |
| Severity | `high` (breaks something now / destructive) · `medium` (wrong behavior, hidden failure, or security exposure) · `low` (cosmetic, robustness, docs) |

## Summary

| Section | Findings | High | Medium | Low |
|---|---|---|---|---|
| A. Entry points, helpers, options | 28 | 1 | 8 | 19 |
| B. Install scripts | 30 | 4 | 13 | 13 |
| C. Setup & deploy scripts | 20 | 0 | 9 | 11 |
| D. Dotfile configs | 22 | 5 | 6 | 11 |
| E. Tools / PowerShell / opencode tooling | 18 | 1 | 6 | 11 |
| F. Over-engineering (ponytail audit) | 12 | — | — | — |
| **Total unique items** | **118** | **11** | **42** | **65** (+12 OE) |

Top risks in one paragraph: destructive/failed-download paths (`golang-install.sh` `rm -rf /usr/local/go` after an unchecked `wget`; `jetbrains-toolbox` broken `tar` extraction; Debian package names in the Fedora branch), a setup tier that silently installs nothing (`vscode` stub), configs that are never deployed (`starship` mapped to install-only; `tabby`), a CLI flag parser that hangs (`wsl-setup-fedora-dev.sh`), and several LAN-bound services without auth.

---

## A. Entry points, shared helpers, options

| ID | File:Line | Sev | Type | Finding | Suggested fix | Action | Status |
|---|---|---|---|---|---|---|---|
| A1 | `setup.sh:74-79` | medium | correctness | Package IDs from user input are used as array subscripts without validation; `1,,2`/`abc` silently select index 0 (`ansible`), out-of-range IDs later `source "$CDIR/-setup.sh"` and error. | Validate each id: `id="${id//[[:space:]]/}"; [[ "$id" =~ ^[0-9]+$ ]] && (( id < ${#ALL_TASKS[@]} )) \|\| { cecho "red" "Invalid package id"; exit 1; }` | fix | done |
| A2 | `setup.sh:120,126` | low | consistency | `exit 11` not in convention (1=error, 10=cancelled); "no package selected" (a cancel) exits 11 while an actual error (invalid menu option) exits 10 — swapped. | Line 126 → `exit 10`, line 120 → `exit 1` | fix | done |
| A3 | `setup.sh:35,43` | low | style | `[ ]` with non-standard `==` inside `[ ]` (violates `[[ ]]` rule). | `[[ "$key" == "$DEFAULT_MENU_OPTION" ]]`, `[[ -z "$SETUP_MODE" ]]` | fix | done |
| A4 | `unattended_setup.sh:30-88` | medium | consistency | Header docs stale vs `_options.sh`: wrong MINIMAL/CONSOLE/EXTRA lists, `zellij` misplaced, 9 extras missing. | Regenerate lists from arrays or point to `./unattended_setup.sh ls` | fix | done |
| A5 | `unattended_setup.sh:143` | low | consistency | Missing required `--packages` is a usage error but exits 10 (cancel code); `process_args` uses exit 2 for bad args — three codes in one flow. | `exit 1` | fix | done |
| A6 | `unattended_setup.sh:147-152` | low | dead-code | Empty-check after `IFS=',' read -ra` unreachable (ARGS verified non-empty at :139). `--packages ,,,` passes and "installs" nothing with DONE banner. | Delete block; count validated packages and error if 0 | fix | done |
| A7 | `unattended_setup.sh:155-164,181-189` | low | dead-code | Trim-and-skip logic duplicated verbatim in validation and execution loops; drift-prone, strips spaces but not tabs. | Normalize once: `IFS=', ' read -ra SELECTED_PACKAGES <<< "${ARGS["packages"]}"`, drop per-loop trimming | fix | done |
| A8 | `unattended_setup.sh:133` | low | style | Typo: "unatended". | "unattended" | fix | done |
| A9 | `unattended_setup.sh:119,123` | low | dead-code | `process_args` runs twice (implicit tail in `_helpers.sh:486-488` + explicit call). Harmless but redundant; the implicit invocation is the only reason `setup.sh`/`update.sh` honor `--dry-run` (undocumented coupling). | Keep explicit call; remove/gate the implicit tail in `_helpers.sh` or document it | fix | done |
| A12 | `_scripts/core/_helpers.sh:84,86` | low | correctness | `cecho ""`-style calls always pass an extra empty first arg → every `cecho` line output starts with a spurious leading space. | `echo ${args:+$args} "$@"` and same for `decho` | fix | done |
| A13 | `_scripts/core/_helpers.sh:158,160,178,180` | medium | correctness | `decho "Directory found and renamed to [...]"` omits the color arg → message treated as color name, empty line printed. The "your dir was renamed" diagnostics are silently swallowed. | `decho "magenta" "..."` (×4) | fix | done |
| A14 | `_scripts/core/_helpers.sh:41,52` | low | consistency | `process_args` exits 2 on invalid/unknown args; convention defines only 1 and 10. | `exit 1` | fix | done |
| A15 | `_scripts/core/_helpers.sh:282` | medium | correctness | `get_stow_command` interpolates `$RDIR`/`$HOME` unquoted into a string later run via `bash -c`; any space in repo path or `$HOME` word-splits and every stow op fails (contrast `symlink_package_directory:366` which quotes correctly). | `echo "stow --dir=\"$RDIR\" --target=\"$HOME\" $extra_args $stow_arg $package"` | fix | done |
| A16 | `_scripts/core/_helpers.sh:198-205` | low | correctness | `ulimit -Sn` = `unlimited` (common on Fedora) breaks `-lt` comparison ("integer expression expected") and falls into the wrong branch; error text names wrong function (`adjust_ulimit`). | Numeric guard: `[[ "$current_limit" =~ ^[0-9]+$ ]] \|\| { decho ...; return; }` | fix | done |
| A17 | `_scripts/core/_helpers.sh:343-384` | low | dead-code | `symlink_package_directory` has zero call sites repo-wide; also lacks DRY_RUN guards around `mkdir -p`/`rename_dir_if_exists` if ever used. | Delete (−42 lines); resurrect from git history when needed | fix | done |
| A18 | `_scripts/core/_helpers.sh:115-117` | low | dead-code | `is_associative_array` zero call sites (bash/zsh-setup inline the equivalent regex). | Delete or make setup scripts call it | fix | done |
| A19 | `_scripts/core/_helpers.sh:334-337` | low | dead-code | "Missing stow action" check unreachable (`stow_action` always defaulted to `DFS_ACTION="init"`). | Delete 4 lines | fix | done |
| A20 | `_scripts/core/_helpers.sh:23` | low | dead-code | Third condition in `[[ "${#1}" -eq 0 \|\| "${1:0:1}" == "-" \|\| "$1" == "" ]]` subsumed by the first. | `[[ -z "$1" \|\| "${1:0:1}" == "-" ]]` | fix | done |
| A21 | `_scripts/core/_options.sh:17-31` | low | dead-code | All three OS branches assign identical `OPT_NODEJS_DEFAULT_VERSION="24"`; case exists only for the unsupported-OS exit. | Single guarded assignment + `*)` error branch | fix | done |
| A22 | `_scripts/core/_options.sh:121` | low | consistency | `ALL_TASKS` sorted but not deduplicated (`sort` without `-u`) though AGENTS.md documents it as deduplicated union; future two-tier addition would silently duplicate menu indices. | `sort -u` | fix | done |
| A23/C1 | `_scripts/core/tools-setup.sh:19-43` | **high** | correctness | Hand-rolled copy of pre-fix `stow_package` logic: greps `LINK: .tools` (the false-positive the comment in `_helpers.sh:307` warns about) and calls `rename_dir_if_exists "$HOME/.tools"` **with no DRY_RUN guard** → `--dry-run` actually moves the user's `~/.tools`. | Replace whole block with `stow_package "tools" "" "$HOME/.tools"` | fix | done |
| A24/C23 | `_scripts/core/ansible-cleanup.sh:25-32` | low | correctness | `pacman -Rns ansible ansible-lint` fails when `ansible-lint` isn't installed; `|| true` masks it and green "Removed..." prints unconditionally (same at :54, :92 for apt). | Build package list from `pacman -Qi` / check rc, print red on failure | fix | done |
| A25 | `_scripts/core/ansible-cleanup.sh:52,110` | low | style | `[ ]` against repo `[[ ]]` convention. | `[[ ... ]]` | fix | done |
| A26 | `_scripts/wsl-setup-fedora-dev.sh:74-92` | medium | correctness | Every value-taking option does `VAR="$2"; shift 2`; when the flag is last, `shift 2` fails and the loop spins forever — `./wsl-setup-fedora-dev.sh --win-user` hangs. | Guard: `[[ $# -ge 2 ]] \|\| { echo_error "..."; exit 1; }` in each value case | fix | done |
| A27 | `_scripts/wsl-setup-fedora-dev.sh:317` | **high** | correctness | `--packages "rust"` passes a non-existent task (`rustup` is the real one) → always "Unknown package: rust"; invisible because of A28. | `--packages "rustup"` | fix | done |
| A28 | `_scripts/wsl-setup-fedora-dev.sh:163,219,239,266-327,335,359` | medium | correctness | No rc checks on `dnf install/upgrade`, `git clone`, six `unattended_setup.sh` calls, `npm i -g`; `stage_status true` prints `[DONE]` unconditionally → false success hides any failure (this is what hid A27). | Check rc before `stage_status true`, e.g. `if bash ...; then ...; else stage_status false "... (FAILED)"; fi` | fix | done |
| A29 | `_scripts/wsl-setup-fedora-dev.sh:339,368` | low | correctness | `grep -q ... ~/.zshrc` without `2>/dev/null`/existence guard → stderr noise on fresh systems. | `grep -q ... 2>/dev/null` | fix | done |
| A30 | `_scripts/core/system-update.sh:48` | medium | correctness | EPEL bootstrap runs only for non-Fedora (RHEL) but enables repo id `crb`, which exists only on Fedora; on RHEL 9 it is `codeready_builder` (8: `codeready-builder`). Command always errors on the one OS it targets; rc unchecked. | `codeready_builder` (with `%%.*` handling for 8.x) | fix | done |
| A31/D11 | `_scripts/core/_options.sh:123-131`, `README.md:75-76,169-172`, `AGENTS.md`, `CLAUDE.md` | medium | consistency | Menu labels + AGENTS.md/CLAUDE.md/README tier lists contradict the arrays (MINIMAL is actually `base-tools,git,yazi,zellij,zsh`; CONSOLE_ONLY is `fastfetch,glow,nodejs,onefetch`; README omits ~13 real extras and wrongly lists zellij). | Regenerate lists from `_options.sh` or replace with a pointer to `./unattended_setup.sh ls` | fix | done |

Clean: `_scripts/headroom-uninstall.sh`.

## B. Install scripts (`_scripts/core/*_install.sh`)

| ID | File:Line | Sev | Type | Finding | Suggested fix | Action | Status |
|---|---|---|---|---|---|---|---|
| B1 | `_scripts/core/golang-install.sh:60-62` | **high** | correctness | Unchecked `wget` of the Go tarball, then unconditional `sudo rm -rf /usr/local/go` → a failed download destroys a working Go install before `tar` fails. Tarball also lands in caller's CWD; version grep is unanchored (`1.2` matches `1.23`). | `if ! wget -q <url> -O /tmp/go.tar.gz; then cecho red; return 1; fi` before the `rm -rf`; anchor grep | fix | done |
| B2 | `_scripts/core/jetbrains-toolbox-install.sh:43-49` | **high** | correctness | `fedora\|redhat` branch installs Debian package names (`libxi6 libxrender1 libxtst6 libgtk-3-bin dbus-user-session ...`) — none exist in Fedora repos; `dnf install` fails unchecked every run and Toolbox GUI deps stay missing. | Fedora names: `fuse3-libs libXi libXrender libXtst mesa-demos fontconfig gtk3 dbus-x11 tar` | fix | done |
| B3 | `_scripts/core/aws-cli-install.sh:21-33,52` | **high** | correctness | No `arch)` case branch (exits 1 on Arch though the zip path is distro-agnostic); `curl -fsSL -o ~/awscliv2.zip` rc unchecked → proceeds to `rm -rf ~/aws` + `unzip` on a failed download. | Add `arch)` branch; check curl rc before unzip | fix | done |
| B4/C19 | `_scripts/core/nodejs-install.sh:117-121` | medium | correctness | Fedora: `dnf remove -y "nodejs${NODEJS_VERSION}"` missing the hyphen (never matches `nodejs-22` NEVRA, always errors); `setup_lts.x` hardcoded, silently ignoring the user's `NODEJS_VERSION` honored by debian/ubuntu branches. | `"nodejs-${NODEJS_VERSION}"` + `setup_${NODEJS_VERSION}.x` | fix | done |
| B5 | `_scripts/core/nodejs-install.sh:72-75` | medium | security | Debian branch: `sudo curl ... -o nodesource_setup.sh` writes a predictable root-owned file in CWD (symlink-attack / arbitrary-overwrite vector in shared CWD), then `sudo bash` executes it. Ubuntu branch already does it right. | Mirror ubuntu branch: non-sudo `curl -o "$(mktemp)"` → `sudo -E bash <tmp>` | fix | done |
| B6/C13 | `_scripts/core/nodejs-install.sh:140-143`, `lsp-servers-install.sh:27,36,48,60,145,157`, `nvim-install.sh:83-84` | medium | correctness | `sudo npm install -g ...` runs on every path; when node came from Homebrew, npm is not in root's PATH → silent failure (rc unchecked). | Drop the block or guard `[[ "$NJS_INSTALL_MODE" != "brew" ]]` / use user npm | fix | done |
| B7 | `_scripts/core/graphify-install.sh:59` | medium | correctness | `claude install graphify` misuses the CLI (`claude install` takes a version target: stable/latest/\<ver\>) → fails, yet green "skill registered" prints unconditionally. | `graphify install --platform claude` + rc-checked success message | fix | done |
| B8 | `_scripts/core/ansible-install.sh:41-50`, `headroom-install.sh:45-51`, `graphify-install.sh:45-51` | medium | correctness | "Updating it..." path runs `uv tool install` on an installed tool — a verified no-op; nothing is ever updated. | `uv tool upgrade <pkg>` on the already-present path | fix | done |
| B9 | `_scripts/core/dotnet-install.sh:67,89-92`, `lsp-servers-install.sh:84` | medium | correctness | `dotnet tool install -g` errors "already installed" on every re-run (rc unchecked); PPA guard greps only `*.list` but modern `add-apt-repository` writes `.sources` → guard never matches. | `install -g X \|\| update -g X`; extend grep to `*.list *.sources` | fix | done |
| B10 | `_scripts/core/fastfetch-install.sh:27-36`, `powershell-install.sh:30-37` | medium | correctness | `curl -s` (no `-f`) against GitHub API → empty URL on rate-limit/offline; then `wget "" -O /tmp/<name>.deb` (predictable /tmp path, symlink-attack vector) and apt install of garbage, all rc-unchecked. | Empty-URL guard before download; `mktemp` for the .deb | fix | done |
| B11 | `_scripts/core/powershell-install.sh:46-52` | medium | correctness | No `.rh.aarch64.rpm` asset exists upstream (only `.cm.aarch64.rpm`) → on Fedora aarch64 the URL is empty and wget/dnf fail unchecked. Debian branch skips aarch64 explicitly; this branch doesn't. | Skip aarch64 with clear message or fall back to `.cm.aarch64.rpm`/tarball | fix | done |
| B12 | `_scripts/core/gcp-cli-install.sh:25,51` | medium | correctness | RHEL `VERSION_ID` includes minor (`9.4`) → baseurl `cloud-sdk-el9.4-x86_64` 404s; also no `arch)` branch (AUR `google-cloud-sdk` exists). | `el${CURRENT_OS_VER%%.*}`; add arch branch | fix | done |
| B13 | `_scripts/core/kitty-install.sh:37-40` | medium | correctness | No `fedora\|redhat` branch → hard exit, though `kitty` is in Fedora repos. | `fedora\|redhat) install_package "kitty" "kitty --version" ;;` | fix | done |
| B14 | `_scripts/core/terraform-install.sh:19-20` | medium | correctness | No `arch)` branch → exit 1 on Arch where `terraform` is in official extra repo. | Add arch branch | fix | done |
| B15 | `_scripts/core/tabby-install.sh:29-65` | medium | correctness | No `fedora\|redhat` branch; both existing branches hardcode `linux-x64` packages (aarch64 installs an x86_64 package); wget rc unchecked (bad version → HTML page fed to dpkg/pacman). | Add rpm branch; derive arch suffix; check wget rc | fix | done |
| B16/C2 | `_scripts/core/jetbrains-toolbox-install.sh:56-63` | **high** | correctness | `--strip-components=1` appears **after `--`** in the tar pipeline → GNU tar treats it as a member name; binary extracts to `~/.local/bin/jetbrains-toolbox-<ver>/…` so the desktop `Exec=` (line 82) is broken, the already-installed check (line 20) never matches (re-downloads every run), and pipeline rc unchecked so green success prints anyway. | Move `--strip-components=1` before `--` (use `--wildcards -- '*/jetbrains-toolbox'`); check rc | fix | done |
| B17/C12 | `_scripts/core/lsp-servers-install.sh:121-131` | medium | correctness | `TERRAFORM_LS_ARCH` case has no default (unsupported arch → empty → malformed URL); `curl -s` version scrape (no `-f`) → empty version; predictable `/tmp/terraform-ls.zip` that root later unzips to `/usr/local/bin`. | Validate both vars, `curl -fsSL`, `mktemp --suffix=.zip` | fix | done |
| B18 | `claude-code-install.sh:26-29`, `herdr-install.sh:21`, `mise-install.sh:21`, `oh-my-posh-install.sh:28`, `homebrew-install.sh:28` | low | correctness | `curl \| bash` hides download failure (bash on empty stdin exits 0) + unconditional green message; `hermes-install.sh`/`headroom` already do the right thing with a `command -v` verify block. | Copy the verify pattern (or `set -o pipefail`) | fix | done |
| B19 | `_scripts/core/github-cli-install.sh:26-27` | low | security | `mktemp` keyring file never removed (leaks every run). | `rm -f "$out"` or pipe directly into `sudo tee` | fix | done |
| B20 | `_scripts/core/github-cli-install.sh:21` | low | dead-code | Package passed as its own `additional_packages` (copy-paste leftover → duplicate pacman arg); debian branch missing DRY-RUN echo (fedora has one). | Drop 4th arg; add DRY-RUN else-branch | fix | done |
| B21 | `_scripts/core/base-tools-install.sh:32,41-46,65` | low | correctness | `[ ! -f ~/.local/bin/fd ]` follows symlinks → dangling link passes as "missing", `ln -s` then fails "File exists" (same for `bat`); `[ ]` used. | `[[ ! -e ... && ! -L ... ]]` or `ln -sfn`; `[[ ]]` | fix | done |
| B22 | `_scripts/core/docker-install.sh:64,71` | low | consistency | `[ ]` usage; `dnf-3 config-manager --add-repo` without the dnf5 dispatch that `github-cli-install.sh:36-42` implements → fails on dnf5-only systems, rc unchecked. | `[[ ]]`; reuse dnf5 two-way dispatch | fix | done |
| B23 | `k8s-repo-install.sh:31-32`, `gcp-cli-install.sh:25`, `terraform-install.sh:29` | low | correctness | `curl ... \| sudo gpg --dearmor -o <keyring>` — if curl fails mid-stream a truncated/empty keyring overwrites the good one on re-run; rc unchecked. | Temp-file download + rc check before dearmor (or pipefail) | fix | done |
| B24 | `_scripts/core/nvim-install.sh:25,43,49` | low | correctness | `cd /opt/neovim-src \|\| exit 1` in a sourced script kills the whole parent run (line 49 uses `return 1` inconsistently) and leaks the changed CWD to the caller; `pacman -R vim` unchecked. | Subshell `( cd ... && ... )`; `return` not `exit` | fix | done |
| B25 | `_scripts/core/microsoft-repo-install.sh:27-38` | low | correctness | Downloads `packages-microsoft-prod.deb` into caller's CWD (dirties the repo) with no rc check; failed wget leaves a 0-byte deb that `dpkg -i` chokes on; `[ ]` usage. | `mktemp --suffix=.deb` → `dpkg -i` → `rm` | fix | done |
| B26/C16 | `_scripts/core/nerd-fonts-install.sh:89-92` | low | correctness | Unchecked `wget -O "$HOME/$TARGET_FONT.zip"`: a 404 leaves an HTML file, `unzip` errors, `rm` cleans up silently, `fc-cache` runs against nothing. | rc-chain wget/unzip, red message on failure, `rm -f` in both paths | fix | done |
| B27 | `_scripts/core/zed-install.sh:20,27-28` | low | consistency | `redhat` missing from case (exit 1); `curl -f <url> \| sh` missing `-sSL` → redirect yields empty stdin, `sh` exits 0, false green "installation done". | Add `redhat`; use `curl -fsSL` | fix | done |
| B28 | `_scripts/core/ghostty-install.sh:37` | low | consistency | Branch is `fedora` only → `redhat` falls to unsupported exit; every other script groups `fedora\|redhat`. Pop!_OS jammy-base is a known gap in the curl installer. | Merge with a COPR caveat or explicit RHEL skip message | manual fix | done |
| B29 | `_scripts/core/onefetch-install.sh:23-30` | low | dead-code | `debian\|ubuntu\|pop` and `fedora\|redhat` branches byte-identical (brew path). | Merge pattern lists (~−6 lines) | fix | done |
| B30 | `_scripts/core/vscode-install.sh:19` | low | dead-code | "Not implemented yet" stub, but `vscode` is wired into DESKTOP_EXTRA_TASKS → selecting it silently installs nothing. | Implement (microsoft-repo + `code`) or drop from task arrays | manual fix | done |

## C. Setup & deploy scripts (`*_setup.sh` + specials)

| ID | File:Line | Sev | Type | Finding | Suggested fix | Action | Status |
|---|---|---|---|---|---|---|---|
| C3 | `_scripts/core/rtk-setup.sh:22-25` | medium | correctness | `command -v rtk` guard runs even under `--dry-run` (when the install deliberately skipped) → `exit 1` in a *sourced* script kills the entire `unattended_setup.sh --dry-run --packages ...,rtk,...` run. | Skip guard in dry-run: `[[ "$DRY_RUN" -ne "1" ]] && ! command -v rtk ...` | fix | done |
| C4 | `_scripts/core/_options.sh:170` | medium | correctness | `["starship"]="install"` → selecting `starship` never runs `starship-setup.sh`, so the `starship/.config/starship/*.toml` configs are never stowed. (`oh-my-posh` correctly maps to `"setup"`.) | `["starship"]="setup"` | fix | done |
| C5 | `_scripts/core/tabby-setup.sh:22` | medium | dead-code | Script only prints "No config available to stow", but `tabby/.config/tabby/config.yaml` exists and is never deployed by anything. | `stow_package "tabby" "" "$CURRENT_CONFIG_DIR/tabby"` or delete the config dir | manual fix | done |
| C6 | `_scripts/core/bash-setup.sh:30-35` (+ `zsh-setup.sh`) | medium | correctness | `--prompt` option installs the chosen prompt tool, but `config.bash:153` hardcodes oh-my-posh (starship init commented out) and `config.zsh:235` hardcodes starship → the "other" prompt tool is installed and never used. | Honor the choice in the shell configs (generated snippet) or drop the `--prompt` plumbing | manual fix | done |
| C7 | `_scripts/core/hermes-setup.sh:56,87-93` | medium | correctness | If the Headroom prompt creates `~/.hermes/.env` with only 2 proxy vars, the later block sees `.env` exists and skips the 23 KB `.env.template` with API-key placeholders; the "add your keys" hint only prints on a fresh `config.yaml`. | Deploy the `.env` template **before** the headroom block | fix | done |
| C8 | `_scripts/core/hermes-setup.sh:116` | medium | correctness | Deploys 4 systemd user units + `daemon-reload` but no WSL2 branch (headroom-setup.sh:22-25 has one) → on stock WSL2 every run prints the red daemon-reload error and units are dead files. | `enable_wsl_systemd` guarded by `IF_WSL2`, or skip with warning | fix | done |
| C9 | `_scripts/core/headroom-setup.sh:110-112` | medium | correctness | `loginctl enable-linger` rc unchecked, green "User lingering enabled" prints unconditionally; missing `loginctl` output also gets misread as "linger off". | rc-check + `command -v loginctl` guard | fix | done |
| C10/E4 | `headroom/headroom-proxy.service:9`, `hermes-dashboard.service:9` | medium | security | `--host 0.0.0.0` on the LLM proxy (forwards provider API calls using keys from `proxy.env`) and on the dashboard, while all consumers use localhost; headroom README claims it listens on localhost. | Bind `127.0.0.1` by default; explicit opt-in for LAN exposure | manual fix | done |
| C11 | `_scripts/core/lsp-servers-install.sh` (27,36,48,60,84,121-131,145,157) | medium | correctness | Every install block (`npm -g`, `go install`, `dotnet tool`, `rustup component`) runs without rc checks and prints green unconditionally → failed/partial installs invisible. | Route through `execute_command` (also removes the manual DRY_RUN if/else blocks) | fix | done |
| C14 | `_scripts/core/claude-code-setup.sh:46-98` | low | correctness | 24+ `claude ...` invocations with no `command -v claude` guard (rtk-setup/herdr-setup guard it) → stderr noise and loop still proceeds. | Wrap the section in a `command -v claude` check | fix | done |
| C15/E18 | `_scripts/core/opencode-setup.sh:154-156` + `opencode/AGENTS.md` | medium | consistency | `copy_files_if_missing "$RDIR/opencode/plugins" ...` — `opencode/plugins/` doesn't exist in the repo (silent no-op, graphify plugin never deployed globally); AGENTS.md documents plugin deployment. Also `.opencode/opencode.json` explicitly loads the plugin that opencode already auto-loads from `.opencode/plugins/` → double-load. | Add the plugin file, or drop the reference + the redundant plugin-path entry | fix | done |
| C17 | `_scripts/core/nerd-fonts-install.sh:35` | low | consistency | Fallback font hardcoded `"CascadiaCode"` instead of `"$OPT_NERDFONTS_DEFAULT_FONT"` (diverges silently if the option changes). | Use the option variable | fix | done |
| C18 | `_scripts/core/tmux-setup.sh:22` | low | correctness | `[ ! -e ... ]` follows symlinks → a **dangling** `tmux.conf.local` passes the check, then `ln -sr` fails "File exists" and the link is never repaired. | `rm -f` stale symlink before `ln -sr` (DRY_RUN-guarded) | fix | done |
| C20 | `_scripts/core/nodejs-install.sh:72-80,93-101` | low | style | DRY_RUN blocks flush-left inside nested ifs (broken 2-space convention). | Re-indent | fix | done |
| C21 | `_scripts/core/zsh-setup.sh:41-49` | low | consistency | rc-file append has no DRY-RUN else-branch (bash-setup prints one); `grep -q` without `-F`. | Add else-branch; `grep -qF` | fix | done |
| C22 | `bash-setup.sh:30,33`, `zsh-setup.sh:32,35,43`, `git-setup.sh:25`, `headroom-setup.sh:36-38,48-49,65-66,82-83`, `nerd-fonts-install.sh:34,69,86`, `tools-setup.sh:29,37`, `nodejs-install.sh:31` | low | style | `[ ]` used against the repo's `[[ ]]` mandate (mechanical). | Convert to `[[ ]]` | fix | done |
| C24 | `headroom-setup.sh:50`, hermes `.env` deploy | low | security | `proxy.env` / `.env` (provider API keys) deployed world-readable (644). | `chmod 600` after each deploy | fix | done |
| C25 | `_scripts/core/herdr-setup.sh:40,67` | low | correctness | `herdr completion zsh > "$HOME/.zfunc/_herdr"` — if the command errors the redirect leaves a 0-byte file and green success prints. | Write to temp, `mv` on success | fix | done |
| C26 | `_scripts/core/hermes-setup.sh:126` | low | style | Final message claims "Headroom proxy is ready" even when the user answered `n` or ran unattended. | Gate on `HEADROOM_HERMES == y` | fix | done |
| C27 | `_scripts/core/_helpers.sh:24` (via `setup.sh:153`) | medium | correctness | `process_args` resets `DFS_ACTION="init"` whenever `$1` is a flag; the interactive runner sources scripts *with* `TASK_ARGS` (bash/zsh `--prompt ...`) → `./setup.sh refresh` silently downgrades bash/zsh stowing to `init` ("already stowed, nothing to do"). | Never overwrite an already-set action with `init`; only assign for non-empty non-flag `$1` | fix | done |

Clean: `fastfetch/ghostty/kitty/nvim/zed/yazi/zellij/oh-my-posh/starship/git/jetbrains-toolbox` setups, `opencode/merge-opencode-config.py` core semantics (verified by self-test).

## D. Dotfile configs

| ID | File:Line | Sev | Type | Finding | Suggested fix | Action | Status |
|---|---|---|---|---|---|---|---|
| D1 | `nvim/.config/nvim/lua/configs/adeotek_v2/plugins/treesitter.lua:8` | **high** | correctness | `require('nvim-treesitter.configs').setup` no longer exists — the plugin is on the rewritten `main` branch; every nvim start throws, treesitter highlighting/`ensure_installed` dead. | Pin `branch = "master"` in the spec, or migrate to the new `nvim-treesitter.install()` + `vim.treesitter.start()` API | manual fix | done |
| D2 | `git/.config/git/config:75-77` | **high** | correctness | `lgc`, `quicklog`, `quicklog-long` use `--pretty=custom`; verified `fatal: invalid --pretty format: custom` — all three always fail. | Real format string or define `[pretty] custom` | fix | done |
| D3 | `git/.config/git/config:82` | **high** | correctness | `clones = git clone -s --single-branch` — non-`!` alias expansion prepends `git` → runs `git git clone`; verified expansion failure. | `clones = clone -s --single-branch` | fix | done |
| D4 | `README.md:41,203,445`, `AGENTS.md:67`, `CLAUDE.md:109`, `zsh/README.md` | **high** | consistency | Docs describe `config-standalone.zsh` as "recommended for new setups" — the file was deleted; `zsh/README.md` is ~90 % documentation of the removed file. | Delete standalone references; rewrite zsh/README around antidote/config.zsh | fix | done |
| D5 | `README.md:330-333,348-351` | **high** | correctness | `./unattended_setup.sh --packages zsh --prompt oh-my-posh` documented, but `--prompt` is not a valid flag there (only `packages`/`unattended`; unknown flags exit 2) → documented command cannot run. | Add `["prompt"]=""` to ARGS or drop the examples | manual fix | done |
| D6 | `.stow-local-ignore` | medium | dead-code | Stow reads `.stow-local-ignore` from the stow *source* dir passed via `--dir`. In this repo `stow_package` always stows individual package dirs (`bash`, `git`, …), so the repo-root file is never consulted in practice (verified with stow `-v5`); its entries (`.git`, `_scripts`, README, …) also live at the root, never under a package. Note: a future `stow .` from the repo root *would* read it — deletion trades that defense-in-depth for less clutter. | Delete the file | fix | done |
| D7 | `git/.config/git/config:190,193` | medium | correctness | `sw` defined twice (`stash show`, then `switch`); last wins → `git sw` never shows the stash. | Remove line 190 or rename | fix | done |
| D8 | `nvim/.../adeotek_v2/plugins/lsp.lua:109-114` | medium | dead-code | `on_attach` defined but never passed to any setup → intended `gd`/`K`/`<leader>rn` LSP keymaps never created. | Wire via `LspAttach` autocmd | fix | done |
| D9 | `nvim/.../adeotek_v2/plugins/lsp.lua:19-80` | medium | correctness | Legacy `require('lspconfig').X.setup{}` + `automatic_installation` — verified deprecation warning ("removed in v3.0.0") with current nvim-lspconfig. | Migrate to `vim.lsp.config()/enable()` (0.12) | manual fix | done |
| D10 | `tmux/.config/tmux/tmux.conf.local:277` | medium | correctness | `#{ram_percentage}` provided by no declared plugin (tmux-cpu only has `cpu_percentage`) → status bar permanently shows ` RAM` with no value. | Drop the token or add a memory plugin | fix | done |
| D12 | `.gitignore:11` + `nvim/.config/nvim/.gitignore` | medium | consistency | `lazy-lock.json` ignored → plugin versions unpinned; combined with update checker this is what let the treesitter rewrite silently break the config (D1). | Track `lazy-lock.json` (standard lazy.nvim practice) | manual fix | done |
| D13 | `neofetch/` | low | dead-code | No task in `_options.sh`/TASK_TYPES; nothing ever deploys it; upstream archived. Fastfetch covers it. | Delete `neofetch/` + README tree line | fix | done |
| D14 | `starship/*.full`, `oh-my-posh/gbs-text.omp.yaml`, `yazi/*.toml.full`, `nvim/lua/configs/{adeotek_v1,jakoolit}/`, `*.bak` | low | dead-code | Unused variant configs; the yazi `*.full` files get **stowed** as inert `*.toml.full` litter in `~/.config/yazi/`. | Move unused variants to `_extra/` (out of stow packages) | manual fix | done |
| D15 | `tmux/.config/tmux/plugins/` | low | consistency | Vendored `tmux-copycat` used by no declared plugin list; declared `tmux-thumbs`/`tmux-sessionx` absent; `update_plugins_on_launch=false` → fresh machines never get them. | Remove copycat; vendor thumbs/sessionx or flip update-on-launch | manual fix | done |
| D16 | `.gitignore:10` + `tmux/.config/tmux/tmux.conf.local` | low | consistency | File is gitignored but tracked (as a symlink created by tmux-setup.sh) → ignore rule inert, per-machine symlink churn committed. | `git rm --cached tmux/.config/tmux/tmux.conf.local` | fix | done |
| D17 | `bash/.config/bash/config.bash:4,18-57`, `zsh/.config/zsh/config.zsh:4` | low | correctness | `LC_ALL='C.UTF-8'` hard-overrides user locale in both shells; bash appends PATH dirs with no dedup (re-sourcing duplicates; user binaries shadowed) — zsh already uses `typeset -U` + prepend. | `LC_ALL=${LC_ALL:-C.UTF-8}` or drop; mirror zsh PATH pattern in bash | fix | done |
| D18 | `README.md:242-244,451` | low | consistency | "bash creates `~/.bashrc` → symlink" is false (append-source mechanism instead); "oh-my-posh themes/" dir doesn't exist. | Update to actual mechanism/paths | fix | done |
| D19 | `README.md:26,111,294-295` | low | consistency | Version drift: Go 1.25.4 vs actual 1.26.5; Nerd Fonts 3.4.0 vs 3.5.0. | Update numbers or point at `_options.sh` | fix | done |
| D20 | `CLAUDE.md:89,96-98`, `AGENTS.md:44` | low | consistency | References `statusline-command.ps1` (actual: `statusline-command-win.sh`), `*.sample` suffixes that don't exist, and copy-only-if-missing contradicting documented merge behavior. | Correct filenames + copy-vs-merge sentence | fix | done |
| D21 | `.gitignore` | low | correctness | `opencode/__pycache__/*.pyc` untracked but not ignored → shows in `git status`, easy to commit accidentally. | Add `__pycache__/` | fix | done |
| D22 | `nvim/.../adeotek_v2/options.lua:15,18,23-24`, `init.lua:7` | low | dead-code | `showmatch` set twice; `vim.opt.encoding` no-op on nvim; `vim.loop` deprecated (use `vim.uv`); alpha art branch references non-existent `assets/` dir. | Delete duplicates, `vim.uv`, drop/ship assets branch | fix | done |
| D23 | `bash/.config/bash/config.bash:10-11`, `zsh/.config/zsh/config.zsh:156-157` | low | style | `egrep`/`fgrep` aliases → GNU grep ≥3.8 prints deprecation warnings on every use. | Drop or map to `grep -E`/`grep -F` | fix | done |

Clean (verified with the real tools): ghostty config (`+validate-config`), fastfetch jsonc, zellij kdl (`setup --check`), kitty, zed settings, tabby yaml, oh-my-posh themes (`config export`), starship toml, git ignore, zsh plugin load order, tmux.conf (stock oh-my-tmux), `_extra/` templates, `.editorconfig`.

## E. Tools / PowerShell / opencode tooling

| ID | File:Line | Sev | Type | Finding | Suggested fix | Action | Status |
|---|---|---|---|---|---|---|---|
| E1 | `win-tools/.tools/Run-LocalWinEnvSetup.ps1:~233,~256` | **high** | security | `Invoke-Expression "PowerShellGet\$action -Name $($_.Id) $flags"` (and npm variant) interpolate config-file values straight into executed code — any `;`/`$()`/quote in the config runs arbitrary PowerShell. | Native parameter binding (`& cmdlet -Name $_.Id @splat`); `npm install --global -- $_.Id`; never IEX | fix | done |
| E2 | `tools/.tools/cc-sessions.sh:194-200`, `win-tools/.tools/Get-ClaudeCodeSessions.ps1:272-278` | medium | security | `--rm` derives uuid from the session filename unvalidated; `..jsonl` → uuid `..` → `rm -rf .../file-history/..` deletes the whole `file-history` dir. | Validate uuid `^[A-Za-z0-9._-]+$` and reject `.`/`..` before any rm | fix | done |
| E3 | `hermes/config.yaml:752` | medium | correctness | `Authorization: Bearer Bearer ${INFRA_MP_TOKEN}` — duplicated "Bearer", auth to `infra-mp` MCP always fails. (foca profile is correct.) | Single `Bearer` | fix | done |
| E5 | `opencode/opencode.jsonc:73-80` | medium | security | Global config binds opencode server `hostname: 0.0.0.0` with no credential; only the wrapper script supplies a password → plain `opencode serve` is an unauthenticated code-exec server on the LAN. | Drop `hostname` from the deployed config (pass it from the script) or document | manual fix | done |
| E6 | `hermes/.config/systemd/user/hermes-dashboard.service:9` | medium | security | Dashboard binds 0.0.0.0:9119 while `dashboard.basic_auth` user/pass/secret are all empty → unauthenticated dashboard (sessions, files, config) on the LAN. | Bind 127.0.0.1 or require non-empty basic_auth | manual fix | done |
| E7 | `win-tools/.tools/Run-LocalWinEnvSetup.ps1:188,233,256` | medium | correctness | `winget`/`npm` failures only set `$LASTEXITCODE` (never throw) → script prints "Done" for every failed install. | `if ($LASTEXITCODE -ne 0) { throw ... }` inside the try/catch | fix | done |
| E8 | `win-tools/.tools/Run-LocalWinEnvSetup.ps1:15,129-162` | low | dead-code | Docstring lists `tf-install` task type with no handler; `Add-Env-Path` defined, never called. | Remove from docs / delete function | fix | done |
| E9 | `win-tools/.tools/Rename-Files.ps1:72,115` | medium | correctness | `ErrorActionPreference=Stop` + `Get-ChildItem -Recurse`: one unreadable dir aborts the whole run before any rename. | `-ErrorAction SilentlyContinue` on the GCI | fix | done |
| E10 | `win-tools/.tools/Run-PortListen.ps1:83,95-110,112` | low | correctness | UDP "already listening" check is a self-send (only detects bind failure); the real bind is outside try/catch (raw crash if port taken in between); busy-wait loops spin at 100 % CPU. | Drop probe; wrap bind; `Start-Sleep -Milliseconds 50` in loops | fix | done |
| E11 | `win-tools/.tools/Get-ClaudeCodeSessions.ps1:130-136,175-180,225-227` | low | correctness | `-like`/`-ilike` treat `[ ] * ?` in user filter as wildcards (`C:\repo[1]` never matches); `$maxSummary = width-15` can go negative → `Substring` throws. | IndexOf-style substring check; clamp width | fix | done |
| E12 | `win-tools/.tools/Get-ClaudeCodeSessions.ps1:130-136` | low | correctness | `Get-JsonField` regex-parses JSON: leaves `\n`/`\uXXXX` undecoded and needs compact JSON — silently mis-decodes where the bash twin's `jq` is correct. | `ConvertFrom-Json` per line | fix | done |
| E13 | `tools/.tools/cc-sessions.sh:100-105,159-161,193-202` | low | correctness | No `command -v jq` guard (silent degradation); `max_summary` can go negative (`${disp_summary:0:-15}` then trims the tail); `rm` failures counted as removed. | jq guard + exit 1; clamp; rc-check rm | fix | done |
| E14 | `win-tools/.tools/Run-PortProbe.ps1:74,76-81` | low | correctness | Blocking `Connect()` with no timeout (~21 s hang per unreachable host) and always exits 0 → unusable in automation. | `ConnectAsync().Wait(timeout)`; exit 1 on failure | fix | done |
| E15 | `win-tools/.tools/Get-GitHubStats.ps1:125` | low | correctness | `gh repo list --limit 1000` silently truncates large orgs. | Warn when `Count -eq 1000` | fix | done |
| E16 | `win-tools/.tools/Get-WinFirewallRuleByPort.ps1:77`, `Add-WinFirewallRule.ps1:33` | low | dead-code | Redundant `Where-Object { $_ }`; `SupportsShouldProcess` declared but `ShouldProcess()` never called (−WhatIf works only by accident). | Delete line; wrap `New-NetFirewallRule` in ShouldProcess | fix | done |
| E17 | `win-tools/.tools/Rename-Files.ps1:119-121`, `Get-FilesList.ps1:21-34` | low | consistency | Exclude check compares every path segment incl. the file name (docs say "directory names"); Get-FilesList examples cite the stale name `list_files.ps1`. | Compare directory segments only; update examples | fix | done |
| E19 | `headroom/README.md:31` + `providers.env:34` + `hermes/config.yaml:570,747` | low | consistency | Two different Zen URLs documented vs configured (one wrong); `SEARXNG_URL` misplaced as top-level YAML key (ignored by hermes); `tirith_fail_open: true` passes traffic when the security scanner errors. | Reconcile URLs; move var to `.env.template`; set `false` unless deliberate | manual fix | done |
| E20 | `opencode/merge-opencode-config.py:90-98,123,133-134` | low | correctness | Backup write leaks an unclosed file handle; `dropped` safety net assumes dict → scalar top-level live JSON raises uncaught TypeError; `--live-wins` still appends template-only array entries (contradicts docstring). | `shutil.copyfile`; `isinstance` guard; skip array-union under `--live-wins` (or document) | fix | done |

## F. Over-engineering scan (ponytail audit)

Verified shrink/delete candidates (behavior-neutral). Biggest cut first:

| Tag | What to cut | Replacement | Ref | Est. −lines | Action | Status |
|---|---|---|---|---|---|---|
| delete | `symlink_package_directory()` in `_helpers.sh` — zero callers, unguarded if used | nothing (git history keeps it) | A17 | −42 | fix | done |
| shrink | `update.sh`: 5 hand-rolled DRY_RUN if/else blocks, no rc checks | `execute_command "<cmd>" "<msg>"` | A10 | −30 | fix | done |
| delete | `vscode-install.sh` stub wired into DESKTOP_EXTRA_TASKS, installs nothing | implement or unwire | B30 | −20 (stub) | manual fix | done |
| delete | `tabby-setup.sh` no-op stub while `tabby/` config exists | stow it or delete both | C5 | −15 | manual fix | done |
| shrink | `jetbrains-toolbox-install.sh`: per-OS `if DRY_RUN … else cecho` duplication in every branch | `execute_command` | O8 | −15 | fix | done |
| delete | `neofetch/` package dir — no task, never deployed | delete dir | D13 | −40 (files) | fix | done |
| shrink | `k8s-repo-install.sh` 7-line DRY-RUN echo block | `execute_command` per command | O9 | −8 | fix | done |
| shrink | `gcp-cli-install.sh:42-47` + `powershell-install.sh:47-51`: 5-line arch if/else derivations of what is just `CURRENT_ARCH` | direct assignment / shared case | O11 | −8 | fix | done |
| shrink | `unattended_setup.sh`: trim logic duplicated in two loops | one `IFS=', ' read -ra` | A7 | −8 | fix | done |
| shrink | `_options.sh`: 3 identical `OPT_NODEJS_DEFAULT_VERSION` assignments | single guarded assignment | A21 | −10 | fix | done |
| shrink | `onefetch-install.sh`: byte-identical debian/fedora branches | merged pattern list | B29 | −6 | fix | done |
| delete | `is_associative_array()` (zero callers), unreachable stow-action check, subsumed arg condition in `_helpers.sh`; `Add-Env-Path` + `tf-install` in PS1; unreachable empty-check in `unattended_setup.sh` | delete | A18/A19/A20/A6/E8 | −18 | fix | done |

**net: ≈ −160 lines of script (plus the `neofetch/` dir), −0 deps.**

Cross-cutting root causes (worth one sweep each): unchecked `curl|bash` + unconditional green success messages (B18, B7, C11, C23…); missing `arch` / `fedora|redhat` case branches (B3, B12–B15, B27, B28); `[ ]` vs `[[ ]]` stragglers (A3, A25, B21, B22, B25, C20–C22).

## G. Shellcheck baseline — false positives / vendored (no action)

| Finding | Reason | Action | Status |
|---|---|---|---|
| ~300 findings under `tmux/.config/tmux/plugins/**` (tpm, resurrect, continuum, copycat, cpu) | Vendored third-party plugins; upstream code | do not fix | rejected |
| 25 findings in `zsh/.config/zsh/config.zsh` + `ai-config.zsh` (SC2148, SC2034 plugin vars, SC2296 `${(s.:.)}`, SC2154 `terminfo/functions/commands`, SC2206/SC2128 `$path`, SC1090) | Shellcheck doesn't speak zsh; plugin variables and zsh builtins are real usage | do not fix | rejected |
| 19 findings in `ghostty/.config/ghostty/config` | Ghostty key=value config, not shell | do not fix | rejected |
| 4 errors in `git/.config/git/config` (SC1035 `[include]`) | git config syntax, not shell | do not fix | rejected |
| SC2086 `hstr ${READLINE_LINE}` in `config.bash:103`; SC2086 `mise activate` in `config.zsh:250` | Vendor-verbatim lines; cosmetic | do not fix | rejected |
| SC2164 `builtin cd -- "$cwd"` in yazi/fzf widgets (`config.bash:129`, `config.zsh:208`) | Guarded by `[ -d ]`; `|| exit` inside a widget would kill the interactive shell | do not fix | rejected |
| SC1091 "Not following" infos when shellcheck is invoked from repo root with `find .` paths | Invocation artifact (source paths resolve against CWD); scripts are clean when checked in place | do not fix | rejected |

## Verification notes

- Hand-verified in this session: B1, B2, B16/C2, D2, D3, D4, D7, E3, A26, A27, C1/A23, C4, A7, A10 (update.sh source read), B29, B21, plus D1 config shape (treesitter `configs`-module usage present; main-branch breakage verified by the review agent against the installed plugin).
- Shellcheck clean on all `_scripts/` at error/warning level; `bash -n` clean repo-wide.
- Agent-verified with live execution where noted in descriptions (git aliases, `uv tool install` no-op, tar member-name behavior, missing PowerShell RPM asset, `claude install` semantics, stow ignore-file location).

## H. Post-fix pass verification + follow-ups

**Re-verification after applying all fixes (2026-09-16):**

- `shellcheck -x` across every repo-owned `.sh` (vendored tmux plugins excluded): **zero error/warning findings**; `bash -n`: all clean.
- `./unattended_setup.sh ls` → 46 packages, rc 0. `--dry-run --packages git,nvim,starship,tabby,vscode,golang,jetbrains-toolbox,nodejs,tools --verbose` → DONE, rc 0 (tabby stow plan verified; vscode now implements).
- `./unattended_setup.sh --dry-run --packages ",,,"` → exit 1 (A6); unknown package → exit 1 (A5/convention); `setup.sh`: cancel → 10, invalid id → 1, invalid menu option → 1 (A1/A2).
- `./update.sh --dry-run --verbose` → all five steps via `execute_command`, DRY-RUN lines correct (A10/A11).
- `nvim --headless` loads with treesitter on `master` (D1), migrated lspconfig API (D9), no errors/deprecation warnings; functional LSP attach test on a Lua buffer passed.
- `bash` and `zsh` source their configs cleanly with the new prompt-tool selection (C6); PATH dedup verified (D17); git aliases parse and expand correctly (D2/D3/D7).
- `merge-opencode-config.py`: `py_compile` clean + functional matrix (no-change → no backup; `--live-wins` keeps live arrays; scalar live → guarded exit 1) (E20).
- `pwsh` parser: all 9 edited `.ps1` files parse OK; zero `Invoke-Expression` remain; YAML/JSONC parse checks pass (E-items).

**Follow-ups discovered during the fix pass (not in the original report):**

| ID | File | Sev | Finding | Action | Status |
|---|---|---|---|---|---|
| H1 | `_scripts/core/*.sh` (init guard) | low | Documented `RDIR=$(dirname "$(cd "${0%/*}" && pwd)")` guard resolves RDIR one level short, so *standalone* `bash _scripts/core/<script>.sh` cannot source `_helpers.sh` (sourced-by-driver usage unaffected). Fix repo-wide guard or document sourced-only. | manual fix | to do |
| H2 | `_scripts/core/claude-code-setup.sh:51-101` | low | Marketplace/plugin `claude ...` invocations still lack per-command rc checks (C14 added only the `command -v` guard). | fix | to do |
| H3 | `_scripts/core/tabby-install.sh:24` | low | Interactive `read -r TABBY_VERSION` fires even in unattended/dry-run mode. | fix | to do |
| H4 | `git/.config/git/config` | low | `ss`/`ssk` aliases use deprecated `git stash save` (→ `stash push -m`). | fix | to do |
| H5 | `nvim/.../adeotek_v2/options.lua` | low | Clipboard-provider warning prints on every headless start (noise in scripts/CI). | manual fix | to do |
| H6 | `nvim/.config/nvim/lua/config.lua` | low | `NVIM_CONFIG` env selection of v1/jakoolit silently breaks since those configs were archived to `_extra/nvim/`. | manual fix | to do |
| H7 | `_scripts/core/hermes-setup.sh:57` | low | `[[ "${ARGS["unattended"]}" -ne "1" ]]` errors when the script is sourced standalone with empty `ARGS` (pre-existing pattern). | fix | to do |
| H8 | `_scripts/core/ghostty-install.sh` | low | Debian-family curl installer gap: Pop!_OS jammy-base unsupported upstream. | manual fix | to do |
| H9 | `win-tools/.tools/Run-PortListen.ps1:12` | low | Docstring still claims UDP pre-check "verifies port not already in use" (now detected via bind in try/catch). | fix | to do |
| H10 | `win-tools/.tools/Get-ClaudeCodeSessions.ps1` | low | Pre-filter `-match '"type":"ai-title"'` still requires compact JSON spacing (out of E12 scope). | fix | to do |

Nothing to commit — all changes are in the working tree (incl. one staged untrack for D16). Commit per the repo convention (`[fix:global] …`) is left to the user.
