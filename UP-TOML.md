# UP and TOML

UP and TOML share a common goal: **human-friendly configuration files**. Both avoid the noise of brackets and quotes where possible. However, UP takes readability further with more natural syntax, consistent rules, and better comprehension of complex nested structures.

## Core Principle

UP is designed to be **immediately understandable** with minimal syntax overhead. While TOML prioritizes "obvious meaning," it introduces complexity with table headers, dotted keys, and array-of-tables syntax that can obscure the actual data structure.

## Syntax Comparison

### Simple Key-Value Pairs

Both formats excel at simple configurations:

**TOML:**
```toml
app_name = "MyService"
version = "1.2.3"
port = 8080
debug = true
```

**UP:**
```up
app_name MyService
version 1.2.3
port!int 8080
debug!bool true
```

**Readability advantage:** UP eliminates the `=` and quotes for strings, making it look like natural writing. The type annotations (`!int`, `!bool`) are explicit when needed, but strings—the most common type—need no annotation.

### Nested Structures

This is where the differences become dramatic:

**TOML:**
```toml
[server]
port = 8080
host = "0.0.0.0"
timeout = "30s"

[database]
driver = "postgres"
host = "db.internal"
pool_size = 20

[database.retry]
max_attempts = 3
backoff = "exponential"
```

**UP:**
```up
server {
  port!int 8080
  host 0.0.0.0
  timeout 30s
}

database {
  driver postgres
  host db.internal
  pool_size!int 20
  retry {
    max_attempts!int 3
    backoff exponential
  }
}
```

**Comprehension advantage:**
- UP uses **visual nesting** with braces, making the hierarchy immediately visible
- TOML's `[section]` headers require mental mapping to reconstruct the tree
- In UP, you can see parent-child relationships at a glance
- TOML's `[database.retry]` requires understanding the dotted-key notation to know it's nested under `database`

### Deeply Nested Configuration

**TOML:**
```toml
[service.api.authentication.oauth]
client_id = "abc123"
client_secret = "xyz789"

[service.api.authentication.jwt]
secret = "secret-key"
expiry = 3600

[service.api.rate_limiting]
enabled = true
requests_per_minute = 100
```

**UP:**
```up
service {
  api {
    authentication {
      oauth {
        client_id abc123
        client_secret xyz789
      }
      jwt {
        secret secret-key
        expiry!int 3600
      }
    }
    rate_limiting {
      enabled!bool true
      requests_per_minute!int 100
    }
  }
}
```

**Comprehension advantage:**
- UP shows the **complete structure visually** through indentation
- TOML forces you to parse `[service.api.authentication.oauth]` into a mental tree
- UP's structure matches how you think about hierarchy
- With TOML, moving sections around requires updating all the header paths

### Lists and Arrays

**TOML:**
```toml
tags = ["web", "api", "production"]
ports = [8080, 8443, 9090]

# Array of tables - confusing syntax
[[servers]]
name = "alpha"
ip = "10.0.0.1"

[[servers]]
name = "beta"
ip = "10.0.0.2"
```

**UP:**
```up
tags [web, api, production]
ports [8080, 8443, 9090]

# Clear, consistent syntax
servers [
  {
    name alpha
    ip 10.0.0.1
  }
  {
    name beta
    ip 10.0.0.2
  }
]
```

**Readability advantage:**
- UP uses `[]` for arrays consistently
- TOML's `[[array_of_tables]]` syntax is a special case you must learn
- UP's nested object syntax is the same everywhere
- The double-bracket notation in TOML confuses many users

### Tabular Data

For data that's naturally tabular, UP's table syntax is even cleaner:

**TOML:**
```toml
[[users]]
id = 1
name = "Alice"
email = "alice@example.com"
role = "admin"

[[users]]
id = 2
name = "Bob"
email = "bob@example.com"
role = "developer"

[[users]]
id = 3
name = "Carol"
email = "carol@example.com"
role = "designer"
```

**UP (array of objects):**
```up
users [
  { id!int 1, name Alice, email alice@example.com, role admin }
  { id!int 2, name Bob, email bob@example.com, role developer }
  { id!int 3, name Carol, email carol@example.com, role designer }
]
```

**UP (table syntax):**
```up
users!table {
  columns [id, name, email, role]
  rows [
    [1, Alice, alice@example.com, admin]
    [2, Bob, bob@example.com, developer]
    [3, Carol, carol@example.com, designer]
  ]
}
```

**Comprehension advantage:**
- TOML repeats `[[users]]` and all keys for every row
- UP's table syntax eliminates repetition
- Column names appear once at the top
- Data reads like a spreadsheet or CSV
- Much more compact and scannable
- The structure (columns) is separate from the data (rows)

**Another example - configuration matrix:**

**TOML:**
```toml
[[environments]]
name = "development"
host = "dev.example.com"
port = 8080
ssl = false

[[environments]]
name = "staging"
host = "staging.example.com"
port = 8080
ssl = true

[[environments]]
name = "production"
host = "prod.example.com"
port = 443
ssl = true
```

**UP table:**
```up
environments!table {
  columns [name, host, port, ssl]
  rows [
    [development, dev.example.com, 8080, false]
    [staging, staging.example.com, 8080, true]
    [production, prod.example.com, 443, true]
  ]
}
```

The table syntax makes it **immediately obvious** you're looking at structured, repeating data. The TOML version obscures the pattern with repetitive markup.

### Mixed Data Structures

**TOML:**
```toml
[deployment]
strategy = "rolling"
max_surge = 2

[[deployment.steps]]
action = "stop_traffic"
wait = 10

[[deployment.steps]]
action = "update_instances"
batch_size = 5

[[deployment.steps]]
action = "health_check"
timeout = 60

[deployment.rollback]
enabled = true
threshold = 0.95
```

**UP:**
```up
deployment {
  strategy rolling
  max_surge!int 2
  steps [
    {
      action stop_traffic
      wait!int 10
    }
    {
      action update_instances
      batch_size!int 5
    }
    {
      action health_check
      timeout!int 60
    }
  ]
  rollback {
    enabled!bool true
    threshold!float 0.95
  }
}
```

**Comprehension advantage:**
- The structure is **immediately obvious** in UP
- TOML mixes table headers and array-of-tables notation
- UP uses consistent block and array syntax throughout
- Scanning the UP version reveals the data shape instantly

## Multiline Strings

**TOML:**
```toml
description = """
This is a multiline string.
It preserves newlines.
But you need triple quotes."""

# Literal strings
regex = '''I [dw]on't need \d{2} escapes'''
```

**UP:**
```up
description ```
This is a multiline string.
It preserves newlines.
Clean and simple.
```

regex ```
I [dw]on't need \d{2} escapes
```
```

**Readability advantage:**
- UP uses consistent triple-backtick syntax (familiar from Markdown)
- TOML has both `"""` and `'''` with different escaping rules
- UP treats all multiline strings the same way
- Optional language hints in UP: `` ```python `` for syntax highlighting

## Inline vs. Block Syntax

UP offers flexibility without sacrificing clarity:

**UP (inline):**
```up
server { host localhost, port!int 8080 }
```

**UP (block):**
```up
server {
  host localhost
  port!int 8080
}
```

**TOML requires:**
```toml
[server]
host = "localhost"
port = 8080
```

TOML has inline tables but they're limited and can't be extended:
```toml
server = { host = "localhost", port = 8080 }
```

## Comments

Both support comments well:

**TOML:**
```toml
# This is a comment
port = 8080 # inline comment
```

**UP:**
```up
# This is a comment
port!int 8080 # inline comment
```

Comments are equally readable in both formats.

## Real-World Example

### Application Configuration

**TOML:**
```toml
app_name = "MyApp"
version = "2.1.0"
environment = "production"

[server]
port = 8080
host = "0.0.0.0"
read_timeout = 30
write_timeout = 30

[database]
driver = "postgres"
host = "db.example.com"
port = 5432
database = "myapp"
username = "admin"

[database.pool]
min_connections = 5
max_connections = 20
connection_timeout = 10

[database.retry]
enabled = true
max_attempts = 3
backoff = "exponential"

[logging]
level = "info"
format = "json"

[[logging.outputs]]
type = "file"
path = "/var/log/app.log"

[[logging.outputs]]
type = "syslog"
host = "log.example.com"
port = 514

[features]
new_ui = true
beta_api = false
analytics = true

[[features.experiments]]
name = "new_checkout"
enabled = true
percentage = 50

[[features.experiments]]
name = "improved_search"
enabled = true
percentage = 100
```

**UP:**
```up
app_name MyApp
version 2.1.0
environment production

server {
  port!int 8080
  host 0.0.0.0
  read_timeout!int 30
  write_timeout!int 30
}

database {
  driver postgres
  host db.example.com
  port!int 5432
  database myapp
  username admin
  pool {
    min_connections!int 5
    max_connections!int 20
    connection_timeout!int 10
  }
  retry {
    enabled!bool true
    max_attempts!int 3
    backoff exponential
  }
}

logging {
  level info
  format json
  outputs [
    {
      type file
      path /var/log/app.log
    }
    {
      type syslog
      host log.example.com
      port!int 514
    }
  ]
}

features {
  new_ui!bool true
  beta_api!bool false
  analytics!bool true
  experiments [
    {
      name new_checkout
      enabled!bool true
      percentage!int 50
    }
    {
      name improved_search
      enabled!bool true
      percentage!int 100
    }
  ]
}
```

### What Makes UP More Comprehensible?

1. **Visual hierarchy**: Indentation and braces show structure immediately
2. **Consistent syntax**: Same block/array patterns throughout
3. **No mental mapping**: Don't need to reconstruct `[database.pool]` as nested structure
4. **Table syntax**: Repeating data is compact and spreadsheet-like
5. **Scannable**: Eye can follow the tree structure naturally
6. **Natural writing**: Minimal punctuation, reads like prose

### Where TOML Struggles

1. **Table headers break flow**: `[section]` markers scatter throughout the file
2. **Path reconstruction**: `[a.b.c]` requires mental parsing
3. **Array-of-tables**: `[[array]]` is a special syntax case that repeats keys
4. **Tabular data**: Every row repeats all column names (verbose)
5. **Non-local definition**: Related settings separated by headers
6. **Order matters**: Table headers must appear in correct order

## Type System

**TOML:**
```toml
# Types inferred from syntax
string = "hello"
integer = 42
float = 3.14
boolean = true
datetime = 1979-05-27T07:32:00Z
array = [1, 2, 3]
```

**UP:**
```up
# Strings are default (most common case)
string hello

# Explicit types for everything else
integer!int 42
float!float 3.14
boolean!bool true
datetime!time 1979-05-27T07:32:00Z
array [1, 2, 3]
```

**Advantage:**
- UP's **explicit is better than implicit** approach means no ambiguity
- `version = "1.2.3"` vs `version = 1.2.3` in TOML changes the type
- UP: `version 1.2.3` (string) vs `version!float 1.2` (number) is always clear
- No need to remember TOML's type inference rules

## Migration from TOML

UP is often a **straightforward translation** with improved readability:

**TOML:**
```toml
[package]
name = "myproject"
version = "0.1.0"

[dependencies]
serde = "1.0"
tokio = "1.28"
```

**UP:**
```up
package {
  name myproject
  version 0.1.0
}

dependencies {
  serde 1.0
  tokio 1.28
}
```

**Translation rules:**
1. Convert `[section]` to `section {}`
2. Convert `[parent.child]` to nested blocks
3. Remove `=` signs
4. Remove quotes from strings
5. Convert `[[array]]` to array of objects `[{}]` or `!table` syntax
6. Add type annotations for non-strings

**For tabular data, consider the table syntax:**
```toml
[[servers]]
name = "alpha"
ip = "10.0.0.1"
region = "us-east"

[[servers]]
name = "beta"
ip = "10.0.0.2"
region = "us-west"
```

Becomes:
```up
servers!table {
  columns [name, ip, region]
  rows [
    [alpha, 10.0.0.1, us-east]
    [beta, 10.0.0.2, us-west]
  ]
}
```

## When to Use Each

| Use Case | TOML | UP |
|----------|------|-----|
| **Rust ecosystem** (Cargo.toml) | ✅ Standard | ⚠️ Non-standard |
| **Python packaging** | ✅ Common | ✅ Alternative |
| **General config files** | ✅ Good | ✅ Better |
| **Complex nested configs** | ⚠️ Gets messy | ✅ Excellent |
| **Tabular/structured data** | ⚠️ Very repetitive | ✅ Clean tables |
| **Team readability** | ⚠️ Learning curve | ✅ Intuitive |
| **Large config files** | ⚠️ Hard to navigate | ✅ Easy to scan |

## Summary

| Feature | TOML | UP |
|---------|------|-----|
| **Simple key-values** | Excellent | Excellent |
| **Nested structures** | Table headers | Visual blocks |
| **Deep nesting** | Cumbersome paths | Natural hierarchy |
| **Arrays of objects** | `[[special]]` syntax | Consistent `[{}]` |
| **Tabular data** | Repetitive `[[array]]` | Clean `!table` syntax |
| **Comprehension** | Requires mental parsing | Immediately visual |
| **Scanning** | Jump between sections | Follow tree structure |
| **Type clarity** | Syntax-based inference | Explicit annotations |
| **Learning curve** | Multiple special cases | One consistent pattern |

**UP's advantage: Structure matches how humans think about hierarchical data. No mental mapping from `[a.b.c]` headers to nested trees—you see the tree directly.**

TOML was a significant improvement over INI files, bringing explicit tables and arrays. UP takes the next step: making complex configurations as easy to read as simple ones, with syntax that matches the structure you're imagining.

**If you value readability and comprehension, especially for complex nested configurations, UP provides a more natural and intuitive experience.**

