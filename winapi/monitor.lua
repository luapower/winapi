
--proc/monitor: multi-monitor API
--Written by Cosmin Apreutesei. Public Domain.

setfenv(1, require'winapi')
require'winapi.winuser'

--NOTE: EnumDisplayMonitors() returns the monitors in random order, that can also change between reboots.

ffi.cdef[[
HMONITOR MonitorFromPoint(POINT pt, DWORD dwFlags);
HMONITOR MonitorFromRect(LPCRECT lprc, DWORD dwFlags);
HMONITOR MonitorFromWindow(HWND hwnd, DWORD dwFlags);

typedef struct tagMONITORINFO
{
    DWORD   cbSize;
    RECT    monitor_rect;
    RECT    work_rect;
    DWORD   dwFlags;
} MONITORINFO, *LPMONITORINFO;

typedef struct tagMONITORINFOEXW
{
    MONITORINFO;
    WCHAR       szDevice[32];
} MONITORINFOEXW, *LPMONITORINFOEXW;

BOOL GetMonitorInfoW(HMONITOR hMonitor, LPMONITORINFOEXW lpmi);
typedef BOOL (* MONITORENUMPROC)(HMONITOR, HDC, LPRECT, LPARAM);

BOOL EnumDisplayMonitors(
     HDC hdc,
     LPCRECT lprcClip,
     MONITORENUMPROC lpfnEnum,
     LPARAM dwData);
]]

MONITOR_DEFAULTTONULL     = 0x00000000
MONITOR_DEFAULTTOPRIMARY  = 0x00000001
MONITOR_DEFAULTTONEAREST  = 0x00000002

MONITORINFOF_PRIMARY = 0x00000001 --the only flag in dwFlags

MONITORINFOEX = struct{ctype = 'MONITORINFOEXW', size = 'cbSize',
	fields = sfields{
		'flags', 'dwFlags', flags, pass,
	}
}

function MonitorFromPoint(pt, mflags)
	return ptr(C.MonitorFromPoint(POINT(pt), flags(mflags)))
end

function MonitorFromRect(rect, mflags)
	return ptr(C.MonitorFromRect(RECT(rect), flags(mflags)))
end

function MonitorFromWindow(hwnd, mflags)
	return ptr(C.MonitorFromWindow(hwnd, flags(mflags)))
end

function GetMonitorInfo(hmonitor, info)
	info = MONITORINFOEX(info)
	checknz(C.GetMonitorInfoW(hmonitor, info))
	return info
end

function EnumDisplayMonitors(hdc, cliprect)
	local t = {}
	local cb = ffi.cast('MONITORENUMPROC', function(hmonitor, hdc, vrect)
		table.insert(t, hmonitor)
		return 1 --continue
	end)
	local ret = C.EnumDisplayMonitors(hdc, cliprect, cb, 0)
	cb:free()
	checknz(ret)
	return t
end

--Win8.1 hi-dpi support

MDT_EFFECTIVE_DPI  = 0
MDT_ANGULAR_DPI    = 1
MDT_RAW_DPI        = 2
MDT_DEFAULT        = MDT_EFFECTIVE_DPI

ffi.cdef[[
HRESULT GetDpiForMonitor(
  HMONITOR         hmonitor,
  int              dpiType, // MDT_*
  UINT             *dpiX,
  UINT             *dpiY
); // Win8.1+
]]

local shcore
function GetDPIForMonitor(hmonitor, MDT, dx, dy)
	shcore = shcore or ffi.load'shcore'
	local dx = dx or ffi.new'UINT[1]'
	local dy = dy or ffi.new'UINT[1]'
	checkz(shcore.GetDpiForMonitor(hmonitor, flags(MDT), dx, dy))
	return dx[0], dy[0]
end

if not ... then
	for i,monitor in ipairs(EnumDisplayMonitors()) do
		local info = GetMonitorInfo(monitor)
		print(i, info.monitor_rect, info.work_rect)
	end

	local win8_1 = false --enable this if on Win8.1+
	if win8_1 then
		local mon = assert(MonitorFromPoint())
		print('DPI', GetDPIForMonitor(mon, MDT_EFFECTIVE_DPI))
	end
end

