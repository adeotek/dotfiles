# Other compiler breaking changes in the .NET 11 SDK

Watch for these when you upgrade:

- `[with(x, y), z]` is now collection arguments, not a call to a method named `with`, at
  LangVersion 15 or later. Use `@with(x, y)` to call the method.
- `union Foo;` inside a type can now parse as a union declaration (CS9370). Use `@union`.
- A type named `closed` needs `@closed` (CS9380), and fields of that type may produce CS1519.
- A `Span<T>`/`ReadOnlySpan<T>` collection expression now has *declaration-block* safe-context.
  Assigning a loop-local `Span<int> items = [x];` to an outer `scoped` span is now an error. Use an
  array, or hoist the span out of the loop.
- `nameof(this.P)` inside an attribute is now an error. Write `nameof(P)`.
- `(X.Y) when` in a switch-expression arm now parses as the constant pattern `(X.Y)` followed by a
  `when` clause, not as a cast.
- `x && y`, where `x` is statically an interface type and `y` is `dynamic`, is now error CS7083.
  Cast `x` to a concrete type or to `dynamic`.
- Synthesized `ref readonly`-returning delegates and `ref readonly` local functions now need
  `System.Runtime.InteropServices.InAttribute` (CS0518 if it's missing).
