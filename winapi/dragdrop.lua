--proc/ole/dragdrop: drag & drop OLE API
setfenv(1, require'winapi')
require'winapi.ole'

DRAGDROP_S_FIRST               = 0x00040100
DRAGDROP_S_LAST                = 0x0004010F
DRAGDROP_S_DROP                = 0x00040100
DRAGDROP_S_CANCEL              = 0x00040101
DRAGDROP_S_USEDEFAULTCURSORS   = 0x00040102

DROPEFFECT_NONE   = 0
DROPEFFECT_COPY   = 1
DROPEFFECT_MOVE   = 2
DROPEFFECT_LINK   = 4
DROPEFFECT_SCROLL = 0x80000000

DATADIR_GET = 1
DATADIR_SET = 2

TYMED_HGLOBAL   = 1
TYMED_FILE      = 2
TYMED_ISTREAM   = 4
TYMED_ISTORAGE  = 8
TYMED_GDI       = 16
TYMED_MFPICT    = 32
TYMED_ENHMF     = 64
TYMED_NULL      = 0

ffi.cdef([[
typedef struct IEnumFORMATETC IEnumFORMATETC;
typedef struct IDropTarget IDropTarget;
typedef struct IDataObject IDataObject;
typedef struct IDropSource IDropSource;

typedef IDropTarget *LPDROPTARGET;
typedef IDataObject *LPDATAOBJECT;
typedef IDropSource *LPDROPSOURCE;

typedef struct IDropTargetVtbl {

	HRESULT ( __stdcall *QueryInterface )(
		IDropTarget * This,
		REFIID riid,
		void **ppvObject);

	ULONG ( __stdcall *AddRef )(
		IDropTarget * This);

	ULONG ( __stdcall *Release )(
		IDropTarget * This);

	HRESULT ( __stdcall *DragEnter )(
		IDropTarget * This,
		IDataObject *pDataObj,
		DWORD grfKeyState,
		]]..(ffi.abi'32bit' and 'LONG x, LONG y' or 'POINTL pt')..[[,
		DWORD *pdwEffect);

	HRESULT ( __stdcall *DragOver )(
		IDropTarget * This,
		DWORD grfKeyState,
		]]..(ffi.abi'32bit' and 'LONG x, LONG y' or 'POINTL pt')..[[,
		DWORD *pdwEffect);

	HRESULT ( __stdcall *DragLeave )(
		IDropTarget * This);

	HRESULT ( __stdcall *Drop )(
		IDropTarget * This,
		IDataObject *pDataObj,
		DWORD grfKeyState,
		]]..(ffi.abi'32bit' and 'LONG x, LONG y' or 'POINTL pt')..[[,
		DWORD *pdwEffect);

} IDropTargetVtbl;

struct IDropTarget {
	struct IDropTargetVtbl *lpVtbl;
	int refcount;
};

typedef WORD CLIPFORMAT;

typedef struct tagDVTARGETDEVICE {
	DWORD tdSize;
	WORD tdDriverNameOffset;
	WORD tdDeviceNameOffset;
	WORD tdPortNameOffset;
	WORD tdExtDevmodeOffset;
	BYTE tdData[1];
} DVTARGETDEVICE;

typedef struct tagFORMATETC {
	CLIPFORMAT cfFormat;
	DVTARGETDEVICE *ptd;
	DWORD dwAspect;
	LONG lindex;
	DWORD tymed;
} FORMATETC;

typedef struct tagFORMATETC *LPFORMATETC;

typedef struct IEnumFORMATETCVtbl {

  HRESULT ( __stdcall *QueryInterface )(
		IEnumFORMATETC * This,
		REFIID riid,
		void **ppvObject);

  ULONG ( __stdcall *AddRef )(
		IEnumFORMATETC * This);

  ULONG ( __stdcall *Release )(
		IEnumFORMATETC * This);

  HRESULT ( __stdcall *Next )(
		IEnumFORMATETC * This,
		ULONG celt,
		FORMATETC *rgelt,
		ULONG *pceltFetched);

  HRESULT ( __stdcall *Skip )(
		IEnumFORMATETC * This,
		ULONG celt);

  HRESULT ( __stdcall *Reset )(
		IEnumFORMATETC * This);

  HRESULT ( __stdcall *Clone )(
		IEnumFORMATETC * This,
		IEnumFORMATETC **ppenum);

} IEnumFORMATETCVtbl;

struct IEnumFORMATETC {
	struct IEnumFORMATETCVtbl *lpVtbl;
};

typedef void *HMETAFILEPICT;

typedef struct tagSTGMEDIUM {
	DWORD tymed;
	union {
		HBITMAP hBitmap;
		HMETAFILEPICT hMetaFilePict;
		HENHMETAFILE hEnhMetaFile;
		HGLOBAL hGlobal;
		LPOLESTR lpszFileName;
		IStream *pstm;
		IStorage *pstg;
	};
	IUnknown *pUnkForRelease;
} uSTGMEDIUM;

typedef uSTGMEDIUM STGMEDIUM;
typedef STGMEDIUM* LPSTGMEDIUM;

typedef struct IDataObjectVtbl {

	HRESULT ( __stdcall *QueryInterface )(
		IDataObject * This,
		REFIID riid,
		void **ppvObject);

	ULONG ( __stdcall *AddRef )(
		IDataObject * This);

	ULONG ( __stdcall *Release )(
		IDataObject * This);

	HRESULT ( __stdcall *GetData )(
		IDataObject * This,
		FORMATETC *pformatetcIn,
		STGMEDIUM *pmedium);

	HRESULT ( __stdcall *GetDataHere )(
		IDataObject * This,
		FORMATETC *pformatetc,
		STGMEDIUM *pmedium);

	HRESULT ( __stdcall *QueryGetData )(
		IDataObject * This,
		FORMATETC *pformatetc);

	HRESULT ( __stdcall *GetCanonicalFormatEtc )(
		IDataObject * This,
		FORMATETC *pformatectIn,
		FORMATETC *pformatetcOut);

	HRESULT ( __stdcall *SetData )(
		IDataObject * This,
		FORMATETC *pformatetc,
		STGMEDIUM *pmedium,
		BOOL fRelease);

	HRESULT ( __stdcall *EnumFormatEtc )(
		IDataObject * This,
		DWORD dwDirection,
		IEnumFORMATETC **ppenumFormatEtc);

	HRESULT ( __stdcall *DAdvise )(
		IDataObject * This,
		FORMATETC *pformatetc,
		DWORD advf,
		IAdviseSink *pAdvSink,
		DWORD *pdwConnection);

	HRESULT ( __stdcall *DUnadvise )(
		IDataObject * This,
		DWORD dwConnection);

	HRESULT ( __stdcall *EnumDAdvise )(
		IDataObject * This,
		IEnumSTATDATA **ppenumAdvise);

} IDataObjectVtbl;

struct IDataObject {
	struct IDataObjectVtbl *lpVtbl;
};

typedef struct IDropSourceVtbl {

	HRESULT ( __stdcall *QueryInterface )(
		IDropSource * This,
		REFIID riid,
		void **ppvObject);

	ULONG ( __stdcall *AddRef )(
		IDropSource * This);

	ULONG ( __stdcall *Release )(
		IDropSource * This);

	HRESULT ( __stdcall *QueryContinueDrag )(
		IDropSource * This,
		BOOL fEscapePressed,
		DWORD grfKeyState);

	HRESULT ( __stdcall *GiveFeedback )(
		IDropSource * This,
		DWORD dwEffect);

} IDropSourceVtbl;

struct IDropSource {
	struct IDropSourceVtbl *lpVtbl;
};

HRESULT RegisterDragDrop(HWND hwnd, LPDROPTARGET pDropTarget);
HRESULT RevokeDragDrop(HWND hwnd);
HRESULT DoDragDrop(LPDATAOBJECT pDataObj, LPDROPSOURCE pDropSource,
            DWORD dwOKEffects, LPDWORD pdwEffect);

void ReleaseStgMedium(LPSTGMEDIUM);

]])

function RegisterDragDrop(...) return checkz(ole32.RegisterDragDrop(...)) end
function RevokeDragDrop(...) return checkz(ole32.RevokeDragDrop(...)) end
function DoDragDrop(...) return checkz(ole32.DoDragDrop(...)) end

ReleaseStgMedium = ole32.ReleaseStgMedium
