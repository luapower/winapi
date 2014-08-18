--proc/winbase: winbase.h. incomplete :)
setfenv(1, require'winapi')

ffi.cdef[[
DWORD GetCurrentThreadId(void);
]]

GetCurrentThreadId = C.GetCurrentThreadId
