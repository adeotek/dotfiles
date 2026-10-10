---
description: Document code — doc comments, a README section, or module docs — from the code as it actually is.
argument-hint: "[file, package, or area to document]"
---
Document the code named below.

Target: $ARGUMENTS

If no target was given above, ask what to cover before starting.

Document what the code does today, not what it was meant to do. Read the code before writing a word; never describe behavior you did not verify in the source or by running it.

## Recon
1. `read` the target in full. For a package or directory, `ls` it, then read the entry point, the exported/public surface, and the tests.
2. Match the existing docs: look for doc-comment style, an existing README, and `docs/` structure. Reuse the house pattern (heading levels, term casing, where examples live) instead of inventing one.
3. Note the contract the code must satisfy: inputs, outputs, errors/return codes, side effects, concurrency and ordering guarantees, resource limits, and validation rules it enforces.

## Write
4. Lead with purpose and the contract, then the non-obvious detail. A reader should learn what it is for, how to call it, and what to expect on failure before the internals.
5. Document the boundaries: what is rejected and how (bad input, wrong state), the failure modes, and any limit (size, timeout, rate) that the code enforces.
6. Include an example only if it is correct and runnable — verify any command, snippet, or path you quote against the repo. Prefer a real, minimal example over a plausible-looking one.
7. Explain the *why* only where the code cannot: a workaround, a spec/issue reference, a surprising invariant. Do not narrate what the next line already says in clear code.
8. Keep it tight: no filler, no marketing, no restating the signature in prose. Cut a sentence that changes nothing about how a reader would use the code.

## Verify before reporting done
- Every claim is traceable to a line you read or a command you ran — call out anything you could not verify.
- Every path, symbol, flag, and command mentioned exists right now (`search` for it).
- Every code sample is correct and, where cheap, actually executed.
- The result matches the surrounding docs' structure and tone, and reads as documentation of this codebase, not a generic tutorial.
- Report what you documented, where it was written, and the open questions you could not settle from the code.
