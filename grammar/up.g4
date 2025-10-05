// UP Grammar for ANTLR4
// Unified Properties
// This grammar can generate parsers for Java, Python, JavaScript, C#, C++, Go, Swift, PHP

grammar snap;

// Parser Rules

document
    : statement* EOF
    ;

statement
    : keyWithType value? NEWLINE
    | comment
    | NEWLINE
    ;

comment
    : HASH restOfLine NEWLINE
    ;

keyWithType
    : IDENTIFIER typeAnnotation?
    ;

typeAnnotation
    : BANG IDENTIFIER       # TypeName
    | BANG INTEGER          # DedentCount
    ;

value
    : scalar                # ScalarValue
    | multiline             # MultilineValue
    | block                 # BlockValue
    | list                  # ListValue
    | table                 # TableValue
    ;

scalar
    : STRING
    ;

multiline
    : BACKTICKS languageHint? NEWLINE multilineContent BACKTICKS NEWLINE?
    ;

languageHint
    : IDENTIFIER
    ;

multilineContent
    : MULTILINE_TEXT
    ;

block
    : LBRACE NEWLINE blockContent RBRACE
    ;

blockContent
    : statement*
    ;

list
    : LBRACKET NEWLINE listContent RBRACKET     # MultilineList
    | LBRACKET inlineList RBRACKET              # InlineListDef
    ;

listContent
    : listItem*
    ;

listItem
    : scalar NEWLINE
    | block NEWLINE
    | LBRACKET inlineList RBRACKET NEWLINE
    ;

inlineList
    : (inlineItem (COMMA inlineItem)*)?
    ;

inlineItem
    : scalar
    ;

table
    : LBRACE NEWLINE tableColumns tableRows RBRACE
    ;

tableColumns
    : IDENTIFIER LBRACKET inlineList RBRACKET NEWLINE
    ;

tableRows
    : IDENTIFIER LBRACE NEWLINE rowList RBRACE
    ;

rowList
    : (LBRACKET inlineList RBRACKET NEWLINE)*
    ;

restOfLine
    : STRING?
    ;

// Lexer Rules

BANG        : '!' ;
LBRACE      : '{' ;
RBRACE      : '}' ;
LBRACKET    : '[' ;
RBRACKET    : ']' ;
COMMA       : ',' ;
COLON       : ':' ;
HASH        : '#' ;

BACKTICKS
    : '```' -> pushMode(MULTILINE_MODE)
    ;

IDENTIFIER
    : [A-Za-z_] [A-Za-z0-9_-]*
    ;

INTEGER
    : [0-9]+
    ;

STRING
    : ~[\r\n{}\[\]`!,:#]+
    ;

NEWLINE
    : '\r'? '\n'
    ;

WHITESPACE
    : [ \t]+ -> skip
    ;

// Multiline mode for capturing content between triple backticks
mode MULTILINE_MODE;

MULTILINE_TEXT
    : .*? '```' { setText(getText().substring(0, getText().length() - 3)); } -> popMode
    ;

