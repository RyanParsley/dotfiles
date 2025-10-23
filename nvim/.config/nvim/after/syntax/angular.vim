" Additional Angular-specific syntax highlighting
" Control flow blocks
syntax match angularControlFlow "@\(if\|else\|for\|switch\|case\|default\|defer\|placeholder\|loading\|error\)" contained
highlight link angularControlFlow Conditional

" Property bindings
syntax match angularBinding "\[\w\+\]" contained
highlight link angularBinding Special

" Event bindings
syntax match angularEvent "(\w\+)" contained
highlight link angularEvent Function

" Two-way bindings
syntax match angularTwoWay "\[(\w\+)\]" contained
highlight link angularTwoWay Special

" Template reference variables
syntax match angularTemplateRef "#\w\+" contained
highlight link angularTemplateRef Identifier

" Structural directives
syntax match angularDirective "\*\w\+" contained
highlight link angularDirective PreProc
