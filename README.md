# UP

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![Website](https://img.shields.io/badge/Website-uplang.org-blue)](https://uplang.org)

**Unified Properties**

UP is a modern, human-friendly data serialization format designed to be simpler than YAML, more powerful than JSON, and more readable than TOML. It combines the best features of existing formats while introducing unique capabilities like dedenting and type annotations.

**Quick Links:**
- 📖 [Syntax Reference](SYNTAX-REFERENCE.md)
- 🔧 [Implementations](IMPLEMENTATIONS.md)
- 📚 [Grammar Specification](grammar/)
- 🌐 [Website](https://uplang.org)

## Why UP?

- **🎯 Simple**: Cleaner syntax than YAML, no tricky indentation rules
- **💪 Powerful**: Type annotations, multiline strings, nested structures, tables
- **📖 Readable**: Human-friendly format that's easy to write and maintain
- **🚀 Fast**: Simple parser design, efficient implementations
- **🔧 Flexible**: Support for embedded code blocks with language hints
- **✨ Unique**: Dedenting feature for clean embedded content

## Features

### Type Annotations
```up
name John Doe
age!int 30
active!bool true
url!uri https://example.com
created!ts 2025-10-05T12:00:00Z
timeout!dur 30s
```

### Blocks (Nested Structures)
```up
server {
  host localhost
  port!int 8080
  database {
    host db.example.com
    port!int 5432
  }
}
```

### Lists
```up
# Multiline lists
items [
apple
banana
cherry
]

# Inline lists
colors [red, green, blue]
```

### Multiline Strings with Language Hints
```up
script!bash ```bash
#!/bin/bash
echo "Hello, World!"
```

config ```json
{
  "key": "value",
  "number": 42
}
```
```

### Dedenting (Unique Feature!)
```up
# Remove 4 leading spaces from each line
code!4 ```python
    def hello():
        print("world")
```

# Becomes:
# def hello():
#     print("world")
```

### Tables
```up
users!table {
  columns [id, name, email, age]
  rows {
    [1, Alice, alice@example.com, 30]
    [2, Bob, bob@example.com, 25]
    [3, Carol, carol@example.com, 35]
  }
}
```

### Comments
```up
# Comments start with # and go to end of line
name John Doe  # Everything is intuitive
```

### Templates & Composition (Revolutionary!)
```up
# base.up - Common configuration
vars {
  app_name MyApp
  default_port!int 8080
}

app_name $vars.app_name
server {
  port $vars.default_port
}

# production.up - Environment-specific
config!base base.up

server!overlay {
  host production.example.com
  replicas!int 10
}

# Result: Base + Production overlay = Final config
```

**No string templating hell! Just declarative composition using `!` annotations.**

**Iterative variable resolution** - Variables can reference each other regardless of order:
```up
vars {
  environment production
  region us-west-2
  host $vars.environment.$vars.region.example.com  # Resolved iteratively
  url https://$vars.host:443
}
```

**Dynamic namespaces** - Generate content on-the-fly for testing and mocking:
```up
!use [time, id, faker, random]

test_user {
  id $id.uuid
  name $faker.name
  email $faker.email
  created_at $time.now
  score!int $random.int(1, 100)
}
```

**Declarative list generation** - `$list` namespace with `$self` context:
```up
!use [list, faker, id]

# Generate 10 test users with sequence context
users $list.generate(10, {
  id $id.uuid
  sequence!int $self.number
  name $faker.name
  email $faker.email
  is_first!bool $self.first
  label "User $self.number of $self.count"
})
```

**Runtime schema validation** - Types reference schemas for validation:
```up
# Schema validates structure and constraints
server!file://./schemas/server.up-schema {
  host localhost
  port!int 8080
  timeout!dur 30s
}

# Or use schema registry
server!https://schemas.uplang.org/server/1.0.0 {
  host example.com
  port!int 443
  tls_enabled!bool true
}
```

**Multi-document files** - Use comment separators (`# ---`) to define multiple configs in one file:
```up
# base config
vars { port!int 8080 }

# ---

# dev config
config!base base.up
server!overlay { debug!bool true }

# ---

# prod config
config!base base.up
server!overlay { replicas!int 10 }
```

See [TEMPLATING.md](TEMPLATING.md) for full documentation.

## Quick Start

#---

## Implementations

UP has official implementations in multiple languages:

<table>
<tr>
<th>Language</th>
<th>Repository</th>
<th>Package</th>
<th>Status</th>
</tr>
<tr>
<td><b>Go</b></td>
<td><a href="https://github.com/uplang/go">uplang/go</a></td>
<td><code>go get github.com/uplang/go</code></td>
<td>✅ Stable</td>
</tr>
<tr>
<td><b>JavaScript/TypeScript</b></td>
<td><a href="https://github.com/uplang/js">uplang/js</a></td>
<td><code>npm install @uplang/parser</code></td>
<td>✅ Stable</td>
</tr>
<tr>
<td><b>Python</b></td>
<td><a href="https://github.com/uplang/py">uplang/py</a></td>
<td><code>pip install uplang</code></td>
<td>✅ Stable</td>
</tr>
<tr>
<td><b>Rust</b></td>
<td><a href="https://github.com/uplang/rust">uplang/rust</a></td>
<td><code>cargo add uplang</code></td>
<td>✅ Stable</td>
</tr>
<tr>
<td><b>Java</b></td>
<td><a href="https://github.com/uplang/java">uplang/java</a></td>
<td>Maven/Gradle</td>
<td>🚧 In Progress</td>
</tr>
<tr>
<td><b>C</b></td>
<td><a href="https://github.com/uplang/c">uplang/c</a></td>
<td><code>make install</code></td>
<td>✅ Stable</td>
</tr>
</table>

[**→ See All Implementations**](IMPLEMENTATIONS.md)

---

## Tooling

### Command-Line Tools

| Tool | Description | Installation |
|------|-------------|--------------|
| **up** | Main CLI for parsing, formatting, validation | `go install github.com/uplang/tools/up@latest` |
| **up-language-server** | LSP server for IDE integration | `go install github.com/uplang/tools/language-server@latest` |
| **up-repl** | Interactive REPL | `go install github.com/uplang/tools/repl@latest` |

### Editor Support

| Editor | Extension | Features |
|--------|-----------|----------|
| **VS Code** | [vscode-up](https://github.com/uplang/vscode-up) | Syntax highlighting, LSP, auto-completion |
| **IntelliJ IDEA** | [intellij-up](https://github.com/uplang/intellij-up) | Full IDE integration, refactoring |
| **Vim/Neovim** | LSP via `nvim-lspconfig` | Syntax highlighting, LSP support |
| **Emacs** | LSP via `lsp-mode` | Full LSP integration |

### Namespace Plugins

Extend UP with dynamic functions:

| Namespace | Description | Example |
|-----------|-------------|---------|
| **string** | String manipulation | `string:uuid`, `string:upper` |
| **time** | Date/time functions | `time:now`, `time:format` |
| **env** | Environment variables | `env:get HOME` |
| **file** | File operations | `file:read config.txt` |
| **random** | Random data | `random:int 1 100` |
| **fake** | Test data generation | `fake:name`, `fake:email` |

[**→ See All Namespaces**](https://github.com/uplang/ns)

---

## Ecosystem

### Related Projects

- [**spec**](https://github.com/uplang/spec) - Language specification and grammar
- [**tools**](https://github.com/uplang/tools) - CLI tools and language server
- [**ns**](https://github.com/uplang/ns) - Official namespace plugins
- [**vscode-up**](https://github.com/uplang/vscode-up) - VS Code extension
- [**intellij-up**](https://github.com/uplang/intellij-up) - IntelliJ IDEA plugin

### Documentation

- [**Syntax Reference**](SYNTAX-REFERENCE.md) - Complete syntax guide
- [**Templating**](TEMPLATING.md) - Template composition and variables
- [**Schema Validation**](SCHEMA-VALIDATION.md) - Schema definition and validation
- [**Dynamic Namespaces**](DYNAMIC-NAMESPACES.md) - Creating custom namespace plugins
- [**UP-JSON**](UP-JSON.md) - JSON representation format

---

## Installation

```bash
# UP CLI tool
go install github.com/uplang/tools/up@latest

# Language Server
go install github.com/uplang/tools/language-server@latest

# Or use language-specific parser libraries
# See IMPLEMENTATIONS.md for all available implementations
```

### Usage

```bash
# Parse a UP file and output as JSON
up parse -i config.up --pretty

# Validate UP syntax
up validate -i config.up

# Format a UP file
up format -i config.up -o formatted.up

# Process templates (NEW!)
up template process -i config/production.up -o output.up

# Validate templates
up template validate -i config/production.up
```

### Example Document

```up
# Application configuration
app_name MyApp
version 1.0.0
debug!bool false

# Server settings
server {
  host 0.0.0.0
  port!int 8080
  tls_enabled!bool true
}

# Database configuration
database {
  driver postgres
  host db.example.com
  port!int 5432
  max_connections!int 50
}

# Feature flags
features {
  new_ui!bool true
  beta_api!bool false
}

# API endpoints
endpoints [
/health
/api/v1/users
/api/v1/products
]

# Environment variables
environment ```bash
export DATABASE_URL="postgresql://localhost/mydb"
export REDIS_URL="redis://localhost:6379"
export API_KEY="secret-key-here"
```

# Scheduled jobs
jobs!table {
  columns [name, schedule, command]
  rows {
    [backup, 0 2 * * *, /usr/local/bin/backup.sh]
    [cleanup, 0 3 * * *, /usr/local/bin/cleanup.sh]
  }
}
```

## Templating System

UP includes a revolutionary **declarative templating system** that avoids traditional string-based templating hell.

### Key Features

- **`_vars`** - Define reusable structured variables
- **`_base`** - Inherit from base configurations
- **`_overlay`** - Merge configurations declaratively
- **`_include`** - Compose from multiple files
- **`_patch`** - Apply targeted modifications
- **`_merge`** - Configure merge strategies

### Why UP Templating?

❌ **Traditional templating** (Helm, Jinja2):
```yaml
replicas: {{ .Values.replicas | default 3 }}
{{- if .Values.production }}
  tls: {{ .Values.tls | toJson }}
{{- end }}
```
Problems: String substitution, complex logic, type-unsafe, hard to debug

✅ **UP templating**:
```up
_base base.up
_overlay {
  server {
    replicas!int 10
    tls_enabled!bool true
  }
}
```
Benefits: Declarative, type-safe, composable, predictable

### Example: Multi-Environment Setup

```
config/
├── base.up              # Common config
├── development.up       # Dev environment
├── production.up        # Prod environment
└── features/
    ├── enable-beta.up
    └── high-availability.up
```

Compose them:
```bash
up template process -i config/production.up -o prod.up
```

See [TEMPLATING.md](TEMPLATING.md) and [examples/templates/](examples/templates/) for complete documentation.

## Language Implementations

UP has official parser implementations in multiple languages. Each implementation is maintained in its own repository.

For complete details and installation instructions, see **[IMPLEMENTATIONS.md](IMPLEMENTATIONS.md)**.

### Go (Reference Implementation)
```go
import "github.com/uplang/go"

p := up.NewParser()
doc, err := p.ParseDocument(reader)
```

Repository: [`github.com/uplang/go`](https://github.com/uplang/go)

### JavaScript/TypeScript
```javascript
const up = require('@uplang/js');
const doc = up.parse(upText);
```

Repository: [`github.com/uplang/js`](https://github.com/uplang/js)

### Python
```python
import uplang
doc = uplang.parse(up_text)
```

Repository: [`github.com/uplang/py`](https://github.com/uplang/py)

### Rust
```rust
use uplang::parse;
let doc = parse(up_text)?;
```

Repository: [`github.com/uplang/rust`](https://github.com/uplang/rust)

### C
```c
#include <up.h>
up_document_t *doc = up_parse_string(up_text);
```

Repository: [`github.com/uplang/c`](https://github.com/uplang/c)

## Grammar Specifications

UP has formal grammar definitions in multiple parser generator formats:

- **Bison/Yacc + Flex**: [`grammar/up.y`](grammar/up.y) + [`grammar/up.l`](grammar/up.l)
- **ANTLR4**: [`grammar/up.g4`](grammar/up.g4)
- **PEG**: [`grammar/up.peg`](grammar/up.peg)
- **Tree-sitter**: [`grammar/grammar.js`](grammar/grammar.js)
- **EBNF Specification**: [`grammar/GRAMMAR.md`](grammar/GRAMMAR.md)
- **Lexer Specification**: [`grammar/LEXER.md`](grammar/LEXER.md)

These can be used to generate parsers in any language supported by these tools.

## Examples

Comprehensive examples demonstrating all UP features:

- [`01-basic-scalars.up`](examples/01-basic-scalars.up) - Type annotations
- [`02-blocks.up`](examples/02-blocks.up) - Nested structures
- [`03-lists.up`](examples/03-lists.up) - Lists and arrays
- [`04-multiline.up`](examples/04-multiline.up) - Code blocks with language hints
- [`05-dedent.up`](examples/05-dedent.up) - Dedenting feature
- [`06-comments.up`](examples/06-comments.up) - Comment syntax
- [`07-tables.up`](examples/07-tables.up) - Tabular data
- [`08-mixed-complex.up`](examples/08-mixed-complex.up) - Real-world configuration

See [`examples/README.md`](examples/README.md) for detailed descriptions.

## Comparison with Other Formats

| Feature | UP | JSON | YAML | TOML | HCL |
|---------|------|------|------|------|-----|
| Human-friendly | ✅ | ❌ | ✅ | ✅ | ✅ |
| Type annotations | ✅ | ❌ | ❌ | ✅ | ✅ |
| Multiline strings | ✅ | ❌ | ✅ | ✅ | ✅ |
| Comments | ✅ | ❌ | ✅ | ✅ | ✅ |
| Nested structures | ✅ | ✅ | ✅ | ✅ | ✅ |
| Simple syntax | ✅ | ✅ | ❌ | ✅ | ✅ |
| Dedenting | ✅ | ❌ | ❌ | ❌ | ❌ |
| Language hints | ✅ | ❌ | ❌ | ❌ | ❌ |
| Tables | ✅ | ❌ | ❌ | ✅ | ❌ |
| No indentation rules | ✅ | ✅ | ❌ | ✅ | ✅ |

### Why Not JSON?
- No comments
- No multiline strings
- Verbose syntax with quotes and commas
- Not human-friendly for configuration

### Why Not YAML?
- Complex indentation rules
- Too many features (anchors, aliases, tags)
- Surprising behavior (Norway problem, octal numbers)
- Difficult to parse correctly

### Why Not TOML?
- Limited nesting capabilities
- No language hints for code blocks
- Verbose table syntax
- No dedenting feature

### Why UP?
- **Simpler** than YAML (no indentation traps)
- **More powerful** than JSON (comments, multiline, types)
- **More readable** than TOML (nested blocks)
- **Unique features** (dedenting, language hints)
- **Easy to parse** (line-oriented, unambiguous)

## Language Design Principles

1. **Line-Oriented**: Each statement is on its own line
2. **Explicit Structure**: Delimiters (`{`, `[`, ` ``` `) are clear and unambiguous
3. **Optional Types**: Everything is a string by default, types are annotations
4. **Minimal Syntax**: Few special characters, no complex escaping rules
5. **Predictable**: No surprising behavior or edge cases
6. **Extensible**: Custom type annotations supported
7. **Developer-Friendly**: Designed for configuration files and data exchange

## Syntax Summary

```up
# Comments
# Start with # and go to end of line

# Key-value pairs
key value
key!type value

# Blocks (nested structures)
key {
  nested_key value
}

# Lists
key [
item1
item2
]

# Inline lists
key [item1, item2, item3]

# Multiline strings
key ```
multiline content
preserved whitespace
```

# Multiline with language hint
key!lang ```python
def hello():
    print("world")
```

# Dedenting (removes N leading spaces)
key!4 ```
    indented content
    becomes dedented
```

# Tables
key!table {
  columns [col1, col2, col3]
  rows {
    [val1, val2, val3]
    [val4, val5, val6]
  }
}
```

## Type Annotations

UP supports arbitrary type annotations. **String is the default** - no annotation needed.

Common type annotations:

- **`!int`, `!integer`** - Integer numbers
- **`!float`, `!double`, `!number`** - Floating-point numbers
- **`!bool`, `!boolean`** - Boolean values
- **`!url`, `!uri`** - URLs and URIs
- **`!ts`, `!timestamp`** - Timestamps
- **`!dur`, `!duration`** - Durations
- **`!list`** - Lists
- **`!table`** - Tables
- **Custom types** - Any identifier can be a type

**Note:** String is the default type. Only specify `!string` if you need to explicitly document that something is a string, but it's usually redundant (e.g., `version 1.2.3` is already a string).

Types are metadata for consumers. The parser preserves type information but doesn't validate values.

## Use Cases

UP is ideal for:

- **Application configuration files**
- **Infrastructure as Code** (similar to HCL)
- **CI/CD pipelines** (simpler than YAML)
- **API specifications**
- **Data exchange** (alternative to JSON)
- **Documentation with embedded code**
- **Configuration management**
- **Test fixtures and mock data**

## Tools and Ecosystem

### Command-Line Tools
- `up parse` - Parse UP and output JSON
- `up validate` - Validate UP syntax
- `up format` - Format/prettify UP files

### Editor Support
- Tree-sitter grammar for syntax highlighting
- Language Server Protocol (LSP) implementation (planned)
- VS Code extension (planned)
- Vim/Neovim plugin (planned)

### Integrations
- Convert to/from JSON, YAML, TOML (planned)
- Schema validation (planned)
- Template support (planned)

## Repository Structure

This repository (`spec`) contains the **UP language specification** only:

```
spec/
├── grammar/           # Grammar definitions
│   ├── up.y         # Bison/Yacc grammar
│   ├── up.l         # Flex lexer
│   ├── up.g4        # ANTLR4 grammar
│   ├── up.peg       # PEG grammar
│   ├── grammar.js   # Tree-sitter grammar
│   ├── GRAMMAR.md   # EBNF specification
│   └── LEXER.md     # Lexer specification
├── examples/          # Example UP files
│   ├── *.up         # Feature demonstrations
│   ├── templates/   # Template examples
│   └── README.md    # Example documentation
├── schemas/           # Schema examples
├── *.md               # Documentation files
└── README.md          # This file
```

**Implementation repositories** (parsers and tools):
- **Go**: [`github.com/uplang/go`](https://github.com/uplang/go) - Reference parser + CLI
- **JavaScript**: [`github.com/uplang/js`](https://github.com/uplang/js)
- **Python**: [`github.com/uplang/py`](https://github.com/uplang/py)
- **Rust**: [`github.com/uplang/rust`](https://github.com/uplang/rust)
- **C**: [`github.com/uplang/c`](https://github.com/uplang/c)

**Namespace implementations**:
- **Namespaces**: [`github.com/uplang/ns`](https://github.com/uplang/ns) - Official namespaces

### Testing Examples

```bash
# Install the reference CLI
go install github.com/uplang/go/cmd/up@latest

# Validate all examples
for file in examples/*.up; do
  up validate -i "$file"
done
```

## Contributing

Contributions are welcome! Areas where help is needed:

- [ ] Additional language parsers (Java, C#, Ruby, PHP, etc.)
- [ ] Editor plugins and syntax highlighting
- [ ] Schema validation system
- [ ] LSP implementation
- [ ] Conversion tools (JSON ↔ UP, YAML ↔ UP)
- [ ] Documentation and tutorials
- [ ] Performance benchmarks
- [ ] More examples and use cases

Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## Specification

The formal specification is available in [`grammar/GRAMMAR.md`](grammar/GRAMMAR.md).

Key points:
- Line-oriented parsing
- Context-sensitive for multiline blocks
- Whitespace-significant for line boundaries only
- UTF-8 support
- No reserved keywords

## FAQ

### Is UP production-ready?

UP has a stable reference implementation in Go and parsers in multiple languages. All examples parse correctly and the grammar is well-defined.

### How does UP handle Unicode?

Full UTF-8 support for identifiers, strings, and comments.

### Can I use UP for large files?

Yes, UP parsers are designed to handle files of any size efficiently. The Go implementation uses streaming parsing.

### How do I handle secrets/sensitive data?

Like other configuration formats, UP files can contain sensitive data. Use encryption, environment variable substitution, or secret management tools.

### Can UP replace JSON/YAML/TOML?

UP can be used anywhere these formats are used. It's especially good for configuration files and human-edited documents.

### What about backward compatibility?

The UP specification is stable. Future versions will maintain backward compatibility with existing documents.

## License

MIT License - see [LICENSE](LICENSE) for details.

## Documentation

### Language Specification
- **[SYNTAX-REFERENCE.md](SYNTAX-REFERENCE.md)** - **⭐ Syntax rules and quoting guidelines**
- **[UP-JSON.md](UP-JSON.md)** - UP and JSON relationship, ordering semantics, canonical representation
- **[TEMPLATING.md](TEMPLATING.md)** - Complete templating and composition guide
- **[SCHEMA-VALIDATION.md](SCHEMA-VALIDATION.md)** - Runtime schema validation and type safety
- **[CHANGELOG.md](CHANGELOG.md)** - Version history and changes
- **[CONTRIBUTING.md](CONTRIBUTING.md)** - Contribution guidelines

### Namespaces
All namespace documentation is now in the [ns repository](https://github.com/uplang/ns):
- **[Built-in Namespaces](https://github.com/uplang/ns/blob/main/BUILTIN-NAMESPACES.md)** - All built-in namespaces (time, id, string, etc.)
- **[Dynamic Namespaces](https://github.com/uplang/ns/blob/main/DYNAMIC-NAMESPACES.md)** - Dynamic variables and list generation
- **[Namespace Plugins](https://github.com/uplang/ns/blob/main/NAMESPACE-PLUGINS.md)** - Creating custom namespaces
- **[Namespace Security](https://github.com/uplang/ns/blob/main/NAMESPACE-SECURITY.md)** - Security considerations

## Links

### Specification
- **Specification**: https://github.com/uplang/spec
- **Issues**: https://github.com/uplang/spec/issues
- **Discussions**: https://github.com/uplang/spec/discussions
- **Grammar Specs**: [`grammar/`](grammar/)
- **Examples**: [`examples/`](examples/)

### Implementations
- **Go**: https://github.com/uplang/go
- **JavaScript/TypeScript**: https://github.com/uplang/js
- **Python**: https://github.com/uplang/py
- **Rust**: https://github.com/uplang/rust
- **C**: https://github.com/uplang/c

### Ecosystem
- **Namespaces**: https://github.com/uplang/ns

## Acknowledgments

UP draws inspiration from:
- **JSON** - Simplicity and ubiquity
- **YAML** - Human-friendly syntax
- **TOML** - Type annotations and clarity
- **HCL** - Block structures
- **Markdown** - Code blocks with language hints

---

**UP**: Better than JSON. Simpler than YAML. More powerful than TOML.
