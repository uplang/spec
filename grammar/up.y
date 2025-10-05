/* UP Grammar for Bison/Yacc */
/* Unified Properties */

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void yyerror(const char *s);
int yylex(void);
%}

%union {
    char *string;
    int integer;
    void *node;
    void *list;
}

%token <string> IDENTIFIER STRING MULTILINE_CONTENT
%token <integer> INTEGER
%token BANG LBRACE RBRACE LBRACKET RBRACKET COMMA COLON BACKTICKS HASH NEWLINE
%token END_OF_FILE

%type <node> document statement value scalar block list table
%type <node> key_with_type multiline_block
%type <list> statements block_content list_content inline_list
%type <list> inline_items table_rows row_list
%type <string> type_annotation language_hint

%start document

%%

/* Document Structure */
document
    : statements END_OF_FILE
    | END_OF_FILE
    ;

statements
    : statement
    | statements statement
    ;

statement
    : key_with_type value NEWLINE
    | key_with_type NEWLINE
    | comment
    | NEWLINE
    ;

comment
    : HASH STRING NEWLINE
    | HASH NEWLINE
    ;

/* Keys and Type Annotations */
key_with_type
    : IDENTIFIER
    | IDENTIFIER type_annotation
    ;

type_annotation
    : BANG IDENTIFIER
    | BANG INTEGER
    ;

/* Values */
value
    : scalar
    | multiline_block
    | block
    | list
    | table
    ;

scalar
    : STRING
    ;

/* Multiline Blocks */
multiline_block
    : BACKTICKS NEWLINE MULTILINE_CONTENT BACKTICKS
    | BACKTICKS language_hint NEWLINE MULTILINE_CONTENT BACKTICKS
    ;

language_hint
    : IDENTIFIER
    ;

/* Blocks */
block
    : LBRACE NEWLINE block_content RBRACE
    ;

block_content
    : /* empty */
    | statements
    ;

/* Lists */
list
    : LBRACKET NEWLINE list_content RBRACKET
    | LBRACKET inline_list RBRACKET
    ;

list_content
    : /* empty */
    | list_content scalar NEWLINE
    | list_content block NEWLINE
    | list_content LBRACKET inline_list RBRACKET NEWLINE
    ;

inline_list
    : /* empty */
    | inline_items
    ;

inline_items
    : scalar
    | inline_items COMMA scalar
    ;

/* Tables */
table
    : LBRACE NEWLINE table_columns table_rows RBRACE
    ;

table_columns
    : IDENTIFIER LBRACKET inline_list RBRACKET NEWLINE
    ;

table_rows
    : IDENTIFIER LBRACE NEWLINE row_list RBRACE
    ;

row_list
    : /* empty */
    | row_list LBRACKET inline_list RBRACKET NEWLINE
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Parse error: %s\n", s);
}

