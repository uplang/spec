# UP Examples

This directory contains comprehensive examples demonstrating all features of the UP language.

## Examples Overview

### Core Language Examples

| Example | Description |
|---------|-------------|
| `01-basic-scalars.up` | Simple key-value pairs with various type annotations |
| `02-blocks.up` | Nested block structures for hierarchical data |
| `03-lists.up` | Multiline and inline list syntax |
| `04-multiline.up` | Multiline strings with language hints for code blocks |
| `05-dedent.up` | Dedenting feature to remove leading whitespace |
| `06-comments.up` | Comment syntax and usage patterns |
| `07-tables.up` | Table structures with columns and rows |
| `08-mixed-complex.up` | Realistic complex configuration using all features |

### Templating Examples

| Example | Description |
|---------|-------------|
| `templates/base.up` | Base configuration with shared defaults |
| `templates/development.up` | Development environment overrides |
| `templates/staging.up` | Staging environment configuration |
| `templates/production.up` | Production environment settings |
| `templates/features/*.up` | Feature modules for composition |
| `templates/composed/*.up` | Composed configurations from multiple files |
| `templates/multi-doc-example.up` | **Multi-document file** - All environments in one file |
| `dynamic-test-data.up` | **Dynamic namespaces** - Generate test data with faker, random, time, id |
| `plugin-example.up` | **Namespace plugins** - Custom namespace via executable plugin |
| `namespace-aliases-example.up` | **Namespace aliases** - Multiple versions/implementations with aliases |

## Running Examples

### Using the Go parser

```bash
# Parse and output as JSON
up parse -i examples/01-basic-scalars.up --pretty

# Validate syntax
up validate -i examples/02-blocks.up

# Format (parse and output as UP)
up format -i examples/03-lists.up
```

### Using Templating

```bash
# Process a template file
up template process -i examples/templates/production.up

# Process and output as JSON
up template process -i examples/templates/production.up --json --pretty

# Validate a template
up template validate -i examples/templates/composed/production-ha.up

# Multi-document example - extract and process specific config
sed -n '/# Production configuration/,/^# ---$/p' examples/templates/multi-doc-example.up | up template process

# Dynamic namespaces - generate test data (requires implementation)
up template process -i examples/dynamic-test-data.up --seed 12345
```

**Note:** Dynamic namespaces (`!use` pragma) are currently a design specification. Implementation is planned for future releases.

### Using JavaScript parser

```bash
cd parsers/javascript
node -e "const up = require('./up'); console.log(JSON.stringify(up.parse(require('fs').readFileSync('../../examples/01-basic-scalars.up', 'utf8')), null, 2))"
```

### Using Python parser

```bash
cd parsers/python
python up.py ../../examples/01-basic-scalars.up
```

### Using Rust parser

```bash
cd parsers/rust
cargo run --bin up-parse ../../examples/01-basic-scalars.up
```

### Using C parser

```bash
cd parsers/c
make
# Modify example.c to read from file, then:
./example
```

## Feature Demonstrations

### Type Annotations

See `01-basic-scalars.up` for examples of:
- `!int`, `!integer` - Integer values
- `!bool`, `!boolean` - Boolean values
- `!url`, `!uri` - URL/URI strings
- `!ts`, `!timestamp` - Timestamp values
- `!dur`, `!duration` - Duration values
- Custom types like `!uuid`, `!hex`, `!celsius`

### Blocks

See `02-blocks.up` for:
- Simple blocks
- Nested blocks
- Deeply nested hierarchies
- Blocks with mixed value types

### Lists

See `03-lists.up` for:
- Multiline lists (one item per line)
- Inline lists (`[a, b, c]`)
- Empty lists
- Lists of inline lists (coordinates)

### Multiline Strings

See `04-multiline.up` for:
- Basic multiline strings
- Language hints (`python`, `json`, `sql`, `bash`, etc.)
- Embedded code with proper syntax
- Configuration file embedding

### Dedenting

See `05-dedent.up` for:
- `!N` syntax where N is number of spaces to remove
- Common use case: embedding indented code
- Works with any content type

### Comments

See `06-comments.up` for:
- Single-line comments starting with `#`
- Comment placement (before/between statements)
- Comments inside blocks and lists
- Section divider patterns

### Tables

See `07-tables.up` for:
- Table syntax with `columns` and `rows`
- Data in tabular format
- Multiple tables in one document
- Various column counts

### Real-World Usage

See `08-mixed-complex.up` for:
- Application configuration
- Database connection settings
- Feature flags
- Scheduled jobs as tables
- Email templates with multiline HTML
- Security and monitoring configuration
- Everything combined

## Testing Examples

All examples should parse without errors using the UP parser. To test all examples:

```bash
# Using Go implementation
for file in examples/*.up; do
    echo "Testing $file..."
    up validate -i "$file" || echo "FAILED: $file"
done

# Or use the test script (if created)
./test-examples.sh
```

## Creating Your Own Examples

When creating UP documents:

1. Start with simple key-value pairs
2. Add type annotations where types matter
3. Use blocks for hierarchical data
4. Use lists for collections
5. Use multiline blocks for code/JSON/etc
6. Use dedent (`!N`) when embedding indented content
7. Use tables for tabular data
8. Add comments to document your configuration

## Comparison with Other Formats

UP combines the best aspects of:
- **JSON**: Structure and nesting
- **YAML**: Human readability and multiline strings
- **TOML**: Type annotations and simplicity
- **HCL**: Blocks and flexibility

But with:
- Simpler syntax than YAML
- Better multiline support than JSON/TOML
- Type annotations unlike JSON/YAML
- Dedenting feature for clean embedded code
- Table syntax for tabular data

## Contributing Examples

To add a new example:

1. Create a `.up` file in this directory
2. Add a clear comment header explaining what it demonstrates
3. Update this README with the example description
4. Test it with all parsers
5. Submit a pull request

