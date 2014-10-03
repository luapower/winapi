
--list modules and their metadata.
--note: you can also use `head -2 -q *.lua | grep '\-\-' | sort`

local lfs = require'lfs'

local function modules()
	local t = {}
	for f in lfs.dir'.' do
		local name = f:match'^([^_][^%.]+)%.lua$'
		if name then
			f = io.open(f, 'r')
			local s0 = f:read'*l'
			local s1 = f:read'*l'
			local s2 = f:read'*l'
			f:close()
			if s0:find'^%s*$' and s1:find'^%-%-[^/]+/' then
				local path, descr = s1:match'^%-%-%s*([^%:]+)%:%s*(.*)'
				local author, license =
					s2:match'^%-%-Written [Bb]y ([^%.]+)%.%s*([^%.]+)%.'
				t[#t+1] = {name = name, path = path, descr = descr,
					author = author, license = license}
			end
		end
	end
	table.sort(t, function(t1, t2) return t1.path < t2.path end)
	return t
end

if not ... then
	local fmt = '%-20s %-26s %s'
	print(string.format(fmt, 'MODULE', 'PATH', 'DESCRIPTION'))
	print(('-'):rep(100))
	for i,t in ipairs(modules()) do
		print(string.format(fmt, t.name, t.path, t.descr))
	end
end

return {
	modules = modules,
}

