---
name: code-review
description: "Read-only code review: inspect a diff, staged work, or named files for correctness, security and best practices, then report severity-ordered findings with a verdict. Use on \"review this\", \"review my changes/PR/commit\", or before merging."
metadata:
  audience: developers
  review-mode: read-only
---

# Read-only code review

Review the changes you are asked about — diffs, staged work, or named files — for correctness, security, and best practices.

## When to use

- The user asks for a review of a diff, commit, branch, staged work, PR, or named files.
- A change is about to be merged or shipped and needs a second pair of eyes.

## Rules

- Never modify files, stage, commit, or run state-changing commands. You review; you do not fix.
- Ground every finding in the actual code: read the files, surrounding call sites, and tests before reporting. Use `git diff` / `git show` / `git log` to inspect changes that are not given to you.
- Order findings by severity; for each, give the file (and line when single-line), the concrete failure scenario, and a suggested fix. Skip nits that linters/formatting already cover.
- Distinguish confirmed problems from suspicions.

## Procedure

1. Establish the scope — the supplied diff, or the change found via `git status` / `git diff` / `git log`.
2. Read each changed file and the code that calls it, plus the tests that cover it.
3. Write findings ordered by severity, each with file (line), failure scenario, suggested fix.
4. End with a verdict: approve / approve with comments / request changes — plus residual risks you could not verify.

## Verification

- Every finding names a file (and line when single-line) and a concrete failure scenario.
- Confirmed problems and suspicions are labelled as such.
- The report ends with a verdict; if the change is clean, it says so plainly.
