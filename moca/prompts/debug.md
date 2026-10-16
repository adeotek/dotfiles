---
description: Debug a failure by finding the root cause before changing code.
argument-hint: "<error, failing test, or symptom>"
---
Debug this: $ARGUMENTS

Find the root cause before changing any code. Do not guess-and-patch; a fix that makes the symptom disappear without explaining it is not done.

## Reproduce first
1. Get the exact reproduction: the failing command, its full output, and the exit code. Run it yourself if you can — a described error and the real one often differ.
2. `read` the failing test or the module that reports the error. Its assertions and error messages say what the code is supposed to do; that is the spec you are debugging against.
3. If it does not reproduce, say what you tried and what differs from the reported environment (versions, flags, data, OS). Do not proceed on a reproduction you never saw.

## Locate the cause
4. Collect evidence before hypothesizing: read the full stack trace / log lines, then `read` the frames that belong to this repo. Ignore nothing that look surprising.
5. `search` for where the failing value is produced, not where it explodes. Follow it back to its origin — the bug is usually one step earlier than the crash.
6. Check the shape of the data at the boundary: nil/empty/zero, wrong type or unit, unexpected encoding, an unset env var or config key. Print or log hover values if it is unclear.
7. Form one hypothesis at a time and test it (a targeted run, a temporary print, a bisect via `git log -S`/`git bisect` for a regression). Discard a hypothesis as soon as the evidence contradicts it; do not accumulate them.

## Fix and verify
8. Fix the root cause — the smallest change that removes the defect, in the style of the surrounding code. Do not "fix" it by widening an error handler, weakening an assertion, or deleting the failing test.
9. Add or extend a regression test that fails on the old code and passes on the fix. If the project has none for this area, say so.
10. Re-run the original reproduction and the project's check command (the system prompt names it); paste the commands and their results.
11. Report: the root cause in one or two sentences, the fix, why the failing case now passes, and any related path with the same defect you did not change (name it, or fix it and say why).
