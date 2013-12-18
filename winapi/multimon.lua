--proc/multimon: multi-monitor API
setfenv(1, require'winapi')
require'winapi.winusertypes'

ffi.cdef[[
HMONITOR MonitorFromPoint(POINT pt, DWORD dwFlags);
HMONITOR MonitorFromRect(LPCRECT lprc, DWORD dwFlags);
HMONITOR MonitorFromWindow(HWND hwnd, DWORD dwFlags);

typedef struct tagMONITORINFO
{
    DWORD   cbSize;
    RECT    rcMonitor;
    RECT    rcWork;
    DWORD   dwFlags;
} MONITORINFO, *LPMONITORINFO;

typedef struct tagMONITORINFOEXW
{
    MONITORINFO;
    WCHAR       szDevice[32];
} MONITORINFOEXW, *LPMONITORINFOEXW;

BOOL GetMonitorInfoW(HMONITOR hMonitor, LPMONITORINFO lpmi);
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

MONITORINFO = struct{ctype = 'MONITORINFO', size = 'cbSize',
	fields = sfields{
		'flags', 'dwFlags', flags, pass,
	}
}

MonitorFromPoint = C.MonitorFromPoint
MonitorFromRect = C.MonitorFromRect
MonitorFromWindow = C.MonitorFromWindow

function GetMonitorInfo(mon, info)
	info = MONITORINFO(info)
	checknz(C.GetMonitorInfoW(mon, info))
	return info
end

EnumDisplayMonitors = C.EnumDisplayMonitors

