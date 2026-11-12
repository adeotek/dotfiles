# Non-virtual static interface members on older runtimes

C# 15 lets you declare and call **non-virtual static** interface members even when the target
runtime doesn't support default interface implementations, as on .NET Framework or
`netstandard2.0`. This helps multi-targeted libraries.

```csharp
public interface IMeasurement
{
    public static double ToMeters(double centimeters) => centimeters / 100;
}

double m = IMeasurement.ToMeters(250);   // call it on the interface, not on an implementing type
```

These still require runtime support for default interface methods:

- instance default implementations,
- `static abstract` and `static virtual` members,
- `protected`, `protected internal` and `private protected` interface members.

For down-level targets, keep interface helpers static and non-virtual, and don't give them the
`protected` access modifiers.
