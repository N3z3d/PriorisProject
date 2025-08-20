# TDD Workflow Automation - Prioris Project

## Workflow Triggers

### Feature Implementation
**Trigger**: "Implement [feature] with TDD" or "Add [functionality] following TDD"
**Flow**:
1. **flutter_tester** → Create failing tests first (RED)
2. **dart_implementer** → Write minimal implementation (GREEN)  
3. **flutter_tester** → Verify tests pass
4. **dart_implementer** → Refactor code (REFACTOR)
5. **flutter_tester** → Ensure tests still pass

### UI Component Creation
**Trigger**: "Create [widget] component" or "Build [UI element]"
**Flow**:
1. **flutter_tester** → Create widget tests
2. **widget_builder** → Implement Flutter widget
3. **flutter_tester** → Run widget tests
4. **widget_builder** → Apply premium styling/animations

### Data Layer Changes  
**Trigger**: "Add [entity] repository" or "Implement [data] persistence"
**Flow**:
1. **flutter_tester** → Create repository tests with mocks
2. **repository_manager** → Implement Supabase repository
3. **flutter_tester** → Run integration tests
4. **repository_manager** → Optimize queries/performance

## Automated Commands

### Test Execution Chain
```bash
# Unit tests
flutter test test/unit/ --coverage

# Widget tests  
flutter test test/widget/

# Integration tests
flutter test test/integration/

# Coverage report
genhtml coverage/lcov.info -o coverage/html
```

### Code Generation Chain
```bash
# Generate JSON serialization
flutter packages pub run build_runner build

# Generate mocks for testing
flutter packages pub run build_runner build --delete-conflicting-outputs

# Format code
dart format .

# Analyze code
dart analyze
```

## Quality Gates

### Before Each Commit
- [ ] All tests pass (`flutter test`)
- [ ] No analyzer warnings (`dart analyze`)
- [ ] Code formatted (`dart format .`)
- [ ] Coverage > 80% for new features
- [ ] No accessibility violations

### TDD Cycle Validation
- [ ] **RED**: Test fails initially ❌
- [ ] **GREEN**: Test passes with minimal code ✅
- [ ] **REFACTOR**: Code improved, tests still pass ✅

## Agent Coordination Rules

1. **Always Test First**: flutter_tester must run before any implementation
2. **Incremental Development**: Small, focused changes following TDD cycles
3. **Pattern Consistency**: All agents follow established project conventions
4. **Documentation**: Update relevant docs when patterns change
5. **Clean Commits**: Each TDD cycle should result in a clean, focused commit

## Integration Points

### With Existing Codebase
- Respect current domain models and aggregates
- Follow established repository patterns
- Maintain Supabase integration consistency
- Preserve premium UI/UX design system

### With Development Tools
- Use existing test infrastructure
- Leverage build_runner for code generation
- Integrate with VS Code/Cursor IDE features
- Maintain compatibility with CI/CD pipeline