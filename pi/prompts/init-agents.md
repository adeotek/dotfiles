---
description: Create or update AGENTS.md at the project root from the current state of the codebase — works like Claude Code's /init.
argument-hint: "[monorepo subproject, optional]"
---
Create or update AGENTS.md (or an equivalent agent-instructions file such as CLAUDE.md when explicitly named) at the project root, based on the current state of the codebase${1:+ for subproject/area: $1}.

Scope rules:
- This is only for AGENTS.md — the machine-facing instruction file. Do NOT use for general documentation tasks (README, docs/, architecture guides).
- In monorepos, run against the repo root unless the user names a specific subproject.

## Procedure
1. LOOK FOR EXISTING INSTRUCTIONS FIRST. Search for AGENTS.md (and any CLAUDE.md/.cursorrules that duplicate it) from the working directory up to the repo root. If one exists, read it fully before anything else — existing user-authored rules (commit policies, conventions, 'never do X' notes) are authoritative and must survive the run. The run is an UPDATE of a living file, never a regeneration from scratch.
2. RECON THE REPO (fast, batched):
   - ls the repo root; read README.md.
   - Read build/test config and manifests: package.json (+ scripts), pyproject.toml/setup.py, Cargo.toml, go.mod, *.csproj/*.sln/*.slnx, mise.toml/justfile/Makefile, global.json/Directory.Build.props.
   - Read CI workflows (.github/workflows/, .forgejo/workflows/, .gitlab-ci.yml) — they are ground truth for the canonical build/test/lint commands.
   - Note lint/format configs (eslint, ruff, .editorconfig, biome), test setup, package/dependency managers (lockfiles, mise/asdf/nvm).
   - Sketch the source layout: 2-level tree of src/ (or equivalent) plus tests/, with one-line purpose per top-level directory inferred from names and a spot-check read, not guesses.
   - Check docs/ or a knowledge graph (e.g. graphify-out/) for architecture notes worth referencing.
3. VERIFY COMMANDS BEFORE DOCUMENTING THEM. For each command you intend to document (build, dev, test, lint, migrate, codegen): either run it, or confirm it appears verbatim in a manifest script or CI workflow. If a command cannot be verified (needs a DB, API keys, hardware), document it but mark it 'unverified'. Never invent a command that exists nowhere.
4. DRAFT THE FILE — concise, agent-facing, ideally under ~100 lines:
   - # Project — 1-3 sentence overview + phase/scope note if stated.
   - ## Build & Run — verified commands with one-line comments; direct tool invocations AND task-runner shortcuts.
   - ## Architecture / Layout — short tree of top-level dirs with one-liners; only what an agent needs to navigate.
   - ## Conventions — style rules, framework-specific rules, naming, testing conventions, config/env overrides; only rules observable in the code or stated in existing instructions.
   - ## Verification Rule — what must pass before declaring work done (build + lint + tests).
   - ## Git workflow rules — copy any existing commit/push policy verbatim; if none exists, do not invent one.
   - ## Notes / Pitfalls — non-obvious gotchas discovered during recon (env var overrides, required local config, port conflicts).
5. CREATE OR MERGE:
   - No existing file → write the draft directly.
   - Existing file → merge section by section: keep every user-authored rule verbatim (wording included); update only facts that are now stale (renamed dirs, changed commands, removed projects) and add missing sections. Produce the proposed result as a diff and show it to the user BEFORE writing when anything user-authored would be changed or removed. Pure additions to a missing section can be written directly, but still show what was added.
6. FINISH: report what was created/updated, list the commands that were verified vs unverified, and flag anything in the old file you could not validate against the current repo (stale paths, removed projects) instead of silently keeping or deleting it.

## Pitfalls
- Do not copy the README wholesale. AGENTS.md is for an agent: commands, rules, layout — not tutorials, install guides, or marketing prose.
- Never invent commands. Only document what a manifest, CI workflow, or a successful run proves.
- Never delete, reword, or 'improve' user-authored rules such as commit policies — they are deliberate. If one looks stale, flag it in the summary and let the user decide.
- Bloat kills compliance. A 300-line AGENTS.md is ignored; cut ruthlessly. If the project is big, link to docs/ instead of inlining it.
- In monorepos, document the root-level commands and point to per-package READMEs rather than duplicating every package's workflow.
- Do not run destructive commands during verification (migrations against shared DBs, deploys, clean/install steps that mutate lockfiles). Verify with --help, --dry-run, or a build/test run only.
- If AGENTS.md and CLAUDE.md both exist and disagree, surface the conflict to the user instead of silently picking one.

## Verification (do before reporting done)
1. Every command documented in AGENTS.md is traceable to a manifest script, CI workflow, or a run executed during this session (note which).
2. Every file/directory path referenced in AGENTS.md exists in the repo right now.
3. Diff against the previous version shows: no user-authored rule removed or reworded, only intended stale-fact updates and additions.
4. The file is valid Markdown with no broken fences, and every heading matches the structure the user already uses (if extending an existing file).
