" Override Vim's experimental astro indent (HTMLIndentExpr-based, mis-indents JSX-like content
" and reindents on `,` and <CR>). Fall back to 'autoindent'; prettier on save handles formatting.
setlocal indentexpr=
setlocal indentkeys&
