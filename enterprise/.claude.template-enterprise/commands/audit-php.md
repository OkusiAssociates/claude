# PHP 8.3+ Raw Code Audit

Perform a comprehensive audit of this PHP codebase targeting **PHP 8.3+ exclusively**. This is a raw code audit with **NO frameworks** (no Laravel, Symfony, etc.) and **minimal/rare Composer usage**.

## Context Requirements

- **PHP Version**: 8.3+ only (modern features expected)
- **Coding Standard**: Check against PHP-HTML Coding Standard (PHCS) if present
- **Code Style**: Raw PHP, no frameworks
- **Dependencies**: Minimal external packages, manual implementations preferred
- **Composer**: Rarely used, justify if present
- **Frameworks**: NONE - this is raw PHP code

## 1. PHCS Compliance (if applicable)

If `PHP-HTML-CODING-STANDARD.md` or `@PHP-HTML-CODING-STANDARD.md` exists in the project:

- Check for PHCS compliance using `phcs check` command (if available)
- Validate against all 12 PHCS sections
- Reference specific PHCS codes (format: PHCS0101, PHCS0301, etc.)
- Verify mandatory security functions exist: `e()`, `attr()`, `js()`, `url()`, `csrf_field()`
- Check file structure compliance (PHCS0101-0103)

### PHCS Sections Overview

| Section | Code Range | Topic |
|---------|------------|-------|
| 1 | PHCS0100 | File Structure & Layout |
| 2 | PHCS0200 | PHP Variables & Types |
| 3 | PHCS0300 | Strings & Output Escaping |
| 4 | PHCS0400 | Functions |
| 5 | PHCS0500 | Control Flow |
| 6 | PHCS0600 | Error Handling |
| 7 | PHCS0700 | HTML Structure |
| 8 | PHCS0800 | Forms & Input Validation |
| 9 | PHCS0900 | Database Operations |
| 10 | PHCS1000 | Security (XSS/CSRF/SQLi) |
| 11 | PHCS1100 | Sessions & State |
| 12 | PHCS1200 | Style & Development |

### Mandatory File Structure (PHCS0101-0103)

1. `<?php` on line 1 (PHCS0102)
2. `declare(strict_types=1);` on line 2 (PHCS0101)
3. Security includes first: `require_once 'security.inc.php';` (PHCS0103)
4. `.inc.php` extension for include files (PHCS0103)
5. `.php` extension for entry points (PHCS0103)

### Mandatory Security Functions (PHCS0301-0304, PHCS0801)

Verify these functions exist and are used correctly:

```php
// PHCS0301: HTML body escaping
function e(string $text, int $flags = ENT_QUOTES | ENT_HTML5, string $encoding = 'UTF-8'): string {
  return htmlspecialchars($text, $flags, $encoding);
}

// PHCS0302: HTML attribute escaping
function attr(string $text): string {
  return htmlspecialchars($text, ENT_QUOTES | ENT_HTML5, 'UTF-8');
}

// PHCS0303: JavaScript context escaping
function js(string $text): string {
  return json_encode($text, JSON_HEX_TAG | JSON_HEX_AMP | JSON_HEX_APOS | JSON_HEX_QUOT);
}

// PHCS0304: URL escaping (with scheme whitelist)
function url(string $url): string {
  $parsed = parse_url($url);
  if (isset($parsed['scheme']) && !in_array($parsed['scheme'], ['http', 'https', 'mailto'], true)) {
    return '';
  }
  return htmlspecialchars($url, ENT_QUOTES | ENT_HTML5, 'UTF-8');
}

// PHCS0801: CSRF form protection
function csrf_field(): string {
  if (session_status() === PHP_SESSION_NONE) session_start();
  if (empty($_SESSION['csrf_token'])) {
    $_SESSION['csrf_token'] = bin2hex(random_bytes(32));
  }
  return '<input type=hidden name=csrf_token value="' . attr($_SESSION['csrf_token']) . '">';
}
```

Audit every `<?=` and `echo` for correct escaping function usage:
- HTML body text: `e()` (PHCS0301)
- HTML attributes: `attr()` (PHCS0302)
- JavaScript context: `js()` (PHCS0303)
- Full URLs from user input: `url()` (PHCS0304)
- URL query parameters: `urlencode()` (PHCS0304)
- POST forms: `csrf_field()` (PHCS0801)

## 2. Static Analysis Tools

Run these tools automatically:

```bash
# PHPStan (level 9 - strictest)
phpstan analyse --level=9 src/

# PHP_CodeSniffer (PSR-12 baseline)
phpcs --standard=PSR12 src/

# PHCS check (if available)
phcs check file.php
```

Report all violations with file:line references.

**Note:** Only reference tools that are actually installed. Available tools:
- `phpstan` (v2.1.33)
- `phpcs` (v3.7.2)
- `phpunit` (v9.6.17)
- `phcs` (at `/usr/local/bin/phcs`, source: `/ai/scripts/Okusi/PHPCS/`)

## 3. PHP 8.3+ Language Features

### Modern Syntax (Required)
- **Typed Class Constants (8.3)**:
  ```php
  public const string NAME = 'value';  // Required
  ```
- **Dynamic Class Constant/Enum Fetch (8.3)**:
  ```php
  $const = $class::{$name};
  ```
- **`json_validate()` (8.3)**: Validate JSON without parsing
  ```php
  if (json_validate($json)) { /* ... */ }
  ```
- **Override Attribute (8.3)**:
  ```php
  #[Override]
  public function method(): void { }
  ```
- **Readonly Amendments (8.3)**: Deep cloning of readonly properties

### PHP 8.0-8.2 Features (Required)
- **Constructor Property Promotion (8.0)**:
  ```php
  public function __construct(
    public string $name,
    public int $age,
  ) {}
  ```
- **Named Arguments (8.0)**: Use for clarity
- **Enums (8.1)**: Use instead of class constants for fixed sets
  ```php
  enum Status: string {
    case Active = 'active';
    case Inactive = 'inactive';
  }
  ```
- **Readonly Properties (8.1)**: Immutable data
- **Readonly Classes (8.2)**: All properties readonly
- **Match Expressions (8.0)**: Use for value mapping (PHCS0503)
  ```php
  $result = match($value) {
    1 => 'one',
    2 => 'two',
    default => 'other',
  };
  ```

### Forbidden/Deprecated Patterns
- Old array syntax: `array()` (use `[]`)
- `switch` for simple value mapping (use `match`) (PHCS0503)
- `switch` IS allowed for side-effects, fall-through, and multi-statement cases
- Untyped properties/parameters (PHCS0202)
- Missing return types (PHCS0203)
- `create_function()` (removed in 8.0)
- `each()` (removed in 8.0)

## 4. Security (PHCS0300, PHCS1000)

### XSS Prevention (PHCS1001, PHCS1002)
**ALWAYS use the correct escaping function per context:**

```php
// PHCS0301/PHCS1001: HTML body - use e()
<h1><?=e($pageTitle)?></h1>
<p><?=e($userDescription)?></p>

// PHCS0302/PHCS1002: HTML attributes - use attr()
<input type=text name=search value='<?=attr($searchTerm)?>'>
<meta name=description content='<?=attr($description)?>'>

// PHCS0303: JavaScript context - use js()
<script>var userName = <?=js($userName)?>;</script>

// PHCS0304: URLs from user input - use url()
<a href='<?=url($externalUrl)?>'>Link</a>

// PHCS0304: URL query parameters - use urlencode()
<a href='/search?q=<?=urlencode($query)?>'>Search</a>
```

Check for:
- Raw `<?=$variable?>` without escaping (CRITICAL - PHCS1001)
- Direct superglobal output: `<?=$_GET['q']?>` (CRITICAL - PHCS1001)
- Using `e()` in attribute context (should use `attr()` for clarity - PHCS1002)
- Using `e()` or `attr()` in JavaScript context (must use `js()` - PHCS0303)
- Missing `htmlspecialchars()` flags (`ENT_QUOTES | ENT_HTML5`)
- Missing UTF-8 encoding specification
- Unescaped `$_SERVER` values (many are spoofable - PHCS1001)

### SQL Injection (PHCS0901, PHCS0902, PHCS1003)
**ALWAYS use prepared statements:**

```php
// mysqli prepared statement (primary pattern)
$stmt = $mysqli->prepare('SELECT * FROM users WHERE id = ?');
$stmt->bind_param('i', $userId);
$stmt->execute();
$result = $stmt->get_result();

// PDO prepared statement
$stmt = $pdo->prepare('SELECT * FROM users WHERE id = :id');
$stmt->execute([':id' => $userId]);
```

Check for:
- Raw queries with user input (CRITICAL - PHCS1003)
- String concatenation in SQL (CRITICAL - PHCS0902)
- `mysqli_real_escape_string()` as sole protection (insufficient)
- `sprintf()` in SQL queries (NOT safe)
- Missing parameter binding
- Dynamic column/table names without whitelist (PHCS0902)

### CSRF Protection (PHCS0801)
```php
// Every POST form MUST include csrf_field()
<form action='process.php' method=post>
  <!-- form fields -->
  <?=csrf_field()?>
  <button type=submit>Submit</button>
</form>

// Server-side verification
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
  if (!csrf_verify()) {
    http_response_code(403);
    error_log('CSRF validation failed: ' . $_SERVER['REMOTE_ADDR']);
    die('Invalid request');
  }
}
```

Check for:
- POST forms without `csrf_field()` (CRITICAL - PHCS0801)
- Missing server-side CSRF verification
- GET requests for state-changing operations
- `hash_equals()` usage for timing-safe comparison

### Path Traversal
```php
// Safe path validation
$basePath = '/var/www/uploads/';
$filePath = realpath($basePath . $userInput);

if ($filePath === false || !str_starts_with($filePath, $basePath)) {
  die('Invalid path');
}
```

### Command Injection
```php
// FORBIDDEN with user input:
exec($userInput);
shell_exec($userInput);
system($userInput);
passthru($userInput);

// If absolutely necessary:
$safe = escapeshellarg($userInput);
exec("command $safe", $output);
```

### Include/Require Safety
```php
// CRITICAL - File inclusion vulnerability
require $_GET['page'] . '.php';  // NEVER

// Safe - Whitelist approach
$allowed = ['home', 'about', 'contact'];
$page = $_GET['page'] ?? 'home';
if (in_array($page, $allowed, true)) {
  require "$page.php";
}
```

### XXE (XML External Entity)
PHP 8.2+ disables external entity loading by default. When parsing XML:
```php
// Use LIBXML_NONET flag for additional safety
$dom = new DOMDocument();
$dom->loadXML($xml, LIBXML_NONET | LIBXML_NOENT);
```

**Note:** `libxml_disable_entity_loader()` was removed in PHP 8.2 and causes a Fatal Error on PHP 8.3+. Do not use it.

### Deserialization
```php
// FORBIDDEN - Never unserialize user input
$data = unserialize($_POST['data']);  // NEVER

// Use JSON instead
$data = json_decode($_POST['data'], true);
```

### Security Headers
```php
header('X-Content-Type-Options: nosniff');
header('X-Frame-Options: DENY');
header('Content-Security-Policy: default-src \'self\'');
header('Strict-Transport-Security: max-age=31536000; includeSubDomains');
```

**Note:** `X-XSS-Protection` is deprecated and ignored by modern browsers. Rely on Content-Security-Policy instead.

## 5. Strict Type System (PHCS0101, PHCS0202-0203)

### Mandatory `declare(strict_types=1)` (PHCS0101)
**Every PHP file MUST start with:**
```php
<?php
declare(strict_types=1);

// Rest of code...
```

### Complete Type Declarations (PHCS0202-0203)
- All function parameters typed (PHCS0202)
- All return types annotated (PHCS0203)
- All class properties typed
- Use union types: `string|int`
- Use intersection types: `Countable&Traversable`
- Use nullable syntax: `?string` or `string|null`
- Use `never` type for functions that always throw or exit
- Use `void` for no return value
- Use `mixed` only when truly necessary (justify)

### Type Issues to Find
- Missing `declare(strict_types=1)` (PHCS0101)
- Untyped function parameters (PHCS0202)
- Missing return types (PHCS0203)
- Untyped class properties
- Use of `mixed` without justification
- Missing `#[Override]` attributes on overriding methods

## 6. Variable Handling & Quoting (PHCS0201, PHCS1202)

### Naming Conventions (PHCS0201)
- Local variables: `$camelCase`
- Configuration/important variables: `$PascalCase`
- Constants: `UPPER_SNAKE_CASE`

### String Quoting (PHCS1202)
- Default to single quotes: `'static string'`
- Double quotes only when interpolation is needed: `"Hello $name"`
- Use `<?=` short echo tag in HTML templates: `<?=e($var)?>`

### isset() vs array_key_exists()
- `isset($arr['key'])` returns `false` when value is `null`
- `array_key_exists('key', $arr)` returns `true` even for `null` values
- Use `isset()` when checking for non-null existence (most cases)
- Use `array_key_exists()` when `null` is a valid, meaningful value

## 7. Database Operations (PHCS0900)

### mysqli Prepared Statements (PHCS0901) - Primary Pattern
```php
// Basic query
$stmt = $mysqli->prepare('SELECT * FROM users WHERE id = ?');
$stmt->bind_param('i', $userId);
$stmt->execute();
$result = $stmt->get_result();
$row = $result->fetch_assoc();

// Multiple parameters with different types
$stmt = $mysqli->prepare(
  'INSERT INTO orders (user_id, product, quantity, price) VALUES (?, ?, ?, ?)');
$stmt->bind_param('isid', $userId, $product, $qty, $price);
$stmt->execute();
```

### PDO Prepared Statements
```php
$options = [
  PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
  PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
  PDO::ATTR_EMULATE_PREPARES => false,
];
$pdo = new PDO($dsn, $user, $pass, $options);

$stmt = $pdo->prepare('SELECT * FROM users WHERE email = :email');
$stmt->execute([':email' => $email]);
```

### Transaction Management
```php
// mysqli transaction
$mysqli->begin_transaction();
try {
  // Multiple queries...
  $mysqli->commit();
} catch (Exception $e) {
  $mysqli->rollback();
  throw $e;
}
```

### Query Optimization
- Check for N+1 query patterns
- Use JOINs instead of multiple queries
- Add indexes where needed
- Limit result sets

### Connection Error Handling (PHCS0903)
```php
// mysqli with exception handling
mysqli_report(MYSQLI_REPORT_ERROR | MYSQLI_REPORT_STRICT);
try {
  $conn = new mysqli($host, $user, $pass, $db);
  $conn->set_charset('utf8mb4');
} catch (mysqli_sql_exception $e) {
  error_log("Database connection failed: " . $e->getMessage());
  throw new RuntimeException("Service temporarily unavailable");
}
```

## 8. HTML Structure (PHCS0700)

### Attribute Quoting (PHCS0701)
- No quotes for simple values: `class=container`, `type=text`
- Single quotes for multi-word values: `class='row mb-3'`
- Double quotes only for values containing single quotes: `title="Don't click"`

### 2-Space Indentation (PHCS0702)
All PHP and HTML code MUST use 2-space indentation. This overrides PSR-12's 4-space recommendation.

```html
<!DOCTYPE html>
<html lang=en>
<head>
  <meta charset=UTF-8>
  <title><?=e($title)?></title>
</head>
<body>
  <div class=container>
    <div class=row>
      <div class=col>Content</div>
    </div>
  </div>
</body>
</html>
```

### Void Elements (PHCS0704)
HTML5 void elements MUST NOT include a closing slash:
```html
<meta charset=UTF-8>     <!-- Correct -->
<meta charset=UTF-8 />   <!-- Wrong: XHTML legacy -->
<br>                      <!-- Correct -->
<br />                    <!-- Wrong -->
<input type=text>         <!-- Correct -->
<input type=text />       <!-- Wrong -->
```

## 9. Forms & Input Validation (PHCS0800)

### CSRF Protection (PHCS0801)
Every POST form MUST include `<?=csrf_field()?>` before the submit button.

### Input Filtering (PHCS0802)
```php
// Always use filter_input() for superglobals
$email = filter_input(INPUT_POST, 'email', FILTER_VALIDATE_EMAIL);
$search = filter_input(INPUT_GET, 'q', FILTER_SANITIZE_FULL_SPECIAL_CHARS) ?? '';
$page = filter_input(INPUT_GET, 'page', FILTER_VALIDATE_INT) ?? 1;
```

### Server-Side Validation (PHCS0803)
- Client-side validation is for UX only - never trust it
- Always validate on server: type, length, format, whitelist
- Use `filter_input()` / `filter_var()` for all user input
- Whitelist for select/radio values

### Validation Checklist
- [ ] Required fields checked server-side
- [ ] Data types validated (string, int, email, URL)
- [ ] Length within bounds
- [ ] Format matches expected pattern
- [ ] Select/radio values in whitelist
- [ ] CSRF token valid (POST forms)

## 10. Sessions & State (PHCS1100)

### Session Start (PHCS1101)
```php
// Always check status before starting
if (session_status() === PHP_SESSION_NONE) {
  session_start();
}
```

### Session Regeneration (PHCS1102)
```php
// CRITICAL: Regenerate after authentication changes
session_regenerate_id(true);  // true = delete old session
```

### Secure Session Configuration
```php
ini_set('session.cookie_httponly', '1');
ini_set('session.cookie_secure', '1');    // HTTPS only
ini_set('session.cookie_samesite', 'Strict');
ini_set('session.use_strict_mode', '1');
ini_set('session.use_only_cookies', '1');
```

### Session Security Checks
- `session_regenerate_id(true)` after login (PHCS1102)
- Proper session destruction on logout
- Session data not used without validation
- No session fixation vulnerabilities

## 11. Code Style (PHCS1200)

### 2-Space Indentation (PHCS0702, PHCS1201)
- 2 spaces everywhere, never tabs
- Applies to both PHP and HTML
- Overrides PSR-12's 4-space recommendation

### PSR-12 Baseline (with PHCS overrides)
- PHP tags: `<?php` for code files, `<?=` for template echo (PHCS0102)
- File encoding: UTF-8 without BOM
- Side effects: Files should declare OR execute, not both
- Naming: Classes `PascalCase`, methods `camelCase`, constants `UPPER_CASE`
- Braces: **Next line** for class/method declarations, **same line** for control structures
- Line length: 120 characters soft limit
- Declare statements: One per line
- Import statements: One per line, alphabetically sorted
- **Indentation: 2 spaces** (PHCS override, not 4)

### String Quoting (PHCS1202)
- Single quotes by default
- Double quotes only when interpolation is needed

## 12. OOP Patterns

### Class Design
- Single Responsibility Principle (PHCS0403)
- Proper encapsulation (`private`/`protected`)
- Composition over inheritance
- Use interfaces for contracts
- Use abstract classes for shared behavior
- Use traits for code reuse (with caution)

### Readonly Classes (8.2+)
```php
readonly class Config {
  public function __construct(
    public string $host,
    public int $port,
  ) {}
}
```

### Proper Exception Handling (PHCS0601)
```php
// Specific exceptions
try {
  $result = riskyOperation();
} catch (InvalidArgumentException $e) {
  // Handle specific error
} catch (RuntimeException $e) {
  // Handle runtime error
}

// FORBIDDEN: error suppression operator @
@file_get_contents($path);  // NEVER (PHCS0601)
```

### Error Logging (PHCS0603)
- Use `error_log()` for all application errors
- Include context (IP, user ID, request info)
- Never expose error details to users
- Never log passwords, credentials, or PII

## 13. Performance

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
- Cache expensive operations
- Use generators for large datasets:
  ```php
  function getRows(mysqli_result $result): Generator {
    while ($row = $result->fetch_assoc()) {
      yield $row;
    }
  }
  ```

### String Operations
```php
// Fast
$result = implode('', $parts);

// Slow
$result = '';
foreach ($parts as $part) {
  $result .= $part;
}
```

## 14. Code Smells & Anti-Patterns

### Detect Issues
- **God Classes**: Classes doing too much
- **Long Methods**: >50 lines suggests refactoring
- **Deep Nesting**: >3 levels of indentation (use early returns - PHCS0502)
- **Magic Numbers**: Unexplained numeric literals
- **Tight Coupling**: Classes too dependent
- **Global State**: `$_SESSION`, `$_GLOBALS` overuse
- **Superglobal Access**: Wrap in request objects or use `filter_input()`
- **Error Suppression**: Any use of `@` operator (PHCS0601)
- **extract() Usage**: Can overwrite variables unexpectedly

## Output Format

For each issue found:

1. **Severity**: Critical/High/Medium/Low
2. **Location**: `file.php:line_number`
3. **PHCS Code**: Reference if applicable (e.g., PHCS0301, PHCS0901)
4. **Description**: Clear explanation of the issue
5. **Impact**: How this affects security/performance
6. **Recommendation**: Concrete fix with PHP 8.3+ syntax

## Executive Summary

Provide:
- **Overall Health Score**: X/10 with justification
- **PHCS Compliance**: Overall compliance percentage (if applicable)
- **Security Functions**: Status of e(), attr(), js(), url(), csrf_field()
- **Top 5 Critical Issues**: Immediate attention required
- **Quick Wins**: Low-effort, high-impact improvements
- **Long-term Recommendations**: Architectural improvements
- **Security Critical**: XSS (PHCS1001), SQLi (PHCS1003), CSRF (PHCS0801) findings
- **Type Safety**: Missing type declarations (PHCS0202-0203)
- **Static Analysis**: PHPStan/phpcs results summary
- **Test Coverage**: Percentage and gaps

## Tool Integration

Run these tools automatically:

```bash
# PHPStan (compulsory)
phpstan analyse --level=9 src/

# PHP_CodeSniffer (compulsory)
phpcs --standard=PSR12 src/

# PHCS check (compulsory if available)
phcs check file.php

# PHPUnit (if tests exist)
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
- PHCS compliance status and security function availability
- File statistics (total lines, classes, methods)
- Security vulnerabilities with severity and PHCS codes
- Complete findings organized by severity
- Tool output summaries
- Actionable recommendations with code examples
