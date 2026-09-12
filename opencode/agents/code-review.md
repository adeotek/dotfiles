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
    "find *": allow
    "git diff *": allow
    "git log *": allow
    "git show *": allow
    "git status": allow
    "git stash list": allow
    "git branch *": allow
    "git remote *": allow
    "graphify *": allow
    "ls *": allow
    "rg *": allow
    "sort *": allow
    "which *": allow
    "rtk rm *": ask
    "rtk *": allow
    "*": ask
  task: deny
color: accent
---
