---
description: Read-only review of a diff, branch, or named files for correctness, security, and best practice.
argument-hint: "[diff target or files, e.g. 'main..HEAD' or 'src/api']"
---
Review the code changes named below and report findings. This is a review, not a fix: do not modify files, stage, commit, or run state-changing commands.

Target: $ARGUMENTS

If no target was given above, review the uncommitted work (`git diff` plus `git status`); if the tree is clean, ask which ref or files to review before doing anything else.

## Gather the change
1. Get the diff: `git diff --stat <target>` first, then the full `git diff <target>`; for a committed range use `git diff <base>...<head>` or `git log --oneline <range>`. Name the exact commands you ran.
2. `read` every changed file in full, not just the hunks — context above and below the hunk decides whether a change is correct.
3. Trace the call sites of each changed function/export with `search`; a signature or behavior change is a finding only after its callers are checked.
4. Read the tests that cover the changed code. Note what is covered and what is not; run the project's check command (the system prompt names it) when it is cheap, and say whether it passed.

## What to look for, in this order
1. **Correctness** — broken logic, wrong off-by-one/boundary handling, unhandled nil/empty/error paths, wrong concurrency (races, missing locks, goroutine leaks), resource leaks (unclosed files/sockets), silently swallowed errors.
2. **Security** — injection (shell/SQL/path), unvalidated or untrusted input crossing a trust boundary, secrets or credentials in code or logs, auth/authz gaps, insecure defaults, dependency or serialization pitfalls.
3. **Data & compatibility** — migrations, schema or format changes, backward/forward compatibility, API or config contract changes, anything that needs a coordinated deploy.
4. **Tests** — missing cases for the new behavior, tests that assert the implementation instead of the contract, weakened or deleted assertions.
5. **Fit with the codebase** — deviates from an existing module pattern, duplicates a helper that already exists, breaks a documented convention.

## Report
- Order findings by severity (blocker → major → minor); skip anything a formatter or linter already enforces.
- Per finding: `file:line`, the concrete failure scenario (inputs/state → wrong result), and a suggested fix. Say plainly when a problem is a suspicion you could not confirm versus a confirmed defect.
- Do not pad the list. If the change is clean, say so and name the residual risks you could not verify (untested paths, environment-dependent behavior, things outside the diff's reach).
- End with a verdict: **approve**, **approve with comments**, or **request changes**, and one line on what would flip it.
