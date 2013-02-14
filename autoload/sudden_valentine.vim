scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim


function! s:heart_plus(x)
	let b = 0.8
	return a:x >= 0
\		? sqrt(1 - a:x * a:x) + b * sqrt(a:x)
\		: sqrt(1 - a:x * a:x) - b * sqrt(-a:x)
endfunction

function! s:heart_minus(x)
	let b = 0.8
	return a:x >= 0
\		? -sqrt(1 - a:x * a:x) + b * sqrt(a:x)
\		: -sqrt(1 - a:x * a:x) - b * sqrt(-a:x)
endfunction


function! s:heart_pos()
	let max = 1000
	let pos = []

	for i in range(max)
		let x = i / (max * 1.0)
		let y = s:heart_plus(x)
		call add(pos, [ x, y])
		call add(pos, [-x, y])

		let x = (max - i) / (max * 1.0)
		let y = s:heart_minus(x)
		call add(pos, [ x, y])
		call add(pos, [-x, y])
	endfor
	
	return pos
endfunction


function! s:get(data, x, y, default)
	return get(get(a:data, a:y, []), a:x, a:default)
endfunction


" function! s:fill(data, mark, fill, x, y)
" 	let self = s:get(a:data, a:x, a:y, a:mark)
" 	if self ==# a:mark || self ==# a:fill
" 		return a:data
" 	else
" 		let result = a:data
" 		let result[a:y][a:x] = a:fill
" 	endif
" 	let result = s:fill(result, a:mark, a:fill, a:x-1, a:y+1)
" 	let result = s:fill(result, a:mark, a:fill, a:x  , a:y+1)
" 	let result = s:fill(result, a:mark, a:fill, a:x+1, a:y+1)
" 	let result = s:fill(result, a:mark, a:fill, a:x+1, a:y)
" 	let result = s:fill(result, a:mark, a:fill, a:x+1, a:y-1)
" 	let result = s:fill(result, a:mark, a:fill, a:x  , a:y-1)
" 	let result = s:fill(result, a:mark, a:fill, a:x-1, a:y-1)
" 	let result = s:fill(result, a:mark, a:fill, a:x-1, a:y)
" 	return result
" endfunction


function! s:marked(data, mark, fill, x, y)
	let item = s:get(a:data, a:x, a:y, a:mark)
	return item ==# a:mark || item ==# a:fill
endfunction


function! s:fill(data, mark, fill, x, y)
	if s:marked(a:data, a:mark, a:fill, a:x, a:y)
		return a:data
	else
		let result = a:data
		let result[a:y][a:x] = a:fill
	endif

	let i = 1
	while !s:marked(a:data, a:mark, a:fill, a:x+i, a:y)
		let result[a:y][a:x+i] = a:fill
		let i += 1
	endwhile

	let i = -1
	while !s:marked(a:data, a:mark, a:fill, a:x+i, a:y)
		let result[a:y][a:x+i] = a:fill
		let i -= 1
	endwhile

	let i = 1
	while !s:marked(a:data, a:mark, a:fill, a:x, a:y+i)
		let result[a:y+i][a:x] = a:fill
		let i += 1
	endwhile

	let i = -1
	while !s:marked(a:data, a:mark, a:fill, a:x, a:y+i)
		let result[a:y+i][a:x] = a:fill
		let i -= 1
	endwhile

	let result = s:fill(result, a:mark, a:fill, a:x-1, a:y+1)
	let result = s:fill(result, a:mark, a:fill, a:x+1, a:y+1)
	let result = s:fill(result, a:mark, a:fill, a:x+1, a:y-1)
	let result = s:fill(result, a:mark, a:fill, a:x-1, a:y-1)
	return result
endfunction


function! sudden_valentine#heart(width, height, mark, ...)
	let width = a:width
	let height = a:height

	let fill = get(a:, 1, "")

	let pos = s:heart_pos()
	call map(pos, "[ float2nr(v:val[0] * width)+width, float2nr(v:val[1] * - height + 1.5 * height) ]")

	let space = strlen(a:mark) > 1 ? '　' : ' '
	let lines = map(range(float2nr(2.5 * height)+2), "map(range(width * 2 + 4), 'space')")

	for [x, y] in pos
		let lines[y][x] = a:mark
	endfor

	if !empty(fill)
		let fill = strwidth(fill) <= 1 && strwidth(a:mark) > 1 ? fill.fill : fill
		let lines = s:fill(lines, a:mark, fill, len(get(lines, len(lines)/2))/2, len(lines)/2)
	endif

	return map(lines, "substitute(substitute(join(v:val, ''), space.'*$', '', 'g'), '　', '  ', 'g')")
endfunction


" function! sudden_valentine#fill(heart, mark, fill)
" 	let lines = map(copy(a:heart), "split(v:val, '\\zs')")
" 	let lines = s:fill(lines, a:mark, a:fill, len(get(lines, len(lines)/2))/2, len(lines)/2)
" 	return map(lines, "join(v:val, '')")
" endfunction


function! s:insert_text(base, text)
	let result  = split(a:base, '\zs')
	let center = strchars(a:base)/2
	let start = center - strwidth(a:text)/2
" 	let start = center - float2nr(strwidth(a:text) / 2.0-0.5)
	for c in split(a:text, '\zs')
		let result[start] = c
		if strwidth(c) > 1
" 		if strwidth(c) > strwidth(get(result,start+1,"   "))
			unlet result[start+1]
		endif
		let start += 1
	endfor
	return join(result, "")
endfunction


function! sudden_valentine#in_message(heart, message)
	if strwidth(a:message) < 13
		let heart = a:heart
		let height = float2nr(g:sudden_valentine_size_height * 3)
		let heart[height] = s:insert_text(heart[height], a:message)
	else
		let level = strwidth(a:message) / 13.0
		let heart = a:heart
		let center = float2nr(level * 3)
		let heart[center] = s:insert_text(heart[center], a:message)
	endif
	return heart
endfunction


function! sudden_valentine#make(message, ...)
	let mark = get(a:, 1, g:sudden_valentine_mark)
	let fill = get(a:, 2, g:sudden_valentine_fill)
	let width = strwidth(mark) == 1 ? 12 : 7
	let height = 4
	let level = strwidth(a:message) < 13 ? 1 : (strwidth(a:message) / 13.0)
	let heart = sudden_valentine#heart(float2nr(width * level * g:sudden_valentine_size_width), float2nr(height * level * g:sudden_valentine_size_height), mark, fill)

" 	if !empty(fill)
" 		let heart = sudden_valentine#fill(heart, mark, fill)
" 	endif

	let heart = sudden_valentine#in_message(heart, a:message)
	return heart
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo

