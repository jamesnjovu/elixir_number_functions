# GitHub Actions Workflows

This directory contains GitHub Actions workflows for the NumberF project. These workflows provide comprehensive CI/CD automation including testing, security auditing, dependency management, and release automation.

## Workflows Overview

### 1. CI Workflow (`.github/workflows/ci.yml`)

**Triggers:**
- Push to `main` or `develop` branches
- Pull requests to `main` or `develop` branches

**Jobs:**
- **Test Matrix**: Tests across multiple Elixir/OTP versions (1.14-1.16 with OTP 24-26)
- **Comprehensive Tests**: Runs all tests including performance and benchmarks
- **Property Tests**: Executes property-based tests with extended timeouts
- **Integration Tests**: Runs integration and real-world scenario tests
- **Performance Tests**: Executes performance and benchmark tests
- **Documentation Tests**: Runs doctests and generates documentation
- **Concurrency Tests**: Tests concurrent operations
- **Coverage Analysis**: Generates detailed coverage reports
- **Quality Checks**: Code quality, security audit, and dependency checks

**Features:**
- Multi-version compatibility testing
- Code coverage reporting with Codecov integration
- Caching for faster builds
- Parallel job execution for efficiency
- Comprehensive test categorization

### 2. Nightly Tests (`.github/workflows/nightly.yml`)

**Triggers:**
- Scheduled daily at 2 AM UTC
- Manual dispatch

**Jobs:**
- **Extended Compatibility Matrix**: Tests across all supported Elixir/OTP combinations
- **Stress Tests**: Runs tests multiple times to catch intermittent issues
- **Long Running Tests**: Extended property-based and benchmark tests (2-hour timeout)
- **Memory Leak Detection**: Specialized tests for memory leak detection
- **Cross Platform Tests**: Tests on Ubuntu, Windows, and macOS
- **Security Audit**: Comprehensive security vulnerability scanning

**Purpose:**
- Catch issues that might not appear in regular CI
- Test platform-specific behavior
- Detect memory leaks and performance regressions
- Comprehensive security scanning

### 3. Release Workflow (`.github/workflows/release.yml`)

**Triggers:**
- Git tags matching `v*` pattern
- GitHub releases

**Jobs:**
- **Test Before Release**: Comprehensive test suite before publishing
- **Publish to Hex.pm**: Automated package publishing
- **Publish Documentation**: Automated documentation publishing to HexDocs
- **Create GitHub Release**: Automated GitHub release creation with changelog
- **Notification**: Success/failure notifications

**Features:**
- Automatic changelog extraction
- Release artifact creation
- Pre-release detection (alpha, beta, rc)
- Documentation generation and publishing

### 4. Dependency Update (`.github/workflows/dependency-update.yml`)

**Triggers:**
- Scheduled weekly on Mondays at 9 AM UTC
- Manual dispatch

**Jobs:**
- **Update Dependencies**: Checks for and updates outdated dependencies
- **Security Audit**: Scans for security vulnerabilities
- **Check Elixir Updates**: Monitors for new Elixir versions

**Features:**
- Automatic dependency updates with PR creation
- Security vulnerability detection with issue creation
- Elixir version monitoring
- Automated testing of updated dependencies

## Custom Mix Tasks Integration

The workflows integrate with custom mix tasks defined in the project:

- `mix test.numberf_fast`: Runs fast tests (excludes performance, benchmark, property tests)
- `mix test.numberf_all`: Runs comprehensive test suite including all test categories

## Test Categories

The project uses test tags to categorize different types of tests:

- **Default**: Standard unit and integration tests
- **Performance**: Performance benchmarking tests (excluded by default)
- **Property**: Property-based tests using generators
- **Benchmark**: Detailed benchmark tests
- **Compatibility**: Cross-version compatibility tests

## Environment Variables

All workflows use `MIX_ENV=test` for consistency, except the release workflow which uses `MIX_ENV=prod`.

## Caching Strategy

Each workflow implements intelligent caching:
- Dependencies (`deps/`)
- Build artifacts (`_build/`)
- Unique cache keys per workflow and Elixir/OTP version
- Fallback cache keys for partial matches

## Security Features

- **Dependency Auditing**: Regular security vulnerability scanning
- **Automated Security Issues**: Creates GitHub issues for vulnerabilities
- **Secure Token Usage**: Proper handling of `GITHUB_TOKEN` and `HEX_API_KEY`
- **Permission Scoping**: Minimal required permissions for each job

## Coverage Reporting

- **Codecov Integration**: Automatic coverage report uploads
- **Coverage Thresholds**: Configurable minimum coverage requirements
- **Detailed Reports**: Line-by-line coverage analysis

## Notification System

- **Release Notifications**: Success/failure notifications for releases
- **Security Alerts**: Automatic issue creation for security vulnerabilities
- **Dependency Updates**: PR creation for dependency updates

## Setup Requirements

### Required Secrets

1. **HEX_API_KEY**: Required for publishing to Hex.pm
   - Generate at: https://hex.pm/dashboard/keys
   - Add to repository secrets

2. **GITHUB_TOKEN**: Automatically provided by GitHub Actions
   - Used for creating PRs, issues, and releases

### Optional Integrations

1. **Codecov**: For enhanced coverage reporting
   - Sign up at: https://codecov.io
   - Add `CODECOV_TOKEN` to repository secrets (if private repo)

## Workflow Customization

### Adding New Test Categories

1. Add test tags in your test files:
   ```elixir
   @tag :your_category
   test "your test" do
     # test code
   end
   ```

2. Update workflows to include/exclude the new category:
   ```yaml
   - name: Run your category tests
     run: mix test --only your_category
   ```

### Modifying Elixir/OTP Matrix

Update the matrix in `ci.yml`:
```yaml
matrix:
  include:
    - elixir: '1.17'  # Add new version
      otp: '27'       # Add new OTP version
```

### Customizing Coverage Thresholds

Modify the coverage step in workflows:
```yaml
- name: Generate coverage report
  run: mix test.coverage --min-coverage 85  # Adjust threshold
```

## Troubleshooting

### Common Issues

1. **Cache Misses**: If builds are slow, check cache key patterns
2. **Test Timeouts**: Increase timeout values for long-running tests
3. **Memory Issues**: Monitor memory usage in performance tests
4. **Platform Differences**: Check cross-platform test results

### Debugging Workflows

1. Enable debug logging:
   ```yaml
   env:
     ACTIONS_STEP_DEBUG: true
   ```

2. Add debug steps:
   ```yaml
   - name: Debug info
     run: |
       mix --version
       elixir --version
       mix deps.tree
   ```

## Best Practices

1. **Fast Feedback**: CI workflow prioritizes fast tests first
2. **Parallel Execution**: Jobs run in parallel where possible
3. **Resource Efficiency**: Caching and job dependencies minimize resource usage
4. **Security First**: Regular security audits and vulnerability scanning
5. **Comprehensive Coverage**: Multiple test categories ensure thorough validation

## Monitoring and Maintenance

- **Weekly Dependency Updates**: Automated dependency management
- **Nightly Comprehensive Testing**: Catches issues early
- **Security Monitoring**: Continuous vulnerability scanning
- **Performance Tracking**: Regular performance regression detection

This workflow setup provides enterprise-grade CI/CD automation while maintaining simplicity and reliability.
