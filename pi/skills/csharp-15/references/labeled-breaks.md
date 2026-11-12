# Labeled `break` and `continue`

Put a label directly on a loop or `switch` statement, then name it from an inner statement.

```csharp
outer: for (int row = 0; row < grid.Height; row++)
{
    for (int column = 0; column < grid.Width; column++)
    {
        if (grid[row, column].IsBlocked) continue outer;   // next row
        if (grid[row, column].IsGoal)    break outer;      // leave both loops
    }
}

dispatch: switch (command.Kind)
{
    case CommandKind.Batch:
        foreach (var step in command.Steps)
        {
            if (step.IsAbort) break dispatch;   // exits the switch statement, not just the foreach
            Run(step);
        }
        break;
    default:
        Run(command);
        break;
}
```

## Rules

- `break label;` targets the nearest enclosing `for`, `foreach`, `while`, `do` or `switch`
  **statement** with that label. A `switch` *expression* isn't a target.
- `continue label;` targets only a **loop**. It can't target a `switch`.
- Only the statement **immediately** after the label is labeled. In `a: b: while (...)`, the loop is
  labeled `b`, so `break a;` doesn't target it. Use one label per loop.
- Unlabeled `break` and `continue` behave exactly as before.
- Neither form can leave a `finally` block. If the jump crosses `try` blocks, their `finally`
  blocks run in order, innermost first.
- As with unlabeled jumps, the target must enclose the statement **in the same function**. You
  can't jump out of a lambda or local function to an outer loop.
- Labels share `goto`'s label rules. A label's scope is its whole block, including nested blocks,
  and two labels with the same name and overlapping scopes are an error. **Give each labeled loop
  in a method a distinct name**, such as `rows:` and `cols:`, rather than reusing `outer:`.
- The same label can serve both `break` and `continue`, which removes the old pair of `goto`
  labels at the end of the body and after the loop.

## Refactoring guidance

- Replace a Boolean "found" flag that's re-checked at each level with `break label;`.
- Replace `goto END;` placed right after a loop with `break label;`.
- Replace `goto NEXT;` with `NEXT: ;` at the end of the body with `continue label;`.
- The **IDE0410** analyzer ("Use labeled jump statement") flags these patterns and offers fixes. Its
  option is `csharp_style_prefer_labeled_jump_statements = true|false` (default `true`). Disable it
  with `dotnet_diagnostic.IDE0410.severity = none`.
- Extracting a method is still often cleaner. Use labeled jumps when the loops share many locals or
  extraction would need tuples or `out` parameters.
