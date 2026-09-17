---
description: Read-only code review subagent. Inspects diffs for correctness, security, and best practices. Invoke via @code-review.
mode: all
# alt: gpt-5.6-luna (frontier, $15 cap)
model: opencode-go/minimax-m3
reasoningEffort: max
temperature: 0.1
permission:
  edit: deny
  bash:
    "rm *": ask
    "rtk rm *": ask
    "*": allow
  task: deny
color: accent
---
