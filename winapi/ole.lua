--proc/ole: OLE API: just the necessary minimum to support the dragdrop module.
setfenv(1, require'winapi')

ole32 = ffi.load'ole32'

E_NOINTERFACE = 0x80004002

ffi.cdef[[
typedef WCHAR OLECHAR;
typedef OLECHAR *LPOLESTR;

typedef struct IUnknown IUnknown;
typedef struct IStream IStream;
typedef struct IStorage IStorage;
typedef struct IAdviseSink IAdviseSink;
typedef struct IEnumSTATDATA IEnumSTATDATA;

HRESULT OleInitialize(LPVOID pvReserved);
void    OleUninitialize(void);
]]

function OleInitialize()
	checkz(ole32.OleInitialize(nil))
end

OleInitialize()

OleUninitialize = ole32.OleUninitialize

