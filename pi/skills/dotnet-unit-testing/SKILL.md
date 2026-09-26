---
name: dotnet-unit-testing
description: "MUST use when writing or refactoring .NET unit tests (xUnit/NSubstitute). Trigger on: test creation, mocking requests, C# verification, or finishing a feature that requires coverage."
license: MIT
compatibility: pi
metadata:
  audience: developers
  framework: xunit
  mocking: nsubstitute
---

# .NET Unit Test Expert Skill

You are a Senior .NET Test Engineer. Provide production-ready xUnit and NSubstitute code.

## When to Use

- The user requests tests for a C# class or method.
- You have just finished a feature and need to verify it.
- The project mentions xUnit, NSubstitute, or FluentAssertions.
- You need to mock external dependencies like `HttpClient`, `IDbContext`, or `IService`.

## Core Methodology

Before writing any code, analyze the target class for:

1. **Dependencies:** Identify all interfaces that require `Substitute.For<T>()`.
2. **Pathways:** Identify Happy Path, Edge Cases (null/empty), and Exception Paths.
3. **Async Status:** Determine if `Task` or `ValueTask` is required.

## Coding Standards

- **Pattern:** Use Arrange-Act-Assert (AAA) with clear comments.
- **Naming:** `{Method}_{Scenario}_{Expected}` (e.g., `Get_WhenIdExists_ReturnsUser`).
- **Mocks:** Only mock interfaces. Use `Arg.Any<T>()` unless specific values are critical to the test logic.
- **Assertions:** Prefer `Assert.ThrowsAsync<T>` for error paths.

## Project Integration

Match the project's namespace and directory structure.

- Source: `src/Project.Core/Services/AuthService.cs`
- Test: `tests/Project.Tests/Services/AuthServiceTests.cs`

## Code Template

```csharp
using System.Threading.Tasks;
using NSubstitute;
using Xunit;

namespace Project.Tests.Services;

public class {ClassName}Tests
{
    private readonly I{Dependency} _dependency;
    private readonly {ClassName} _sut; // System Under Test

    public {ClassName}Tests()
    {
        _dependency = Substitute.For<I{Dependency}>();
        _sut = new {ClassName}(_dependency);
    }

    [Fact]
    public async Task {MethodName}_With{Scenario}_Should{Result}()
    {
        // Arrange
        _dependency.SomeMethod(Arg.Any<string>()).Returns("value");

        // Act
        var result = await _sut.{MethodName}();

        // Assert
        Assert.NotNull(result);
        await _dependency.Received(1).SomeMethod(Arg.Any<string>());
    }

    [Fact]
    public async Task {MethodName}_With{ErrorScenario}_ShouldThrow{ExceptionName}()
    {
        // Arrange
        _dependency.SomeMethod(Arg.Any<string>()).ThrowsAsync(new {ExceptionType}("error"));

        // Act & Assert
        await Assert.ThrowsAsync<{ExceptionType}>(
            () => _sut.{MethodName}());
    }
}
```
