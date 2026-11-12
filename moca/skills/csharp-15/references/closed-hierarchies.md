# Closed hierarchies: `closed`

`closed` on a class means only its **declaring assembly (and module)** may declare **direct**
subclasses. Because the set of direct descendants is fixed, a `switch` expression that handles them
all is exhaustive without a default arm, including in consuming assemblies.

```csharp
// Assembly 1
public closed record class JobStatus;
public record class Queued : JobStatus;
public record class Running(int PercentComplete) : JobStatus;
public record class Completed(TimeSpan Elapsed) : JobStatus;
public sealed record class Failed(string Error) : JobStatus;

// Any assembly
public static string Describe(JobStatus status) => status switch
{
    Queued => "waiting to start",
    Running(var percent) => $"{percent}% complete",
    Completed(var elapsed) => $"finished in {elapsed.TotalSeconds:F1}s",
    Failed(var error) => $"failed: {error}",
};  // no CS8509

// Assembly 2
public record class Paused : JobStatus;   // error: 'JobStatus' is a closed class
```

## Declaration rules

- `closed` applies **only to classes**, including record classes, not to structs or interfaces.
- A closed class is **implicitly `abstract`**, so you can't instantiate it. Combining `closed` with
  `sealed`, `static` or an explicit `abstract` is an error.
- Direct subtypes must be declared in the same assembly **and module** as the closed class.
- **It isn't transitive.** A plain subclass of a closed class can be extended from other
  assemblies. Mark the leaves `sealed`, or the intermediate levels `closed`, to lock them down.
- **Generic rule:** a generic class that directly derives from a closed class must use **every**
  one of its type parameters in the base class specification.

```csharp
public closed record class Tree<T>;
public record class Leaf<T>(T Value) : Tree<T>;                        // OK
public record class Branch<T>(Tree<T> Left, Tree<T> Right) : Tree<T>;  // OK
public record class Constant<U>(U Value) : Tree<int>;                  // error: U not used in the base
```

- `closed` is contextual. A type named `closed` now needs `@closed` (CS9380), and a field of type
  `closed` may now parse as a modifier (CS1519).

## Exhaustiveness rules

- **Only direct descendants count.** Indirect descendants are covered by their parent's arm.
  Ordinary subsumption still applies: put a more-derived arm (`Sedan`) **before** its base (`Car`).
  The reverse order gives CS8510 (unreachable).
- An arm for the closed base type after all direct descendants is an **unreachable-case error**.
- **Accessibility matters.** If a direct descendant isn't accessible at the switch site (for
  example, an `internal` subtype seen from another assembly, or a `protected` nested subtype), the
  switch isn't exhaustive (CS8509). Fix this with a `_` arm, a base-type arm, or by making every
  direct subtype at least as accessible as the base.
- **Nullable input:** a switch over `JobStatus?` also needs a `null` arm.
- **Type parameters:** a switch over `X` where `X : JobStatus` is exhaustive on the same terms as a
  switch over `JobStatus`.
- **Generic closed bases:** only subtypes that can actually produce the given construction are
  required. For `C<string>`, a `D2<V> : C<V[]>` case isn't needed. Constraints on subtypes
  **aren't** used to rule cases out, and a non-speakable generic subtype makes the switch
  non-exhaustive. Add a base-type arm in those situations.
- A closed class with **no** subtypes isn't exhausted by an empty switch.
- Exhaustiveness applies to `switch` *expressions*, which is where the missing-case diagnostic
  comes from.

## Other effects

- **Sealed hierarchy interface checks.** When every class in a closed hierarchy is `sealed` or
  `closed`, an explicit cast to an interface that no class in the hierarchy implements is a compile
  error, the same rule as for a sealed class.
- **Metadata.** The class gets `[IsClosedType]`, and every constructor gets
  `[CompilerFeatureRequired("ClosedClasses")]`. Older compilers and VB therefore can't derive from
  it.
- **Versioning.** Adding `closed` to a published class, or adding a new direct subtype to a closed
  class, is a **breaking change** for consumers, whose exhaustive switches stop being exhaustive.
  Treat the subtype list as public API.

## Union or closed hierarchy?

| Choose a union when | Choose a closed hierarchy when |
| --- | --- |
| The cases are existing or unrelated types (`int`, `string`, third-party types) | You own every case type and they form one family |
| You don't want inheritance or shared members | The cases share base members, state or virtual behavior |
| A lightweight struct wrapper suits you (watch boxing) | You want reference semantics and polymorphism |
| The same type might belong to several unions | A type belongs to exactly one family |
