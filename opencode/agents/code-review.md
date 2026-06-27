---
description: Read-only code review subagent. Inspects diffs for correctness, security, and best practices. Invoke via @code-review.
mode: all
# alt: qwen3.7-plus
model: opencode-go/deepseek-v4-pro
reasoningEffort: max
temperature: 0.1
permission:
  edit: deny
  bash:
    "echo *": allow
    "git diff *": allow
    "grep *": allow
    "graphify *": allow
    "ls *": allow
    "sort *": allow
    "*": ask
  task: deny
color: accent
---
