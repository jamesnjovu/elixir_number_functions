# Contributing to NumberF

Thank you for considering contributing to NumberF! This document provides guidelines and instructions for contributing to make the process smooth for everyone.

## Code of Conduct

By participating in this project, you agree to maintain a welcoming, inclusive, and harassment-free environment. Please be respectful toward others.

## How Can I Contribute?

### Reporting Bugs

If you encounter a bug, please create an issue with the following information:
- Clear title that summarizes the issue
- Steps to reproduce the behavior
- Expected behavior
- Actual behavior
- Elixir and NumberF versions
- Any additional context that might be helpful

### Suggesting Enhancements

We welcome feature suggestions! When suggesting enhancements:
- Use a clear title for the issue
- Provide a detailed description of the suggested enhancement
- Explain why this enhancement would be useful
- List example use cases if applicable

### Pull Requests

1. Fork the repository
2. Create a new branch for your feature (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

#### Pull Request Guidelines

- Update the README.md with details of changes if applicable
- Update the CHANGELOG.md with details of changes
- The PR should work with all supported Elixir versions
- Ensure all tests pass
- Add tests for new features to ensure code coverage
- Follow the existing code style

## Development Setup

1. Clone the repository
   ```bash
   git clone https://github.com/jamesnjovu/elixir_number_functions.git
   cd number_f
   ```

2. Install dependencies
   ```bash
   mix deps.get
   ```

3. Run tests
   ```bash
   mix test
   ```

4. Run code formatting
   ```bash
   mix format
   ```

## Styleguides

### Git Commit Messages

- Use the present tense ("Add feature" not "Added feature")
- Use the imperative mood ("Move cursor to..." not "Moves cursor to...")
- Limit the first line to 72 characters or less
- Reference issues and pull requests after the first line

### Elixir Styleguide

- Follow the [Elixir Style Guide](https://github.com/christopheradams/elixir_style_guide)
- Run `mix format` before committing

### Documentation Styleguide

- Use [ExDoc](https://hexdocs.pm/ex_doc/readme.html) syntax
- Include examples in function documentation
- Keep explanations clear and concise

## Module Structure

When adding new modules or functions, please follow the existing structure:

- Core functionality in the main `NumberF` module
- Specialized functions in appropriate submodules
- Add exports to the main module for commonly used functionality

## Adding New Features

When adding new features:

1. Add appropriate test coverage
2. Add thorough documentation with examples
3. Update type specifications if applicable
4. Consider internationalization implications
5. Update the README.md if the feature is user-facing

## Questions?

If you have any questions about contributing, please open an issue for discussion.

Thank you for helping improve NumberF!