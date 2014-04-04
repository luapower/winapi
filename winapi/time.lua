--proc/time: time functions
setfenv(1, require'winapi')

ffi.cdef[[
DWORD GetTickCount();
ULONGLONG GetTickCount64();
]]

GetTickCount = C.GetTickCount --NOTE: wraps around after 49 days of system runtime

function GetTickCount64()
	return C.GetTickCount64() --Vista+
end
