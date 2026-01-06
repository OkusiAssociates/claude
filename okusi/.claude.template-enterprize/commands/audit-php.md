# PHP 8.3+ Raw Code Audit

Perform a comprehensive audit of this PHP codebase targeting **PHP 8.3+ exclusively**. This is a raw code audit with **NO frameworks** (no Laravel, Symfony, etc.) and **minimal/rare Composer usage**.

## Context Requirements

- **PHP Version**: 8.3+ only (modern features expected)
- **Code Style**: Raw PHP, no frameworks
- **Dependencies**: Minimal external packages, manual implementations preferred
- **Composer**: Rarely used, justify if present
- **Frameworks**: NONE - this is raw PHP code

## 1. PHP 8.3+ Language Features

### Modern Syntax (Required)
- **Typed Class Constants (8.3)**:
  ```php
  public const string NAME = 'value';  // ✓ PHP 8.3+
  ```
- **Dynamic Class Constant/Enum Fetch (8.3)**:
  ```php
  $const = $class::{$name};  // ✓
  ```
- **`json_validate()` (8.3)**: Validate JSON without parsing
  ```php
  if (json_validate($json)) { /* ... */ }  // ✓ PHP 8.3+
  ```
- **Override Attribute (8.3)**:
  ```php
  #[Override]
  public function method(): void { }  // ✓ Explicit override
  ```
- **Readonly Amendments (8.3)**: Deep cloning of readonly properties

### PHP 8.0-8.2 Features (Required)
- **Constructor Property Promotion (8.0)**:
  ```php
  public function __construct(
      public string $name,  // ✓
      public int $age,
  ) {}
  ```
- **Named Arguments (8.0)**: Use for clarity
- **Enums (8.1)**: Use instead of class constants
  ```php
  enum Status: string {  // ✓
      case Active = 'active';
      case Inactive = 'inactive';
  }
  ```
- **Readonly Properties (8.1)**: Immutable data
- **Readonly Classes (8.2)**: All properties readonly
- **Match Expressions (8.0)**: Use instead of switch
  ```php
  $result = match($value) {  // ✓
      1 => 'one',
      2 => 'two',
      default => 'other',
  };
  ```

### Forbidden/Deprecated Patterns
- Old array syntax: `array()` (use `[]`)
- `switch` statements (use `match`)
- Untyped properties/parameters
- Missing return types
- `create_function()` (removed in 8.0)
- `each()` (removed in 8.0)

## 2. Strict Type System

### Mandatory `declare(strict_types=1)`
**Every PHP file MUST start with:**
```php
<?php

declare(strict_types=1);

// Rest of code...
```

### Complete Type Declarations
- All function parameters typed
- All return types annotated
- All class properties typed
- Use union types: `string|int`
- Use intersection types: `Countable&Traversable`
- Use nullable syntax: `?string` or `string|null`
- Use `never` type for functions that never return
- Use `void` for no return value
- Use `mixed` only when truly necessary (justify)

### Type Issues to Find
- Missing `declare(strict_types=1)`
- Untyped function parameters
- Missing return types
- Untyped class properties
- Use of `mixed` without justification
- Missing override attributes

## 3. PSR Standards (Code Style Only)

### PSR-1 (Basic Coding Standard)
- PHP tags: `<?php` (never short tags)
- File encoding: UTF-8 without BOM
- Side effects: Files should declare OR execute, not both
- Naming: Classes `PascalCase`, methods `camelCase`, constants `UPPER_CASE`

### PSR-12 (Extended Coding Style)
- Indentation: 4 spaces
- Line length: 120 characters soft limit
- Braces: Opening brace on same line for classes/methods
- Declare statements: One per line
- Import statements: One per line, alphabetically sorted

### PSR-4 (Autoloading - If Manual)
If implementing manual autoloading:
```php
spl_autoload_register(function (string $class): void {
    $file = str_replace('\\', '/', $class) . '.php';
    if (file_exists($file)) {
        require $file;
    }
});
```

## 4. Static Analysis Tools

Run these tools automatically:

```bash
# PHPStan (level 9 - strictest)
phpstan analyse --level=9 src/

# Psalm (strictest)
psalm --show-info=true

# PHP_CodeSniffer (PSR-12)
phpcs --standard=PSR12 src/

# PHP-CS-Fixer
php-cs-fixer fix --dry-run --diff
```

Report all violations with file:line references.

## 5. Raw PHP Security

### SQL Injection (Manual PDO)
**ALWAYS use prepared statements:**
```php
// ✓ Safe - Prepared statement
$stmt = $pdo->prepare('SELECT * FROM users WHERE id = :id');
$stmt->execute(['id' => $userId]);

// ✗ CRITICAL - SQL injection
$result = $pdo->query("SELECT * FROM users WHERE id = $userId");
```

Check for:
- Raw queries with user input
- String concatenation in SQL
- Missing parameter binding
- Unsafe `PDO::quote()` usage

### XSS (Cross-Site Scripting)
**ALWAYS escape output:**
```php
// ✓ Safe
echo htmlspecialchars($userInput, ENT_QUOTES, 'UTF-8');

// ✗ CRITICAL - XSS vulnerability
echo $userInput;
```

Check for:
- Unescaped user output
- Missing `htmlspecialchars()`
- Incorrect flags (must use `ENT_QUOTES`)
- Wrong encoding (must specify UTF-8)

### CSRF (Manual Token Implementation)
```php
// ✓ Generate token
session_start();
if (empty($_SESSION['csrf_token'])) {
    $_SESSION['csrf_token'] = bin2hex(random_bytes(32));
}

// ✓ Validate token
if (!hash_equals($_SESSION['csrf_token'], $_POST['csrf_token'] ?? '')) {
    die('CSRF validation failed');
}

// ✗ No CSRF protection
```

### Session Security (Manual Configuration)
**Configure sessions securely:**
```php
// ✓ Secure session configuration
ini_set('session.cookie_httponly', '1');
ini_set('session.cookie_secure', '1');  // HTTPS only
ini_set('session.cookie_samesite', 'Strict');
ini_set('session.use_strict_mode', '1');
ini_set('session.use_only_cookies', '1');
session_start();
```

### File Upload Validation
```php
// ✓ Proper validation
$allowed = ['image/jpeg', 'image/png'];
$finfo = finfo_open(FILEINFO_MIME_TYPE);
$mime = finfo_file($finfo, $_FILES['upload']['tmp_name']);

if (!in_array($mime, $allowed, true)) {
    die('Invalid file type');
}

// Validate size
if ($_FILES['upload']['size'] > 5_000_000) {  // 5MB
    die('File too large');
}

// ✗ Unsafe - trusts client
if ($_FILES['upload']['type'] !== 'image/jpeg') { }
```

### Path Traversal
```php
// ✓ Safe path validation
$basePath = '/var/www/uploads/';
$filePath = realpath($basePath . $userInput);

if ($filePath === false || !str_starts_with($filePath, $basePath)) {
    die('Invalid path');
}

// ✗ Unsafe
$file = file_get_contents('/uploads/' . $_GET['file']);
```

### Command Injection
```php
// ✗ FORBIDDEN - Never use these with user input:
exec($userInput);
shell_exec($userInput);
system($userInput);
passthru($userInput);

// ✓ If absolutely necessary, use escapeshellarg():
$safe = escapeshellarg($userInput);
exec("command $safe", $output);
```

### Include/Require Safety
```php
// ✗ CRITICAL - File inclusion vulnerability
require $_GET['page'] . '.php';

// ✓ Safe - Whitelist approach
$allowed = ['home', 'about', 'contact'];
$page = $_GET['page'] ?? 'home';
if (in_array($page, $allowed, true)) {
    require "$page.php";
}
```

### XXE (XML External Entity)
```php
// ✓ Disable external entities
libxml_disable_entity_loader(true);
$dom = new DOMDocument();
$dom->loadXML($xml);

// ✗ Unsafe XML parsing
```

### Deserialization
```php
// ✗ FORBIDDEN - Never unserialize user input
$data = unserialize($_POST['data']);

// ✓ Use JSON instead
$data = json_decode($_POST['data'], true);
```

### Security Headers (Manual)
```php
// ✓ Security headers
header('X-Content-Type-Options: nosniff');
header('X-Frame-Options: DENY');
header('X-XSS-Protection: 1; mode=block');
header('Content-Security-Policy: default-src \'self\'');
header('Strict-Transport-Security: max-age=31536000; includeSubDomains');
```

## 6. Raw Database Handling (Manual PDO)

### PDO Configuration
```php
// ✓ Proper PDO setup
$options = [
    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    PDO::ATTR_EMULATE_PREPARES => false,
];
$pdo = new PDO($dsn, $user, $pass, $options);
```

### Transaction Management
```php
// ✓ Proper transaction handling
try {
    $pdo->beginTransaction();
    // Multiple queries...
    $pdo->commit();
} catch (Exception $e) {
    $pdo->rollBack();
    throw $e;
}
```

### Query Optimization
- Check for N+1 query patterns
- Use JOINs instead of multiple queries
- Add indexes where needed
- Limit result sets

## 7. Modern OOP Patterns (No Framework)

### Class Design
- Single Responsibility Principle
- Proper encapsulation (`private`/`protected`)
- Composition over inheritance
- Use interfaces for contracts
- Use abstract classes for shared behavior
- Use traits for code reuse (with caution)

### Readonly Classes (8.2+)
```php
readonly class Config {  // ✓ All properties readonly
    public function __construct(
        public string $host,
        public int $port,
    ) {}
}
```

### Proper Exception Handling
```php
// ✓ Specific exceptions
try {
    $result = riskyOperation();
} catch (InvalidArgumentException $e) {
    // Handle specific error
} catch (RuntimeException $e) {
    // Handle runtime error
}

// ✗ Bare catch
try {
    $result = riskyOperation();
} catch (Exception $e) {  // Too broad
    // ...
}
```

## 8. Performance (Raw PHP)

### OPcache Configuration
Check `php.ini` for optimal settings:
```ini
opcache.enable=1
opcache.memory_consumption=128
opcache.interned_strings_buffer=8
opcache.max_accelerated_files=10000
opcache.revalidate_freq=2
```

### Efficient Patterns
- Use `foreach` over `for` with arrays
- Avoid repeated function calls in loops
- Use `isset()` over `array_key_exists()` when possible
- Cache expensive operations
- Use generators for large datasets:
  ```php
  function getRows(): Generator {  // ✓ Memory efficient
      while ($row = $stmt->fetch()) {
          yield $row;
      }
  }
  ```

### String Operations
```php
// ✓ Fast
$result = implode('', $parts);

// ✗ Slow
$result = '';
foreach ($parts as $part) {
    $result .= $part;
}
```

## 9. Testing (PHPUnit - Manual)

### PHPUnit 11+ Features
- Use attributes instead of annotations:
  ```php
  #[Test]
  public function it_validates_input(): void { }
  ```
- Data providers with attributes
- Proper setUp/tearDown
- Mock objects for dependencies

### Test Quality
- Test coverage >80% target
- Edge cases tested
- Error conditions tested
- No database in unit tests (use mocks)
- Integration tests separate

### Coverage
```bash
phpunit --coverage-html coverage/
```

## 10. Manual Autoloading & Include Patterns

### Simple Autoloader
```php
spl_autoload_register(function (string $class): void {
    $namespace = 'App\\';
    $baseDir = __DIR__ . '/src/';

    $len = strlen($namespace);
    if (strncmp($namespace, $class, $len) !== 0) {
        return;
    }

    $relativeClass = substr($class, $len);
    $file = $baseDir . str_replace('\\', '/', $relativeClass) . '.php';

    if (file_exists($file)) {
        require $file;
    }
});
```

### Manual Includes
- Organize by feature/module
- Use relative paths carefully
- Validate paths before including
- No dynamic includes with user input

## 11. Minimal Composer Usage (If Present)

### composer.json Audit
If Composer is used (rare):
- Justify each dependency
- Check for security vulnerabilities:
  ```bash
  composer audit
  ```
- Update outdated packages:
  ```bash
  composer outdated
  ```
- Ensure `composer.lock` is committed

### Autoloading
```json
{
    "autoload": {
        "psr-4": {
            "App\\": "src/"
        }
    }
}
```

## 12. Code Smells & Anti-Patterns

### Detect Issues
- **God Classes**: Classes doing too much
- **Long Methods**: >50 lines suggests refactoring
- **Deep Nesting**: >3 levels of indentation
- **Magic Numbers**: Unexplained numeric literals
- **Tight Coupling**: Classes too dependent
- **Global State**: `$_SESSION`, `$_GLOBALS` overuse
- **Superglobal Access**: Wrap in request objects

## Output Format

For each issue found:

1. **Severity**: Critical/High/Medium/Low
2. **Location**: `file.php:line_number`
3. **PSR Reference**: If applicable (e.g., PSR-12)
4. **Description**: Clear explanation of the issue
5. **Impact**: How this affects security/performance
6. **Recommendation**: Concrete fix with PHP 8.3+ syntax

## Executive Summary

Provide:
- **Overall Health Score**: X/10 with justification
- **Top 5 Critical Issues**: Immediate attention required
- **Quick Wins**: Low-effort, high-impact improvements
- **Long-term Recommendations**: Architectural improvements
- **Security Critical**: SQL injection, XSS, CSRF findings
- **Type Safety**: Missing type declarations
- **Static Analysis**: PHPStan/Psalm results summary
- **Test Coverage**: Percentage and gaps

## Tool Integration Results

Include output from:
```bash
phpstan analyse --level=9 src/
psalm --show-info=true
phpcs --standard=PSR12 src/
phpunit --coverage-text
```

## Save Results

Save the complete audit report to:

```
./AUDIT-PHP.md
```

Include:
- Date and auditor information
- PHP version detected
- File statistics (total lines, classes, methods)
- Security vulnerabilities with severity
- Complete findings organized by severity
- Tool output summaries
- Actionable recommendations with code examples
- Migration path from older PHP patterns to 8.3+
