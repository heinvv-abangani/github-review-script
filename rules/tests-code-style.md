---
title: "Testing Best Practices"
severity: "warning"
category: "tests"
filePatterns: ["**/*.test.*", "**/__tests__/**/*"]
---
# Testing Best Practices

## Ensure tests are passing after any refactoring
- Tests can be run using `composer run test`
- Whenever you make changes to a PHP file ensure that tests are passing

## Reduce Code Duplication
- For repeated code such as test setup, mocks or assertions, extract them into helper methods or setup functions.
- Example: If multiple tests initialize the same mocks or objects, move this logic to a shared setup function rather than duplicating code in each test.

## Follow the structure of the folders for the class which is being tested
- Example: if you are writing tests for a class which is in the folder "classes" in the root of the project, put the test class inside tests/phpunit/hello-plus/classes
