" Todo tree function
let g:todo_win = 0
let g:todo_path = '-'
let g:todo_file = '-'
let g:orig_win = 0

" The user pressed enter in the todo list
function TodoTreeEnter()
	" Check if the first 4 characters is "File"
	let four = getline(line('.'))[0:3]
	if match(four, 'File') == 0
		echo "File is not supported"
		return
	endif

	" Extract line number
	let line = split(getline(line('.')), ':')[0]

	" Switch to the original window
	call win_gotoid(g:orig_win)

	" Go to the line
	exec ': ' . line
endfunction

function! TodoTree()
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

		" Resize the window
		vertical resize width

		" Set editable for now
		set modifiable

		" Highlight TODOs in the buffer
		syntax match todotree_todo 'TODO'
		hi def link todotree_todo Todo

		" Highlight numbers in the buffer
		syntax match todotree_number '\d\+'
		hi def link todotree_number Number

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

-- Display the file name
vim.api.nvim_buf_set_lines(0, 0, -1, false, {
	vim.g.todo_file .. ' (' .. file .. ')', ''
})

-- If return is nill, then file extension is not supported
if list == nil then
	-- Add the line to the buffer
	ext = string.match(file, '%.([^%.]+)$')
	msg = 'File extension (*.' .. ext .. ') is not supported'
	vim.api.nvim_buf_set_lines(0, -1, -1, false, {msg})
	return
end

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
		" set noma
		setlocal nomodifiable

		let g:todo_win = win_getid()
	endif
endfunction
