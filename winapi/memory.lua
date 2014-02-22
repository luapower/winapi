--proc/memory: memory management
setfenv(1, require'winapi')

-- Global Memory Flags
GMEM_FIXED           = 0x0000
GMEM_MOVEABLE        = 0x0002
GMEM_NOCOMPACT       = 0x0010
GMEM_NODISCARD       = 0x0020
GMEM_ZEROINIT        = 0x0040
GMEM_MODIFY          = 0x0080
GMEM_DISCARDABLE     = 0x0100
GMEM_NOT_BANKED      = 0x1000
GMEM_SHARE           = 0x2000
GMEM_DDESHARE        = 0x2000
GMEM_NOTIFY          = 0x4000
GMEM_LOWER           = GMEM_NOT_BANKED
GMEM_VALID_FLAGS     = 0x7F72
GMEM_INVALID_HANDLE  = 0x8000
GHND                 = bit.bor(GMEM_MOVEABLE, GMEM_ZEROINIT)
GPTR                 = bit.bor(GMEM_FIXED, GMEM_ZEROINIT)
-- Flags returned by GlobalFlags (in addition to GMEM_DISCARDABLE)
GMEM_DISCARDED       = 0x4000
GMEM_LOCKCOUNT       = 0x00FF

ffi.cdef[[
LPVOID GlobalLock(HGLOBAL hMem);
BOOL  GlobalUnlock(HGLOBAL hMem);
SIZE_T GlobalSize(HGLOBAL hMem);
HGLOBAL GlobalAlloc(UINT uFlags, SIZE_T dwBytes);
]]

GlobalLock = ffi.C.GlobalLock

function GlobalUnlock(hmem)
	return callnz2(ffi.C.GlobalUnlock, hmem)
end

function GlobalSize(hmem)
	return checknz(ffi.C.GlobalSize(hmem))
end

function GlobalAlloc(fl, sz)
	return checkh(ffi.C.GlobalAlloc(flags(fl), sz))
end
