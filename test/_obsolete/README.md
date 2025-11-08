# Obsolete Tests

These tests have been moved here because they fail to compile/load due to:

1. **Missing source files**: The implementation files they test no longer exist
2. **Broken imports**: Dependencies have been refactored or removed
3. **Architectural changes**: The code structure has evolved significantly

## Status: Requires Refactor or Removal

These tests were identified during the cleanup phase (2025-01-08).

**Action needed**:
- Review each test to determine if it tests functionality that still exists
- If yes: Rewrite the test to work with the new architecture
- If no: Document what was removed and why, then delete the test

## List of Obsolete Tests

See `git log` for the commit that moved these files here.
