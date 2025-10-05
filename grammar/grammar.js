// UP Grammar for Tree-sitter
// Tree-sitter is used by GitHub, Atom, NeoVim, and many modern editors
// Generate parser with: tree-sitter generate

module.exports = grammar({
  name: 'up',

  extras: $ => [
    /[ \t]/,
  ],

  rules: {
    document: $ => repeat($.statement),

    statement: $ => choice(
      seq(
        $.key_with_type,
        optional($.value),
        $.newline
      ),
      $.comment,
      $.newline
    ),

    comment: $ => seq(
      '#',
      optional($.rest_of_line),
      $.newline
    ),

    key_with_type: $ => seq(
      $.identifier,
      optional($.type_annotation)
    ),

    type_annotation: $ => choice(
      seq('!', $.identifier),
      seq('!', $.integer)
    ),

    value: $ => choice(
      $.scalar,
      $.multiline,
      $.block,
      $.list,
      $.table
    ),

    scalar: $ => $.string,

    multiline: $ => seq(
      '```',
      optional($.language_hint),
      $.newline,
      $.multiline_content,
      '```',
      optional($.newline)
    ),

    language_hint: $ => $.identifier,

    multiline_content: $ => /[^`]*(?:`[^`][^`]*|``[^`][^`]*)*/,

    block: $ => seq(
      '{',
      $.newline,
      repeat($.statement),
      '}'
    ),

    list: $ => choice(
      seq('[', $.newline, repeat($.list_item), ']'),
      seq('[', optional($.inline_list), ']')
    ),

    list_item: $ => seq(
      choice(
        $.scalar,
        $.block,
        seq('[', optional($.inline_list), ']')
      ),
      $.newline
    ),

    inline_list: $ => seq(
      $.inline_item,
      repeat(seq(',', $.inline_item))
    ),

    inline_item: $ => $.scalar,

    table: $ => seq(
      '{',
      $.newline,
      $.table_columns,
      $.table_rows,
      '}'
    ),

    table_columns: $ => seq(
      'columns',
      '[',
      optional($.inline_list),
      ']',
      $.newline
    ),

    table_rows: $ => seq(
      'rows',
      '{',
      $.newline,
      repeat(seq('[', optional($.inline_list), ']', $.newline)),
      '}'
    ),

    identifier: $ => /[A-Za-z_][A-Za-z0-9_-]*/,

    integer: $ => /[0-9]+/,

    string: $ => /[^\r\n{}\[\]`!,:#]+/,

    rest_of_line: $ => /[^\r\n]*/,

    newline: $ => /\r?\n/,
  }
});

