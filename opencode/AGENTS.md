# AGENTS.md — working rules

These rules hold in every project. They override opencode's base prompt, any
skill and any custom agent prompt; where two instructions disagree, the stricter
one wins. "The task asks for a commit" is not permission to commit.

## Approval required

Ask, then wait for an explicit yes — one action per yes, not a plan or a task.

- **Commit / push.** Show `git status` and the diff, propose the exact message,
  get a yes per commit. Skills and plugins may stage; none may commit or push.
- **Destructive or irreversible.** `rm -rf`, `git push --force`,
  `git reset --hard`, `git clean`, `kubectl delete`, `docker … prune`, DB
  `DROP`/`ALTER`/mass `DELETE`, disk, partition or NAS work.
- **Installing anything.** `dnf`/`apt`/`brew`/`winget`, OS packages, project
  dependencies.
- **Publishing.** Releases, tags, PRs into `main`, deploys.

Auto-approve (`--auto`, a `permission` allow rule) is a backstop, not the
policy: a command that runs unattended still needs a yes when it is listed
above. `opencode run --auto` and any headless session have nobody to ask — stop
and report what needs approval.

Never print, echo or commit secrets (`.env`, `auth.json`, `*.key`, tokens);
redact them when quoting output.

## Before changing code

- **Verify, then answer.** Read the file, run the command or `webfetch` the docs
  before asserting a signature, config key or behaviour — never recall it. If a
  gap remains, say "I don't know".
- **Plan non-trivial work** — cross-file, ~10+ lines, a refactor, a new feature.
  In bullets: what changes, where, why, the risk. Then wait for a yes. `plan`
  (Tab) is read-only and writes only `.opencode/plans/*.md`; the approved plan
  is what `build` executes. Typos, one-liners and doc fixes skip this.
- **Two readings, different work?** Use the `question` tool instead of guessing.

## Verification

- Run the checks the project declares: build, lint, typecheck and test commands
  from the README, package scripts or Makefile. Never assume a framework.
- Add what the repo uses but does not script: `shellcheck` on shell scripts, a
  generated artifact that must be regenerated.
- Diagnostics arrive automatically after edits (pyright, gopls, eslint, csharp
  and friends are auto-detected); the experimental `lsp` nav tool is off unless
  `OPENCODE_EXPERIMENTAL_LSP_TOOL` is set — navigate with `grep` and `glob`.
- Fix every violation before calling the task done. Report a failure as the
  command, the full error output and the fix.

End the final answer with the open items as a numbered list — approvals to
give, steps left, decisions needed — or state that nothing is open.

## Agents and tools

Two primary agents: `build` (default, all tools) and `plan` (read-only).

- Delegate to keep context lean: `@explore` for read-only codebase search,
  `@general` for one parallel unit of multi-step work, `@code-review` before a
  PR, `@dev`/`@devops` for their domains. Don't delegate what one `grep`
  answers.
- Keep `todowrite` current on multi-step work; it is the progress record.
- `skill` loads a `SKILL.md` by name — read it before relying on it.
- Browser automation: `playwright-cli` (`--help` lists its commands), headless
  unless a visible browser is needed, and only for JS-driven or logged-in pages
  `webfetch` cannot read.

## Project context and skills

- Rules load by walking **up** from the working directory: `AGENTS.md`, else
  `CLAUDE.md`, first match wins; the global one is
  `~/.config/opencode/AGENTS.md`. Nested files are never read — open a
  subdirectory's `AGENTS.md` or `README.md` yourself before working there.
- Extra instruction files come from the config's `instructions` array.
- Read `docs/architecture.md`, `docs/design.md`, `docs/language-style.md`,
  `docs/testing.md` only when the task touches that area.
- A skill is advertised by name and description; its body outranks your priors,
  and this file outranks it.
- `graphify-out/` present: ask the graph before grepping a large tree (`graphify
  query`, `path`, `explain`), and run `graphify update .` after changing code.

## Scope

Touch only what the task needs: no drive-by refactors, renames or reformatting,
no new markdown unless asked, prefer editing an existing file to adding one.
When the change outgrows its stated surface, stop and say so.

## Commit and PR titles

`[{type}:{scope}] short description`

- **type** — `feat`, `fix` (a bug) or `chore` (tooling, deps, refactor, config).
- **scope** — `global` (several areas), `docs`, `ui`, `tui`, `backend`, `core`,
  or the area's slug (`auth`, `ci`, `k8s`).
- E.g. `[feat:auth] add passkey sign-in`, `[fix:tui] stop flicker on resize`.

No AI attribution trailers; one version bump per PR; PR descriptions
are free-form.
