scriptencoding utf-8
if exists('g:loaded_sudden_valentine')
  finish
endif
let g:loaded_sudden_valentine = 1

let s:save_cpo = &cpo
set cpo&vim

let g:sudden_valentine_mark = get(g:, "sudden_valentine_mark", "*")
let g:sudden_valentine_fill = get(g:, "sudden_valentine_fill", "")

let g:sudden_valentine_size_width  = get(g:, "sudden_valentine_size_width", 1.0)
let g:sudden_valentine_size_height = get(g:, "sudden_valentine_size_height", 1.0)


command! -nargs=+
\	SuddenValentine
\	call append(line("."), sudden_valentine#make(<q-args>))


let &cpo = s:save_cpo
unlet s:save_cpo
