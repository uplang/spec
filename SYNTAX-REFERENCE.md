# UP Syntax Reference

Quick reference for UP syntax rules and common patterns.

## Core Syntax Rules

### Key-Value Pairs

UP is **whitespace-delimited**. The basic unit is:

```up
key value
```

### Multi-Word Values **REQUIRE QUOTES**

❌ **WRONG:**
```up
name John Doe
description This is a description
```

This parses as:
```
name: "John"
Doe: (new key with no value)
description: "This"
is: "a"
description: (duplicate key)
```

✅ **CORRECT:**
```up
name "John Doe"
description "This is a description"
```

### Single-Word Values Don't Need Quotes

```up
name Alice
status active
environment production
```

### Type Annotations

```up
port!int 8080
enabled!bool true
timeout!dur 30s
version "1.2.3"
```

### URLs and Emails (No Spaces = No Quotes Needed)

```up
email alice@example.com
repository https://github.com/user/repo
website https://example.com/path/to/page
```

### Blocks

```up
server {
  host localhost
  port!int 8080
  name "My Server"
}
```

### Lists

```up
# Multiline
tags [
  production
  web
  api
]

# Inline
tags [production, web, api]
```

### Multiline Strings (No Quotes Needed)

```up
description ```
This is a multiline string.
Whitespace is preserved.
No quotes needed inside.
```

notes ```
Multi-line notes
can contain anything
including "quotes"
```
```

### Multiline Strings with Dedent (Best Practice)

**For structured documents, use dedent to maintain indentation:**

❌ **BAD (ruins indentation):**
```up
metadata {
  notes ```
This breaks the visual structure
because it's not indented
```
}
```

✅ **GOOD (maintains structure):**
```up
metadata {
  notes!2 ```
    This maintains the visual structure
    by using dedent to remove leading spaces
    ```
}
```

**Dedent removes N spaces from each line:**
```up
# !4 removes 4 spaces from each line
description!4 ```
    Line 1 has 4 leading spaces
    Line 2 also has 4 leading spaces
    Result: both lines flush left in output
    ```

# Choose dedent based on your indentation level
block {
  field!2 ```
    Content indented 2 spaces
    ```

  nested {
    field!4 ```
      Content indented 4 spaces
      ```
  }
}
```

## Common Patterns

### Schema Definitions

✅ **CORRECT:**
```up
namespace greeting
version 1.2.3
description "Simple greeting generator"

functions {
  hello {
    description "Generate a greeting"

    params {
      name!string {
        description "Name to greet"
        default World
        required!bool false
      }
    }

    returns!string {
      description "Greeting message"
      example "Hello, Alice!"
    }
  }
}

metadata {
  author "UP Team"
  license MIT
  safe!bool true
}
```

### Security Policies

✅ **CORRECT:**
```up
policy {
  verify_hashes!bool true
  require_signatures!bool true
}

trusted_signers {
  up_core {
    name "UP Core Team"
    email security@uplang.org
    trust_level official
  }
}
```

### Lock Files

✅ **CORRECT:**
```up
namespaces {
  greeting {
    version 1.2.3

    files {
      executable {
        path ./up-namespaces/greeting
        hash sha256:abc123...
      }
    }

    verified!bool true
    source local
  }
}
```

### Example Data

✅ **CORRECT:**
```up
users [
  {
    name "Alice Johnson"
    email alice@example.com
    role admin
  }
  {
    name "Bob Smith"
    email bob@example.com
    role user
  }
]
```

## When To Quote

### Always Quote

- ✅ Multi-word values: `"Hello World"`
- ✅ Values with special characters: `"!@#$%"`
- ✅ Values that look like other types: `"123"` (string 123, not number)
- ✅ Empty strings: `""`
- ✅ Values starting with special chars: `"$variable"`

### Never Quote

- ✅ Single words: `production`
- ✅ Numbers (with type annotation): `port!int 8080`
- ✅ Booleans (with type annotation): `enabled!bool true`
- ✅ URLs/emails (no spaces): `https://example.com`
- ✅ Multiline strings (use ` ``` ` instead)

### Optional (But Recommended for Clarity)

- ✅ Version strings: `version "1.2.3"` or `version 1.2.3`
- ✅ File paths: `path "./my file.txt"` or `path ./myfile.txt`

## Common Mistakes

### Mistake 1: Unquoted Multi-Word Values

❌ **WRONG:**
```up
description This is wrong
name John Doe
message Hello World
```

✅ **CORRECT:**
```up
description "This is wrong"
name "John Doe"
message "Hello World"
```

### Mistake 2: Quoting Single Words Unnecessarily

⚠️ **Works but unnecessary:**
```up
environment "production"
status "active"
```

✅ **Better (simpler):**
```up
environment production
status active
```

### Mistake 3: Forgetting Type Annotations for Non-Strings

❌ **WRONG (parsed as strings):**
```up
port 8080
enabled true
```

✅ **CORRECT:**
```up
port!int 8080
enabled!bool true
```

### Mistake 4: Quoting Multiline Strings

❌ **WRONG:**
```up
description "Line 1
Line 2
Line 3"
```

✅ **CORRECT:**
```up
description ```
Line 1
Line 2
Line 3
```
```

## Quick Reference Table

| Value Type | Needs Quotes? | Example |
|------------|---------------|---------|
| Single word | No | `status active` |
| Multi-word | **YES** | `name "John Doe"` |
| URL/Email | No | `email user@example.com` |
| Number | No (+ type) | `port!int 8080` |
| Boolean | No (+ type) | `enabled!bool true` |
| Version | Optional | `version "1.2.3"` or `version 1.2.3` |
| Path (no spaces) | No | `path ./file.txt` |
| Path (with spaces) | **YES** | `path "./my file.txt"` |
| Multiline | Use ` ``` ` | See multiline syntax |
| Empty string | **YES** | `value ""` |

## Validation

To check if your UP is valid:

```bash
# Parse and validate
up validate -i yourfile.up

# Parse and output as JSON (will fail if invalid)
up parse -i yourfile.up --pretty
```

## Summary

**The Golden Rule:** If a value contains **whitespace**, it **MUST** be quoted.

**Type Safety:** Remember that strings are default, so only use quotes when needed for parsing, and use type annotations (`!int`, `!bool`, etc.) when you want non-string types.

