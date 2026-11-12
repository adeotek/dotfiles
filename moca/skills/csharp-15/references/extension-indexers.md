# Extension indexers

C# 14 extension blocks can now declare **indexers**. Indexers are instance members, so the block
needs a **named receiver**.

```csharp
public static class SequenceIndexer
{
    extension(IEnumerable<int> sequence)
    {
        public int this[int index] => sequence.ElementAt(index);
    }
}

IEnumerable<int> numbers = Enumerable.Range(1, 10);
int third = numbers[2];

public static class SettingsExtensions
{
    extension(IDictionary<string, string> settings)
    {
        public string this[string section, string key]          // get + set
        {
            get => settings[$"{section}:{key}"];
            set => settings[$"{section}:{key}"] = value;
        }
    }
}
IDictionary<string, string> settings = new Dictionary<string, string>();
settings["Logging", "Level"] = "Debug";
```

## Rules

- Extension indexers support everything ordinary indexers do: `get` and `set`, expression bodies,
  `ref`-returning accessors, `scoped` parameters, attributes and `params`.
- **Not allowed:** `abstract`, `virtual`, `override`, `new`, `sealed`, `partial`, `protected` and
  related modifiers, and `init` accessors. These are the existing extension-member restrictions.
- Every type parameter of a generic extension block must appear in the receiver or the indexer's
  parameters.
- `[IndexerName("X")]` changes the metadata names: an `X` property and `get_X`/`set_X`
  implementation methods, `Item` by default. The implementation methods are static methods on the
  enclosing class with the receiver first, so you can disambiguate with
  `SettingsExtensions.get_Item(settings, "Logging", "Level")`.
- **Lookup order** (the first applicable tier wins):
  1. real instance indexers,
  2. implicit `Index`/`Range` support from instance members,
  3. extension indexers,
  4. implicit `Index`/`Range` support from extension members.

  An extension can never hijack an existing instance indexer.
- Within each scope, lookup tries `Length` before `Count`, starting with instance members and then
  moving outward through extension scopes.
- **Type inference** uses only the receiver and the index arguments, never the assigned value.
  `i[42, null] = new object();` fails inference where calling `E.set_Item(...)` would succeed.
- Null-conditional element access (`x?[i]`), index assignments in object initializers, list patterns
  and spread patterns all use the same resolution.

## Unlock `^`, ranges and list patterns with extensions

An extension `Count` or `Length`, an extension `this[int]` and a `Slice(int, int)` make a type
indexable from the end, sliceable and matchable with list patterns. Classic `this`-parameter
extension methods count too.

```csharp
public sealed class Readings(int[] values) { public int[] Values { get; } = values; }

public static class ReadingExtensions
{
    extension(Readings readings)
    {
        public int Count => readings.Values.Length;
        public int this[int index] => readings.Values[index];
        public Readings Slice(int start, int length) => new(readings.Values.AsSpan(start, length).ToArray());
    }
}

Readings r = new([10, 20, 30, 40]);
_ = r[^1];               // 40
_ = r[1..3][0];          // 20
_ = r is [10, .., 40];   // true
```

## Limitations

- Extension indexers are **never used for arrays or `string`**, even if you declare one.
- They can't appear in **expression trees**. This matters for LINQ providers such as EF Core:
  don't use extension indexers inside `IQueryable` lambdas.
- They aren't considered on `base[...]` access, or when the receiver is a type rather than a value.
- Extension `Length` and `Count` don't feed the collection-expression spread optimization, so
  `[.. x]` won't presize from them.
