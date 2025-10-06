---
title: "JavaScript and Frontend Development"
severity: "warning"
category: "javascript"
filePatterns: ["**/*.js", "**/*.ts", "**/*.jsx", "**/*.tsx"]
---
# JavaScript and Frontend Development

## Code Style and Syntax
- Use modern ES6+ syntax when possible (arrow functions, destructuring, template literals)
- Follow consistent naming conventions: camelCase for variables/functions, PascalCase for classes
- Use const for values that won't be reassigned, let for variables that will change
- Prefer template literals over string concatenation
- Use object shorthand notation when appropriate

## Event Handling
- Use appropriate event types for different interactions:
  - `mouseenter`/`mouseleave` for hover effects
  - `click` for button and link interactions
  - `keydown`/`keyup` for keyboard navigation
  - `focus`/`blur` for form interactions
- Implement both mouse and keyboard interaction patterns for accessibility
- Use event delegation when appropriate to handle dynamic content
- Prevent default behavior only when necessary and provide alternatives

## Accessibility and User Experience
- Always maintain keyboard navigation alongside mouse interactions
- Use proper ARIA attributes (`aria-hidden`, `aria-expanded`, `aria-label`)
- Implement focus management for dynamic content
- Provide visual feedback for all interactive elements
- Support screen readers with semantic HTML and ARIA attributes

## State Management
- Use clear, descriptive state variable names
- Maintain consistency between UI state and data attributes
- Use constants for state values to avoid magic strings
- Implement proper state transitions with validation
- Handle edge cases like rapid user interactions

## Error Handling and Validation
- Provide clear, actionable error messages
- Validate inputs and state before performing actions
- Use try-catch blocks for operations that might fail
- Implement graceful degradation when features fail
- Log errors appropriately for debugging while maintaining user experience

## Performance and Optimization
- Use event throttling/debouncing for high-frequency events like scroll or resize
- Minimize DOM queries by caching selectors when possible
- Use `requestAnimationFrame` for smooth animations
- Implement proper cleanup for event listeners and timers
- Avoid memory leaks by removing event listeners when elements are destroyed

## Testing and Debugging
- Write tests that cover both positive and negative scenarios
- Test accessibility features alongside functional features
- Use Playwright's debugging tools for frontend testing
- Test on different devices and viewport sizes
- Verify state changes after user interactions

## Progressive Enhancement
- Ensure core functionality works without JavaScript
- Enhance user experience progressively with interactive features
- Provide fallbacks for unsupported features
- Test with JavaScript disabled to ensure basic functionality
