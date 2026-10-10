# AGENTS.md — Operational Rules for AI Agents

## 1. Git Commit Policy — ALWAYS FOLLOW
**Never run `git commit`, `git push`, or any command that creates a commit without my explicit, per-commit approval.**
This applies in ALL situations, including:
- When a skill, plugin, or superpower workflow suggests or implies committing as part of its normal process
- When changes are small, "safe," or clearly complete
- When I've approved a plan that *mentions* committing — plan approval is not commit approval
- When working autonomously or in a long agentic loop
Before committing, always:
1. Show me the changes (`git diff` / `git status`) or a summary of what would be committed
2. Propose the exact commit message
3. Wait for my explicit "yes/approved/commit it" — a general "looks good" about the code is not sufficient authorization to commit
If a skill's instructions conflict with this policy, this policy wins. Skills may stage changes or describe what a commit would contain, but must stop short of actually committing.

## 2. Verification Before Done
Before declaring any task complete, you MUST run verification steps appropriate to the project. This typically includes:
- **Compile/build**: Ensure the project compiles without errors
- **Lint**: Run the project's linter and fix all violations
- **Type check**: Run the type checker (TypeScript, MyPy, etc.) if applicable
- **Test**: Run relevant unit/integration tests
- If any step fails, fix the issue before marking the task done.

## 3. Analysis/Plan Phase
For any non-trivial change (cross-file, >10 lines changed, refactoring, new feature):
1. **Research**: Use LSP, grep, read, and findReferences to understand the relevant code
2. **Plan**: Present a clear plan describing what will change, why, and the expected impact
3. **Wait for approval**: Do not write code until the user explicitly approves
Simple changes (typo fix, single-line refactor, docs update) may skip this phase.

## 4. Lazy-Loading Sub-Rules
If the project has these docs:
- `docs/architecture.md` — System architecture documentation (load before cross-module work)
- `docs/design.md` — UI design rules (load before adding/modifying UI components)
- `docs/language-style.md` — Language-specific style guides (load before writing in that language)
- `docs/testing.md` — Testing conventions (load before writing/modifying tests)
Do not load them proactively. Only read them via the Read tool when the task explicitly requires them.

## 5. General Conduct
- **Verify, then answer**: When your response depends on API signatures, library behavior, project conventions, config values, or file contents, verify the relevant information by reading actual files, running commands, or checking live documentation. Never rely on memory alone when the ground truth is one tool call away.
- Be concise, direct, and use bullet points for plans.
- For errors: include the command, the full error output, and the proposed fix.
- When uncertain about intent, ask rather than assume.
- Do not avoid responding with `I don't know` when you are not able to respond or you don't have the right information.

## 6. Code Intelligence and Navigation
Prefer LSP over Grep/Glob/Read for code navigation:
- `goToDefinition` / `goToImplementation` to jump to source
- `findReferences` to see all usages across the codebase
- `workspaceSymbol` to find where something is defined
- `documentSymbol` to list all symbols in a file
- `hover` for type info without reading the file
- `incomingCalls` / `outgoingCalls` for call hierarchy
Before renaming or changing a function signature, use `findReferences` to find all call sites first.
Use Grep/Glob only for text/pattern searches (comments, strings, config values) where LSP doesn't help.
After writing or editing code, check LSP diagnostics before moving on.

## 7. Browser Automation
Use `playwright-cli` for browser automation tasks. Run `playwright-cli --help`
to see available commands. Prefer headless mode (default) unless a visible
browser is explicitly needed.
