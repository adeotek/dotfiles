# Cross-Platform Dry-Run & OS Dispatch

> 15 nodes

## Key Concepts

- **_helpers.sh (Shared Utilities)** (11 connections) — `_scripts/core/_helpers.sh`
- **_options.sh (Task Arrays & Tiers)** (5 connections) — `_scripts/core/_options.sh`
- **setup.sh (Interactive Setup)** (3 connections) — `setup.sh`
- **unattended_setup.sh (Unattended Setup)** (3 connections) — `unattended_setup.sh`
- **update.sh (System Update)** (2 connections) — `update.sh`
- **wsl-setup-fedora-dev.sh (WSL2 Fedora Setup)** (2 connections) — `_scripts/wsl-setup-fedora-dev.sh`
- **Dry-Run Safety Pattern** (2 connections) — `_scripts/core/_helpers.sh`
- **WSL2 Environment Support** (2 connections) — `_scripts/core/_helpers.sh`
- **Rename-Files.ps1 (Bulk Rename with Dry-Run)** (2 connections) — `win-tools/.tools/Rename-Files.ps1`
- **Multi-Distro Support (Arch/Debian/Fedora)** (1 connections) — `_scripts/core/_helpers.sh`
- **Task Tier Hierarchy (Minimal/Console/Desktop)** (1 connections) — `_scripts/core/_options.sh`
- **tools-setup.sh** (1 connections) — `_scripts/core/tools-setup.sh`
- **OS-Dispatch Pattern (case $CURRENT_OS_ID)** (1 connections) — `_scripts/core/_helpers.sh`
- **stow_package() Helper Function** (1 connections) — `_scripts/core/_helpers.sh`
- **Dry-Run Pattern in PowerShell Tools** (1 connections) — `win-tools/.tools/Rename-Files.ps1`

## Relationships

- No strong cross-community connections detected

## Source Files

- `_scripts/core/_helpers.sh`
- `_scripts/core/_options.sh`
- `_scripts/core/tools-setup.sh`
- `_scripts/wsl-setup-fedora-dev.sh`
- `setup.sh`
- `unattended_setup.sh`
- `update.sh`
- `win-tools/.tools/Rename-Files.ps1`

## Audit Trail

- EXTRACTED: 28 (74%)
- INFERRED: 10 (26%)
- AMBIGUOUS: 0 (0%)

---

*Part of the graphify knowledge wiki. See [[index]] to navigate.*