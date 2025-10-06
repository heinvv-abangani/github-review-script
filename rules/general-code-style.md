---
title: "General Code Style"
severity: "info"
category: "style"
filePatterns: ["**/*"]
---
# Code Style

## Avoid Magic Numbers
- Do not use unexplained hardcoded values ("magic numbers") in code or tests.
- Define such values as named constants or use existing constants to clarify their meaning.

## Consistent Error Codes and Status
- When returning error codes and HTTP status, always be very specific to use the correct code, not only 200 and 500.

## Prioritize Style and Developer Experience
- Always pay attention for clarity, maintainability, and ease of understanding, even if the underlying logic does not change.
- Code style and developer experience are important for long-term project health.

## Avoid Comments and Class/Method Docblocks
- Do not add comments unless absolutely necessary to explain what the code is doing
- Do not add Docblocks to methods, classes, or files
- Prefer self-documenting code over explanatory comments

## Self Documented Code
- Avoid adding comments that can be constants or well-named functions
- Always prefer to create small functions that describe themselves
- Use descriptive variable and function names instead of comments
