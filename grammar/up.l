/* UP Lexer for Flex */
/* Unified Properties */

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "up.tab.h"

int line_num = 1;
int column_num = 1;
int in_multiline = 0;
char multiline_buffer[65536];
int multiline_pos = 0;

void update_position(int length);
%}

%option noyywrap
%option yylineno

%x MULTILINE
%x COMMENT

IDENTIFIER      [A-Za-z_][A-Za-z0-9_-]*
INTEGER         [0-9]+
WHITESPACE      [ \t]+
NEWLINE         \r?\n

%%

    /* Comments */
^{WHITESPACE}?"#"   { BEGIN(COMMENT); return HASH; }
<COMMENT>[^\n\r]*   { yylval.string = strdup(yytext); return STRING; }
<COMMENT>{NEWLINE}  { BEGIN(INITIAL); line_num++; column_num = 1; return NEWLINE; }

    /* Multiline blocks */
"```"               {
                        if (in_multiline) {
                            in_multiline = 0;
                            multiline_buffer[multiline_pos] = '\0';
                            yylval.string = strdup(multiline_buffer);
                            multiline_pos = 0;
                            BEGIN(INITIAL);
                            return MULTILINE_CONTENT;
                        } else {
                            in_multiline = 1;
                            BEGIN(MULTILINE);
                            return BACKTICKS;
                        }
                    }

<MULTILINE>"```"    {
                        in_multiline = 0;
                        multiline_buffer[multiline_pos] = '\0';
                        yylval.string = strdup(multiline_buffer);
                        multiline_pos = 0;
                        BEGIN(INITIAL);
                        return BACKTICKS;
                    }

<MULTILINE>.        {
                        if (multiline_pos < sizeof(multiline_buffer) - 1) {
                            multiline_buffer[multiline_pos++] = yytext[0];
                        }
                    }

<MULTILINE>{NEWLINE} {
                        if (multiline_pos < sizeof(multiline_buffer) - 1) {
                            multiline_buffer[multiline_pos++] = '\n';
                        }
                        line_num++;
                        column_num = 1;
                    }

    /* Operators and delimiters */
"!"                 { update_position(yyleng); return BANG; }
"{"                 { update_position(yyleng); return LBRACE; }
"}"                 { update_position(yyleng); return RBRACE; }
"["                 { update_position(yyleng); return LBRACKET; }
"]"                 { update_position(yyleng); return RBRACKET; }
","                 { update_position(yyleng); return COMMA; }
":"                 { update_position(yyleng); return COLON; }

    /* Identifiers and integers */
{IDENTIFIER}        { update_position(yyleng); yylval.string = strdup(yytext); return IDENTIFIER; }
{INTEGER}           { update_position(yyleng); yylval.integer = atoi(yytext); return INTEGER; }

    /* Whitespace and newlines */
{WHITESPACE}        { update_position(yyleng); /* skip */ }
{NEWLINE}           { line_num++; column_num = 1; return NEWLINE; }

    /* String content - everything else */
[^\n\r{}\[\]`!,:#]+ { update_position(yyleng); yylval.string = strdup(yytext); return STRING; }

    /* End of file */
<<EOF>>             { return END_OF_FILE; }

%%

void update_position(int length) {
    column_num += length;
}

