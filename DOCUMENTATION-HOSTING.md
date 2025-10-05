# Documentation Hosting Guide

This guide explains how automatic documentation is generated and hosted for each UP language implementation.

## Overview

Each language implementation has its documentation automatically generated and hosted using language-specific services:

| Language | Documentation Service | URL Pattern | Auto-Update |
|----------|----------------------|-------------|-------------|
| **Go** | pkg.go.dev | `https://pkg.go.dev/github.com/uplang/go` | ✅ Automatic on push |
| **JavaScript/TypeScript** | GitHub Pages (TypeDoc) | `https://uplang.github.io/js/` | ✅ Via GitHub Actions |
| **Python** | ReadTheDocs | `https://uplang.readthedocs.io/` | ✅ Automatic on push |
| **Rust** | docs.rs | `https://docs.rs/up-lang` | ✅ Automatic on crates.io publish |
| **Java** | GitHub Pages (JavaDoc) | `https://uplang.github.io/java/` | ✅ Via GitHub Actions |
| **C** | GitHub Pages (Doxygen) | `https://uplang.github.io/c/` | ✅ Via GitHub Actions |

---

## Go - pkg.go.dev

### How It Works
- **Automatic**: Go's official documentation site automatically indexes all public Go modules
- **Trigger**: Updates when you push tags or when the site crawls your repository
- **Source**: Extracts documentation from Go doc comments
- **Cost**: Free

### Setup
No setup required! Just ensure your code has proper doc comments:

```go
// Package up provides a parser for the UP (Unified Properties) format.
//
// UP is a human-friendly data serialization format designed for
// configuration files and data exchange.
package up

// Parse parses a UP document from a string.
//
// Returns the parsed document and any parsing errors encountered.
func Parse(input string) (*Document, error) {
    // ...
}
```

### URL
`https://pkg.go.dev/github.com/uplang/go`

### Badge
```markdown
[![Go Reference](https://pkg.go.dev/badge/github.com/uplang/go.svg)](https://pkg.go.dev/github.com/uplang/go)
```

---

## JavaScript/TypeScript - GitHub Pages + TypeDoc

### How It Works
- **Semi-Automatic**: Uses GitHub Actions to generate and deploy docs
- **Trigger**: On push to `main` or on release tags
- **Source**: TypeDoc extracts from TypeScript/JSDoc comments
- **Cost**: Free (GitHub Pages)

### Setup

1. **Install TypeDoc**:
```bash
npm install --save-dev typedoc
```

2. **Add `typedoc.json`**:
```json
{
  "entryPoints": ["src/index.ts"],
  "out": "docs",
  "excludePrivate": true,
  "excludeProtected": true,
  "excludeExternals": true,
  "readme": "README.md",
  "name": "UP Parser for JavaScript/TypeScript",
  "includeVersion": true
}
```

3. **Add npm script** in `package.json`:
```json
{
  "scripts": {
    "docs": "typedoc"
  }
}
```

4. **GitHub Actions Workflow** (`.github/workflows/docs.yml`):
```yaml
name: Documentation

on:
  push:
    branches: [main]
  release:
    types: [published]

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'

      - name: Install dependencies
        run: npm ci

      - name: Generate documentation
        run: npm run docs

      - name: Deploy to GitHub Pages
        uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./docs
```

5. **Enable GitHub Pages**:
   - Go to repository Settings → Pages
   - Source: Deploy from branch `gh-pages`
   - Save

### Documentation Comments
```typescript
/**
 * Parses a UP document from a string.
 *
 * @param input - The UP document as a string
 * @returns The parsed document
 * @throws {ParseError} If the input is not valid UP syntax
 *
 * @example
 * ```typescript
 * const doc = parse("name John Doe\nage!int 30");
 * console.log(doc.entries);
 * ```
 */
export function parse(input: string): Document {
    // ...
}
```

### URL
`https://uplang.github.io/js/`

### Badge
```markdown
[![Documentation](https://img.shields.io/badge/docs-typedoc-blue.svg)](https://uplang.github.io/js/)
```

---

## Python - ReadTheDocs

### How It Works
- **Automatic**: ReadTheDocs automatically builds docs from your repository
- **Trigger**: On push to any branch (configurable)
- **Source**: Sphinx extracts from docstrings
- **Cost**: Free for open source

### Setup

1. **Create account at** https://readthedocs.org/
2. **Import your project** from GitHub
3. **Add `docs/` directory** with Sphinx configuration:

```bash
cd py
pip install sphinx sphinx-rtd-theme
sphinx-quickstart docs
```

4. **Configure `docs/conf.py`**:
```python
import os
import sys
sys.path.insert(0, os.path.abspath('../src'))

project = 'UP Language Parser'
copyright = '2024, UP Language Team'
author = 'UP Language Team'

extensions = [
    'sphinx.ext.autodoc',
    'sphinx.ext.napoleon',
    'sphinx.ext.viewcode',
]

html_theme = 'sphinx_rtd_theme'
```

5. **Add `.readthedocs.yaml`**:
```yaml
version: 2

build:
  os: ubuntu-22.04
  tools:
    python: "3.11"

python:
  install:
    - requirements: requirements.txt
    - method: pip
      path: .

sphinx:
  configuration: docs/conf.py
```

### Documentation Comments
```python
def parse(input: str) -> Document:
    """
    Parse a UP document from a string.

    Args:
        input: The UP document as a string

    Returns:
        The parsed document with all entries

    Raises:
        ParseError: If the input is not valid UP syntax

    Example:
        >>> doc = parse("name John Doe\\nage!int 30")
        >>> print(doc.entries)
    """
    # ...
```

### URL
`https://uplang.readthedocs.io/`

### Badge
```markdown
[![Documentation Status](https://readthedocs.org/projects/uplang/badge/?version=latest)](https://uplang.readthedocs.io/)
```

---

## Rust - docs.rs

### How It Works
- **Automatic**: docs.rs automatically builds documentation for all crates.io packages
- **Trigger**: When you publish to crates.io
- **Source**: Extracts from Rust doc comments
- **Cost**: Free

### Setup
No setup required! Just publish to crates.io and docs.rs builds automatically.

Ensure your code has proper doc comments:

```rust
//! UP Language Parser
//!
//! This crate provides a parser for the UP (Unified Properties) format.
//!
//! # Examples
//!
//! ```
//! use up_lang::parse;
//!
//! let doc = parse("name John Doe\nage!int 30").unwrap();
//! println!("{:?}", doc);
//! ```

/// Parses a UP document from a string.
///
/// # Arguments
///
/// * `input` - The UP document as a string
///
/// # Returns
///
/// The parsed document
///
/// # Errors
///
/// Returns `ParseError` if the input is not valid UP syntax
///
/// # Examples
///
/// ```
/// use up_lang::parse;
/// let doc = parse("name value").unwrap();
/// ```
pub fn parse(input: &str) -> Result<Document, ParseError> {
    // ...
}
```

### Publish to crates.io
```bash
cargo login
cargo publish
```

### URL
`https://docs.rs/up-lang`

### Badge
```markdown
[![Documentation](https://docs.rs/up-lang/badge.svg)](https://docs.rs/up-lang)
```

---

## Java - GitHub Pages + JavaDoc

### How It Works
- **Semi-Automatic**: Uses GitHub Actions to generate and deploy docs
- **Trigger**: On push to `main` or on release tags
- **Source**: JavaDoc extracts from Java doc comments
- **Cost**: Free (GitHub Pages)

### Setup

1. **Configure JavaDoc** in `pom.xml`:
```xml
<build>
  <plugins>
    <plugin>
      <groupId>org.apache.maven.plugins</groupId>
      <artifactId>maven-javadoc-plugin</artifactId>
      <version>3.6.0</version>
      <configuration>
        <show>public</show>
        <outputDirectory>${project.build.directory}/apidocs</outputDirectory>
      </configuration>
    </plugin>
  </plugins>
</build>
```

2. **GitHub Actions Workflow** (`.github/workflows/docs.yml`):
```yaml
name: Documentation

on:
  push:
    branches: [main]
  release:
    types: [published]

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Set up JDK 21
        uses: actions/setup-java@v4
        with:
          java-version: '21'
          distribution: 'temurin'

      - name: Generate JavaDoc
        run: mvn javadoc:javadoc

      - name: Deploy to GitHub Pages
        uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./target/apidocs
```

### Documentation Comments
```java
/**
 * Parses a UP document from a string.
 *
 * @param input the UP document as a string
 * @return the parsed document
 * @throws ParseException if the input is not valid UP syntax
 *
 * @since 1.0
 * @see Document
 * @see ParseException
 *
 * @example
 * <pre>{@code
 * Document doc = UP.parse("name John Doe\nage!int 30");
 * System.out.println(doc.getEntries());
 * }</pre>
 */
public static Document parse(String input) throws ParseException {
    // ...
}
```

### URL
`https://uplang.github.io/java/`

### Badge
```markdown
[![Documentation](https://img.shields.io/badge/docs-javadoc-blue.svg)](https://uplang.github.io/java/)
```

---

## C - GitHub Pages + Doxygen

### How It Works
- **Semi-Automatic**: Uses GitHub Actions to generate and deploy docs
- **Trigger**: On push to `main` or on release tags
- **Source**: Doxygen extracts from C doc comments
- **Cost**: Free (GitHub Pages)

### Setup

1. **Install Doxygen** and create `Doxyfile`:
```bash
doxygen -g Doxyfile
```

2. **Configure `Doxyfile`**:
```
PROJECT_NAME           = "UP Parser for C"
OUTPUT_DIRECTORY       = docs
GENERATE_HTML          = YES
GENERATE_LATEX         = NO
INPUT                  = src include
RECURSIVE              = YES
EXTRACT_ALL            = YES
EXTRACT_PRIVATE        = NO
EXTRACT_STATIC         = YES
```

3. **GitHub Actions Workflow** (`.github/workflows/docs.yml`):
```yaml
name: Documentation

on:
  push:
    branches: [main]
  release:
    types: [published]

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Install Doxygen
        run: sudo apt-get install -y doxygen graphviz

      - name: Generate documentation
        run: doxygen Doxyfile

      - name: Deploy to GitHub Pages
        uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./docs/html
```

### Documentation Comments
```c
/**
 * @file up.h
 * @brief UP Language Parser API
 * @author UP Language Team
 */

/**
 * @brief Parse a UP document from a string
 *
 * This function parses a UP document and returns a document structure
 * containing all parsed entries.
 *
 * @param input The UP document as a null-terminated string
 * @return Pointer to the parsed document, or NULL on error
 *
 * @note The caller is responsible for freeing the returned document
 *       using up_document_free()
 *
 * @code
 * const char *up_text = "name John Doe\nage!int 30";
 * up_document_t *doc = up_parse_string(up_text);
 * if (doc) {
 *     // Use document
 *     up_document_free(doc);
 * }
 * @endcode
 *
 * @see up_document_free
 * @see up_parse_file
 */
up_document_t* up_parse_string(const char *input);
```

### URL
`https://uplang.github.io/c/`

### Badge
```markdown
[![Documentation](https://img.shields.io/badge/docs-doxygen-blue.svg)](https://uplang.github.io/c/)
```

---

## Summary

### Automatic Documentation (Zero Config)
- **Go**: pkg.go.dev ✅
- **Rust**: docs.rs ✅

### Semi-Automatic (GitHub Actions Setup)
- **JavaScript/TypeScript**: TypeDoc + GitHub Pages
- **Python**: ReadTheDocs (webhook)
- **Java**: JavaDoc + GitHub Pages
- **C**: Doxygen + GitHub Pages

### Best Practices

1. **Write Good Doc Comments**: All implementations should have comprehensive documentation
2. **Include Examples**: Code examples in documentation are invaluable
3. **Link Between Repos**: Cross-link docs, spec, and examples
4. **Keep Updated**: Documentation should be regenerated on every release
5. **Test Examples**: Ensure code examples in docs actually compile/run

---

## CI Status Badges

All repositories include GitHub Actions CI badges that link to test status:

```markdown
[![CI](https://github.com/uplang/{repo}/workflows/CI/badge.svg)](https://github.com/uplang/{repo}/actions)
```

This shows the current status of:
- Unit tests
- Integration tests
- Linting
- Code coverage (optional)

---

## Additional Resources

- **GitHub Pages**: https://pages.github.com/
- **ReadTheDocs**: https://docs.readthedocs.io/
- **pkg.go.dev**: https://go.dev/about
- **docs.rs**: https://docs.rs/about
- **TypeDoc**: https://typedoc.org/
- **Doxygen**: https://www.doxygen.nl/
- **JavaDoc**: https://docs.oracle.com/javase/8/docs/technotes/tools/windows/javadoc.html

