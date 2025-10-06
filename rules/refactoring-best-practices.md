---
title: "Refactoring Best Practices"
severity: "info"
category: "refactoring"
filePatterns: ["**/*.php", "**/*.js", "**/*.ts"]
---
# Refactoring Best Practices

- **Type hints**: Prefer precise types (e.g., `Elementor\\Widget_Base`) over `mixed`. Update PHPDoc accordingly.
- **Simplicity first**: Keep base classes minimal. Expose only what implementations need. Avoid speculative hooks.
- **SRP**: Each class should have a single responsibility. Move shared behaviors into small, focused helpers.
- **Autoloading**: Rely on the plugin autoloader; avoid `require_once`. Place abstract classes and interfaces under `classes/` with clear namespaces.
- **Naming**: Use clear, conventional names: `Abstract_Section`, `Section_Interface`. Avoid abbreviations.
- **Backward compatibility**: If moving/renaming public classes, consider class aliases in the autoloader or transitional shims.
- **Tests**: Run unit and e2e tests after changes. Update tests only when behavior changes; otherwise keep expectations intact.
- **Atomic edits**: Refactor in small, verifiable steps. Commit after green tests.
- **Docs**: Update folder `README.md` files and code comments to reflect new structure and usage.
w