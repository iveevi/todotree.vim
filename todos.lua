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
