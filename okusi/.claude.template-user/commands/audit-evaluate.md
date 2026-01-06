Please perform a comprehensive audit of this codebase. Your analysis should cover the following areas:

## 1. Code Quality & Architecture
- Identify code smells, anti-patterns, and architectural issues
- Check for proper separation of concerns and adherence to SOLID principles
- Evaluate module/component organization and dependencies
- Assess code readability, maintainability, and documentation coverage

## 2. Security Vulnerabilities
- Scan for common security issues (SQL injection, XSS, CSRF, etc.)
- Check for hardcoded credentials or sensitive data exposure
- Review authentication/authorization implementation
- Identify insecure dependencies or outdated packages
- Assess input validation and sanitization practices

## 3. Performance Issues
- Identify potential bottlenecks (N+1 queries, inefficient algorithms)
- Check for memory leaks or resource management issues
- Review caching strategies and database query optimization
- Analyze frontend performance (bundle sizes, render blocking resources)

## 4. Error Handling & Reliability
- Evaluate error handling coverage and consistency
- Check for proper logging and monitoring integration
- Identify potential race conditions or concurrency issues
- Review backup/recovery mechanisms and data integrity checks

## 5. Testing & Quality Assurance
- Assess test coverage and identify untested critical paths
- Review test quality and identify missing test scenarios
- Check for flaky tests or improper test isolation
- Evaluate CI/CD pipeline effectiveness

## 6. Technical Debt & Modernization
- Identify deprecated APIs, libraries, or language features
- Find duplicated code that could be refactored
- Suggest modern alternatives to legacy patterns
- Evaluate framework/library versions and upgrade paths

## 7. Development Practices
- Check adherence to stated coding standards and conventions
- Review git history for commit quality and branching strategy
- Assess configuration management and environment handling
- Evaluate developer tooling and automation opportunities

For each issue found, please provide:
1. **Severity**: Critical/High/Medium/Low
2. **Location**: Specific file(s) and line numbers
3. **Description**: Clear explanation of the issue
4. **Impact**: How this affects the application
5. **Recommendation**: Concrete steps to fix or improve

Prioritize findings by severity and provide an executive summary with:
- Top 5 critical issues requiring immediate attention
- Quick wins that can improve code quality with minimal effort
- Long-term refactoring recommendations
- Overall codebase health score (1-10) with justification

Save the results to a report file ./AUDIT-EVALUATE.md.

THINK HARD ABOUT THIS.
