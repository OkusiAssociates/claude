# Python 3.12+ Raw Code Audit

Perform a comprehensive audit of this Python codebase targeting **Python 3.12+ exclusively**. This is a raw code audit with **NO frameworks** (no Django, Flask, FastAPI, etc.) and **minimal external dependencies**.

## Context Requirements

- **Python Version**: 3.12+ only (modern features expected)
- **Code Style**: Raw Python, standard library focus
- **Dependencies**: Minimal external packages, justify any non-stdlib imports
- **Frameworks**: NONE - this is raw Python code

## 1. Python 3.12+ Language Features

### Modern Syntax (Required)
- **Type Parameter Syntax (PEP 695)**: Generic classes/functions with new syntax
  ```python
  def max[T](args: list[T]) -> T:  # ✓ Python 3.12+
  # NOT: def max(args: List[T]) -> T:  # ✗ Old style
  ```
- **F-string Improvements**: Multiline, nested quotes
- **Override Decorator**: `@override` for explicit method overriding
- **Pattern Matching**: Use `match/case` for complex conditionals (3.10+)
- **Exception Groups (3.11+)**: `except*` for multiple exceptions

### Forbidden/Deprecated Patterns
- Pre-3.10 `Union[X, Y]` (use `X | Y`)
- Pre-3.9 `List`, `Dict` from typing (use `list`, `dict`)
- `typing.Optional` (use `X | None`)
- Percent formatting: `"Hello %s" % name` (use f-strings)
- `.format()` method (use f-strings)
- `os.path` module (use `pathlib.Path`)

## 2. Type Hints & Type Safety

### Complete Type Annotations (PEP 484/526/695)
- All function parameters typed
- All return types annotated
- Class attributes typed
- Module-level variables typed
- Use `typing.Protocol` for structural subtyping
- Avoid `Any` type (justify if absolutely necessary)

### Type Checking
Run static type checkers:

```bash
# mypy (recommended)
mypy --strict .

# pyright (alternative)
pyright --strict .
```

### Type Hint Issues to Find
- Missing return type annotations
- Untyped function parameters
- Use of `Any` without justification
- Missing generic type parameters
- Incorrect type variance
- Missing `@override` decorators

## 3. PEP Compliance

### Code Style (PEP 8)
- Line length: 88 characters (Black default) or 100 (configurable)
- Indentation: 4 spaces
- Import ordering: stdlib → third-party → local
- Naming conventions:
  - `snake_case` for functions/variables
  - `PascalCase` for classes
  - `UPPER_CASE` for constants
  - `_leading_underscore` for private

### Docstrings (PEP 257)
- All public modules, classes, functions documented
- Docstring format: Google, NumPy, or reStructuredText (consistent)
- One-line summary for simple functions
- Multi-line with descriptions for complex functions

### Other PEPs
- PEP 484: Type Hints
- PEP 526: Syntax for Variable Annotations
- PEP 695: Type Parameter Syntax (3.12+)

## 4. Code Quality Tools

Run these tools automatically:

```bash
# Ruff (fast, comprehensive)
ruff check .

# Black (formatting)
black --check .

# mypy (type checking)
mypy --strict .

# Optional: pylint
pylint --disable=C0111 .
```

Report all violations with file:line references.

## 5. Raw Code Security

### File I/O Security
- **Path Traversal**: Validate file paths with `pathlib.Path.resolve()`
  ```python
  # ✓ Safe
  safe_path = (base_dir / user_input).resolve()
  if not safe_path.is_relative_to(base_dir):
      raise ValueError("Invalid path")

  # ✗ Unsafe
  open(user_input)  # Path traversal risk
  ```
- **Temp Files**: Use `tempfile` module securely
  ```python
  with tempfile.NamedTemporaryFile(mode='w', delete=False) as f:  # ✓
  # NOT: open('/tmp/myfile.txt', 'w')  # ✗ Race condition
  ```

### Command Execution
- **Subprocess Injection**: Never use `shell=True` with user input
  ```python
  # ✓ Safe
  subprocess.run(['ls', user_dir])

  # ✗ Unsafe
  subprocess.run(f'ls {user_dir}', shell=True)  # Command injection!
  ```
- Validate all arguments passed to subprocess
- Use `shlex.quote()` if shell=True is unavoidable

### Dangerous Functions
- **`eval()` and `exec()`**: FORBIDDEN with user input
  ```python
  eval(user_input)  # ✗ Arbitrary code execution
  ```
- **`pickle.loads()`**: NEVER on untrusted data
  ```python
  pickle.loads(user_data)  # ✗ Deserialization attack
  ```
- Use `json` or `ast.literal_eval()` for safe parsing

### Secrets Management
- **Hardcoded Credentials**: Check for passwords, API keys in code
- **Environment Variables**: Use `os.environ.get()` with defaults
- **Random Numbers**:
  ```python
  import secrets  # ✓ Cryptographically secure
  # NOT: import random  # ✗ Not secure for crypto
  ```

### Input Validation
- Validate `sys.argv` and `argparse` inputs
- Sanitize before file operations
- Type validation for user input
- Range checking for numeric inputs

## 6. Standard Library Patterns

### Prefer Standard Library
- `pathlib.Path` over `os.path`
  ```python
  # ✓ Modern
  path = Path('/etc/config')
  if path.exists():

  # ✗ Legacy
  if os.path.exists('/etc/config'):
  ```
- `argparse` for CLI arguments (not manual `sys.argv` parsing)
- `logging` module for output (not print statements)
- `dataclasses` for data containers
  ```python
  @dataclass
  class Config:  # ✓
      host: str
      port: int

  # NOT: Manual __init__  # ✗
  ```
- `enum.Enum` for constants
- Context managers (`with` statements) for resources

### Collections Module
- `defaultdict` for dictionaries with default values
- `Counter` for counting
- `namedtuple` for simple data structures
- `deque` for queues

### Itertools
- `itertools` for efficient iteration
- Generator expressions for large datasets
- Avoid loading entire files into memory

## 7. Performance (Raw Python)

### Efficient Patterns
- **List Comprehensions**: Faster than loops
  ```python
  result = [x*2 for x in items]  # ✓
  # NOT: for loop with append  # ✗ Slower
  ```
- **Generator Expressions**: For large data
  ```python
  total = sum(x*2 for x in huge_list)  # ✓ Memory efficient
  ```
- **String Concatenation**: Use `''.join()` for multiple strings
  ```python
  result = ''.join(parts)  # ✓
  # NOT: result = part1 + part2 + part3  # ✗ Slow
  ```

### Avoid Repeated Lookups
```python
# ✓ Cache method/attribute lookups
append = result.append
for item in items:
    append(item)

# ✗ Repeated attribute lookup
for item in items:
    result.append(item)
```

### `__slots__` for Memory
```python
class Point:
    __slots__ = ['x', 'y']  # ✓ Saves memory
```

## 8. Testing (Minimal Framework)

### unittest (Standard Library)
- Test organization (test_*.py files)
- Use `unittest.TestCase`
- Proper setUp/tearDown
- `unittest.mock` for mocking

### pytest (If Used)
- Minimal plugins only
- Simple fixtures
- Parametrized tests with `@pytest.mark.parametrize`
- No heavy framework integration

### Test Quality
- Test coverage >80% target
- Edge cases tested
- Error conditions tested
- No flaky tests
- Proper test isolation

### Coverage
```bash
coverage run -m pytest
coverage report
```

## 9. Module Organization (No Packages)

### File Structure
- Clear module separation
- Avoid circular imports
- Simple import paths
- `if __name__ == "__main__":` pattern for scripts

### Import Patterns
```python
# ✓ Good
from pathlib import Path
from typing import Protocol

# ✗ Bad
from typing import *  # Wildcard imports
import sys, os  # Multiple on one line
```

### Circular Imports
- Detect with import analysis
- Restructure to remove cycles
- Use type-checking imports if needed:
  ```python
  from typing import TYPE_CHECKING
  if TYPE_CHECKING:
      from .module import Type
  ```

## 10. Minimal Dependencies

### Dependency Audit
- List all non-stdlib imports
- Justify each external dependency
- Check for security vulnerabilities:
  ```bash
  pip list --outdated
  pip-audit  # Security check
  ```
- Prefer stdlib alternatives

### Virtual Environment
```bash
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

### Requirements File
- Pin versions: `package==1.2.3`
- Separate dev dependencies
- Minimal production requirements

## 11. Code Smells & Anti-Patterns

### Detect Issues
- **God Classes**: Classes doing too much
- **Long Functions**: >50 lines suggests refactoring needed
- **Deep Nesting**: >3 levels of indentation
- **Magic Numbers**: Unexplained numeric literals
- **Mutable Default Arguments**: `def func(lst=[])`  # ✗
- **Bare `except:`**: Catch specific exceptions
- **Global Variables**: Minimize usage

### Exception Handling
```python
# ✓ Specific exceptions
try:
    result = risky_operation()
except ValueError as e:
    handle_error(e)

# ✗ Bare except
try:
    result = risky_operation()
except:  # Catches everything!
    pass
```

## 12. Object-Oriented Design

### Class Design (No Framework)
- Single Responsibility Principle
- Proper encapsulation (use `_private` attributes)
- Composition over inheritance
- Use `@property` for computed attributes
- `__repr__` for debugging
- `__str__` for user-facing output

### Abstract Base Classes
```python
from abc import ABC, abstractmethod

class Base(ABC):
    @abstractmethod
    def method(self) -> None:
        pass
```

### Protocols (Structural Typing)
```python
from typing import Protocol

class Drawable(Protocol):
    def draw(self) -> None: ...
```

## Output Format

For each issue found:

1. **Severity**: Critical/High/Medium/Low
2. **Location**: `file.py:line_number`
3. **PEP Reference**: If applicable (e.g., PEP 8, PEP 484)
4. **Description**: Clear explanation of the issue
5. **Impact**: How this affects the code/security
6. **Recommendation**: Concrete fix with Python 3.12+ syntax

## Executive Summary

Provide:
- **Overall Health Score**: X/10 with justification
- **Top 5 Critical Issues**: Immediate attention required
- **Quick Wins**: Low-effort, high-impact improvements
- **Long-term Recommendations**: Architectural improvements
- **Type Safety**: mypy/pyright results summary
- **Code Quality**: ruff/pylint results summary
- **Security**: Critical vulnerabilities found
- **Test Coverage**: Percentage and gaps

## Tool Integration Results

Include output from:
```bash
ruff check .
black --check .
mypy --strict .
pytest --cov
```

## Save Results

Save the complete audit report to:

```
./AUDIT-PYTHON.md
```

Include:
- Date and auditor information
- Python version detected
- File statistics (total lines, modules, classes, functions)
- Complete findings organized by severity
- Tool output summaries
- Actionable recommendations with code examples
- Migration path from older Python patterns to 3.12+
