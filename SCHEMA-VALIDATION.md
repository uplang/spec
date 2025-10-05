# UP Schema Validation

UP supports runtime schema validation where any key can declare adherence to a schema. Schemas are defined using UP syntax and can be referenced via URLs or file paths.

## Core Concept

**Schemas are types. Types reference schemas.**

```up
# Declare that this block must conform to a schema
server!https://schemas.uplang.org/server/1.0.0 {
  host localhost
  port!int 8080
}

# Or use a local file
config!file://./schemas/config.up-schema {
  environment production
}

# Or reference a type that maps to a schema
user!user {
  name "Alice"
  email alice@example.com
}
```

## Schema Specification Syntax

### URL Schemas

```up
# HTTPS URL
config!https://schemas.uplang.org/config/1.0.0 {
  # Must conform to remote schema
}

# HTTP URL (less secure, warning issued)
data!http://internal.company.com/schemas/data.up {
  # ...
}
```

### File Schemas

```up
# Relative path
server!file://./schemas/server.up-schema {
  # Must conform to local schema
}

# Absolute path
config!file:///etc/up/schemas/config.up-schema {
  # ...
}

# Project-relative (resolved from project root)
database!file://schemas/database.up-schema {
  # ...
}
```

### Type Mapping

**Define schema mappings in `.up-schemas` file:**

```up
# .up-schemas - Schema registry for this project

schemas {
  # Map type names to schema locations
  user https://schemas.uplang.org/user/1.0.0
  server file://./schemas/server.up-schema
  database file://./schemas/database.up-schema

  # With version pinning
  config!v1 https://schemas.uplang.org/config/1.0.0
  config!v2 https://schemas.uplang.org/config/2.0.0
}

# Default schema versions
defaults {
  config v1
}

# Cache configuration
cache {
  enabled!bool true
  directory ~/.up/schema-cache
  ttl!dur 24h
}
```

**Then use short type names:**

```up
# Resolves to https://schemas.uplang.org/user/1.0.0
user!user {
  name "Alice"
  email alice@example.com
}

# Resolves to file://./schemas/server.up-schema
server!server {
  host localhost
  port!int 8080
}
```

## Schema Format

Schemas are written in UP syntax:

**File: `server.up-schema`**

```up
# UP Schema Definition
schema server

version 1.0.0
description "Server configuration schema"

# Define required and optional fields
fields {
  host!string {
    required!bool true
    description "Server hostname"
    pattern ^[a-zA-Z0-9.-]+$
    examples [localhost, example.com, 127.0.0.1]
  }

  port!int {
    required!bool true
    description "Server port"
    min 1
    max 65535
    examples [8080, 443, 3000]
  }

  timeout!dur {
    required!bool false
    description "Connection timeout"
    default 30s
    min 1s
    max 5m
  }

  tls_enabled!bool {
    required!bool false
    description "Enable TLS"
    default false
  }

  replicas!int {
    required!bool false
    description "Number of replicas"
    min 1
    max 100
    default 1
  }
}

# Additional validation rules
validation {
  # Custom validation rules
  rules [
    {
      name "port_443_requires_tls"
      condition "port == 443"
      requires "tls_enabled == true"
      error "Port 443 requires TLS to be enabled"
    }
    {
      name "high_port_requires_replicas"
      condition "port > 9000"
      requires "replicas >= 3"
      warning "High ports should have multiple replicas"
    }
  ]
}

metadata {
  author "UP Team"
  url https://schemas.uplang.org/server/1.0.0
  license MIT
}
```

## Validation Rules

### Field Validation

**String fields:**
```up
field!string {
  required!bool true
  min_length 1
  max_length 100
  pattern ^[a-z]+$
  enum [dev, staging, prod]
  examples [prod]
}
```

**Numeric fields:**
```up
field!int {
  required!bool true
  min 0
  max 100
  multiple_of 10
  examples [10, 20, 30]
}

field!float {
  required!bool false
  min 0.0
  max 1.0
  exclusive_min!bool false
  exclusive_max!bool true
}
```

**Boolean fields:**
```up
field!bool {
  required!bool true
  default false
}
```

**Complex types:**
```up
field!list {
  required!bool true
  min_items 1
  max_items 10
  unique!bool true
  item_type string
}

field!block {
  required!bool true
  schema embedded_schema  # Reference to another schema
}
```

### Nested Schemas

```up
# server.up-schema
schema server

fields {
  host!string {
    required!bool true
  }

  database!database {
    required!bool true
    # References database.up-schema
  }
}
```

### Conditional Validation

```up
validation {
  # If TLS is enabled, certificate paths are required
  conditional [
    {
      if "tls_enabled == true"
      then_required [tls_cert_path, tls_key_path]
    }
    {
      if "environment == production"
      then_required [backup_enabled, monitoring_enabled]
    }
  ]
}
```

## Validation Process

### 1. Schema Resolution

```
Key with schema: server!https://schemas.uplang.org/server/1.0.0

1. Check if schema is in cache
2. If not, download from URL
3. Verify schema signature (if configured)
4. Parse schema
5. Cache schema
6. Return schema definition
```

### 2. Value Validation

```
For each field in value:

1. Check if field is defined in schema
2. If strict mode: reject undefined fields
3. Check required fields are present
4. Validate field types
5. Validate field constraints (min, max, pattern, etc.)
6. Run custom validation rules
7. Collect errors and warnings
```

### 3. Error Reporting

```
Validation failed for server:
  ✗ Missing required field: host
  ✗ Field 'port' value 99999 exceeds maximum 65535
  ⚠ Field 'timeout' not defined in schema (strict mode)
  ✗ Validation rule failed: port_443_requires_tls
    Port 443 requires TLS to be enabled
```

## CLI Integration

### Validation Commands

```bash
# Parse with validation (default)
up parse -i config.up

# Parse without validation
up parse -i config.up --no-validate

# Explicit validation
up validate -i config.up

# Validate with strict mode (reject undefined fields)
up validate -i config.up --strict

# Validate and show warnings
up validate -i config.up --warnings

# Dry-run validation (don't cache schemas)
up validate -i config.up --dry-run
```

### Schema Management

```bash
# List available schemas
up schema list

# Show schema details
up schema show server

# Download and cache schema
up schema fetch https://schemas.uplang.org/server/1.0.0

# Clear schema cache
up schema cache clear

# Validate schema itself
up schema validate ./schemas/server.up-schema

# Generate schema from example
up schema generate -i example.up -o schema.up-schema
```

## Configuration

**File: `.up-config`**

```up
# UP Parser Configuration

validation {
  enabled!bool true
  strict!bool false
  fail_on_warning!bool false

  # Schema resolution
  allow_http!bool false
  allow_file!bool true
  allow_remote!bool true

  # Timeout for remote schemas
  timeout!dur 10s

  # Retry configuration
  retries!int 3
  retry_delay!dur 1s
}

schemas {
  # Schema cache
  cache_enabled!bool true
  cache_dir ~/.up/schema-cache
  cache_ttl!dur 24h

  # Schema verification
  verify_signatures!bool false
  trusted_sources [
    https://schemas.uplang.org
    https://github.com/up-lang/schemas
  ]
}

# Security
security {
  # Only allow schemas from trusted sources
  restrict_sources!bool false
  trusted_sources [
    https://schemas.uplang.org
  ]

  # Require HTTPS for remote schemas
  require_https!bool true
}
```

## Examples

### Example 1: Server Configuration

**Schema: `server.up-schema`**

```up
schema server
version 1.0.0

fields {
  host!string {
    required!bool true
  }

  port!int {
    required!bool true
    min 1
    max 65535
  }

  tls_enabled!bool {
    required!bool false
    default false
  }
}
```

**Usage:**

```up
# Valid
server!file://./schemas/server.up-schema {
  host localhost
  port!int 8080
  tls_enabled!bool false
}

# Invalid - will fail validation
server!file://./schemas/server.up-schema {
  host localhost
  # Missing required field: port
}
```

### Example 2: User Profile

**Schema: `user.up-schema`**

```up
schema user
version 1.0.0

fields {
  name!string {
    required!bool true
    min_length 1
    max_length 100
  }

  email!string {
    required!bool true
    pattern ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$
  }

  age!int {
    required!bool false
    min 0
    max 150
  }

  roles!list {
    required!bool false
    item_type string
    enum_items [admin, user, guest]
    unique!bool true
  }
}
```

**Usage:**

```up
users [
  user!https://schemas.uplang.org/user/1.0.0 {
    name "Alice Johnson"
    email alice@example.com
    age!int 30
    roles [admin, user]
  }
  user!https://schemas.uplang.org/user/1.0.0 {
    name "Bob Smith"
    email bob@example.com
    # age optional
    roles [user]
  }
]
```

### Example 3: Conditional Validation

**Schema: `deployment.up-schema`**

```up
schema deployment
version 1.0.0

fields {
  environment!string {
    required!bool true
    enum [dev, staging, prod]
  }

  replicas!int {
    required!bool true
    min 1
  }

  backup_enabled!bool {
    required!bool false
  }

  monitoring_enabled!bool {
    required!bool false
  }
}

validation {
  conditional [
    {
      if "environment == prod"
      then_required [backup_enabled, monitoring_enabled]
      error "Production deployments must have backup and monitoring"
    }
    {
      if "environment == prod"
      then "replicas >= 3"
      error "Production requires at least 3 replicas"
    }
  ]
}
```

**Usage:**

```up
# Valid production deployment
deployment!file://./schemas/deployment.up-schema {
  environment prod
  replicas!int 5
  backup_enabled!bool true
  monitoring_enabled!bool true
}

# Invalid - fails conditional validation
deployment!file://./schemas/deployment.up-schema {
  environment prod
  replicas!int 1  # Too few
  # Missing backup_enabled and monitoring_enabled
}
```

## Schema Registry

UP provides a central registry for common schemas:

**Registry structure:**
```
https://schemas.uplang.org/
├── server/
│   ├── 1.0.0/schema.up
│   ├── 1.1.0/schema.up
│   └── 2.0.0/schema.up
├── database/
│   └── 1.0.0/schema.up
├── user/
│   └── 1.0.0/schema.up
└── namespace/
    └── 1.0.0/schema.up
```

**Registry manifest:**
```up
# https://schemas.uplang.org/manifest.up

registry up_official

schemas {
  server {
    versions [1.0.0, 1.1.0, 2.0.0]
    latest 2.0.0
    stable 1.1.0
  }

  database {
    versions [1.0.0]
    latest 1.0.0
  }

  user {
    versions [1.0.0]
    latest 1.0.0
  }
}

metadata {
  url https://schemas.uplang.org
  maintainer "UP Team"
  license MIT
}
```

## Type System Integration

### Schema as Type

```up
# Schema defines a type
schema user
version 1.0.0

fields {
  name!string { required!bool true }
  email!string { required!bool true }
}
```

### Using Schema Type

```up
# Reference schema by URL
alice!https://schemas.uplang.org/user/1.0.0 {
  name "Alice"
  email alice@example.com
}

# Or by registered type name (from .up-schemas)
bob!user {
  name "Bob"
  email bob@example.com
}
```

### Generic Schemas

```up
# Schema with generics
schema list<T>
version 1.0.0

fields {
  items!list {
    required!bool true
    item_type $T
  }
}

# Usage
numbers!list<int> {
  items [1, 2, 3]
}

names!list<string> {
  items ["Alice", "Bob"]
}
```

## Validation API

For programmatic use:

```go
// Go API
import "github.com/uplang/spec/parsers/go/src"

// Parse with validation
doc, err := up.ParseFile("config.up", up.WithValidation(true))

// Validate against schema
schema, err := up.LoadSchema("https://schemas.uplang.org/server/1.0.0")
errors := schema.Validate(doc)

// Custom validation
validator := up.NewValidator()
validator.AddRule("port_check", func(value interface{}) error {
    // Custom validation logic
})
```

```javascript
// JavaScript API
const up = require('@up-lang/parser');

// Parse with validation
const doc = await up.parseFile('config.up', {validate: true});

// Validate against schema
const schema = await up.loadSchema('https://schemas.uplang.org/server/1.0.0');
const errors = schema.validate(doc);
```

```python
# Python API
import up

# Parse with validation
doc = up.parse_file('config.up', validate=True)

# Validate against schema
schema = up.load_schema('https://schemas.uplang.org/server/1.0.0')
errors = schema.validate(doc)
```

## Security Considerations

### Schema Verification

1. **HTTPS only** (default) - Require HTTPS for remote schemas
2. **Signature verification** - Verify schema signatures
3. **Trusted sources** - Whitelist allowed schema sources
4. **Cache validation** - Verify cached schemas haven't been tampered with

### Safety Rules

```up
# .up-security
schema_validation {
  # Only allow schemas from trusted sources
  restrict_sources!bool true
  trusted_sources [
    https://schemas.uplang.org
    https://internal.company.com/schemas
  ]

  # Require HTTPS
  require_https!bool true

  # Verify schema signatures
  verify_signatures!bool true

  # Fail on validation errors
  fail_on_error!bool true

  # Cache security
  verify_cache!bool true
  cache_ttl!dur 24h
}
```

## Summary

**Schema Validation:**
- ✅ Schemas written in UP syntax
- ✅ Reference via URL or file path
- ✅ Types map to schemas
- ✅ Runtime validation
- ✅ CLI control (--no-validate flag)

**Schema Features:**
- ✅ Field requirements and constraints
- ✅ Type validation
- ✅ Pattern matching (regex)
- ✅ Conditional validation
- ✅ Custom rules
- ✅ Nested schemas

**Benefits:**
- 🔒 Type-safe configuration
- 📝 Self-documenting
- ✅ Validated at parse time
- 🌍 Shareable schemas
- 🚀 Central registry

**UP is now self-validating - schemas ensure correctness!**

