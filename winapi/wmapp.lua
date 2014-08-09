--proc/WM_APP code manager.
--WM_APP messages are shared resources. this module keeps track of them
--and allows you to acquire and release them as needed.

WM_APP = 0x8000

local codes = {} --sparse array of codes
local min_code = WM_APP + 1
local max_code = min_code - 1 --start with no slots

function acquire_message_code()
	--scan array for gaps.
	for code = min_code, max_code do
		if not codes[code] then
			codes[code] = true
			return code
		end
	end
	--no gaps, grow array.
	max_code = max_code + 1
	codes[max_code] = true
	return max_code
end

function release_message_code(code)
	assert(code >= min_code and code <= max_code) --not an acquired code
	codes[code] = nil
	--released the last code: shrink array.
	if code == max_code then
		max_code = max_code - 1
	end
end


if not ... then

local code1 = acquire_message_code()
local code2 = acquire_message_code()
local code3 = acquire_message_code()
release_message_code(code2) --make gap
assert(acquire_message_code() == code2) --fill gap
assert(acquire_message_code() == code3 + 1) --grow
release_message_code(code3 + 1) --shrink
assert(acquire_message_code() == code3 + 1) --grow

end
