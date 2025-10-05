# Contributing to UP

Thank you for your interest in contributing to UP! This document provides guidelines and information for contributors.

## How to Contribute

### Reporting Issues

- Use the GitHub issue tracker
- Provide clear description and examples
- Include UP version and environment details
- For parser bugs, include the problematic UP document

### Suggesting Features

- Open a GitHub discussion first for major features
- Explain the use case and motivation
- Provide examples of how it would work
- Consider backward compatibility

### Contributing Code

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass
6. Commit with clear messages (`git commit -m 'Add amazing feature'`)
7. Push to your fork (`git push origin feature/amazing-feature`)
8. Open a Pull Request

## Development Setup

### Go Implementation

```bash
# Clone the repository
git clone https://github.com/uplang/spec
cd up

# Install dependencies
go mod download

# Build
make build

# Run tests
go test ./...

# Run linter
golangci-lint run
```

### Language Parsers

Each parser in `parsers/` has its own build system:

```bash
# JavaScript/TypeScript
cd parsers/javascript
npm install
npm test

# Python
cd parsers/python
pip install -e .
python -m pytest

# Rust
cd parsers/rust
cargo build
cargo test

# C
cd parsers/c
make
make test
```

## Code Style

### Go
- Follow standard Go formatting (`gofmt`)
- Use meaningful variable names
- Add comments for exported functions
- Keep functions focused and small

### Other Languages
- Follow language-specific conventions
- Maintain consistency with existing code
- Add documentation comments

## Testing

### Adding Tests

- Add test cases for new features
- Test edge cases and error conditions
- Ensure backward compatibility
- Update example files if needed

### Running Tests

```bash
# Go tests
go test ./...

# Integration tests with examples
for file in examples/*.up; do
    ./bin/up validate -i "$file"
done
```

## Documentation

### Updating Documentation

- Update README.md for user-facing changes
- Update grammar specs for language changes
- Add examples for new features
- Keep documentation in sync with code

### Writing Examples

- Place examples in `examples/` directory
- Add clear comments explaining features
- Test examples with all parsers
- Update `examples/README.md`

## Grammar Changes

If proposing changes to the UP language:

1. Update `grammar/GRAMMAR.md` with formal specification
2. Update all grammar files:
   - `grammar/up.y` (Bison/Yacc)
   - `grammar/up.l` (Flex)
   - `grammar/up.g4` (ANTLR4)
   - `grammar/up.peg` (PEG)
   - `grammar/grammar.js` (Tree-sitter)
3. Update all parser implementations
4. Add examples demonstrating the feature
5. Update documentation

## Parser Implementation Guidelines

When implementing a UP parser in a new language:

### Structure

```
parsers/<language>/
├── README.md          # Usage and installation
├── parser files       # Implementation
├── tests/            # Unit tests
└── examples/         # Language-specific examples
```

### Requirements

- Parse all example files correctly
- Handle errors gracefully
- Provide clear error messages
- Support streaming/large files
- Include comprehensive tests
- Document the API
- Add installation instructions

### Testing

Ensure your parser correctly handles:
- All examples in `examples/` directory
- Edge cases (empty files, only comments, etc.)
- Error cases (unclosed blocks, invalid syntax)
- Unicode content
- Large files

## Commit Messages

Use clear, descriptive commit messages:

```
Add Python parser implementation

- Implement full UP parser in Python
- Add unit tests
- Add setup.py for pip installation
- Update README with Python usage
```

Format:
- First line: Brief summary (50 chars or less)
- Blank line
- Detailed description with bullet points
- Reference issues: `Fixes #123`

## Pull Request Process

1. Ensure all tests pass
2. Update documentation
3. Add examples if needed
4. Fill out PR template
5. Request review from maintainers
6. Address feedback
7. Wait for approval and merge

## Areas for Contribution

### High Priority

- [ ] Additional language parsers (Java, C#, Ruby, PHP, Swift, Kotlin)
- [ ] Schema validation system
- [ ] LSP (Language Server Protocol) implementation
- [ ] Performance benchmarks

### Medium Priority

- [ ] VS Code extension
- [ ] Vim/Neovim plugin
- [ ] Conversion tools (JSON ↔ UP, YAML ↔ UP)
- [ ] Template/interpolation support
- [ ] Online playground/REPL

### Low Priority

- [ ] Syntax highlighting for more editors
- [ ] Additional examples and tutorials
- [ ] Comparison benchmarks
- [ ] Logo and branding

## Community

- Be respectful and inclusive
- Help others in discussions
- Share your use cases
- Provide constructive feedback

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

## Questions?

- Open a GitHub discussion
- Check existing issues and PRs
- Read the documentation in `grammar/` and `examples/`

Thank you for contributing to UP!

