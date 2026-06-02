---
description: Read-only code review subagent. Inspects diffs for correctness, security, and best practices. Invoke via @code-review.
mode: all
model: opencode/glm-5.1
temperature: 0.1
permission:
  edit: deny
  write: deny
  bash: deny
  task: deny
color: accent
---

{file:./AGENTS.md}
