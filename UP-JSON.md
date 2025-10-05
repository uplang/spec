# UP and JSON

Every UP document has a **deterministic, canonical JSON representation**. This document explains the relationship between UP and JSON, including data type mappings, ordering semantics, and bidirectional conversion.

## Core Principle

UP is a **superset of JSON's data model** with better syntax and explicit ordering semantics. Any JSON document can be represented in UP, and any UP document can be converted to JSON.

## Data Type Mappings

| UP | JSON | Notes |
|------|------|-------|
| Scalar values | Strings, numbers, booleans | Direct mapping |
| `key value` | `"key": "value"` | String by default |
| `key!int 42` | `"key": 42` | Type annotations guide JSON types |
| `key!bool true` | `"key": true` | Boolean |
| `key {}` | `"key": {}` | Object (ordered by key) |
| `key!list {}` | `"key": {}` | Object (insertion-order) |
| `key []` | `"key": []` | Array |
| Multiline strings | Strings with `\n` | Whitespace preserved |
| Comments | *omitted* | Comments don't appear in JSON |

## Ordering Semantics

### JSON: Unordered Objects

JSON specification (RFC 8259) states that objects are **unordered collections**:
```json
{
  "port": 8080,
  "host": "localhost",
  "debug": true
}
```

While many implementations preserve insertion order, **it's not guaranteed**. Two JSON documents with the same keys in different order are semantically equivalent.

### UP: Explicit Ordering

UP provides **two types of maps** with explicit ordering semantics:

#### 1. Key-Ordered Maps (Default `{}`)

Default UP blocks are **ordered by key alphabetically** for deterministic output:

```up
server {
  port!int 8080
  host localhost
  debug!bool true
}
```

Converts to JSON with keys sorted:
```json
{
  "server": {
    "debug": true,
    "host": "localhost",
    "port": 8080
  }
}
```

**Benefits:**
- **Deterministic** - Same UP always produces same JSON
- **Diffable** - Easy to compare configurations
- **Mergeable** - Predictable merge behavior
- **Cacheable** - Same content hash for equivalent data

#### 2. Insertion-Ordered Maps (`!list {}`)

For cases where **insertion order matters**, use `!list` annotation:

```up
steps!list {
  checkout git clone ...
  build make build
  test make test
  deploy ./deploy.sh
}
```

Preserves insertion order in JSON:
```json
{
  "steps": {
    "checkout": "git clone ...",
    "build": "make build",
    "test": "make test",
    "deploy": "./deploy.sh"
  }
}
```

**Characteristics:**
- Keys are **unique** (it's still a map)
- Order is **preserved** as written
- Behaves like a **list with named items**
- Useful for: pipelines, ordered steps, sequential configs

**Syntax options:**
```up
# These are equivalent - insertion-ordered maps
pipeline!list {}
pipeline!ordered {}
pipeline!seq {}
```

## Complete Examples

### Example 1: Configuration File

**UP:**
```up
app_name MyService
version 1.2.3

server {
  port!int 8080
  host 0.0.0.0
  timeout!dur 30s
}

database {
  driver postgres
  host db.internal
  pool_size!int 20
}

features {
  new_ui!bool true
  beta_api!bool false
}
```

**JSON (canonical, keys sorted):**
```json
{
  "app_name": "MyService",
  "database": {
    "driver": "postgres",
    "host": "db.internal",
    "pool_size": 20
  },
  "features": {
    "beta_api": false,
    "new_ui": true
  },
  "server": {
    "host": "0.0.0.0",
    "port": 8080,
    "timeout": "30s"
  },
  "version": "1.2.3"
}
```

Note: All values without type annotations are strings by default.

### Example 2: Pipeline with Insertion Order

**UP:**
```up
pipeline!list {
  init {
    command npm install
    timeout!int 300
  }

  lint {
    command npm run lint
    continue_on_error!bool true
  }

  test {
    command npm test
    required!bool true
  }

  build {
    command npm run build
    artifacts [dist, build]
  }

  deploy {
    command ./deploy.sh
    environment production
  }
}
```

**JSON (insertion order preserved):**
```json
{
  "pipeline": {
    "init": {
      "command": "npm install",
      "timeout": 300
    },
    "lint": {
      "command": "npm run lint",
      "continue_on_error": true
    },
    "test": {
      "command": "npm test",
      "required": true
    },
    "build": {
      "artifacts": ["dist", "build"],
      "command": "npm run build"
    },
    "deploy": {
      "command": "./deploy.sh",
      "environment": "production"
    }
  }
}
```

Note: Within each step block (init, lint, etc.), keys are still sorted unless those blocks are also marked `!list`.

### Example 3: Mixed Ordering

**UP:**
```up
# Top level: key-ordered (default)
workflow_name MyWorkflow

# Jobs preserve insertion order
jobs!list {
  setup {
    runs_on ubuntu-latest
    steps!list {
      checkout actions/checkout@v2
      install npm install
    }
  }

  test {
    runs_on ubuntu-latest
    needs [setup]
    steps!list {
      test npm test
      coverage npm run coverage
    }
  }

  deploy {
    runs_on ubuntu-latest
    needs [test]
    steps!list {
      build npm run build
      deploy ./deploy.sh
    }
  }
}

# Config at top level: key-ordered
config {
  timeout_minutes!int 30
  max_parallel!int 3
}
```

## Type Annotations and JSON Types

UP type annotations guide JSON type conversion. **String is the default** - only specify types for non-strings:

```up
# Strings (default - no annotation needed)
name John Doe
host localhost
version 1.2.3

# Numbers (annotation required)
port!int 8080
timeout!float 30.5
cpu!number 2.5

# Booleans (annotation required)
enabled!bool true
debug!boolean false

# Null (annotation required)
value!null null

# Arrays
tags [web, api, production]
ports [8080, 8443, 9090]

# Nested objects
server {
  config {
    timeout!int 30
  }
}
```

**JSON:**
```json
{
  "cpu": 2.5,
  "debug": false,
  "enabled": true,
  "host": "localhost",
  "name": "John Doe",
  "port": 8080,
  "ports": [8080, 8443, 9090],
  "server": {
    "config": {
      "timeout": 30
    }
  },
  "tags": ["web", "api", "production"],
  "timeout": 30.5,
  "value": null
}
```

## Multiline Strings

UP multiline strings convert to JSON strings with newlines:

**UP:**
```up
description ```
This is a multiline
string that preserves
whitespace and newlines
```

code!python ```python
def hello():
    print("world")
```
```

**JSON:**
```json
{
  "code": "def hello():\n    print(\"world\")",
  "description": "This is a multiline\nstring that preserves\nwhitespace and newlines"
}
```

## Tables to JSON

UP tables convert to array of objects:

**UP:**
```up
users!table {
  columns [id, name, email]
  rows {
    [1, Alice, alice@example.com]
    [2, Bob, bob@example.com]
    [3, Carol, carol@example.com]
  }
}
```

**JSON:**
```json
{
  "users": [
    {"id": 1, "name": "Alice", "email": "alice@example.com"},
    {"id": 2, "name": "Bob", "email": "bob@example.com"},
    {"id": 3, "name": "Carol", "email": "carol@example.com"}
  ]
}
```

## Bidirectional Conversion

### JSON to UP

Converting JSON to UP requires choosing ordering strategy:

**Default (key-ordered):**
```bash
up parse input.json -o output.up --order-keys
```

**Preserve insertion order:**
```bash
up parse input.json -o output.up --preserve-order
```

### UP to JSON

UP to JSON is **deterministic**:

```bash
up parse input.up --json --pretty
```

Output is always:
- Keys sorted alphabetically (except `!list` blocks)
- Consistent formatting
- Deterministic hashing

## Canonical Form

UP's canonical form ensures:

1. **Deterministic output** - Same UP → Same JSON always
2. **Stable diffs** - Changes are easy to see
3. **Content addressable** - Hash the JSON for caching
4. **Reproducible builds** - Same config → Same build

**Example:**

These two UP documents are semantically equivalent and produce **identical JSON**:

```up
# Version A
server { port!int 8080, host localhost }
```

```up
# Version B - different formatting, whitespace
server {
  host localhost
  port!int 8080
}
```

Both produce:
```json
{"server": {"host": "localhost", "port": 8080}}
```

## When to Use Which Ordering

| Use Case | Ordering | Syntax |
|----------|----------|--------|
| Configuration files | Key-ordered | `{}` |
| Feature flags | Key-ordered | `{}` |
| Environment variables | Key-ordered | `{}` |
| **Pipelines/workflows** | Insertion-order | `!list {}` |
| **Sequential steps** | Insertion-order | `!list {}` |
| **Ordered operations** | Insertion-order | `!list {}` |
| **Migration scripts** | Insertion-order | `!list {}` |

## Implementation Notes

### Parser Behavior

1. **Default blocks `{}`**: Store as ordered map, output sorted by key
2. **Annotated blocks `!list {}`**: Store as ordered map, output in insertion order
3. **Arrays `[]`**: Always preserve order (standard array behavior)

### Internal Representation

```go
type Block map[string]interface{}      // Key-ordered by default
type OrderedBlock []KeyValue           // Insertion-order for !list
type List []interface{}                // Arrays, always ordered

type KeyValue struct {
    Key   string
    Value interface{}
}
```

### JSON Output

```go
// Key-ordered (default)
func (b Block) MarshalJSON() ([]byte, error) {
    keys := make([]string, 0, len(b))
    for k := range b {
        keys = append(keys, k)
    }
    sort.Strings(keys) // Sort alphabetically
    // ... marshal in order
}

// Insertion-ordered (!list)
func (b OrderedBlock) MarshalJSON() ([]byte, error) {
    // Marshal in the order items appear
    // ... preserve insertion order
}
```

## Compatibility

### JSON Compatibility

- ✅ All valid JSON can be represented in UP
- ✅ All UP can be converted to valid JSON
- ✅ Round-trip: JSON → UP → JSON (with deterministic key ordering)

### Tools

```bash
# Validate UP-JSON round-trip
up parse input.up --json | up parse --format up

# Compare JSON outputs
up parse a.up --json > a.json
up parse b.up --json > b.json
diff a.json b.json

# Generate JSON schema from UP
up schema input.up -o schema.json
```

## Summary

| Feature | JSON | UP Default `{}` | UP `!list {}` |
|---------|------|-------------------|-----------------|
| **Key ordering** | Unspecified | Alphabetical | Insertion order |
| **Deterministic** | No | Yes | Yes |
| **Unique keys** | Yes | Yes | Yes |
| **Use case** | Data exchange | Configs, settings | Pipelines, sequences |
| **Diff-friendly** | Sometimes | Always | Always |
| **Syntax** | `{}` | `{}` | `!list {}` |

**UP provides the clarity JSON lacks: explicit ordering semantics for deterministic, diffable, mergeable configurations.**

### Type Safety

UP achieves type safety with simplicity:

- **String is the default** - No annotation needed for the most common type
- **Explicit for everything else** - Must specify `!int`, `!bool`, etc. for non-strings
- **Parser stays simple** - No ambiguity: `1.2.3` is always a string unless annotated
- **Type-safe by design** - If you want a number, you must say `!int 42`

This approach means:
- ✅ No guessing types from values (is `123` a string or number?)
- ✅ No configuration to change parser behavior
- ✅ Explicit intent: `version 1.2.3` vs `port!int 8080`
- ✅ Parser remains fast and predictable

