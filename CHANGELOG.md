# UP Changelog

## Version 2.0.0 - Templating System (2025-10-05)

### ⚠️ Important: Syntax Clarification

**Multi-word values MUST be quoted in UP.**

UP is whitespace-delimited, so:
- ❌ `name John Doe` → Parses as `name: "John", Doe: (key)`
- ✅ `name "John Doe"` → Parses as `name: "John Doe"`

See **[SYNTAX-REFERENCE.md](SYNTAX-REFERENCE.md)** for complete quoting rules.

**Fixed in this release:**
- ✅ Schema files now use proper quoting
- ✅ Security policy files corrected
- ✅ Lock files validated
- ✅ Core examples reviewed
- ✅ Multiline strings now use dedent (`!N`) to maintain indentation

**Note:** Some documentation examples may still need updating. When in doubt, quote multi-word values.

**Multiline string best practice:**
```up
# BAD - breaks indentation
metadata {
  notes ```
Content not indented
```
}

# GOOD - maintains structure
metadata {
  notes!2 ```
    Content properly indented
    ```
}
```

### 🎉 Major New Feature: Templating

Declarative configuration composition using `!annotation` syntax, consistent with UP's type system.

#### Template Annotations

- `config!base file` - Inherit from base configuration
- `key!overlay { }` - Declarative merge
- `key!include [...]` - Compose from multiple files
- `key!patch { }` - Targeted modifications
- `key!merge { }` - Configure merge strategies
- `$vars.path` - Variable references

#### New CLI Commands

```bash
up template process -i template.up -o output.up
up template validate -i template.up
```

#### Key Design

- Uses `!annotation` syntax (consistent with `port!int 8080`)
- No special `_` prefixes or reserved keys
- Type-safe variables, no string substitution
- Declarative composition, no template logic

#### Multi-Document Support

- **Comment-based separators** - Use `# ---` or any comment as document separator
- **Parser-agnostic** - Separators are just comments, no parser changes needed
- **Easy concatenation** - Combine files with simple comment separators
- **Semantic analysis ready** - Tooling can warn about ordering issues (overlay before base, undefined refs)
- **Testing-friendly** - Keep related configs together for easier testing

Example:
```up
# base config
vars { port!int 8080 }

# ---

# dev config
server!overlay { debug!bool true }

# ---

# prod config
server!overlay { replicas!int 10 }
```

#### Iterative Variable Resolution

- **Order-independent** - Variables can reference other variables regardless of declaration order
- **Deep nesting** - Variables can build on variables that build on variables
- **String interpolation** - Multiple `$vars.` references in a single string
- **Convergence detection** - Automatically resolves until all variables are replaced
- **Circular dependency detection** - Errors if resolution doesn't converge (likely circular reference)

Example:
```up
vars {
  region us-west-2
  environment production
  host $vars.environment.$vars.region.example.com
  url https://$vars.host:443/api
  health $vars.url/health
}
# All variables resolve correctly regardless of order
```

#### UP-JSON Relationship

New **UP-JSON.md** document explains:
- **Deterministic JSON output** - Every UP document has canonical JSON representation
- **Ordering semantics** - Default `{}` blocks are key-ordered (alphabetical)
- **Insertion-order maps** - Use `!list {}` for insertion-order preservation
- **Type mappings** - How UP types convert to JSON types
- **Bidirectional conversion** - JSON ↔ UP with explicit ordering

Key innovation: **Two types of maps**
- `key {}` - Key-ordered map (default, deterministic, sorted alphabetically)
- `key!list {}` - Insertion-ordered map (preserves declaration order)

#### Dynamic Variable Namespaces (Design)

New **DYNAMIC-NAMESPACES.md** specification for dynamic content generation:

**Pragma-based opt-in:**
```up
!use [time, id, faker, random]
```

**Reserved namespaces:**
- `time` - Timestamps and time operations (`$time.now`, `$time.add(24h)`)
- `date` - Calendar dates (`$date.today`, `$date.add(-7d)`)
- `id` - ID generation (`$id.uuid`, `$id.short`, `$id.ulid`)
- `random` - Random data (`$random.int(1, 100)`, `$random.string(32)`)
- `faker` - Realistic fake data ([go-faker](https://github.com/go-faker/faker) inspired)
  - Personal: `$faker.name`, `$faker.email`, `$faker.phone`
  - Address: `$faker.street`, `$faker.city`, `$faker.zipcode`
  - Internet: `$faker.domain`, `$faker.ipv4`, `$faker.username`
  - Business: `$faker.company`, `$faker.job_title`
- `env` - Environment variables (`$env.HOME`, `$env.PORT(8080)`)
- `file` - File operations (`$file.read(config.json)`)

**Use cases:**
- Testing - Generate realistic test data
- Mocking - Create mock API responses
- Load testing - Generate varied test scenarios
- Seed data - Populate development databases

**Design principles:**
- ✅ Opt-in via pragmas - Static UP stays simple
- ✅ Explicit namespaces - Clear what's available
- ✅ Clean syntax - `$namespace.function(params)`
- ✅ Deterministic when seeded - Reproducible tests
- ✅ Safe by default - Dangerous namespaces require explicit opt-in

#### Pluggable Namespace System (Design)

New **NAMESPACE-PLUGINS.md** specification for extensible namespaces:

**Any executable can be a namespace:**
```bash
#!/bin/bash
# ./up-namespaces/greeting

INPUT=$(cat)
FUNCTION=$(echo "$INPUT" | jq -r '.function')
NAME=$(echo "$INPUT" | jq -r '.params.positional[0] // "World"')

case "$FUNCTION" in
  hello)
    echo "{\"value\": \"Hello, $NAME!\", \"type\": \"string\"}"
    ;;
esac
```

**UP schemas describe namespaces:**
```up
# greeting.up-schema
namespace greeting
version 1.0.0

functions {
  hello {
    description Generate a hello greeting
    params {
      name!string {
        default World
        required!bool false
      }
    }
    returns!string {
      example Hello, Alice!
    }
  }
}
```

**Plugin protocol:**
- JSON input via stdin with function name and params
- JSON output via stdout with value and type
- Located in `./up-namespaces/`, `~/.up/namespaces/`, or `/usr/local/up/namespaces/`

**Benefits:**
- 🚀 Extend UP without modifying core
- 📚 Self-documenting with UP schemas
- 🌍 Language-agnostic (bash, python, go, rust, etc.)
- 🔒 Sandboxable and secure
- 🎯 Simple shell scripts to complex services

**UP schemas are UP** - schemas all the way down!

#### Namespace Security & Versioning (Design)

New **NAMESPACE-SECURITY.md** specification for secure, reproducible namespaces:

**Version pinning:**
```up
# Exact version
!use [greeting@1.2.3]

# Version range
!use [greeting>=1.0.0,<2.0.0]

# Compatible versions
!use [greeting^1.2.0]
```

**Lock file (up-namespaces.lock):**
```up
namespaces {
  greeting {
    version 1.2.3
    files {
      executable {
        hash sha256:a3b5c9d1e2f4567890abcdef...
      }
    }
    verified!bool true
  }
}
```

**Security features:**
- ✅ SHA-256 hash verification for integrity
- ✅ Ed25519/RSA cryptographic signatures for authenticity
- ✅ Version compatibility checking
- ✅ Trusted signer management
- ✅ Security policy files (`.up-security`)
- ✅ Audit logging for security events
- ✅ Registry integration with verification

**Security policy:**
```up
policy {
  verify_hashes!bool true
  require_signatures!bool true
  fail_on_hash_mismatch!bool true
}

namespace_policies {
  dangerous {
    namespaces [file, env, exec]
    require_explicit_approval!bool true
    require_signature!bool true
  }
}
```

**Benefits:**
- 🔒 Cryptographic verification prevents tampering
- 📌 Lock files ensure reproducibility
- 🛡️ Signatures verify authenticity
- 🔍 Audit logs track security events
- ⚙️ Flexible policies for different environments

#### Runtime Schema Validation (Design)

New **SCHEMA-VALIDATION.md** specification for type-safe validation:

**Types reference schemas:**
```up
# File-based schema
server!file://./schemas/server.up-schema {
  host localhost
  port!int 8080
}

# URL-based schema
config!https://schemas.uplang.org/config/1.0.0 {
  environment production
}

# Type mapping (via .up-schemas)
user!user {
  name "Alice"
  email alice@example.com
}
```

**Schemas written in UP:**
```up
schema server
version 1.0.0

fields {
  host!string {
    required!bool true
    pattern ^[a-zA-Z0-9.-]+$
  }

  port!int {
    required!bool true
    min 1
    max 65535
  }
}

validation {
  rules [
    {
      condition "port == 443"
      requires "tls_enabled == true"
      error "Port 443 requires TLS"
    }
  ]
}
```

**CLI integration:**
```bash
# Parse with validation (default)
up parse -i config.up

# Skip validation
up parse -i config.up --no-validate

# Strict mode
up validate -i config.up --strict
```

**Features:**
- ✅ Schemas as types
- ✅ Field constraints (min, max, pattern, required)
- ✅ Conditional validation rules
- ✅ Remote schema registry
- ✅ Schema caching
- ✅ CLI control

**Benefits:**
- 🔒 Type-safe configuration
- ✅ Validated at parse time
- 📝 Self-documenting
- 🌍 Shareable schemas
- 🚀 Central registry

#### Namespace Aliases

Support for aliasing namespaces to use multiple versions or implementations simultaneously.

**Syntax:**
```up
!use [namespace as alias]
!use [namespace@version as alias]
!use [url as alias]
```

**Examples:**
```up
# Multiple versions for migration
!use [time, time@1.0.0 as oldtime, time@2.0.0 as newtime]

current $time.now
legacy $oldtime.now
enhanced $newtime.now
```

```up
# Different implementations
!use [
  github.com/uplang/ns-random as random,
  github.com/myorg/secure-random as securerandom
]

session_id $random.uuid
api_key $securerandom.bytes(size=32)
```

**Use Cases:**
- Multiple versions for gradual migration
- Different implementations side-by-side
- Avoiding naming conflicts with custom namespaces
- Compatibility testing across versions

**Documentation:**
- [DYNAMIC-NAMESPACES.md](DYNAMIC-NAMESPACES.md#namespace-aliases)
- [NAMESPACE-SECURITY.md](NAMESPACE-SECURITY.md#version-pinning-with-aliases)
- Example: [namespace-aliases-example.up](examples/namespace-aliases-example.up)

### 📦 Project Reorganization

- Moved Go parser from `internal/` to `parsers/go/` for consistency
- All language parsers now in `parsers/` directory
- Added `template.go` for templating engine

### 📚 Documentation

- **TEMPLATING.md** - Complete templating guide
- **README.md** - Updated with templating section
- **parsers/go/README.md** - Updated for new location

### 📁 New Example Templates

Created comprehensive templating examples:

**Base & Environments:**
- `examples/templates/base.up` - Common configuration
- `examples/templates/development.up` - Dev environment
- `examples/templates/staging.up` - Staging environment
- `examples/templates/production.up` - Production environment

**Feature Modules:**
- `examples/templates/features/enable-beta.up` - Beta features
- `examples/templates/features/high-availability.up` - HA configuration
- `examples/templates/features/enhanced-logging.up` - Advanced logging

**Composed Configurations:**
- `examples/templates/composed/production-beta.up` - Prod + beta
- `examples/templates/composed/production-ha.up` - Prod + HA + logging

All templates successfully validated! ✅

### 🔧 Implementation

- Type annotation-based directive detection
- Circular dependency detection
- Deep/shallow merge strategies
- List merge (append/replace/unique)
- Variable resolution (`$vars.path`)
- Path-based patching

### 🎯 Use Cases

UP templating is perfect for:

1. **Multi-environment configuration** - Base + environment-specific overlays
2. **Feature flag composition** - Mix and match features
3. **Infrastructure as Code** - Kubernetes configs, Terraform variables
4. **Configuration management** - Ansible, Chef, Puppet alternatives
5. **CI/CD pipelines** - GitLab CI, GitHub Actions, Jenkins

### 📊 Comparison with Other Systems

| Feature | UP | Helm | Kustomize | Jsonnet |
|---------|------|------|-----------|---------|
| Syntax | Native UP | Go Templates | YAML | Jsonnet DSL |
| Type Safety | ✅ | ❌ | ⚠️ | ✅ |
| Learning Curve | Low | High | Medium | High |
| Logic in Templates | ❌ | ✅ | ❌ | ✅ |
| Declarative | ✅ | ❌ | ✅ | ⚠️ |
| Multi-Language | ✅ | ❌ | ❌ | ❌ |

### 🚀 Breaking Changes

Go module paths changed:
- Old: `github.com/uplang/spec/internal/parser`
- New: `github.com/uplang/spec/parsers/go/src`

### 🔮 Future Plans

#### Next Release (v2.1.0)
- [ ] JavaScript/TypeScript templating support
- [ ] Python templating support
- [ ] Rust templating support
- [ ] Schema validation for templates
- [ ] Template testing framework

#### Future Releases
- [ ] Remote file includes (URLs)
- [ ] Matrix generation for config combinations
- [ ] Template composition graph visualization
- [ ] LSP integration with template support
- [ ] IDE plugins with template completion

---

## Version 1.0.0 - Initial Release

### Features

- Core UP parser
- Type annotations
- Blocks and lists
- Multiline strings with language hints
- Dedenting feature
- Comments
- Tables
- Parsers for Go, JavaScript, Python, Rust, C
- Grammar definitions (Bison, ANTLR4, PEG, Tree-sitter)
- Comprehensive examples
- Complete documentation

