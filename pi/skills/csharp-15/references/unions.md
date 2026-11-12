# Union types

A union value is exactly one of a fixed set of **case types**. The compiler provides implicit
conversions from each case type, exhaustive `switch` checking and null-state tracking. C# unions
are unions of *types*, not tagged unions. For a discriminated union, declare fresh record types as
the cases.

```csharp
public record class Cat(string Name);
public record class Dog(string Name, string Breed);
public record class Bird(string Name);

public union Pet(Cat, Dog, Bird);

Pet pet = new Dog("Rex", "Labrador");   // implicit union conversion

string name = pet switch
{
    Dog d => d.Name,
    Cat c => c.Name,
    Bird b => b.Name,
};                                      // exhaustive: no `_` arm needed
```

## When to use a union

- **Result-or-error returns** that callers must handle completely, for example
  `union Result<T>(Ok<T>, Error)`.
- **Message or command dispatch over a closed set**, where adding a case should produce warnings at
  every `switch` that doesn't handle it yet.
- **Replacing marker interfaces or abstract base classes** that exist only to group types for
  pattern matching. A union needs no inheritance and no shared members.
- **Combining types you don't own**, such as `union IntOrString(int, string)`. Inheritance can't
  express that.

Use a **closed hierarchy** (see `closed-hierarchies.md`) instead when the cases are your own classes,
share members or state, or need reference semantics through a common base class.

## Declaration syntax and rules

```
[attributes] [modifiers] [partial] union Name[<T...>](CaseType1, CaseType2, ...) [: interfaces] [where ...]
    { members }   or   ;
```

- **Case types** can be any type convertible to `object`: classes, structs, interfaces, type
  parameters, nullable types and other unions. Cases may overlap.
- **Lowering.** A union declaration lowers to a plain `struct` (not a `record struct`). The struct
  has `[Union]`, implements `IUnion`, has a `public object? Value { get; }` and one public
  constructor per case type. Value-type cases are **boxed** into the single `object?` field.
- **No record behavior.** A union adds no equality members, cloning or deconstruction. It answers
  "which case is it?", not "what fields does it have?"
- **Body restrictions.** The body may declare methods, computed properties, operators and
  interfaces, but **not** instance fields, auto-properties or field-like events. It also can't
  declare a public single-parameter constructor, because those are the generated case
  constructors. Any constructor you write must chain through `this(...)`, directly or indirectly,
  to a generated one. A member that conflicts with a generated member is an error.
- `union` is contextual. Escape an identifier with `@union`.

```csharp
public record class Meters(double Value);
public record class Feet(double Value);

public union Length(Meters, Feet)
{
    // Inside the body, `this switch` uses union matching on the contents.
    public double TotalMeters => this switch
    {
        Meters m => m.Value,
        Feet f => f.Value * 0.3048,
        null => throw new InvalidOperationException("The Length has no value."),
    };

    public Length Add(Length other) => new Meters(TotalMeters + other.TotalMeters);
}

// Generic unions and "discriminated" style with fresh case types:
public sealed record class None;
public sealed record class Some<T>(T Value);
public union Option<T>(None, Some<T>);

public sealed record class Ok<T>(T Value);
public sealed record class Error(string Message);
public union Result<T>(Ok<T>, Error);

static Result<int> Parse(string text)
{
    if (int.TryParse(text, out var number))
        return new Ok<int>(number);   // union conversion Ok<int> -> Result<int>
    return new Error($"'{text}' is not a number");
}
```

## Conversions

- An implicit union conversion exists from `E` to union `U` when `E` has a *standard* implicit
  conversion to some case type `C`. It runs the matching creation member, for example
  `new Pet(dog)`. When `U` is a struct, `E` also converts to `U?`.
- If more than one case type is equally applicable, the conversion is **ambiguous** (an error).
- **A user-defined `implicit operator` beats the union conversion.** A user-defined `explicit`
  operator wins only when you write a cast. Without a cast, the union conversion is used.
- A union conversion isn't a standard conversion, so it doesn't chain with a user-defined
  conversion or another union conversion.
- There are **no explicit union conversions** and **no lifted ones**. If `int` is a case type,
  `int?` doesn't convert to the union. Make `int?` the case type if you need that.

## Pattern matching: what each pattern tests

On a union value, type-based patterns look **inside** the union. Untyped recursive patterns look at
the **union instance**.

| Pattern on a union expression | Tests |
| --- | --- |
| Type or declaration pattern: `Dog`, `Dog d` | The **contents** (`Value`) |
| Typed property/positional pattern: `Dog { Breed: "Lab" }` | The contents' type, then the nested patterns on that case value |
| Untyped property/positional pattern: `{ Name: "Rex" }` | The **union instance's** own members or `Deconstruct` |
| List pattern `[...]` | The **union instance's** count and indexer, not the contents' |
| `var x` / `_` | Captures or matches the **union instance** without unwrapping |
| Constant/relational pattern, including `null` | The contents. `null` also matches a null class-union reference or an empty `Nullable<U>`. |

```csharp
public union Pet(Cat, Dog)
{
    public string Name => this switch { Cat c => c.Name, Dog d => d.Name, null => "" };
}

Pet pet = new Cat("Rex");
pet is Dog { Breed: "Labrador" };  // false: tests the contents
pet is { Name: "Rex" };            // true: uses the union's own Name property
pet is not null;                   // true: the contents are non-null (the "has a value" test)

Pet empty = default;
empty is { };                      // TRUE: a non-nullable struct union instance always matches { }
empty is not null;                 // false: the contents are null
```

- `pet is Pet` is **error CS8121**, because `Pet` isn't one of its own case types. A type pattern
  must be compatible with at least one case type. To test for contents, use `is not null` or
  `.Value is not null`. To capture the union, use `var`.
- `x is T` (the is-type operator) behaves as a type pattern on unions.
- Logical patterns keep these distinctions. `var p and not null` captures the union and checks for
  contents. In `Dog and { Breed: "Lab" }`, the type pattern passes the unwrapped `Dog` to the
  property pattern.
- **Avoid recursive unions** such as `union Pet(Cat, Dog, Pet)`. There, `pet is Pet` tests for a
  *contained* `Pet`, which is easy to misread.
- A type parameter constrained to a union type is **never** treated as a union. `u is int` on
  `T u where T : MyUnion` is ordinary type matching.
- Switch on the union itself (`u switch`, or `this switch` inside the body) to get union
  exhaustiveness. Whether patterns over `.Value` (an `object?`) use the case-type knowledge is
  still an open question in the spec, so don't rely on it.

## Exhaustiveness and null: the subtle part

- A `switch` *expression* that handles every case type is exhaustive, with no `_` arm needed, as
  long as nullability analysis considers the contents non-null.
- **Prefer a `null` arm over `_` or `var` arms.** A `_` arm silently swallows a newly added case
  type. A `null` arm keeps the missing-case warning (CS8509) working.
- If any case type is nullable, for example `union NullablePet(Cat?, Dog, Bird)`, the default null
  state of `Value` is "maybe null". Omitting a `null` arm then gives **CS8655**.
- **Trap:** `default(Pet)` holds **null** contents. This happens for default-initialized fields,
  array elements and `default` itself. Yet when all case types are non-nullable, the compiler
  tracks `Value` as "not null" and doesn't warn about a missing `null` arm, so the switch throws
  `SwitchExpressionException` at run time. **Add a `null` arm whenever default union values can
  reach the switch.**
- Null-state rules:
  - The default state of `Value` is "maybe null" if any case type is maybe-null, and "not null"
    otherwise.
  - Creating a union from a value copies that value's null state.
  - A `true` result from `HasValue` or `TryGetValue` makes `Value` "not null" on that branch.

```csharp
static string Describe(Pet? pet) => pet switch   // a nullable union struct works too
{
    Dog d => d.Name,
    Cat c => c.Name,
    Bird b => b.Name,
    null => "no pet",   // matches both an empty Pet? and a Pet whose Value is null
};
```

## Custom (hand-written) union types

Write a union by hand when you need to:

- adapt an existing type,
- use a different storage strategy, such as no boxing or a tagged layout,
- make a class-based union with reference semantics, or
- control the layout for interop.

**The basic union pattern** (all members public):

1. The type has `[System.Runtime.CompilerServices.Union]`.
2. It has one or more public constructors with exactly **one by-value or `in` parameter**. Each
   parameter type defines a case type.
3. It has a public `Value` property of type `object?` (or `object`) with a `get` accessor.

Implementing `IUnion` (`object? Value { get; }`) is recommended. The generated unions implement it,
and it allows runtime checks like `x is IUnion { Value: null }`.

```csharp
[System.Runtime.CompilerServices.Union]
public struct Shape : System.Runtime.CompilerServices.IUnion
{
    private readonly object? _value;
    public Shape(Circle value) { _value = value; }
    public Shape(Rectangle value) { _value = value; }
    public object? Value => _value;
}
```

**Non-boxing access pattern (optional, for performance).** Add `public bool HasValue { get; }` and
one `public bool TryGetValue(out C value)` per case type. With these, the compiler calls
`TryGetValue` for type patterns and `HasValue` for `null` patterns instead of boxing through
`Value`. Each member is independently optional, and neither is a fallback for the other. When a
case type is a nullable value type such as `int?`, the `out` parameter is the underlying `int`. The
compiler only picks a `TryGetValue` through identity, implicit reference or boxing conversions.

```csharp
[System.Runtime.CompilerServices.Union]
public struct IntOrBool : System.Runtime.CompilerServices.IUnion
{
    private readonly int _int; private readonly bool _bool; private readonly byte _tag; // 0 none, 1 int, 2 bool
    public IntOrBool(int? value) { if (value.HasValue) { _int = value.Value; _tag = 1; } }
    public IntOrBool(bool? value) { if (value.HasValue) { _bool = value.Value; _tag = 2; } }
    public object? Value => _tag switch { 1 => _int, 2 => _bool, _ => null };
    public bool HasValue => _tag != 0;
    public bool TryGetValue(out int value) { value = _int; return _tag == 1; }
    public bool TryGetValue(out bool value) { value = _bool; return _tag == 2; }
}

string s = new IntOrBool((int?)42) switch { int i => $"int: {i}", bool b => $"bool: {b}" }; // no boxing
```

**Union member provider.** Use a provider when the constructors must be private, when creation
needs a factory, or when the type is a `record class`, a case the docs call out. Nest a **public**
interface named `IUnionMembers` in the union type and implement it. The compiler then looks for
union members **only** on that interface (inherited members included), never on the type itself.
The interface declares:

- a static `Create(C value)` method per case type, whose return type is identity-convertible to the
  union,
- `Value`,
- optionally `TryGetValue` and `HasValue`.

```csharp
[System.Runtime.CompilerServices.Union]
public struct Outcome<T> : Outcome<T>.IUnionMembers
{
    private readonly object? _value;
    private Outcome(object? value) => _value = value;

    public interface IUnionMembers
    {
        static Outcome<T> Create(T? value) => new(value);
        static Outcome<T> Create(Exception? value) => new(value);
        object? Value { get; }
        bool TryGetValue(out T value);
        bool TryGetValue(out Exception value);
    }

    object? IUnionMembers.Value => _value;
    public bool TryGetValue(out T value) { if (_value is T t) { value = t; return true; } value = default!; return false; }
    public bool TryGetValue(out Exception value) { if (_value is Exception e) { value = e; return true; } value = default!; return false; }
}
```

**Class-based unions** work the same way: put `[Union]` on a class. There, `null` matches both a
null reference and a null `Value`. Seal class-based unions. Per the spec discussion, a derived
class picks up `IUnion` but gets its own constructor set, which produces confusing union matching.

**Well-formedness contract.** The compiler trusts these rules without checking them, so a type
that breaks them gets wrong matching behavior:

- **Soundness:** `Value` is always null or an instance of a case type, even for `default`.
- **Stability:** a union created from case `C` reports `C`, or null if the input was null.
- **Creation equivalence:** if a value converts to two case types, both constructors behave the
  same for it.
- **Consistency:** `HasValue` and `TryGetValue` agree with `Value`.

## Mistakes to avoid

- Don't add instance fields or auto-properties to a `union` body. Put data in the case types.
- Don't use `_ => ...` to "be safe". Use `null => ...` so that new cases still warn.
- Don't assume generated unions are allocation-free: value-type cases box. On hot paths, hand-write
  a union with the non-boxing pattern.
- Don't write `x is MyUnion` to test whether a union holds something. Use `is not null`.
- Don't confuse `{ }` with "has a value". On a struct union, `{ }` always matches.
- Don't nest unions or list a union as its own case unless you're sure you need it.
- Union struct functions that read `this` more than once can see torn updates when a variable is
  reassigned concurrently. If that matters, copy `this` into a local first.
