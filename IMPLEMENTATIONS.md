# UP Language Implementations

Official parser implementations in various programming languages. Each implementation is maintained in its own repository with complete documentation and examples.

## Official Implementations

### Go (Reference Implementation)

[![Go Reference](https://pkg.go.dev/badge/github.com/uplang/go.svg)](https://pkg.go.dev/github.com/uplang/go)
[![Go Report Card](https://goreportcard.com/badge/github.com/uplang/go)](https://goreportcard.com/report/github.com/uplang/go)
[![CI](https://github.com/uplang/go/workflows/CI/badge.svg)](https://github.com/uplang/go/actions)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

**Repository**: https://github.com/uplang/go

📚 **[API Documentation](https://pkg.go.dev/github.com/uplang/go)** | 🧪 **[Test Status](https://github.com/uplang/go/actions)** | 📖 **[Quick Start](https://github.com/uplang/go#readme)**

The reference implementation includes both the parser library and command-line tools.

**Features:**
- Complete UP parser
- Command-line tool (`up`)
- Template processing
- Schema validation support
- Zero dependencies

**Installation:**
```bash
go get github.com/uplang/go
```

---

### JavaScript/TypeScript

[![npm version](https://badge.fury.io/js/%40uplang%2Fup.svg)](https://www.npmjs.com/package/@uplang/up)
[![npm downloads](https://img.shields.io/npm/dm/@uplang/up.svg)](https://www.npmjs.com/package/@uplang/up)
[![CI](https://github.com/uplang/js/workflows/CI/badge.svg)](https://github.com/uplang/js/actions)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

**Repository**: https://github.com/uplang/js

📚 **[API Documentation](https://uplang.github.io/js/)** | 🧪 **[Test Status](https://github.com/uplang/js/actions)** | 📖 **[Quick Start](https://github.com/uplang/js#readme)**

Pure JavaScript/TypeScript implementation for Node.js and browsers.

**Features:**
- Full TypeScript types
- Works in browsers, Node.js, Deno, Bun
- ESM + CommonJS
- Zero dependencies

**Installation:**
```bash
npm install @uplang/up
```

---

### Python

[![PyPI version](https://badge.fury.io/py/up-lang.svg)](https://pypi.org/project/up-lang/)
[![CI](https://github.com/uplang/py/workflows/CI/badge.svg)](https://github.com/uplang/py/actions)
[![Documentation Status](https://readthedocs.org/projects/uplang/badge/?version=latest)](https://uplang.readthedocs.io/)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

**Repository**: https://github.com/uplang/py

📚 **[API Documentation](https://uplang.readthedocs.io/)** | 🧪 **[Test Status](https://github.com/uplang/py/actions)** | 📖 **[Quick Start](https://github.com/uplang/py#readme)**

Python implementation with native types support.

**Features:**
- Pythonic design with dataclasses
- Full type hints
- Zero dependencies
- CLI tool included

**Installation:**
```bash
pip install up-lang
```

---

### Rust

[![Crates.io](https://img.shields.io/crates/v/up-lang.svg)](https://crates.io/crates/up-lang)
[![Documentation](https://docs.rs/up-lang/badge.svg)](https://docs.rs/up-lang)
[![CI](https://github.com/uplang/rust/workflows/CI/badge.svg)](https://github.com/uplang/rust/actions)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

**Repository**: https://github.com/uplang/rust

📚 **[API Documentation](https://docs.rs/up-lang)** | 🧪 **[Test Status](https://github.com/uplang/rust/actions)** | 📖 **[Quick Start](https://github.com/uplang/rust#readme)**

High-performance Rust implementation with zero-copy parsing.

**Features:**
- Memory safe
- Zero-cost abstractions
- Zero dependencies
- CLI tool included

**Installation:**
```toml
[dependencies]
up-lang = "1.0"
```

---

### Java

[![CI](https://github.com/uplang/java/workflows/CI/badge.svg)](https://github.com/uplang/java/actions)
[![Documentation](https://img.shields.io/badge/docs-javadoc-blue.svg)](https://uplang.github.io/java/)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

**Repository**: https://github.com/uplang/java

📚 **[API Documentation](https://uplang.github.io/java/)** | 🧪 **[Test Status](https://github.com/uplang/java/actions)** | 📖 **[Quick Start](https://github.com/uplang/java#readme)**

Modern Java implementation using records and sealed classes (Java 21+).

**Status:** 🚧 In Progress

---

### C

[![CI](https://github.com/uplang/c/workflows/CI/badge.svg)](https://github.com/uplang/c/actions)
[![Documentation](https://img.shields.io/badge/docs-doxygen-blue.svg)](https://uplang.github.io/c/)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

**Repository**: https://github.com/uplang/c

📚 **[API Documentation](https://uplang.github.io/c/)** | 🧪 **[Test Status](https://github.com/uplang/c/actions)** | 📖 **[Quick Start](https://github.com/uplang/c#readme)**

C implementation for maximum portability and embeddability.

**Features:**
- ANSI C compatible
- Minimal dependencies
- Cross-platform
- CLI tool included

**Installation:**
```bash
make && sudo make install
```

---

## Implementation Status

All implementations support the core UP syntax. Advanced features vary by implementation:

| Feature | Go | JS/TS | Python | Rust | C |
|---------|:--:|:-----:|:------:|:----:|:-:|
| Core Parser | ✅ | ✅ | ✅ | ✅ | ✅ |
| Type Annotations | ✅ | ✅ | ✅ | ✅ | ✅ |
| Blocks & Lists | ✅ | ✅ | ✅ | ✅ | ✅ |
| Multiline Strings | ✅ | ✅ | ✅ | ✅ | ✅ |
| Dedenting | ✅ | ✅ | ✅ | ✅ | ✅ |
| Tables | ✅ | ✅ | ✅ | ✅ | ✅ |
| Templates | ✅ | 🚧 | 🚧 | 🚧 | ❌ |
| Schema Validation | 🚧 | ❌ | ❌ | ❌ | ❌ |
| CLI Tool | ✅ | ❌ | ❌ | ❌ | ❌ |

- ✅ Complete
- 🚧 In Progress
- ❌ Not Implemented

## Quick Links

| Language | Repository | Package/Install | Documentation | CI Status |
|----------|------------|-----------------|---------------|-----------|
| **Go** | [uplang/go](https://github.com/uplang/go) | `go get github.com/uplang/go` | [pkg.go.dev](https://pkg.go.dev/github.com/uplang/go) | [Tests](https://github.com/uplang/go/actions) |
| **JavaScript** | [uplang/js](https://github.com/uplang/js) | `npm install @uplang/up` | [TypeDoc](https://uplang.github.io/js/) | [Tests](https://github.com/uplang/js/actions) |
| **Python** | [uplang/py](https://github.com/uplang/py) | `pip install up-lang` | [ReadTheDocs](https://uplang.readthedocs.io/) | [Tests](https://github.com/uplang/py/actions) |
| **Rust** | [uplang/rust](https://github.com/uplang/rust) | `cargo add up-lang` | [docs.rs](https://docs.rs/up-lang) | [Tests](https://github.com/uplang/rust/actions) |
| **Java** | [uplang/java](https://github.com/uplang/java) | Maven/Gradle | [JavaDoc](https://uplang.github.io/java/) | [Tests](https://github.com/uplang/java/actions) |
| **C** | [uplang/c](https://github.com/uplang/c) | `make install` | [Doxygen](https://uplang.github.io/c/) | [Tests](https://github.com/uplang/c/actions) |

## Contributing

### Improving Existing Implementations

Each implementation has its own contribution guidelines. Please see the respective repository for details.

### Adding a New Implementation

Want to implement UP in another language? Great! Here's what you need:

1. **Implement the core parser** following the [UP specification](README.md)
2. **Pass the test suite** - use examples from [`examples/`](examples/)
3. **Create comprehensive tests** with good coverage
4. **Write clear documentation** with examples
5. **Follow language best practices** and idioms
6. **Use an open source license** (MIT preferred)

**Requirements:**
- Complete implementation of core UP syntax
- Parse all examples correctly
- Handle errors gracefully
- Clear API documentation
- README with installation and usage examples

Contact us via [GitHub Discussions](https://github.com/uplang/spec/discussions) to have your implementation listed here!

## Support

For implementation-specific issues, please file issues in the respective repository:
- Go: https://github.com/uplang/go/issues
- JavaScript: https://github.com/uplang/js/issues
- Python: https://github.com/uplang/py/issues
- Rust: https://github.com/uplang/rust/issues
- C: https://github.com/uplang/c/issues

For specification issues or general questions: https://github.com/uplang/spec/issues

## License

Each implementation has its own license (typically MIT). See individual repositories for details.
