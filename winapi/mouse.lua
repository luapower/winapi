--proc/mouse: mouse functions
setfenv(1, require'winapi')
require'winapi.winusertypes'

TME_HOVER       = 0x00000001
TME_LEAVE       = 0x00000002
TME_NONCLIENT   = 0x00000010
TME_QUERY       = 0x40000000
TME_CANCEL      = 0x80000000
HOVER_DEFAULT   = 0xFFFFFFFF

ffi.cdef[[
typedef struct tagTRACKMOUSEEVENT {
    DWORD cbSize;
    DWORD dwFlags;
    HWND  hwnd;
    DWORD hover_time;
} TRACKMOUSEEVENT, *LPTRACKMOUSEEVENT;

BOOL TrackMouseEvent(LPTRACKMOUSEEVENT lpEventTrack);

UINT GetDoubleClickTime();
BOOL SetDoubleClickTime(UINT uInterval);

HWND GetCapture(void);
HWND SetCapture(HWND hWnd);
BOOL ReleaseCapture(void);

BOOL DragDetect(HWND hwnd, POINT pt);
]]

TRACKMOUSEEVENT = struct{
	ctype = 'TRACKMOUSEEVENT', size = 'cbSize',
	fields = sfields{
		'flags', 'dwFlags', flags, pass,
	},

}

function TrackMouseEvent(event)
	event = TRACKMOUSEEVENT(event)
	checknz(C.TrackMouseEvent(event))
end

GetDoubleClickTime = C.GetDoubleClickTime

function SetDoubleClickTime(interval)
	checknz(C.SetDoubleClickTime(interval))
end

function GetCapture()
	return ptr(C.GetCapture())
end

function SetCapture(hwnd)
	return ptr(C.SetCapture(hwnd))
end

function ReleaseCapture()
	return checknz(C.ReleaseCapture())
end

function DragDetect(hwnd, point)
	return C.DragDetect(hwnd, POINT(point)) ~= 0
end

