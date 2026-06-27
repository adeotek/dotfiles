# AGENTS.md — Operational Rules for AI Agents

## 1. Verification Before Done
Before declaring any task complete, you MUST run verification steps appropriate to the project. This typically includes:
- **Compile/build**: Ensure the project compiles without errors
- **Lint**: Run the project's linter and fix all violations
- **Type check**: Run the type checker (TypeScript, MyPy, etc.) if applicable
- **Test**: Run relevant unit/integration tests
- If any step fails, fix the issue before marking the task done.

## 2. Analysis/Plan Phase
For any non-trivial change (cross-file, >10 lines changed, refactoring, new feature):
1. **Research**: Use LSP, grep, read, and findReferences to understand the relevant code
2. **Plan**: Present a clear plan describing what will change, why, and the expected impact
3. **Wait for approval**: Do not write code until the user explicitly approves
- Simple changes (typo fix, single-line refactor, docs update) may skip this phase.

## 3. Lazy-Loading Sub-Rules
If the project has these docs:
- `docs/architecture.md` — System architecture documentation (load before cross-module work)
- `docs/design.md` — UI design rules (load before adding/modifying UI components)
- `docs/language-style.md` — Language-specific style guides (load before writing in that language)
- `docs/testing.md` — Testing conventions (load before writing/modifying tests)
Do not load them proactively. Only read them via the Read tool when the task explicitly requires them.

## 4. General Conduct
- **Verify, then answer**: When your response depends on API signatures, library behavior, project conventions, config values, or file contents, verify the relevant information by reading actual files, running commands, or checking live documentation. Never rely on memory alone when the ground truth is one tool call away.
- Be concise, direct, and use bullet points for plans.
- For errors: include the command, the full error output, and the proposed fix.
- When uncertain about intent, ask rather than assume.
- Do not avoid responding with `I don't know` when you are not able to respond or you don't have the right information.

## 5. Browser Automation
Use `playwright-cli` for browser automation tasks. Run `playwright-cli --help`
to see available commands. Prefer headless mode (default) unless a visible
browser is explicitly needed.
