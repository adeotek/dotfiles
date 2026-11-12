# Memory safety model (preview)

This is the first step of a multi-release redesign. `unsafe` moves from marking code that
*mentions pointers* to marking code that *accesses unmanaged memory*. An `unsafe` member becomes a
contract that **its callers** must uphold. **Only use this when the user opts in.** It requires
preview settings.

## Enabling it (two independent switches)

```xml
<PropertyGroup>
  <LangVersion>preview</LangVersion>                                <!-- syntax + pointer relaxations -->
  <Features>$(Features);updated-memory-safety-rules</Features>       <!-- the new rules (requires-unsafe) -->
  <AllowUnsafeBlocks>true</AllowUnsafeBlocks>                       <!-- needed to write unsafe/safe/unsafe(...) -->
</PropertyGroup>
```

In a file-based app:

```csharp
#:property LangVersion=preview
#:property Features=$(Features);updated-memory-safety-rules
```

- `AllowUnsafeBlocks` is independent of the other two. A project with the updated rules but without
  `AllowUnsafeBlocks` simply gets errors when it calls requires-unsafe APIs.
- A future stable `<MemorySafetyRules>` property is planned but **not implemented**. Don't use it.
- Some docs and diagnostics call this language version "C# 16" (`langversion:16`), meaning the
  preview version that follows C# 15.

## What needs an `unsafe` context

| Operation | Original model | Preview model |
| --- | --- | --- |
| Declare a pointer type, take `&x` | unsafe | **safe** |
| `fixed` statement | unsafe | **safe** |
| `stackalloc` converted to a pointer | unsafe | **safe** |
| `sizeof(T)` for any unmanaged `T` | unsafe | **safe** |
| `*p`, `p->m`, `p[i]` | unsafe | unsafe |
| Function pointer invocation | unsafe | unsafe |
| Fixed-size buffer element access | unsafe | unsafe |
| Calling a member marked `unsafe` | no caller requirement | **caller needs unsafe** (with the updated rules) |
| `stackalloc` to `Span<T>` without an initializer in a `[SkipLocalsInit]` member | safe | **unsafe** (with the updated rules) |

The relaxations (the first four rows) apply with `LangVersion=preview` even when the assembly
hasn't opted in to the updated rules.

## Requires-unsafe members (with the updated rules)

- `unsafe` on a member's signature makes it **requires-unsafe**: every caller must be in an
  `unsafe` context. It no longer creates an unsafe context for the body, so wrap the dereference
  in an inner `unsafe { }` block.

```csharp
public static unsafe int ReadInt32(byte* source)   // obligation flows to callers
{
    unsafe { return *(int*)source; }               // unsafe operation scoped inside
}

unsafe { int v = ReadInt32(buffer); }              // the caller takes on the audit
```

- **Propagate or discharge.** A member either marks itself `unsafe` (propagate), or validates its
  inputs, uses an inner `unsafe` block and keeps a safe signature (discharge). A discharging member
  is an *unsafe boundary*.

```csharp
public static int SumBytes(byte[] source)          // safe signature
{
    ArgumentNullException.ThrowIfNull(source);
    fixed (byte* first = source)                   // no unsafe needed to pin
    {
        unsafe
        {
            // SAFETY: the null check and source.Length bound every read to the pinned array.
            int total = 0;
            for (int i = 0; i < source.Length; i++) total += first[i];
            return total;
        }
    }
}
```

- **Document contracts.** Put a `/// <safety>...</safety>` block on each requires-unsafe member
  describing what callers must guarantee, which an analyzer can require. Put a `// SAFETY:` comment
  inside each `unsafe` block explaining why that spot is sound.
- **Errors under the updated rules:**
  - `unsafe` on a type declaration, a static constructor, a finalizer, a `delegate` or a lambda.
  - Adding `unsafe` to an override or implementation of a member that isn't requires-unsafe.
  - Converting a requires-unsafe method to a delegate outside an unsafe context.
- An `unsafe` constructor gets an unsafe context in its `: base(...)`/`: this(...)` initializer.
- A type whose parameterless constructor is `unsafe` doesn't satisfy a `new()` or `struct`
  constraint in declarations such as base types, field types and aliases (CS9376). In expressions,
  it satisfies them only inside an `unsafe` context.
- Local functions and lambdas don't inherit `unsafe` or `safe` from the containing member. Mark a
  local function `unsafe` explicitly. Lambdas can't be `unsafe`.
- Both parts of a `partial` member must agree on `unsafe`/`safe`.
- **Properties:** put `unsafe`/`safe` on the property *or* on individual accessors, not both, and
  not the same modifier on every accessor. Event accessors can't be marked individually.
- **Fields:** an `unsafe` field forces every write into an `unsafe` context. Use it when the field's
  type can't express an invariant, such as a `byte*` plus a length. `readonly unsafe` adds a
  write-once guarantee. Marking a property or event `unsafe` doesn't affect its backing field.

## The `safe` keyword

`safe` attests that a declaration is sound. Ordinary declarations are safe by default, so use it
only where the compiler requires a choice:

- every **`extern`** method, including `LibraryImport` partials,
- every instance field of a type with `LayoutKind.Explicit`, `[ExtendedLayout]`, or a nonzero
  `Pack`/`Size`.

For a backing field, annotate the auto-property or field-like event instead. Static and const
fields are exempt.

```csharp
[LibraryImport("libc")]
internal static safe partial int getpid();                 // no pointers: attest safe

[LibraryImport("libc", StringMarshalling = StringMarshalling.Utf8)]
internal static unsafe partial nint strlen(byte* str);      // dereferences a pointer: propagate
```

`safe` and `unsafe` can't both appear on one declaration. There's no `safe { }` block. Newer
compilers (after .NET 11.0.100) require `AllowUnsafeBlocks` for both declaration modifiers and
report CS9401 without it.

## `unsafe(expression)`

`unsafe(expression)` creates an unsafe context for exactly one expression, ending at the closing
parenthesis. Use it where a block can't go, or to keep the unsafe scope minimal:

```csharp
static readonly int Signature = unsafe(ReadSignature());       // field initializer
return await unsafe(ReadSignatureCoreAsync());                 // only the call is unsafe, not the await
int b = unsafe(c[null]);                                       // indexer with a pointer parameter (CS9363 otherwise)
```

It also works in constructor initializers and `catch (...) when (...)` filters. It requires
`AllowUnsafeBlocks` and the preview language version.

## Async and other details

- `await` is now allowed inside `unsafe` blocks, but **not inside a `fixed` statement**. Pointers
  kept alive across an `await` are your responsibility.
- **Cross-assembly behavior.** An opted-in assembly gets `[module: MemorySafetyRules(...)]`, and its
  requires-unsafe members get `[RequiresUnsafe]`. You can't apply either attribute yourself.

| Caller | Callee | Result |
| --- | --- | --- |
| Updated rules | Updated rules | `unsafe` markers flow through metadata. Calls need an unsafe context. |
| Updated rules | Original rules | Compat mode: any callee member with a pointer or function pointer in its signature is treated as requires-unsafe. |
| Original rules | Updated rules | The original pointer rules apply. A requires-unsafe member with no pointer in its signature is callable from safe code. |

## Breaking changes when moving to the preview version

- Lambdas can now bind to delegates with pointer parameters, so overloads can become ambiguous
  (CS0121). Fix this with explicit lambda parameter types: `M((int x) => { })`.
- `safe` becomes a modifier, so a type named `safe` needs `@safe`.
- Indexers and members with pointer parameters now need `unsafe` at the call site (CS9363).
