# Vinyl Tracker - Coding Standards & TDD Guidelines

## 🎯 **Core Development Principles**

### **MANDATORY: Test-Driven Development (TDD)**
**ALL code changes MUST follow the Red-Green-Refactor cycle:**

1. **🔴 RED** - Write a failing test first
2. **🟢 GREEN** - Write minimal code to make the test pass
3. **🔵 REFACTOR** - Improve code while keeping tests green

### **⚠️ TDD Enforcement Rules**
- **NO implementation without tests first**
- **NO feature branches without test coverage**
- **NO pull requests without accompanying tests**
- **NO exceptions to TDD workflow**

---

## 📋 **Pre-Development Checklist**

Before writing ANY code:

- [ ] **Requirements clarified** - What exactly needs to be built?
- [ ] **Test scenarios identified** - What should pass/fail?
- [ ] **Test file created** - Where will tests live?
- [ ] **First failing test written** - Red phase complete?
- [ ] **Minimal implementation planned** - What's the smallest change?

---

## 🧪 **TDD Implementation Process**

### **Step 1: Write Failing Tests**
```swift
func testNewFeature_WithValidInput_ShouldReturnExpectedResult() {
    // Given - Setup test data
    let input = createTestInput()
    
    // When - Execute the feature
    let result = newFeature.process(input)
    
    // Then - Verify expected outcome
    XCTAssertEqual(result.status, .success)
    XCTAssertNotNil(result.data)
}
```

### **Step 2: Run Tests (Should Fail)**
```bash
⌘+U in Xcode - Verify test fails for right reason
```

### **Step 3: Write Minimal Implementation**
```swift
// Only write enough code to make the test pass
func process(_ input: Input) -> Result {
    return Result(status: .success, data: "minimal")
}
```

### **Step 4: Run Tests (Should Pass)**
```bash
⌘+U in Xcode - Verify test now passes
```

### **Step 5: Refactor (Optional)**
```swift
// Improve code quality while keeping tests green
// Extract methods, improve naming, optimize performance
```

---

## 📁 **File Organization Standards**

### **Source Code Structure**
```
VinylTracker/
├── Models/
│   ├── Album.swift
│   └── AlbumTests.swift          # Co-locate tests
├── Views/
│   ├── ContentView.swift
│   ├── ScannerView.swift
│   └── ViewTests/
│       ├── ContentViewTests.swift
│       └── ScannerViewTests.swift
├── Services/
│   ├── CameraService.swift
│   └── CameraServiceTests.swift
└── Utils/
    ├── Extensions.swift
    └── ExtensionsTests.swift
```

### **Test Naming Convention**
```swift
// Pattern: test[MethodName]_[Scenario]_[ExpectedResult]
func testAddAlbum_WithValidData_ShouldAddToCollection()
func testAddAlbum_WithDuplicate_ShouldShowAlert()
func testAddAlbum_WithInvalidData_ShouldNotAdd()
```

---

## 🔍 **Test Coverage Requirements**

### **Minimum Coverage Standards**
- **Models**: 100% coverage (data validation critical)
- **ViewModels**: 95% coverage (business logic critical)
- **Views**: 80% coverage (UI logic important)
- **Services**: 100% coverage (external dependencies critical)
- **Utils**: 95% coverage (shared functionality critical)

### **Required Test Types**
- [ ] **Unit Tests** - Individual function/method testing
- [ ] **Integration Tests** - Component interaction testing
- [ ] **Edge Case Tests** - Boundary conditions and error scenarios
- [ ] **Performance Tests** - Ensure acceptable performance
- [ ] **Mock Tests** - External dependency testing

---

## 🚨 **TDD Violation Consequences**

### **If TDD is NOT followed:**
1. **STOP immediately** 🛑
2. **Revert all untested code** ↩️
3. **Start over with tests first** 🔄
4. **Document the violation** 📝
5. **Review process improvements** 🔧

### **Exception Protocol (Rare)**
If absolutely necessary to break TDD:
1. **Document why** in commit message
2. **Create test debt ticket** immediately
3. **Write tests within 24 hours**
4. **No further development** until tests exist

---

## 📝 **Code Quality Standards**

### **Swift Coding Standards**
```swift
// MARK: - Clear section organization
// MARK: - Properties
// MARK: - Initialization
// MARK: - Public Methods
// MARK: - Private Methods
// MARK: - Test Helpers (in tests)

// Naming conventions
protocol AlbumRepositoryProtocol { }    // Protocol suffix
class AlbumCollectionViewModel { }       // Descriptive, specific names
func addAlbum(_ album: Album) { }        // Verb-based method names

// Documentation
/// Adds an album to the collection with duplicate detection
/// - Parameter album: The album to add
/// - Returns: True if added successfully, false if duplicate detected
func addAlbum(_ album: Album) -> Bool { }
```

### **Test Quality Standards**
```swift
// Clear Given-When-Then structure
func testAlbumValidation_WithEmptyTitle_ShouldReturnFalse() {
    // Given - Album with empty title
    let album = Album(title: "", artist: "Valid Artist")
    
    // When - Validating the album
    let isValid = album.isValid
    
    // Then - Should be invalid
    XCTAssertFalse(isValid)
}

// Use descriptive test data
private func createValidAlbum() -> Album {
    return Album(
        title: "Abbey Road",
        artist: "The Beatles",
        year: 1969,
        genre: "Rock"
    )
}
```

---

## 🔄 **Development Workflow**

### **Feature Development Process**
1. **Create feature branch** from main
2. **Write comprehensive tests** for the feature
3. **Implement minimal code** to pass tests
4. **Refactor and optimize** while keeping tests green
5. **Add integration tests** for component interactions
6. **Update documentation** and examples
7. **Create pull request** with test evidence
8. **Code review** focusing on test quality
9. **Merge to main** only after all tests pass

### **Bug Fix Process**
1. **Write test that reproduces the bug** (should fail)
2. **Fix the bug** with minimal code change
3. **Verify test now passes**
4. **Add regression tests** to prevent future occurrences
5. **Update documentation** if needed

---

## 📊 **Quality Gates**

### **Before Any Commit**
- [ ] All existing tests pass (⌘+U)
- [ ] New tests written for changes
- [ ] Code coverage maintained/improved
- [ ] No compiler warnings
- [ ] Documentation updated

### **Before Pull Request**
- [ ] Full test suite passes
- [ ] Performance tests pass
- [ ] Integration tests pass
- [ ] Code review checklist complete
- [ ] README/docs updated

### **Before Merge to Main**
- [ ] All CI/CD checks pass
- [ ] Code review approved
- [ ] Test coverage verified
- [ ] Documentation complete
- [ ] No breaking changes (or documented)

---

## 🛠️ **TDD Reminder Checklist**

**Print this and keep visible during development:**

```
🔴 RED PHASE:
□ Test written and failing
□ Test fails for correct reason
□ Test is minimal and focused

🟢 GREEN PHASE:
□ Minimal implementation written
□ Test now passes
□ No over-engineering

🔵 REFACTOR PHASE:
□ Code improved while tests stay green
□ Performance optimized if needed
□ Code readability enhanced

📝 QUALITY CHECK:
□ All tests pass
□ Coverage maintained
□ Documentation updated
□ Ready for review
```

---

## 🎯 **Success Metrics**

### **Project Health Indicators**
- **Test Coverage**: >90% overall
- **Test Speed**: Full suite <30 seconds
- **Build Success**: >95% on first attempt
- **Bug Rate**: <1 per sprint
- **TDD Compliance**: 100% of features

### **Developer Productivity**
- **Feature Confidence**: High (due to tests)
- **Refactoring Safety**: High (tests catch regressions)
- **Bug Investigation**: Fast (tests isolate issues)
- **Code Reviews**: Faster (tests document behavior)

---

## 📚 **Learning Resources**

### **TDD References**
- [Test-Driven Development by Kent Beck](https://www.amazon.com/Test-Driven-Development-Kent-Beck/dp/0321146530)
- [iOS TDD Best Practices](https://developer.apple.com/documentation/xctest)
- [Swift Testing Guide](https://docs.swift.org/swift-book/LanguageGuide/Testing.html)

### **Project Examples**
See our existing tests:
- `AlbumTests.swift` - Model testing examples
- `AlbumCollectionViewModelTests.swift` - ViewModel testing
- `CameraIntegrationTests.swift` - Integration testing

---

**📋 Remember: This document should be referenced at the start of EVERY development session!**

**🎯 Goal: Zero tolerance for untested code in production.**
