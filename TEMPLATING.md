# UP Templating

UP templating provides declarative configuration composition using the same `!type` annotation syntax as the rest of UP. No string substitution, no logic, just clean data composition.

## Syntax

Template directives use `!annotation` syntax, consistent with UP's type system:

### Variables
```up
vars {
  app_name MyApp
  port!int 8080
  region us-west-2
}

# Reference with $ prefix
server {
  port $vars.port
  region $vars.region
}
```

### Base Configuration
```up
config!base base.up
```
Load and inherit from a base configuration file.

### Overlays
```up
server!overlay {
  host production.example.com
  replicas!int 10
}
```
Declaratively merge this block with existing configuration.

### Includes
```up
features!include [
  features/beta.up
  features/ha.up
]
```
Include and merge multiple files.

### Patches
```up
scaling!patch {
  server.replicas!int 20
  features.beta!bool true
}
```
Apply targeted modifications using path notation.

### Merge Strategy
```up
options!merge {
  strategy deep
  list_strategy append
}
```
Configure how blocks and lists are merged.

## Complete Example

**base.up:**
```up
vars {
  app_name MyApp
  default_port!int 8080
}

app_name $vars.app_name
version 1.0.0

server {
  host 0.0.0.0
  port $vars.default_port
  replicas!int 2
}

database {
  driver postgres
  pool_size!int 20
}

features {
  new_ui!bool false
  beta_api!bool false
}
```

**production.up:**
```up
config!base base.up

vars {
  prod_host production.example.com
}

server!overlay {
  host $vars.prod_host
  port!int 443
  replicas!int 10
  tls_enabled!bool true
}

database!overlay {
  host db.production.example.com
  pool_size!int 100
  ssl_enabled!bool true
}

features!overlay {
  new_ui!bool true
  analytics!bool true
}
```

**Result after processing:**
```up
app_name MyApp
version 1.0.0
server {
  host production.example.com
  port 443
  replicas 10
  tls_enabled true
}
database {
  driver postgres
  pool_size 100
  host db.production.example.com
  ssl_enabled true
}
features {
  new_ui true
  beta_api false
  analytics true
}
```

## Template Annotations

| Annotation | Purpose | Usage |
|------------|---------|-------|
| `!base` | Inherit configuration | `config!base base.up` |
| `!overlay` | Merge block declaratively | `server!overlay { }` |
| `!include` | Include multiple files | `mods!include [file1, file2]` |
| `!patch` | Apply targeted changes | `fixes!patch { path value }` |
| `!merge` | Configure merge behavior | `opts!merge { strategy deep }` |

## Variable References

Use `$vars.path` to reference variables:

```up
vars {
  environment production
  config {
    timeout!dur 30s
    retries!int 3
  }
}

deployment {
  env $vars.environment
  timeout $vars.config.timeout
  retries $vars.config.retries
}
```

## Merge Strategies

### Deep Merge (Default)
Blocks are merged recursively:
```up
# Base
server { host localhost, port!int 8080 }

# Overlay
server!overlay { host prod.com, tls!bool true }

# Result
server { host prod.com, port 8080, tls true }
```

### List Strategies

**append** (default):
```up
tags [web, api]
tags!overlay [production]
# Result: [web, api, production]
```

**replace**:
```up
options!merge { list_strategy replace }
tags!overlay [production, v2]
# Result: [production, v2]
```

**unique**:
```up
options!merge { list_strategy unique }
tags [web, api]
tags!overlay [api, production]
# Result: [web, api, production]
```

## Patching

Path-based modifications:
```up
scaling!patch {
  server.replicas!int 20
  server.cpu 4000m
  features.beta!bool true
  items[*].enabled!bool true
}
```

## Multi-Environment Setup

**Structure:**
```
config/
├── base.up              # Common settings
├── development.up       # Dev overrides
├── staging.up          # Staging overrides
├── production.up       # Production config
└── features/
    ├── beta.up
    └── ha.up
```

**base.up:**
```up
vars {
  app_name MyApp
  default_replicas!int 2
}

app_name $vars.app_name
server {
  replicas $vars.default_replicas
}
```

**development.up:**
```up
config!base base.up

server!overlay {
  host localhost
  debug!bool true
}
```

**production.up:**
```up
config!base base.up

server!overlay {
  host production.example.com
  replicas!int 10
  tls_enabled!bool true
}
```

**production-with-beta.up:**
```up
config!base production.up

features!include [
  features/beta.up
]
```

## CLI Usage

```bash
# Process template
up template process -i production.up -o output.up

# Validate template
up template validate -i production.up

# Output as JSON
up template process -i production.up --json --pretty
```

## Why This Design?

### Consistent with UP
```up
port!int 8080          # Type annotation
config!base base.up  # Template annotation
```
Same `!annotation` pattern everywhere.

### No Reserved Keys
Any key can be used with template annotations:
```up
base!base base.up
foundation!base base.up
parent!base base.up
```

### Clear Variable Syntax
```up
$vars.port              # Clear it's a variable reference
server.replicas!int 10  # Clear it's a type annotation
```

## Comparison

**Traditional (Helm):**
```yaml
replicas: {{ .Values.replicas | default 3 }}
{{- if .Values.production }}
tls: {{ .Values.tls | toJson }}
{{- end }}
```
Problems: String substitution, logic, type-unsafe, mixed languages.

**UP:**
```up
config!base base.up
server!overlay {
  replicas!int 10
  tls_enabled!bool true
}
```
Benefits: Declarative, type-safe, pure UP syntax, no logic.

## Processing Pipeline

```
1. Load and parse all documents (base, includes, current)
   ↓
2. Extract variables from ALL documents (order-independent)
   ↓
3. Merge documents (base → includes → current)
   ↓
4. Apply overlays (blocks with !overlay)
   ↓
5. Apply patches (blocks with !patch)
   ↓
6. Iteratively resolve variables until convergence
   ↓
7. Output final configuration
```

### Iterative Variable Resolution

Variables are resolved **iteratively** rather than sequentially. This means:

- **Order doesn't matter** - Variables can reference other variables regardless of declaration order
- **Deep nesting works** - Variables can build on other variables that build on other variables
- **Convergence detection** - Resolution continues until all variables are resolved or a circular dependency is detected
- **Circular detection** - If resolution doesn't converge within 100 iterations, a circular dependency error is raised

**Example:**
```up
vars {
  # These reference each other - order doesn't matter
  region us-west-2
  environment production

  # Builds from above (even though defined first)
  full_name $vars.environment-$vars.region

  # Uses full_name (defined above)
  deployment_id v1-$vars.full_name

  # Multi-level reference
  tag service-$vars.deployment_id
}

# All resolve correctly:
# full_name = "production-us-west-2"
# deployment_id = "v1-production-us-west-2"
# tag = "service-v1-production-us-west-2"
```

**String Interpolation:**
```up
vars {
  host example.com
  port!int 443
  protocol https

  # Multiple variables in one string
  url $vars.protocol://$vars.host:$vars.port
  health_check $vars.url/health
}

# Result:
# url = "https://example.com:443"
# health_check = "https://example.com:443/health"
```

## Language Implementation

### Go
```go
import up "github.com/uplang/spec/parsers/go/src"

engine := up.NewTemplateEngine()
doc, err := engine.ProcessTemplate("config.up")
```

### JavaScript
```javascript
const up = require('@up-lang/parser');
const doc = await up.template('config.up');
```

### Python
```python
import up
doc = up.process_template('config.up')
```

## Examples

All examples are in `examples/templates/`:
- `base.up` - Common configuration
- `development.up` - Dev environment
- `staging.up` - Staging environment
- `production.up` - Production environment
- `features/*.up` - Feature modules
- `composed/*.up` - Composed configurations

Process them:
```bash
up template process -i examples/templates/production.up
```

## Multi-Document Files

UP supports multiple "documents" in a single file using comment-based separators. This is useful for:
- **Testing** - Keep test configs alongside each other
- **Development** - Iterate on variations without multiple files
- **Composition** - Define related configs together

### Syntax

Use any comment line as a separator (common convention: `# ---`):

```up
# base configuration
vars { app_name MyApp }
server { host localhost, port!int 8080 }

# ---

# development overlay
config!base base.up
server!overlay { debug!bool true }

# ---

# production overlay
config!base base.up
server!overlay { host prod.com, tls!bool true }
```

### Parser Behavior

- **Comment separators are just comments** - Parser treats them like any other comment
- **No special parsing** - No changes needed to parser
- **Files can be concatenated** - Simply concatenate UP files with separator comments

### Semantic Analysis

Tooling can parse comment-separated documents and warn about:

**Ordering Issues:**
```up
# BAD: overlay before base is loaded
server!overlay { tls!bool true }

# ---

config!base base.up
```

**Undefined References:**
```up
database { host $vars.db_host }  # Warning: vars.db_host not defined

# ---

vars { api_host api.example.com }  # Different doc, doesn't define db_host
```

**Circular Dependencies:**
```up
# a.up
config!base b.up

# ---

# b.up
config!base a.up
```

A linter can detect these by:
1. Splitting on separator comments
2. Checking document order
3. Analyzing references across documents
4. Warning about potential issues

### Example

**config-all.up:**
```up
# Base configuration - common settings
vars {
  app_name MyApp
  default_port!int 8080
}

app_name $vars.app_name
version 1.0.0

server {
  host 0.0.0.0
  port $vars.default_port
  replicas!int 2
}

# ---

# Development configuration
config!base base.up

vars {
  dev_host localhost
}

server!overlay {
  host $vars.dev_host
  debug!bool true
  replicas!int 1
}

# ---

# Production configuration
config!base base.up

vars {
  prod_host production.example.com
}

server!overlay {
  host $vars.prod_host
  replicas!int 10
  tls_enabled!bool true
}

features!include [
  features/monitoring.up
  features/high-availability.up
]
```

Process a specific document (by line range, index, or extraction):
```bash
# Extract and process just the production config
sed -n '/# Production/,/^# ---$/p' config-all.up | up template process

# Or use future up multi-doc support:
up template process -i config-all.up --doc 2  # 0-indexed
```

## Design Principles

1. **Use UP syntax** - No new language
2. **Type-safe** - Variables are UP values
3. **Declarative** - Describe what, not how
4. **Composable** - Layer configurations
5. **Predictable** - Clear merge semantics
6. **No logic** - Pure data transformation
7. **Parser-agnostic separators** - Multi-doc via comments only

**No templating hell. Just clean, composable configuration.**
