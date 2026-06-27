---
description: Read-only code review subagent. Inspects diffs for correctness, security, and best practices. Invoke via @code-review.
mode: all
# alt: qwen3.7-plus
model: opencode-go/deepseek-v4-pro
reasoningEffort: max
temperature: 0.1
permission:
  read: allow
  lsp: allow
  glob: allow
  grep: allow
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
    "*": ask
  task: deny
color: accent
---
