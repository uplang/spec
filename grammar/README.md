# UP Grammar Definitions

This directory contains formal grammar definitions for the UP (Unified Properties) language in multiple parser generator formats.

## Overview

UP is a line-oriented, hierarchical data format with these key features:

- **Type annotations**: `key!type value`
- **Blocks**: `key { ... }`
- **Lists**: `key [item1, item2]` or multiline
- **Multiline strings**: ` ```...``` `
- **Tables**: Pipe-delimited tabular data
- **Comments**: `# comment text`
- **Whitespace-delimited**: Keys and values separated by spaces/tabs

## Available Grammar Formats

### 1. Bison/Yacc + Flex ([up.y](up.y) + [up.l](up.l))

**Best for:** C/C++ parsers, mature tooling, LALR(1) parsing

```bash
# Generate parser
bison -d up.y
flex up.l
gcc up.tab.c lex.yy.c -lfl -o up-parser

# Test
echo "name Alice" | ./up-parser
```

**Files:**
- **[up.y](up.y)** - Bison grammar (parser rules)
- **[up.l](up.l)** - Flex lexer (tokenization rules)

**Features:**
- LALR(1) parser generator
- Standard C output
- Battle-tested tooling
- Excellent error reporting

### 2. ANTLR4 ([up.g4](up.g4))

**Best for:** Cross-language parsers, LL(*) parsing, rich tooling

```bash
# Generate parser (Java example)
antlr4 up.g4
javac up*.java

# For Python
antlr4 -Dlanguage=Python3 up.g4

# For JavaScript
antlr4 -Dlanguage=JavaScript up.g4
```

**Target Languages:** Java, Python, JavaScript, C#, C++, Go, Swift, PHP, Dart

**File:** [up.g4](up.g4) - Combined grammar (lexer + parser in one file)

**Features:**
- LL(*) parsing (more flexible than LALR)
- Generates parsers for 10+ languages
- Excellent IDE support
- Built-in tree walking
- Grammar visualization tools

### 3. PEG ([up.peg](up.peg))

**Best for:** Simple integration, unambiguous parsing, packrat parsing

```bash
# Using PEG.js
pegjs up.peg
node
> const parser = require('./up.js');
> parser.parse('name Alice');

# Using Peggy (modern PEG.js)
npx peggy up.peg
```

**File:** [up.peg](up.peg) - Parsing Expression Grammar

**Features:**
- No ambiguity (PEGs are always deterministic)
- Packrat parsing (linear time with memoization)
- Easy to understand
- JavaScript-friendly
- No separate lexer needed

**Compatible with:** PEG.js, Peggy, python-peg, pest (Rust), and other PEG parsers

### 4. Tree-sitter ([grammar.js](grammar.js))

**Best for:** Editor integration, syntax highlighting, incremental parsing

```bash
# Install tree-sitter CLI
npm install -g tree-sitter-cli

# Generate parser
tree-sitter generate

# Test
tree-sitter parse ../examples/01-basic-scalars.up

# Create syntax highlighting queries
tree-sitter highlight ../examples/01-basic-scalars.up
```

**File:** [grammar.js](grammar.js) - Tree-sitter grammar (JavaScript DSL)

**Features:**
- Incremental parsing (fast on edits)
- Error recovery (parses even invalid syntax)
- Syntax highlighting
- Code navigation (go-to-definition, etc.)
- Used by: GitHub, Neovim, Atom, Helix, Zed

**Integration:** Used for UP syntax highlighting in editors and on GitHub

## Grammar Structure

All grammars define these core concepts:

### Tokens (Lexer)

```
IDENTIFIER      [A-Za-z_][A-Za-z0-9_-]*
INTEGER         [0-9]+
BANG            !
LBRACE          {
RBRACE          }
LBRACKET        [
RBRACKET        ]
BACKTICKS       ```
HASH            #
NEWLINE         \n | \r\n
```

### Syntax Rules (Parser)

```ebnf
Document      ::= Statement*
Statement     ::= Key TypeAnnotation? Value? Newline
                | Comment
Key           ::= IDENTIFIER
TypeAnnotation ::= BANG TypeName
Value         ::= Scalar | Block | List | Multiline | Table
Block         ::= LBRACE Statement* RBRACE
List          ::= LBRACKET (Value (COMMA Value)*)? RBRACKET
Multiline     ::= BACKTICKS Content BACKTICKS
Comment       ::= HASH RestOfLine
```

## Key Grammar Characteristics

### Line-Oriented

Statements are separated by newlines, not semicolons:

```up
name Alice          # Statement 1
age!int 30          # Statement 2
active!bool true    # Statement 3
```

### Context-Sensitive

Some constructs require state tracking:

- **Blocks**: Track brace nesting depth
- **Lists**: Track bracket nesting
- **Multiline strings**: Special mode between triple backticks
- **Comments**: Rest-of-line capture

### Whitespace Rules

- **Significant**: Newlines separate statements
- **Insignificant**: Spaces/tabs between key and value (except in multiline blocks)
- **Preserved**: Inside multiline strings and quoted values

### No Reserved Keywords

All identifiers are valid keys:

```up
# These are all valid
if true
for loop
class Person
return value
```

## Testing Grammars

Each grammar format has specific testing commands:

```bash
# Bison/Yacc - Check for conflicts
bison --warnings=all up.y

# ANTLR4 - Validate grammar
antlr4 -Werror up.g4

# PEG.js - Test with trace
pegjs --trace up.peg

# Tree-sitter - Run tests
tree-sitter test
tree-sitter parse ../examples/*.up
```

## Choosing a Grammar Format

| Format | Best For | Pros | Cons |
|--------|----------|------|------|
| **Bison+Flex** | C/C++ integration | Mature, fast, standard | C-specific, setup complexity |
| **ANTLR4** | Multi-language support | 10+ targets, great tooling | Larger runtime, Java-based |
| **PEG** | JavaScript/simple parsers | Unambiguous, easy to read | No left recursion, backtracking |
| **Tree-sitter** | Editor integration | Incremental, error recovery | Specific use case |

## Implementation Guidelines

When implementing a parser using these grammars:

### 1. Tokenization

Handle these special cases:

- **Multiline strings**: Enter special mode on ```` ``` ````, exit on closing ```` ``` ````
- **Comments**: Capture entire line after `#`, include in AST for doc generation
- **Inline strings**: Value continues until newline or special char (`{`, `[`, ``` ` ```)

### 2. Parsing

Key implementation points:

- **Type annotations**: Optional `!type` after key, store with node
- **Blocks**: Recursive descent, track nesting depth
- **Lists**: Handle both inline `[a, b]` and multiline formats
- **Dedenting**: Type annotation `!N` removes N spaces from each line of multiline value

### 3. AST Structure

Recommended AST nodes:

```
Document
  ├─ Node
  │   ├─ key: string
  │   ├─ type: string?
  │   └─ value: Value
  └─ ...

Value = Scalar | Block | List | Table | Multiline
```

### 4. Error Handling

Provide helpful error messages:

```
Parse error at line 15: Expected '}' to close block
  Block opened at line 10: server {
  Got: unexpected EOF
```

## Examples

Test all grammars against example files:

```bash
../examples/01-basic-scalars.up     # Simple key-value pairs
../examples/02-blocks.up            # Nested blocks
../examples/03-lists.up             # List structures
../examples/04-multiline.up         # Multiline strings
../examples/07-tables.up            # Table format
../examples/08-mixed-complex.up     # Complex nested structures
```

## Contributing

When modifying grammars:

1. **Update all formats** - Keep grammars in sync across formats
2. **Test thoroughly** - Use example files to validate changes
3. **Document changes** - Update this README with new syntax
4. **Verify implementations** - Ensure parser implementations in `../go/`, `../java/`, etc. stay compatible

## References

- **[UP Specification](../README.md)** - Complete language specification
- **[Syntax Reference](../SYNTAX-REFERENCE.md)** - Quick syntax guide
- **[Example Files](../examples/)** - Test cases and examples

### Grammar Resources

- **Bison**: https://www.gnu.org/software/bison/manual/
- **Flex**: https://github.com/westes/flex
- **ANTLR4**: https://www.antlr.org/
- **PEG**: https://en.wikipedia.org/wiki/Parsing_expression_grammar
- **Tree-sitter**: https://tree-sitter.github.io/tree-sitter/

## License

All grammar definitions are licensed under GNU GPLv3 - see [../LICENSE](../LICENSE) for details.
