---
title: "Playwright Test Debugging Best Practices"
severity: "warning"
category: "tests"
filePatterns: ["**/*.test.ts", "**/*.spec.ts"]
---
# Playwright Test Debugging Best Practices

## Pre-Debugging Setup

### 1. Environment Verification
- **Check WordPress Environment**: Ensure `wp-env start` is running before tests
- **Run Playwright Setup**: Execute `npm run test:setup:playwright` to configure test environment
- **Verify Database**: Confirm test database is accessible and seeded
- **Check Dependencies**: Ensure all npm packages are installed (`npm install`)
- **Browser Installation**: Verify Playwright browsers are installed (`npx playwright install`)

### 2. Test Configuration
- **Review Playwright Config**: Check `playwright.config.ts` for correct base URL and timeouts
- **Environment Variables**: Verify `.env` file has correct test credentials
- **Storage State**: Check if authentication state files exist and are valid

## Common Failure Patterns

### 1. Connection Issues
```typescript
// Error: Failed to fetch Nonce. Base URL: http://localhost:8888
// Solution: Start WordPress environment
wp-env start
```

### 2. Control Not Found Errors
```typescript
// Error: Control 'section_layout' not found
// Solution: Verify control names match widget implementation
await globalEditor.openSection('section_layout'); // ✅ Correct
await globalEditor.openSection('section_layout'); // ❌ Wrong name
```

### 3. Conditional Control Access
```typescript
// Problem: Controls only available under certain conditions
// Solution: Add conditional checks before accessing controls
const isInfoHub = layoutPreset === 'info-hub';
if (isInfoHub) {
    await globalEditor.setTextControlValue('group_1_subheading', 'Text');
}
```

### 4. Hardcoded Template ID Issues
```typescript
// Problem: Hardcoded post IDs fail when templates don't exist
// ❌ Hardcoded approach
const elementorUrl = '/wp-admin/post.php?post=2174&action=elementor';
await globalEditor.page.goto(elementorUrl);

// ✅ Dynamic template navigation
await globalEditor.page.goto(`/wp-admin/edit.php?post_type=elementor_library&tabs_group=library&elementor_library_type=ehp-footer`);
await globalEditor.page.getByRole('link', { name: 'Footer' }).first().click();
const elementorButton = globalEditor.page.getByRole('link', { name: 'Edit with Elementor' });
const elementorUrl = await elementorButton.getAttribute('href');
if (elementorUrl) {
    await globalEditor.page.goto(elementorUrl);
}
```

### 5. Viewport and Button Click Issues
```typescript
// Problem: "Edit with Elementor" button appears outside viewport
// ❌ Direct click fails
await elementorButton.click(); // TimeoutError: element is outside of the viewport

// ✅ Use direct navigation instead of clicking
const elementorUrl = await elementorButton.getAttribute('href');
if (elementorUrl) {
    await globalEditor.page.goto(elementorUrl);
    await globalEditor.page.waitForURL(elementorUrl);
}
```

## Debugging Strategies

### 1. Isolate Test Components
```typescript
// Test individual sections separately
test('Layout Section Only', async () => {
    await globalEditor.setWidgetTab('content');
    await globalEditor.openSection('section_layout');
    // Test only layout controls
});
```

### 2. Add Debug Logging
```typescript
// Add console.log for debugging
console.log('Current layout preset:', layoutPreset);
console.log('Available sections:', await globalEditor.getAvailableSections());
```

### 3. Use Playwright Debug Mode
```bash
# Run test in debug mode
npm run test:playwright:debug -- tests/path/to/test.ts

# Or use --debug flag
npx playwright test --debug tests/path/to/test.ts
```

### 4. Screenshot Debugging
```typescript
// Take screenshots at failure points
await globalEditor.page.screenshot({ 
    path: `debug-${Date.now()}.png`,
    fullPage: true 
});
```

## Control Validation

### 1. Verify Control Existence
```typescript
// Check if control exists before using
const controlExists = await globalEditor.page.locator('[data-setting="control_name"]').count() > 0;
if (controlExists) {
    await globalEditor.setControlValue('control_name', 'value');
}
```

### 2. Validate Control Values
```typescript
// Ensure control values match available options
const availableOptions = ['option1', 'option2', 'option3'];
const selectedValue = availableOptions[loopIndex % availableOptions.length];
await globalEditor.setSelectControlValue('control_name', selectedValue);
```

### 3. Handle Conditional Controls
```typescript
// Map control availability to conditions
const controlConditions = {
    'style_layout_columns': () => layoutPreset === 'info-hub',
    'style_layout_content_alignment': () => layoutPreset === 'quick-reference',
    'subheading_tag': () => layoutPreset === 'info-hub'
};

// Only access controls when conditions are met
if (controlConditions['control_name']()) {
    await globalEditor.setControlValue('control_name', 'value');
}
```

## Test Data Management

### 1. Constants-Driven Test Design
```typescript
// ✅ Define all values in constants with meaningful variations
const CONTROL_VALUES = {
    layoutPreset: ['info-hub', 'quick-reference'],
    subheadingTexts: ['Subheading Alpha', 'Subheading Beta', 'Subheading Gamma'],
    gaps: ['20', '40', '60'],
    switcherValues: ['yes', 'no', 'yes'],
    borderWidths: ['1', '2', '3']
};

// ✅ All values must change during tests using loopIndex
const gap = globalEditor.getControlValueByIndex(CONTROL_VALUES.gaps, loopIndex);
const switcher = globalEditor.getControlValueByIndex(CONTROL_VALUES.switcherValues, loopIndex);

// ❌ Avoid hardcoded values in test logic
await globalEditor.setSliderControlValue('style_box_gap', '60'); // Hardcoded
```

### 2. Use Realistic Default Values
```typescript
// Match widget defaults exactly when possible
const CONTROL_VALUES = {
    gaps: ['20', '40', '60'], // ✅ Based on actual widget defaults
    columns: ['2', '3', '4'] // ✅ Actual available options
};
```

### 3. Randomize Test Data Safely
```typescript
// Use modulo to ensure values are within bounds
const controlValue = CONTROL_VALUES.controlName[loopIndex % CONTROL_VALUES.controlName.length];
```

### 4. Clean Up Test Data
```typescript
test.afterEach(async () => {
    // Clean up any test-specific data
    await globalEditor.cleanContent();
});
```

## Error Handling

### 1. Constants-Driven Test Values
```typescript
// ✅ Best practice: Use constants for all test values
const CONTROL_VALUES = {
    layoutPreset: ['info-hub', 'quick-reference'],
    subheadingTexts: ['Subheading Alpha', 'Subheading Beta', 'Subheading Gamma'],
    descriptionTexts: ['Description Alpha...', 'Description Beta...'],
    switcherValues: ['yes', 'no', 'yes']
};

// All values change during tests using loopIndex
const layoutPreset = globalEditor.getControlValueByIndex(CONTROL_VALUES.layoutPreset, loopIndex);
const subheadingText = globalEditor.getControlValueByIndex(CONTROL_VALUES.subheadingTexts, loopIndex);
```

### 2. Logical Conditional Control Handling
```typescript
// ✅ Best practice: Use pure logical conditions instead of try-catch
const CONTROL_CONDITIONS = {
    'group_1_business_details_subheading': (layoutPreset: string) => layoutPreset === 'info-hub',
    'style_layout_columns': (layoutPreset: string) => layoutPreset === 'info-hub'
};

// Apply conditions without try-catch blocks
if (CONTROL_CONDITIONS['group_1_business_details_subheading'](layoutPreset)) {
    await globalEditor.setTextControlValue('group_1_business_details_subheading', subheadingText);
}

// ❌ Avoid try-catch for conditional controls - use logical conditions instead
```

### 3. Retry Logic
```typescript
// Retry flaky operations
await globalEditor.page.waitForSelector('.control', { 
    timeout: 10000,
    state: 'visible' 
});
```

### 4. Assertion Softening
```typescript
// Use soft assertions for non-critical failures
await expect.soft(element).toHaveScreenshot('screenshot.png');
```

## Performance Optimization

### 1. Reduce Screenshot Frequency
```typescript
// Only take screenshots when needed
if (process.env.DEBUG_SCREENSHOTS) {
    await expect(element).toHaveScreenshot('debug.png');
}
```

### 2. Optimize Viewport Changes
```typescript
// Batch viewport changes
const viewports = [viewportSize.desktop, viewportSize.tablet, viewportSize.mobile];
for (const viewport of viewports) {
    await globalEditor.page.setViewportSize(viewport);
    // Take screenshot
}
```

### 3. Minimize DOM Queries
```typescript
// Cache selectors
const widget = globalEditor.page.locator(WIDGET_CSS_CLASS).first();
await expect(widget).toBeVisible();
await expect.soft(widget).toHaveScreenshot('screenshot.png');
```

## Documentation and Maintenance

### 1. Document Control Dependencies
```typescript
// Add comments explaining control relationships
// Note: This control is only available when layout_preset === 'info-hub'
if (layoutPreset === 'info-hub') {
    await globalEditor.setControlValue('dependent_control', 'value');
}
```

### 2. Version Control Test Data
```typescript
// Keep test data in sync with widget versions
const WIDGET_VERSION = '1.7.6';
const CONTROL_VALUES = {
    // Updated for widget version 1.7.6
    layoutPreset: ['info-hub', 'quick-reference'],
    // ... other values
};
```

### 3. Regular Test Validation
```bash
# Run tests regularly to catch regressions
npm run test:playwright:headless

# Run specific test suites
npm run test:playwright -- tests/modules/template-parts/widgets/
```

## Troubleshooting Checklist

- [ ] WordPress environment is running (`wp-env status`)
- [ ] Playwright setup has been run (`npm run test:setup:playwright`)
- [ ] Test database is accessible and seeded
- [ ] All npm dependencies are installed
- [ ] Playwright browsers are installed
- [ ] Control names match widget implementation
- [ ] All test values come from constants (no hardcoded values)
- [ ] All values change during tests using loopIndex
- [ ] Conditional controls use logical conditions (CONTROL_CONDITIONS), not try-catch
- [ ] Template navigation uses dynamic approach, not hardcoded IDs
- [ ] Viewport issues are handled with direct navigation when needed
- [ ] Screenshots are taken at appropriate breakpoints
- [ ] Error handling is in place for flaky operations
- [ ] Test cleanup is properly implemented
- [ ] No comments in test code (self-documenting constants and logic)
