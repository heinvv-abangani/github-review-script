---
title: "GitHub Suggestion Formatting"
severity: "info"
category: "process"
filePatterns: ["**/*"]
---

# GitHub Suggestion Formatting Guidelines

## Core Principle: Minimal Precision

**Fix the minimum necessary code with maximum precision.**

Always prefer single-line suggestions when the core issue affects one logical element.

## Single-Line Suggestions (Strongly Preferred)

Use single-line suggestions when:

### ✅ Condition Changes
- Adding checks: `if (condition)` → `if (condition && check)`
- Removing conditions: `if (a && b && c)` → `if (a && b)`
- Fixing operators: `if (a || b)` → `if (a && b)`

### ✅ Function Call Fixes
- Adding parameters: `func()` → `func(param)`
- Changing method calls: `obj.method()` → `obj.newMethod()`
- Fixing references: `handler()` → `() => handler()`

### ✅ Variable/Assignment Issues
- Null checks: `const x = obj.prop` → `const x = obj?.prop`
- Type fixes: `const x = "5"` → `const x = 5`
- Scope fixes: `var x = 1` → `const x = 1`

### ✅ Import/Export Changes
- Adding imports: `import { a }` → `import { a, b }`
- Fixing paths: `from './old'` → `from './new'`

## Multi-Line Suggestions (Use Sparingly)

Use multi-line suggestions ONLY when:

### ❌ Complete Block Restructuring
- Converting if-else to switch statements
- Wrapping code in try-catch blocks
- Restructuring entire conditional logic

### ❌ Adding New Code Blocks
- Adding new functions or methods
- Creating new conditional branches
- Adding error handling blocks

## Examples from Real Issues

### ✅ CORRECT: Single-Line Fix (PR-88 Example)

**Issue:** Plugin loads without dependency check
**Problem Line:** `if ( version_compare( PHP_VERSION, '5.6', '>=' ) ) {`
**Fix:** Add dependency check to existing condition

```json
{
  "body": "**Issue:** Plugin loads even when dependencies missing\\n\\n**Suggested Fix:**\\n```suggestion\\nif ( version_compare( PHP_VERSION, '5.6', '>=' ) && $dependency_checker->check() ) {\\n```"
}
```

### ❌ INCORRECT: Multi-Line for Simple Fix

```json
{
  "body": "**Issue:** Same as above\\n\\n**Suggested Fix:**\\n```suggestion\\nif ( version_compare( PHP_VERSION, '5.6', '>=' ) && $dependency_checker->check() ) {\\n    require ELEMENTOR_PKP_PATH . 'plugin.php';\\n} else {\\n    add_action( 'admin_notices', 'platform_kit_publisher_fail_to_active' );\\n}\\n```"
}
```

**Why incorrect:** The core issue is the condition, not the entire block structure.

## Decision Framework

When creating suggestions, ask:

1. **What's the core issue?** (usually one line)
2. **Can I fix it by changing one logical element?** → Single-line
3. **Does the fix require restructuring multiple related lines?** → Multi-line

## Common Patterns

### Single-Line Patterns
- `condition` → `condition && check`
- `method()` → `method(param)`
- `variable` → `variable?.property`
- `"string"` → `constant`
- `function()` → `() => function()`

### Multi-Line Patterns (Rare)
- Converting entire control structures
- Adding comprehensive error handling
- Refactoring that affects multiple interdependent lines

## Validation Questions

Before using multi-line suggestions:

- Could this be fixed with a single-line change?
- Am I restructuring more than necessary?
- Is the core issue really in multiple lines?

**Remember:** GitHub suggestions are commits. Keep them focused and minimal.
