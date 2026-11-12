---
name: csharp-15
description: "Write, review and modernize C# 15 (.NET 11) code: collection-expression `with(...)` arguments, union types, closed hierarchies, extension indexers, labeled jumps, non-virtual static interface members and the memory-safety preview. Use for `net11.0`/`LangVersion` 15 code or CS8121, CS8509, CS8655, CS9370, CS9380, CS9363 build errors."
version: 2.0.2
author: George Benjamin (adeotek)
license: MIT
platforms: [linux, macos, windows]
metadata:
  audience: developers
  language: csharp
  framework: dotnet-11
---

# C# 15

## When to use this skill

Write, review and modernize C# 15 (.NET 11) code correctly. Use when code targets `net11.0` or
`LangVersion` 15/preview, when the user mentions any C# 15 feature, when replacing marker
interfaces, OneOf-style results, `goto`/flag loop exits or capacity/comparer boilerplate, or when
the build reports CS8121, CS8509, CS8655, CS8510, CS0121/CS0411 on a `with(...)` element, CS9370,
CS9380, CS9363.

This file is the gate: language-version preconditions, the feature map, the routing table and the
checklist. Feature depth lives in `references/` — **open the reference before writing or reviewing
that feature**, not after the compiler complains.

## Feature map

C# 15 ships with the .NET 11 SDK and Visual Studio 2026. It is the default language version for
projects that target `net11.0`.

| Feature | Keyword / syntax | Needs preview? | Reference |
| --- | --- | --- | --- |
| Collection expression arguments | `[with(args), e1, e2]` | No | `references/collection-expression-arguments.md` |
| Union types | `union U(A, B);`, `[Union]` | No | `references/unions.md` |
| Closed hierarchies | `closed class` / `closed record class` | No | `references/closed-hierarchies.md` |
| Extension indexers | `this[...]` inside `extension(T x) { }` | No | `references/extension-indexers.md` |
| Labeled `break` / `continue` | `outer: for (...) { ... break outer; }` | No | `references/labeled-breaks.md` |
| Non-virtual static interface members on older runtimes | `static` helpers in interfaces on .NET Framework / netstandard | No | `references/interfaces-and-runtimes.md` |
| Memory safety model | `unsafe(expr)`, `safe`, requires-unsafe `unsafe` members | **Yes** (`LangVersion=preview` + feature flag) | `references/memory-safety-preview.md` |

## 0. Before using any C# 15 feature

1. **Check the language version.** Look at the project's `TargetFramework` and `LangVersion`.
   `net11.0` without a `LangVersion` gives C# 15. To see the active version, temporarily add
   `#error version`: the compiler reports CS8304 with the compiler and language versions.
2. **Don't set `<LangVersion>latest</LangVersion>`.** Microsoft warns against it because it varies
   by machine. Using a language version newer than the target framework's default is unsupported.
   Prefer moving the TFM to `net11.0`.
3. **Union types need runtime types.** `System.Runtime.CompilerServices.UnionAttribute` and
   `System.Runtime.CompilerServices.IUnion` ship in the .NET 11 runtime. The compiler does **not**
   synthesize them. When you target an older TFM, the project must reference or define them.
4. **Know the new contextual keywords.** These can break existing identifiers, and `@` escapes them:
   - `with(` at the start of a collection-expression element: use `@with(...)` to call a method
     named `with`.
   - `union` before a type name in a declaration: use `@union`.
   - `closed` in type declarations and modifier positions: use `@closed`.
   - `safe`, in preview, as a member modifier: use `@safe`.
5. **C# 15 is GA** with .NET 11. The language reference describes shipped behavior; feature specs
   predate the compiler, so when they disagree the reference wins. Only the memory-safety model
   (item 6) is still preview.
6. **Memory safety needs both switches and an opt-in** — `<LangVersion>preview</LangVersion>` plus
   `<Features>$(Features);updated-memory-safety-rules</Features>` plus `AllowUnsafeBlocks` (and
   `AllowUnsafeBlocks` alone is not enough). Never turn this on unasked.

## Routing table

| Situation | Read before acting |
| --- | --- |
| `new List<T>(n)` + `AddRange`, `new HashSet<T>(comparer) { ... }`, builder authoring, or CS0121/CS0411 at a `with(...)` element | `references/collection-expression-arguments.md` |
| Result-or-error returns, command/message dispatch, replacing marker interfaces or `OneOf`, any `union` declaration or union pattern, CS8121/CS8655, `default` union values | `references/unions.md` |
| Replacing an abstract base used for pattern matching, adding a subtype, exhaustive switch over a base class, CS8509/CS8510 on a hierarchy | `references/closed-hierarchies.md` |
| `this[...]` in an extension block, making a type indexable/sliceable/list-pattern-able from outside, EF Core query shape | `references/extension-indexers.md` |
| Boolean found-flags, `goto END`/`goto NEXT` loop exits, IDE0410 suggestions | `references/labeled-breaks.md` |
| Multi-targeting (`netstandard2.0`, .NET Framework) with interface helpers | `references/interfaces-and-runtimes.md` |
| `unsafe`, `safe`, `unsafe(expr)`, requires-unsafe APIs, CS9363/CS9376/CS9392/CS9401 — **only after the user opted in** | `references/memory-safety-preview.md` |
| Anything breaking after an SDK upgrade (CS9370/CS9380/CS1519/CS7083, span safe-context, `nameof(this.P)`) | `references/breaking-changes.md` |

Union or closed hierarchy? The decision table lives at the end of `references/closed-hierarchies.md`.
Short version: cases are foreign/unrelated types → `union`; cases are your own family sharing state
or virtual behavior → `closed`.

## Non-negotiables when writing C# 15

- [ ] Confirm the project is on C# 15 (`net11.0`, or an explicit `LangVersion` of 15). Don't add
      `latest`.
- [ ] Use `[with(...), ...]` instead of construct-then-add boilerplate when a capacity, comparer or
      constructor argument matters. Never use it with arrays or spans.
- [ ] Model "one of these types" with `union`. Model "one of my subclasses" with `closed`. Switch
      on the union or the closed base, not on `.Value` or `object`.
- [ ] In exhaustive switches, prefer explicit `null` arms over `_`, and always handle `null` when
      default union values or nullable inputs can arrive.
- [ ] Seal the leaves of closed hierarchies, and treat their subtype lists as public API.
- [ ] Hand-write a union with `TryGetValue`/`HasValue` for value-type cases on hot paths.
- [ ] Give each labeled loop a unique label in the method. `continue` never targets a `switch`.
- [ ] Don't use extension indexers on arrays or strings, or inside expression trees and
      `IQueryable` queries.
- [ ] Touch the memory-safety preview only when the user has opted in. Keep `unsafe` blocks
      minimal, and document every requires-unsafe member with `/// <safety>`.

## Diagnostic quick reference

| Diagnostic | Meaning | Read |
| --- | --- | --- |
| CS8121 | A type pattern isn't compatible with any union case type (for example `pet is Pet`). | `references/unions.md` |
| CS8509 | Switch not exhaustive: a missing union case, or an inaccessible closed-hierarchy subtype. | `references/unions.md`, `references/closed-hierarchies.md` |
| CS8655 | Union contents are maybe-null and there's no `null` arm. | `references/unions.md` |
| CS8510 | Unreachable arm (a base arm after its subtypes, or `Car` before `Sedan`). | `references/closed-hierarchies.md` |
| CS0121 / CS0411 | `with(...)` arguments don't pick overloads or infer type arguments. | `references/collection-expression-arguments.md` |
| CS9370 / CS9380 / CS1519 | `union`/`closed` used as an identifier. Escape it with `@`. | `references/breaking-changes.md` |
| CS9363 | A member with pointer parameters (for example an indexer) called outside `unsafe` (preview). | `references/memory-safety-preview.md` |
| CS9376 | A requires-unsafe parameterless constructor used where `new()`/`struct` is required (preview). | `references/memory-safety-preview.md` |
| CS9392 | An explicit-layout field needs `safe`/`unsafe` (preview). | `references/memory-safety-preview.md` |
| CS9401 / CS0227 | `safe`/`unsafe` modifiers or blocks used without `AllowUnsafeBlocks`. | `references/memory-safety-preview.md` |
| `SwitchExpressionException` | Run time: a `default` union (null contents) reached a switch with no `null` arm. | `references/unions.md` |

## Sources

- What's new in C# 15: https://learn.microsoft.com/dotnet/csharp/whats-new/csharp-15
- Collection expressions (arguments): https://learn.microsoft.com/dotnet/csharp/language-reference/operators/collection-expressions#collection-expression-arguments
- Spec, collection expression arguments: https://learn.microsoft.com/dotnet/csharp/language-reference/proposals/csharp-15.0/collection-expression-arguments
- Union types: https://learn.microsoft.com/dotnet/csharp/language-reference/builtin-types/union
- Spec, unions: https://learn.microsoft.com/dotnet/csharp/language-reference/proposals/csharp-15.0/unions
- `closed` modifier: https://learn.microsoft.com/dotnet/csharp/language-reference/keywords/closed
- Patterns (closed hierarchy and union patterns): https://learn.microsoft.com/dotnet/csharp/language-reference/operators/patterns
- Spec, closed hierarchies: https://learn.microsoft.com/dotnet/csharp/language-reference/proposals/csharp-15.0/closed-hierarchies
- Extension members (indexers): https://learn.microsoft.com/dotnet/csharp/language-reference/keywords/extension#extension-indexers
- Spec, extension indexers: https://learn.microsoft.com/dotnet/csharp/language-reference/proposals/csharp-15.0/extension-indexers
- Jump statements: https://learn.microsoft.com/dotnet/csharp/language-reference/statements/jump-statements
- Spec, labeled break/continue: https://learn.microsoft.com/dotnet/csharp/language-reference/proposals/csharp-15.0/labeled-break-continue
- IDE0410: https://learn.microsoft.com/dotnet/fundamentals/code-analysis/style-rules/ide0410
- Interface static members and runtime support: https://learn.microsoft.com/dotnet/csharp/language-reference/keywords/interface#static-interface-members-and-runtime-support
- Unsafe code (updated memory safety model): https://learn.microsoft.com/dotnet/csharp/language-reference/unsafe-code
- Spec, memory safety: https://learn.microsoft.com/dotnet/csharp/language-reference/proposals/unsafe-evolution
- Compiler options (enabling the memory safety rules): https://learn.microsoft.com/dotnet/csharp/language-reference/compiler-options/language#enable-the-updated-memory-safety-rules
- Compiler breaking changes in .NET 11: https://learn.microsoft.com/dotnet/csharp/whats-new/breaking-changes/compiler%20breaking%20changes%20-%20dotnet%2011
- Roslyn language feature status: https://github.com/dotnet/roslyn/blob/main/docs/Language%20Feature%20Status.md
