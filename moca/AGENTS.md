# AGENTS.md — working rules

These rules hold in every project on this machine. They override moca's base
prompt, any skill and any prompt template; where two instructions disagree, the
stricter one wins. "The task asks for a commit" is not permission to commit.

## Approval required

Ask, wait for an explicit yes, and treat it as covering one action — not a plan,
not a task, not a change that is small or obviously complete.

- **Commit / push.** Show `git status` and the diff, propose the exact message,
  get a yes per commit. Skills and prompt templates may stage; none may commit.
- **Destructive or irreversible.** `rm -rf`, `git push --force`,
  `git reset --hard`, `git clean`, `kubectl delete`, `docker … prune`, DB
  `DROP`/`ALTER`/mass `DELETE`, disk, partition or NAS work.
- **Installing anything.** `dnf`/`apt`/`brew`/`winget`, OS packages, project
  dependencies.
- **Publishing.** Releases, tags, PRs into `main`, deploys.

moca's permission prompt is a backstop, not the policy: a command that runs
unattended (auto/yolo mode, an allow rule) still needs a yes when it is listed
above. `moca -p` and `moca execute` have nobody to ask — stop and report what
needs approval instead of working around it.

Never print, echo or commit secrets (`.env`, `auth.json`, `*.key`, tokens);
redact them when quoting output.

## Before changing code

- **Verify, then answer.** Read the file, run the command or fetch the docs with
  `web` before asserting a signature, config key or behaviour — never recall it.
  If that still leaves a gap, say "I don't know" instead of filling it.
- **Plan non-trivial work** — cross-file, ~10+ lines, a refactor, a new feature.
  In bullets: what changes, where, why, the risk. Then wait for a yes. `/plan`
  (or `--mode plan`) confines writes to `docs/plans/*.md`; write the plan as
  `- [ ]` steps, one verifiable change each, and `moca execute <plan.md>` walks
  them in order, ticking the boxes. Typos, one-liners and doc fixes skip this.
- **Two readings, different work?** Ask which one; don't pick and hope.

## Verification

The prompt's "Project checks" line names the command moca detected — run it. Add
only what detection cannot infer: `shellcheck` on shell scripts, an undeclared
linter or type checker, a generated artifact that must be regenerated. Fix every
violation before calling the task done. Nothing detected: run the build and the
tests yourself, then say which. Report a failure as the command, the full error
output and the fix.

End the final answer with the open items as a numbered list — approvals to
give, steps left, decisions needed — or state that nothing is open.

## Tools

No LSP: navigate with `search`, `read` and `ls`, and `search` every call site
before renaming or changing a signature.

- Formatters, generators and `git` may rewrite files; hand-editing source
  through `shell` (`sed -i`, `python -c`, `tee`, heredocs) may not — it bypasses
  read tracking and the pre-edit snapshot.
- `mcp`: `search` → `describe` → `call`, with the arguments the schema declares.
- Browser work: `playwright-cli` (`--help` lists its commands), headless unless
  a visible browser is needed, and only for pages `web` cannot render (JS-driven
  or logged in).

## Project context and skills

- Another `AGENTS.md` loads only from the workdir root, and only in a trusted
  project (`CLAUDE.md` stands in for it); nested ones are never read — read a
  subdirectory's own `AGENTS.md` or `README.md` yourself before working there.
- Read `docs/architecture.md`, `docs/design.md`, `docs/language-style.md`,
  `docs/testing.md` or a style guide only when the task touches that area.
- A skill appears as name, description and path: read its body before using it;
  it outranks your priors, and this file outranks it.
- `graphify-out/` present: ask the graph before grepping a large tree (`graphify
  query`, `path`, `explain`), and run `graphify update .` after changing code.
- Compaction is automatic and unscheduled: anything a resumed session needs
  must be on disk, so tick the plan's steps as you go and keep state in a file,
  not in the conversation.

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
