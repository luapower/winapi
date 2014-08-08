--proc/shellapi: shell API.
setfenv(1, require'winapi')
require'winapi.winuser'
require'winapi.winnt'

shell32 = ffi.load'Shell32'

--file info

ffi.cdef[[
typedef struct _SHFILEINFOW
{
        HICON       hIcon;
        int         iIcon;
        DWORD       dwAttributes;
        WCHAR       szDisplayName[260];
        WCHAR       szTypeName[80];
} SHFILEINFOW;

extern  DWORD_PTR  SHGetFileInfoW(LPCWSTR pszPath, DWORD dwFileAttributes,  SHFILEINFOW *psfi,
    UINT cbFileInfo, UINT uFlags);
]]

SHFILEINFO = struct{
	ctype = 'SHFILEINFOW',
}

SHGFI_ICON              = 0x000000100     -- get icon
SHGFI_DISPLAYNAME       = 0x000000200     -- get display name
SHGFI_TYPENAME          = 0x000000400     -- get type name
SHGFI_ATTRIBUTES        = 0x000000800     -- get attributes
SHGFI_ICONLOCATION      = 0x000001000     -- get icon location
SHGFI_EXETYPE           = 0x000002000     -- return exe type
SHGFI_SYSICONINDEX      = 0x000004000     -- get system icon index
SHGFI_LINKOVERLAY       = 0x000008000     -- put a link overlay on icon
SHGFI_SELECTED          = 0x000010000     -- show icon in selected state
SHGFI_ATTR_SPECIFIED    = 0x000020000     -- get only specified attributes
SHGFI_LARGEICON         = 0x000000000     -- get large icon
SHGFI_SMALLICON         = 0x000000001     -- get small icon
SHGFI_OPENICON          = 0x000000002     -- get open icon
SHGFI_SHELLICONSIZE     = 0x000000004     -- get shell size icon
SHGFI_PIDL              = 0x000000008     -- pszPath is a pidl
SHGFI_USEFILEATTRIBUTES = 0x000000010     -- use passed dwFileAttribute
SHGFI_ADDOVERLAYS       = 0x000000020     -- apply the appropriate overlays
SHGFI_OVERLAYINDEX      = 0x000000040     -- Get the index of the overlay

function SHGetFileInfo(path, fileattr, SHGFI, fileinfo)
	fileinfo = SHFILEINFO(fileinfo)
	return shell32.SHGetFileInfoW(wcs(path), flags(fileattr), fileinfo,
											ffi.sizeof'SHFILEINFOW', flags(SHGFI)), fileinfo
end

--notify icons (WinXP/Win2K+)

ffi.cdef[[
typedef struct _NOTIFYICONDATAW {
    DWORD cbSize;
    HWND hWnd;
    UINT uID;
    UINT uFlags;
    UINT uCallbackMessage;
    HICON hIcon;
    WCHAR  szTip[128];  --Win2K+
    DWORD dwState;
    DWORD dwStateMask;
    WCHAR  szInfo[256];
    union {
        UINT  uTimeout;
        UINT  uVersion;  -- used with NIM_SETVERSION, values 0, 3 and 4
    } DUMMYUNIONNAME;
    WCHAR  szInfoTitle[64];
    DWORD dwInfoFlags;
    GUID guidItem;       --WinXP+
    HICON hBalloonIcon;  --Vista+
} NOTIFYICONDATAW, *PNOTIFYICONDATAW;

typedef struct _NOTIFYICONIDENTIFIER {
    DWORD cbSize;
    HWND hWnd;
    UINT uID;
    GUID guidItem;
} NOTIFYICONIDENTIFIER, *PNOTIFYICONIDENTIFIER;

BOOL Shell_NotifyIconW(DWORD dwMessage, PNOTIFYICONDATAW lpData);
void Shell_NotifyIconGetRect(const NOTIFYICONIDENTIFIER* identifier, RECT* iconLocation);
]]

NIN_SELECT          = (WM_USER + 0)
NINF_KEY            = 0x1
NIN_KEYSELECT       = bit.bor(NIN_SELECT, NINF_KEY)

--XP+
NIN_BALLOONSHOW         = (WM_USER + 2)
NIN_BALLOONHIDE         = (WM_USER + 3)
NIN_BALLOONTIMEOUT      = (WM_USER + 4)
NIN_BALLOONUSERCLICK    = (WM_USER + 5)

--Vista+
NIN_POPUPOPEN           = (WM_USER + 6)
NIN_POPUPCLOSE          = (WM_USER + 7)

NIM_ADD         = 0x00000000
NIM_MODIFY      = 0x00000001
NIM_DELETE      = 0x00000002
NIM_SETFOCUS    = 0x00000003
NIM_SETVERSION  = 0x00000004

-- set NOTIFYICONDATA.uVersion with 0, 3 or 4
-- please read the documentation on the behavior difference that the different versions imply
NOTIFYICON_VERSION      = 3
NOTIFYICON_VERSION_4    = 4 --Vista+

NIF_MESSAGE     = 0x00000001
NIF_ICON        = 0x00000002
NIF_TIP         = 0x00000004
NIF_STATE       = 0x00000008
NIF_INFO        = 0x00000010
--Vista+
NIF_GUID        = 0x00000020
NIF_REALTIME    = 0x00000040
NIF_SHOWTIP     = 0x00000080
NIS_HIDDEN      = 0x00000001
NIS_SHAREDICON  = 0x00000002

-- says this is the source of a shared icon

-- Notify Icon Infotip flags
NIIF_NONE       = 0x00000000
-- icon flags are mutually exclusive
-- and take only the lowest 2 bits
NIIF_INFO       = 0x00000001
NIIF_WARNING    = 0x00000002
NIIF_ERROR      = 0x00000003
--XP SP2+ / WS03 SP1+
NIIF_USER       = 0x00000004
NIIF_ICON_MASK  = 0x0000000F
NIIF_NOSOUND    = 0x00000010
--Vista+
NIIF_LARGE_ICON = 0x00000020
--Win7+
NIIF_RESPECT_QUIET_TIME = 0x00000080

PNOTIFYICONDATA = struct{
	ctype = 'PNOTIFYICONDATA',
}

function Shell_NotifyIcon(msg, data)
	data = PNOTIFYICONDATA(data)
	checknz(shell32.Shell_NotifyIconW(msg, data)
end

