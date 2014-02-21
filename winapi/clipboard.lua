--clipboard API
setfenv(1, require'winapi')
require'winapi.winusertypes'

-- Predefined Clipboard Formats
CF_TEXT              = 1
CF_BITMAP            = 2
CF_METAFILEPICT      = 3
CF_SYLK              = 4
CF_DIF               = 5
CF_TIFF              = 6
CF_OEMTEXT           = 7
CF_DIB               = 8
CF_PALETTE           = 9
CF_PENDATA           = 10
CF_RIFF              = 11
CF_WAVE              = 12
CF_UNICODETEXT       = 13
CF_ENHMETAFILE       = 14
CF_HDROP             = 15
CF_LOCALE            = 16
CF_DIBV5             = 17
CF_OWNERDISPLAY      = 0x0080
CF_DSPTEXT           = 0x0081
CF_DSPBITMAP         = 0x0082
CF_DSPMETAFILEPICT   = 0x0083
CF_DSPENHMETAFILE    = 0x008E
-- "Private" formats don't get GlobalFree()'d
CF_PRIVATEFIRST      = 0x0200
CF_PRIVATELAST       = 0x02FF
-- "GDIOBJ" formats do get DeleteObject()'d
CF_GDIOBJFIRST       = 0x0300
CF_GDIOBJLAST        = 0x03FF

ffi.cdef[[
BOOL OpenClipboard(HWND hWndNewOwner);
BOOL CloseClipboard(void);
BOOL IsClipboardFormatAvailable(UINT format);
HANDLE GetClipboardData(UINT uFormat);
BOOL EmptyClipboard(void);
HANDLE SetClipboardData(UINT uFormat, HANDLE hMem);
]]

function OpenClipboard(hwnd)
	return checknz(ffi.C.OpenClipboard(hwnd))
end

function CloseClipboard(hwnd)
	return checknz(ffi.C.CloseClipboard())
end

function IsClipboardFormatAvailable(format)
	return ffi.C.IsClipboardFormatAvailable(flags(format)) ~= 0
end

function GetClipboardData(uFormat)
	return checkh(ffi.C.GetClipboardData(flags(uFormat)))
end

function EmptyClipboard()
	checknz(ffi.C.EmptyClipboard())
end

function SetClipboardData(format, hmem)
	return checkh(ffi.C.SetClipboardData(flags(format), hmem))
end

--hi-level API

function GetClipboardText()
	if not IsClipboardFormatAvailable(CF_TEXT) then
		return
	end
	require'winapi.memory'
	OpenClipboard()
	return glue.fcall(function()
		local h = GetClipboardData(CF_TEXT)
		local buf = GlobalLock(h)
		return glue.fcall(function()
			local sz = GlobalSize(h)
			return ffi.string(buf, sz - 1)
		end, function() GlobalUnlock(h) end)
	end, CloseClipboard)
end

function SetClipboardText(s)
	require'winapi.memory'
	OpenClipboard()
	glue.fcall(function()
		EmptyClipboard()
		local h = GlobalAlloc(GMEM_MOVEABLE, #s + 1) --windows frees this
		local buf = GlobalLock(h)
		ffi.copy(buf, s)
		GlobalUnlock(h)
		SetClipboardData(CF_TEXT, h)
	end, CloseClipboard)
end


if not ... then
	SetClipboardText('hello from the clipboard!')
	print(GetClipboardText())
end

