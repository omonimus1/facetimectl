# Contributing to facetimectl

Thank you for considering contributing to facetimectl! This document outlines the process for contributing to the project.

## Code of Conduct

By participating in this project, you agree to maintain a respectful and collaborative environment.

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check the existing issues to avoid duplicates. When creating a bug report, include:

- **Clear title and description**
- **Steps to reproduce** the issue
- **Expected behavior** vs. actual behavior
- **macOS version** and facetimectl version
- **Relevant logs or error messages**

Use the bug report template when creating issues.

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion:

- **Use a clear and descriptive title**
- **Provide a detailed description** of the proposed feature
- **Explain why this enhancement would be useful**
- **List any alternative solutions** you've considered

### Pull Requests

1. **Fork the repository** and create your branch from `master`
2. **Follow the coding style** used throughout the project
3. **Write meaningful commit messages** following [Conventional Commits](https://www.conventionalcommits.org/)
4. **Add tests** if applicable
5. **Update documentation** as needed
6. **Ensure all tests pass** before submitting

#### Pull Request Process

1. Update the README.md with details of changes if applicable
2. Update the CHANGELOG.md following the Keep a Changelog format
3. The PR will be merged once you have the sign-off of a maintainer

## Development Setup

### Prerequisites

- macOS 14.0 (Sonoma) or later
- Xcode 16.0 or later
- Swift 6.0

### Building from Source

```bash
# Clone the repository
git clone https://github.com/omonimus1/facetimectl.git
cd facetimectl

# Resolve dependencies
swift package resolve

# Build the project
swift build

# Run tests
swift test

# Build release version
make build
```

### Testing Locally

```bash
# Run the CLI
./bin/facetimectl --help

# Test specific commands
./bin/facetimectl status
./bin/facetimectl contacts --json
```

### Running Tests

```bash
# Run all tests
swift test

# Run tests with verbose output
swift test --verbose
```

## Coding Standards

### Swift Style Guide

- Follow [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- Use Swift 6 language features and concurrency where appropriate
- Keep functions focused and small
- Use meaningful variable and function names
- Add comments for complex logic

### Commit Messages

Follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks
- `ci`: CI/CD changes

Examples:
```
feat: add support for group FaceTime calls
fix: resolve contacts authorization issue on macOS 15
docs: update installation instructions
```

## Project Structure

```
facetimectl/
├── Sources/
│   ├── FaceTimeCore/       # Core FaceTime functionality
│   │   ├── FaceTimeController.swift
│   │   ├── ContactsStore.swift
│   │   └── Models.swift
│   └── facetimectl/        # CLI interface
│       ├── Commands/       # Command implementations
│       └── FacetimectlMain.swift
├── Tests/                  # Test files
├── Formula/                # Homebrew formula
└── docs/                   # Documentation
```

## Adding New Commands

To add a new command:

1. Create a new file in `Sources/facetimectl/Commands/`
2. Implement the `CommandSpec` protocol
3. Register the command in `CommandRouter.swift`
4. Add tests in `Tests/facetimectlTests/`
5. Update documentation

Example:
```swift
struct NewCommand: CommandSpec {
    static var commandName: String { "newcmd" }
    static var description: String { "Description of new command" }
    
    func run(_ router: CommandRouter) async -> Int32 {
        // Implementation
        return 0
    }
}
```

## Documentation

- Update relevant documentation when making changes
- Add inline code comments for complex logic
- Update the README.md if user-facing features change
- Add examples for new features

## Release Process

Releases are managed by maintainers. The process:

1. Update `CHANGELOG.md` with new version
2. Update version in `version.env`
3. Create and push a git tag (e.g., `v1.1.0`)
4. GitHub Actions automatically creates the release
5. Update Homebrew formula with new SHA256

## Questions?

Feel free to open an issue for questions or discussion. We're here to help!

## License

By contributing to facetimectl, you agree that your contributions will be licensed under the MIT License.
