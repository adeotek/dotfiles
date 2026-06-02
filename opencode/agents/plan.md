---
description: Restricted plan/analysis mode. Read-only. For codebase analysis and planning before making changes.
mode: primary
model: opencode/gemini-3.1-pro
temperature: 0.1
permission:
  edit: deny
  write: deny
  bash:
    "which *": allow
    "ls *": allow
    "rg *": allow
    "git diff *": allow
    "git log *": allow
    "git status": allow
    "git show *": allow
    "find *": allow
    "*": deny
---

{file:./AGENTS.md}
