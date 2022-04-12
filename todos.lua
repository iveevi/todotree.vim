-- Each language extension and the comment prefixes it allows
exts = {
	c = {'//', '/*', '*/'},
	cpp = {'//', '/*', '*/'},
	hpp = {'//', '/*', '*/'},
	cs = {'//', '/*', '*/'},
	css = {'//', '/*', '*/'},
	htm = {'//', '<!--', '-->'},
	html = {'//', '<!--', '-->'},
	html = {'//', '<!--', '-->'},
	ini = {'#', '//', '/*', '*/'},
	js = {'//', '/*', '*/'},
	json = {'//', '/*', '*/'},
	jsx = {'//', '/*', '*/'},
	less = {'//', '/*', '*/'},
	lua = {'--'},
	php = {'//', '/*', '*/'},
	pl = {'#', '//', '/*', '*/'},
	properties = {'#', '//', '/*', '*/'},
	py = {'#', '//', '#', '/*', '*/'},
	rb = {'#', '//', '/*', '*/'},
	sass = {'//', '/*', '*/'},
	scss = {'//', '/*', '*/'},
	sh = {'#', '//', '/*', '*/'},
	shtml = {'//', '<!--', '-->'},
	sql = {'--'},
	styl = {'//', '/*', '*/'},
	ts = {'//', '/*', '*/'},
	tsx = {'//', '/*', '*/'},
	vb = {'//', '/*', '*/'},
	vbs = {'//', '/*', '*/'},
	vbscript = {'//', '/*', '*/'},
	vim = {"\""},
	xhtml = {'//', '<!--', '-->'},
	xml = {'//', '<!--', '-->'},
	xml = {'//', '<!--', '-->'},
	xquery = {'//', '/*', '*/'},
	xsd = {'//', '<!--', '-->'},
	xsl = {'//', '<!--', '-->'},
	xslt = {'//', '<!--', '-->'},
	yaml = {'#', '//', '/*', '*/'},
	yml = {'#', '//', '/*', '*/'},
}

function sorted_pairs(t, order)
	-- collect the keys
	local keys = {}
	for k in pairs(t) do keys[#keys+1] = k end

	-- if order function given, sort by it by passing the table and keys a, b,
	-- otherwise just sort the keys
	if order then
		table.sort(keys, function(a,b) return order(t, a, b) end)
	else
		table.sort(keys)
	end

	-- return the iterator function
	local i = 0

	return function()
		i = i + 1
		if keys[i] then
			return keys[i], t[keys[i]]
		end
	end
end


function read_todos(file)
	-- Check that the file extension is supported
	local ext = string.match(file, "%.([^%.]+)$")
	if not exts[ext] then
		print("Unsupported file extension: " .. ext)
		return
	end

	-- Read from file
	local content = io.lines(file)

	-- Line number
	ln = 1

	-- Dictionary of all TODOs and their lines
	dict = {}

	-- Get file extension
	ext = string.match(file, "%.(%w+)$")

	-- List of comment prefixes
	local prefixes = exts[ext]

	for line in content do
		-- Remove leading and trailing whitespace
		line = line:gsub('^%s*(.-)%s*$', '%1')

		-- Trigger condition if line is comment and has 'TODO'
		if string.find(line, 'TODO') then
			-- Check that the line is a comment
			comment = false

			for _, prefix in pairs(prefixes) do
				if line:sub(1, prefix:len()) == prefix then
					comment = true
					break
				end
			end

			-- Jump out
			if not comment then
				goto continue
			end

			-- Get index of 'TODO'
			local index = string.find(line, 'TODO')

			-- Start the line at that index
			line = line:sub(index)

			-- Add to dictionary
			dict[ln] = line
		end

		-- Exit from condition
		::continue::

		ln = ln + 1
	end

	return dict
end

function count_todos(file)
	-- Check that the file extension is supported
	local ext = string.match(file, "%.([^%.]+)$")
	if not exts[ext] then
		return -1
	end

	-- Read from file
	local content = io.lines(file)

	-- Line number
	local ln = 1

	-- Count of TODOs
	count = 0

	-- Get file extension
	ext = string.match(file, "%.(%w+)$")

	-- List of comment prefixes
	local prefixes = exts[ext]

	for line in content do
		-- Remove leading and trailing whitespace
		line = line:gsub('^%s*(.-)%s*$', '%1')

		-- Trigger condition if line is comment and has 'TODO'
		if string.find(line, 'TODO') then
			-- Check that the line is a comment
			comment = false

			for _, prefix in pairs(prefixes) do
				if line:sub(1, prefix:len()) == prefix then
					comment = true
					break
				end
			end

			-- Jump out
			if not comment then
				goto continue
			end

			-- Get index of 'TODO'
			local index = string.find(line, 'TODO')

			-- Start the line at that index
			line = line:sub(index)
			count = count + 1
		end

		-- Exit from condition
		::continue::

		ln = ln + 1
	end

	return count
end

function show_file_todos(file)
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

	count = 0
	for k in pairs(list) do
		count = count + 1
	end

	-- Display the number of TODOs
	vim.api.nvim_buf_set_lines(0, -1, -1, false, {
		'TODOs: ' .. count, ''
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
end
