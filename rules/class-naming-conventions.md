---
title: "Class Naming Conventions"
severity: "warning"
category: "style"
filePatterns: ["**/*.php"]
---
# Class Naming Conventions

## One Class Per File
- **Enforce one class per file**: Each PHP file should contain exactly one class, interface, or trait
- **No multiple class definitions**: Avoid defining multiple classes in a single file
- **Use statements and autoloading**: Always use `use` statements for importing classes instead of `require_once`
- **Rely on autoloading**: Trust the plugin's autoloader to handle class loading automatically
- **No manual includes**: Remove `require_once`, `include_once`, `require`, and `include` statements for loading classes
- **Exception**: Only use manual includes for non-class files like templates or configuration files

## File and Class Names
- Use underscore-separated file names matching the class name (e.g., `contact-buttons-section.php` for `Contact_Buttons_Section`)
- Class names should use `Pascal_Case_With_Underscores` to follow WordPress coding standards
- Use clear, descriptive names that communicate purpose without redundant prefixes or suffixes.
- Interfaces: Do not add `_Interface` or `I` prefixes.
- Abstract classes: Avoid `Abstract_` prefixes. Instead, use meaningful names like `BaseHeaderSection` or `HeaderSectionBase` if needed.
- Only use a distinguishing prefix/suffix when it significantly improves clarity, such as in legacy codebases or where multiple types share very similar names.

## Namespace Conventions
- Use hierarchical namespaces that reflect the directory structure
- Example: `HelloPlus\Modules\TemplateParts\Widgets\Controls\Header`
- Keep namespace depth reasonable (max 6 levels recommended)

## Method Naming
- Use `snake_case` for method names to follow WordPress standards
- Public methods should have descriptive names that clearly indicate their purpose
- Private/protected methods should be more specific and implementation-focused
- Template methods (abstract methods) should describe what they return or do

## Method Ordering
- Order methods as follows for consistency and readability:
  - Abstract methods (if any)
  - Private static methods
  - Private methods
  - Protected static methods
  - Protected methods
  - Public static methods
  - Public methods
  - `__construct` (always last)
- Within each visibility group, place static methods before non-static methods.

## Constants and Configuration
- Use `SCREAMING_SNAKE_CASE` for class constants
- Group related constants into associative arrays when appropriate
- Prefix constants with their context (e.g., `DEFAULT_CONFIG` instead of just `CONFIG`)

## Inheritance Patterns
- Prefer composition over inheritance when possible
- Use interfaces to define contracts
- Abstract classes should provide common functionality, not just structure
- Concrete classes should focus on specific implementation details

## Constructor Patterns
- Accept dependencies through constructor when possible
- Provide sensible defaults for optional parameters
- Use dependency injection rather than creating dependencies inside the class
- Support both constructor injection and method parameter injection for backward compatibility
