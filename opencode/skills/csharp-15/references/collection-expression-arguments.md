# Collection expression arguments: `with(...)`

Pass arguments to the target collection's constructor or builder method from inside a collection
expression. The `with(...)` element must be the **first** element.

```csharp
string[] values = ["one", "two", "three"];

List<string> names = [with(capacity: values.Length * 2), .. values];          // List<T>(int capacity)
HashSet<string> set = [with(StringComparer.OrdinalIgnoreCase), "Hello", "HELLO", "hello"]; // 1 element
IList<int> numbers = [with(capacity: 100), 1, 2, 3];                           // creates List<int>(100)
List<int> copy = [with([1, 2]), 3];                                            // List<T>(IEnumerable<T>): 1, 2, 3
```

## How `with(...)` binds, by target type

| Target type | What `with(args)` does |
| --- | --- |
| Class/struct implementing `IEnumerable` (no `[CollectionBuilder]`, not a type parameter) | Overload resolution over accessible instance constructors. Named arguments and `params` (expanded form) work. |
| Type with `[CollectionBuilder(typeof(B), "Create")]` | Overload resolution over `Create` overloads, treating each as if its last parameter were removed. `args` go **before** the final `ReadOnlySpan<T>` parameter, which is always last. |
| `IEnumerable<T>`, `IReadOnlyCollection<T>`, `IReadOnlyList<T>` | Only `with()` (empty) is allowed. It means the same as no `with`. |
| `ICollection<T>`, `IList<T>` | `with()` or `with(int capacity)`. The compiler constructs a `List<T>`. |
| Arrays, `Span<T>`, `ReadOnlySpan<T>`, anything else | **Error**, even for an empty `with()`. |

## Builder types can take configuration parameters

C# 15 lets `Create` methods take extra parameters before the span. A type can have several `Create`
overloads.

```csharp
[CollectionBuilder(typeof(MySetBuilder), nameof(MySetBuilder.Create))]
public sealed class MySet<T> : IEnumerable<T>
{
    private readonly HashSet<T> _items;

    internal MySet(ReadOnlySpan<T> items, IEqualityComparer<T>? comparer = null)
    {
        _items = new HashSet<T>(comparer);
        foreach (var item in items) _items.Add(item);
    }

    public IEnumerator<T> GetEnumerator() => _items.GetEnumerator();
    IEnumerator IEnumerable.GetEnumerator() => GetEnumerator();
}

public static class MySetBuilder
{
    public static MySet<T> Create<T>(ReadOnlySpan<T> items) => new(items);
    public static MySet<T> Create<T>(IEqualityComparer<T> comparer, ReadOnlySpan<T> items) => new(items, comparer);
}

MySet<string> s = [with(StringComparer.OrdinalIgnoreCase), "A", "a", "B"]; // two elements
MySet<string> t = [with(), "x"];                                          // calls Create(ReadOnlySpan<T>)
```

When you author a builder, put the element span **last** and the configuration parameters first.
Don't make the span the first parameter with optional parameters after it, because `with(...)`
can't bind to that shape.

## Types that require constructor arguments now work

Before C# 15, a collection-expression target needed a parameterless constructor. Now a type whose
constructors all take arguments is a valid target, but only when the expression has a `with(...)`:

```csharp
public class NamedValues(string name) : List<int>
{
    public string Name { get; } = name;
}

NamedValues readings = [with("temperature"), 18, 21, 24];
// NamedValues bad = [18, 21, 24];   // error: no parameterless constructor and no with(...)
```

## Evaluation order

The `with(...)` arguments are evaluated first, then the elements, left to right, each exactly once.
For `.. GetItems()`, `GetItems()` is *called* in its left-to-right position, but *enumerating* its
result may happen after later elements are evaluated. Don't rely on enumeration side effects being
ordered relative to later elements.

## Overload resolution and inference ignore the arguments

Only the *presence* of `with(...)` affects whether a collection expression converts to a candidate
type. The arguments themselves don't. They take part in resolution only after the target type is
fixed.

```csharp
static void Print(List<string> values) { }
static void Print(HashSet<string> values) { }

Print([with(StringComparer.OrdinalIgnoreCase), "one", "ONE"]); // CS0121: ambiguous
HashSet<string> h = [with(StringComparer.OrdinalIgnoreCase), "one", "ONE"];
Print(h);                                                        // OK

static void Use<T>(List<T> values) { }
Use([with(10)]);        // CS0411: T can't be inferred from a capacity argument
Use<int>([with(10)]);   // OK
```

## Mistakes to avoid

- Don't put `with(...)` anywhere but first. That's a compile error.
- Don't pass `dynamic` arguments; that's an error. `__arglist` isn't supported either.
- Don't use `with` on arrays or spans. Choose `List<T>`, `HashSet<T>` or a builder type instead.
- `[with(default)]` on `List<int>` is ambiguous between constructors. Use named arguments
  (`with(capacity: n)`) for clarity.
- `IReadOnlyList<T> x = [with(capacity: 10)]` is an error because read-only interfaces accept only
  `with()`. Target `List<T>` when you want to set the capacity.
- Dictionary-interface targets (`IDictionary<K,V>`, `IReadOnlyDictionary<K,V>` with comparer
  arguments) appear in the spec, but they belong to the separate *dictionary expressions* proposal,
  which isn't in C# 15's feature list (Roslyn lists it as in progress). Don't rely on dictionary
  expressions or `key: value` elements in C# 15 code.
- `with(...)` is a collection-expression feature. Classic initializers
  (`new List<T>(capacity) { ... }`) are unchanged.
- **Good refactors:** `new List<T>(n)` followed by `AddRange`, and `new HashSet<T>(comparer) { ... }`,
  become `[with(n), .. src]` and `[with(comparer), a, b]`.
