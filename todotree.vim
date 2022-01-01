" Todo tree function
let g:todo_win = 0
let g:todo_path = '-'
let g:todo_file = '-'
let g:orig_win = 0

function TodoTreeEnter()
	" Extract line number
	let line = split(getline(line('.')), ':')[0]

	" Switch to the original window
	call win_gotoid(g:orig_win)

	" Go to the line
	exec ': ' . line
endfunction

function! TodoTree(height)
	if win_gotoid(g:todo_win)
		hide
	else
		" Save current window
		let g:orig_win = win_getid()

		" Get current file
		let g:todo_path = expand("%:p")
		let g:todo_file = expand("%:t")

		" Create a new window at the bottom
		rightb vert new

		" Set editable for now
		set modifiable

		" Set as a temporary buffer
		setlocal buftype=nofile
		setlocal bufhidden=delete
		setlocal noswapfile

		" Cursor options
		set cursorline

		" Bind enter key to go to the TODO line
		map <CR> <ESC> :call TodoTreeEnter()<CR>

lua << EOF
require('todos')

file = vim.g.todo_path

list = read_todos(file)

-- Display the file
vim.api.nvim_buf_set_lines(0, 0, -1, false, {
	vim.g.todo_file .. ' (' .. file .. ')', ''
})

-- Display the TODOs
items = 0
for k, v in sorted_pairs(list) do
	-- Format the line number
	lstr = string.format('%+4s', k)
	str = lstr .. ': ' .. v

	-- Add the line to the buffer
	vim.api.nvim_buf_set_lines(0, -1, -1, false, {str})

	-- Increment the number of items
	items = items + 1
end
EOF
		" Turn off editing
		set noma

		let g:todo_win = win_getid()
	endif
endfunction

" Add the keybinds to the function
" :imap <C-e> <ESC> :call TodoTree(10) <CR>
" :map <C-e> :call TodoTree(10) <CR>
