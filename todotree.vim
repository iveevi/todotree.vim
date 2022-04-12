" Todo tree function
let g:todo_win = 0
let g:todo_path = '-'
let g:todo_file = '-'
let g:orig_win = 0

" The user pressed enter in the todo list
function TodoTreeEnter()
	let line = getline(line('.'))

	" Check if the first 4 characters is "File"
	let four = line[0:3]
	if match(four, 'File') == 0
		echo "File is not supported"
		return
	endif

	" Check if the line is the file line
	" (in which case, we go up a directory)
	if match(line, g:todo_file) == 0
		echo "Requesting upper directory"

		" Temporarily allow modifications
		set modifiable

lua << EOF
		require('todos')

		function is_dir(path)
			if os.execute('test -d ' .. path) == 0 then
				return true
			else
				return false
			end
		end

		file = vim.g.todo_path
		dir = file:match('^(.*)[/\\][^/\\]*$')

		-- List all files in the directory
		files = vim.fn.glob(dir .. '/*')

		file_list = {}
		for w in files:gmatch("%S+") do
			-- Check if the file is a directory
			if is_dir(w) == false then
				table.insert(file_list, w)
			end
		end
		
		-- Display the directory
		vim.api.nvim_buf_set_lines(0, 0, -1, false, {'Directory: ' .. dir, ''})

		-- Max length of file
		local max_len = 0

		for i, v in ipairs(file_list) do
			local file = v:match('^.*[/\\](.*)$')
			if file:len() > max_len then
				max_len = file:len()
			end
		end

		-- Display the number of TODOs in each file
		for i, v in ipairs(file_list) do
			local count = count_todos(v)
			
			-- Get the file name and pad it out
			local file = v:match('^.*[/\\]([^/\\]*)$')
			local pad = (max_len + 3) - file:len()
			local pad_str = ''
			for i = 1, pad do
				pad_str = pad_str .. ' '
			end
			file = file .. pad_str

			str = ''
			if count >= 0 then
				todo = 'TODOs'
				if count == 1 then
					todo = 'TODO'
				end

				str = string.format('%s %d %s', file, count, todo)
			else
				local ext = v:match('^.*%.([^%.]*)$')
				str = string.format('%s File extension *.%s not supported', file, ext)
			end
			
			-- Append to the buffer
			vim.api.nvim_buf_set_lines(0, -1, -1, false, {str})
		end
EOF

		" Revert modifications
		set nomodifiable

		return
	endif

	" Extract line number
	let number = split(line, ':')[0]

	" Switch to the original window
	call win_gotoid(g:orig_win)

	" Go to the line
	exec ': ' . number
endfunction

" TODO: alternative for git projects
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
		show_file_todos(vim.g.todo_path)
EOF

		" Turn off editing
		setlocal nomodifiable

		let g:todo_win = win_getid()
	endif
endfunction
