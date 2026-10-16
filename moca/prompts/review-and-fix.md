---
description: Review all changes versus the main branch and fix the issues found
argument-hint: "[extra focus or paths]"
---
Review the work currently on this branch against `main`, then fix what you find.

1. Inspect the full diff: `git fetch origin main` if useful, then read `git log --oneline main..HEAD`, `git diff main...HEAD --stat` and the actual diff of every changed file.
2. Also check uncommitted work (`git status`, `git diff`), since it is part of this branch's changes.
3. Review for: correctness and edge cases, missed call sites, error handling, resource leaks, concurrency/race issues, security and secret handling, style inconsistent with the surrounding code, dead or leftover code, stale docs, and missing or weakened tests.
4. List each issue with file:line and the reason it matters, ordered by severity.
5. Fix each real issue at its root cause with minimal, in-style changes — do not weaken or delete tests to make them pass.
6. Verify: run the project's check command (the system prompt names it), review `git diff` for stray changes, and re-read your own new diff for problems.
7. Report what you changed and how you verified it; call out anything you deliberately left alone and why.

$ARGUMENTS
