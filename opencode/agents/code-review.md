---
description: Read-only code review subagent. Inspects diffs for correctness, security, and best practices. Invoke via @code-review.
mode: all
# alt: gpt-5.6-luna (frontier, $15 cap)
model: opencode-go/minimax-m3
request:
  body:
    reasoningEffort: max
    temperature: 0.1
permissions:
  - action: edit
    resource: "*"
    effect: deny
  - action: shell
    resource: "rm *"
    effect: ask
  - action: shell
    resource: "rtk rm *"
    effect: ask
  - action: shell
    resource: "*"
    effect: allow
  - action: subagent
    resource: "*"
    effect: deny
color: accent
---
