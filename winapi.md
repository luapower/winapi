---
project: winapi
tagline: windows & widgets
platforms: mingw32
---

## Scope

Windows, common controls and dialogs, message loop, support APIs, OpenGL and cairo integration.

## Features

  * accepts (and returns) utf-8 encoded Lua strings throughout (accepts wide char buffers too)
  * winapi calls are error-checked so you don't have to
  * objects are automatically tied to the garbage collector when not owned by other winapi objects
  * flags can be passed as `'FLAG1 | FLAG2'`
  * counting from 1 everywhere
  * object system with virtual properties (eg. `window.w = 500` changes a window's width)
  * Delphi-style anchor-based layout model for all controls
  * [binding infrastructure][winapi_binding] tailored to winapi conventions, facilitating the binding of more APIs
  * cairo, opengl and openvg panel widgets

## Modules

--------------------------- --------------------------------------
__binding infrastructure__
[winapi.init]               load the namespace + ffi tools + wintypes
[winapi.namespace]          the namespace table for the entire API
[winapi.ffi]                load the ffi and bit libs and check the platform
[winapi.util]               wrapping and conversion functions
[winapi.types]              ctype wrapper/memoizer
[winapi.struct]             struct ctype wrapper
[winapi.arrays]             variable length array (VLA) wrapper/memoizer
[winapi.bitmask]            bitmask encoding and decoding
[winapi.wcs]                utf8 to wide character string and back
[winapi.debug]              strict mode and some debug tools. entirely optional module
__types__
[winapi.wintypes]           basic windows types and macros from multiple headers
[winapi.winuser]            winuser types and macros from multiple headers
[winapi.winusertypes]       winuser types that we keep separate for use by external libs
[winapi.logfonttype]        LOGFONTW type
__windows__
[winapi.window]             common API for windows and standard controls
__standard controls__
[winapi.comctl]             common controls API
[winapi.messagebox]         standard message box dialog
[winapi.button]             button and button-like controls
[winapi.combobox]           standard (old, not comctl-based) combobox control
[winapi.comboboxex]         standard (new, from comctl32) combobox control
[winapi.headercontrol]      standard header control
[winapi.listbox]            standard listbox control
[winapi.listview]           standard listview control
[winapi.menu]               standard menu control
[winapi.accelerator]        accelerator tables
[winapi.richedit]           standard richedit control
[winapi.edit]               standard edit control
[winapi.static]             standard static (aka label, text) control
[winapi.tabcontrol]         standard tab control
[winapi.toolbar]            standard toolbar control
[winapi.tooltip]            standard tooltip control
[winapi.treeview]           standard treeview control
__standard dialogs__
[winapi.comdlg]             common dialogs
[winapi.colorchooser]       color chooser dialog
[winapi.filedialogs]        standard open and save file dialogs
__resources__
[winapi.resource]           part of winuser dealing with resources
[winapi.cursor]             cursor resources
[winapi.font]               font resources
[winapi.fontex]             font resources (new API)
[winapi.icon]               icon resources
[winapi.color]              standard color brushes
[winapi.imagelist]          image list resources
__support APIs__
[winapi.mouse]              mouse API
[winapi.keyboard]           keyboard input handling and keyboard layouts
[winapi.rawinput]           raw input handling
[winapi.memory]             memory management
[winapi.process]            process API
[winapi.registry]           registry API
[winapi.sysinfo]            system info API
[winapi.shellapi]           shell API
[winapi.systemmetrics]      system metrics API
[winapi.spi]                system parameters info API
[winapi.winbase]            winbase.h. incomplete :)
[winapi.winnt]              don't know the scope of this yet
[winapi.multimon]           multi-monitor API
[winapi.clipboard]          clipboard access
[winapi.rpc]                RPC runtime and types
[winapi.uuid]               UUID API from rpcdce.h
[winapi.module]             winuser submodule that deals with dlls
[winapi.gdi]                windows GDI API
__opengl__
[winapi.gl]                 opengl dynamic namespace based on `PFN*PROC` cdefs and wglGetProcAddress
[winapi.gl11]               opengl 1.1 API
[winapi.gl21]               opengl 2.1 API
[winapi.wgl]                windows opengl32 ffi module and WGL API from wingdi.h
[winapi.wglext]             opengl WGL API from wglext.h
__oo system__
[winapi.class]              single inheritance object model
[winapi.object]             base object class
[winapi.vobject]            base object class with virtual properties
__oo core classes__
[winapi.handlelist]         track objects by their corresponding 32bit pointer handle
[winapi.imagelistclass]     image list class
__oo windows__
[winapi.basewindowclass]    base class for both overlapping windows and controls
[winapi.windowclass]        overlapping (aka top-level) windows
[winapi.showcase]           showcase window for the showcase part of modules
__oo controls__
[winapi.controlclass]       base class for standard controls
[winapi.panelclass]         custom frameless child window
[winapi.basebuttonclass]    base class for push-buttons, checkboxes, radio buttons
[winapi.buttonclass]        push-button control
[winapi.checkboxclass]      checkbox control
[winapi.comboboxclass]      standard combobox control based on ComboBoxEx32 control
[winapi.editclass]          standard edit control
[winapi.groupboxclass]      groupbox control
[winapi.itemlist]           class template for lists of structured items
[winapi.listboxclass]       standard listbox control
[winapi.listviewclass]      standard listview control
[winapi.menuclass]          standard menu control
[winapi.radiobuttonclass]   radio button control
[winapi.toolbarclass]       standard toolbar control
[winapi.tabcontrolclass]    standard tab control
[winapi.waitemlistclass]    accelerator item list
__oo custom panels__
[winapi.wglpanel]           opengl-enabled panel
[winapi.amanithvgpanel]     opengl + openvg-enabled panel using AmanithVG GLE implementation
[winapi.cairopanel]         `self:on_render(surface)` event to draw on a cairo pixman surface
[winapi.cairosgpanel]       cairo scene graph panel: call `self.scene_graph:render(scene)`
                            on `self:on_render()` to render a cairo scene graph
--------------------------- --------------------------------------

> There is also an unfinished [designer][windesigner] app that could serve as
feature showcase, live testing environment, and ultimately as a GUI designer.
I have no plans to continue working on that though.

## Usage

~~~{.lua}
winapi = require'winapi'
require'winapi.windowclass'

local main = winapi.Window{
   title = 'Demo',
   w = 600, h = 400,
   autoquit = true,
}

os.exit(winapi.MessageLoop())
~~~

> __NOTE:__ The oo modules can also be run as standalone scripts, for showcasing the module's functionality.

## Documentation

There's no method-by-method documentation, but there's a [tech doc], [dev doc], and a [narrative][history]
which should give you more context. Also, oo modules have a small runnable demo at the bottom of the file
which showcases the module's functionality. Run the module as a standalone script to check it out.

[tech doc]:     winapi_design.html
[dev doc]:      winapi_binding.html
[history]:      winapi_history.html

[winapi.accelerator]: https://github.com/luapower/winapi/blob/master/winapi/accelerator.lua
[winapi.amanithvgpanel]: https://github.com/luapower/winapi/blob/master/winapi/amanithvgpanel.lua
[winapi.amanithvgpanel_demo]: https://github.com/luapower/winapi/blob/master/winapi/amanithvgpanel_demo.lua
[winapi.arrays]: https://github.com/luapower/winapi/blob/master/winapi/arrays.lua
[winapi.basebuttonclass]: https://github.com/luapower/winapi/blob/master/winapi/basebuttonclass.lua
[winapi.basewindowclass]: https://github.com/luapower/winapi/blob/master/winapi/basewindowclass.lua
[winapi.bitmask]: https://github.com/luapower/winapi/blob/master/winapi/bitmask.lua
[winapi.button]: https://github.com/luapower/winapi/blob/master/winapi/button.lua
[winapi.buttonclass]: https://github.com/luapower/winapi/blob/master/winapi/buttonclass.lua
[winapi.cairopanel]: https://github.com/luapower/winapi/blob/master/winapi/cairopanel.lua
[winapi.cairosgpanel]: https://github.com/luapower/winapi/blob/master/winapi/cairosgpanel.lua
[winapi.checkboxclass]: https://github.com/luapower/winapi/blob/master/winapi/checkboxclass.lua
[winapi.class]: https://github.com/luapower/winapi/blob/master/winapi/class.lua
[winapi.clipboard]: https://github.com/luapower/winapi/blob/master/winapi/clipboard.lua
[winapi.color]: https://github.com/luapower/winapi/blob/master/winapi/color.lua
[winapi.colorchooser]: https://github.com/luapower/winapi/blob/master/winapi/colorchooser.lua
[winapi.combobox]: https://github.com/luapower/winapi/blob/master/winapi/combobox.lua
[winapi.comboboxclass]: https://github.com/luapower/winapi/blob/master/winapi/comboboxclass.lua
[winapi.comboboxex]: https://github.com/luapower/winapi/blob/master/winapi/comboboxex.lua
[winapi.comctl]: https://github.com/luapower/winapi/blob/master/winapi/comctl.lua
[winapi.comdlg]: https://github.com/luapower/winapi/blob/master/winapi/comdlg.lua
[winapi.controlclass]: https://github.com/luapower/winapi/blob/master/winapi/controlclass.lua
[winapi.cursor]: https://github.com/luapower/winapi/blob/master/winapi/cursor.lua
[winapi.debug]: https://github.com/luapower/winapi/blob/master/winapi/debug.lua
[winapi.edit]: https://github.com/luapower/winapi/blob/master/winapi/edit.lua
[winapi.editclass]: https://github.com/luapower/winapi/blob/master/winapi/editclass.lua
[winapi.ffi]: https://github.com/luapower/winapi/blob/master/winapi/ffi.lua
[winapi.filedialogs]: https://github.com/luapower/winapi/blob/master/winapi/filedialogs.lua
[winapi.font]: https://github.com/luapower/winapi/blob/master/winapi/font.lua
[winapi.fontex]: https://github.com/luapower/winapi/blob/master/winapi/fontex.lua
[winapi.gl]: https://github.com/luapower/winapi/blob/master/winapi/gl.lua
[winapi.gl11]: https://github.com/luapower/winapi/blob/master/winapi/gl11.lua
[winapi.gl21]: https://github.com/luapower/winapi/blob/master/winapi/gl21.lua
[winapi.groupboxclass]: https://github.com/luapower/winapi/blob/master/winapi/groupboxclass.lua
[winapi.handlelist]: https://github.com/luapower/winapi/blob/master/winapi/handlelist.lua
[winapi.headercontrol]: https://github.com/luapower/winapi/blob/master/winapi/headercontrol.lua
[winapi.icon]: https://github.com/luapower/winapi/blob/master/winapi/icon.lua
[winapi.imagelist]: https://github.com/luapower/winapi/blob/master/winapi/imagelist.lua
[winapi.imagelistclass]: https://github.com/luapower/winapi/blob/master/winapi/imagelistclass.lua
[winapi.init]: https://github.com/luapower/winapi/blob/master/winapi/init.lua
[winapi.itemlist]: https://github.com/luapower/winapi/blob/master/winapi/itemlist.lua
[winapi.keyboard]: https://github.com/luapower/winapi/blob/master/winapi/keyboard.lua
[winapi.listbox]: https://github.com/luapower/winapi/blob/master/winapi/listbox.lua
[winapi.listboxclass]: https://github.com/luapower/winapi/blob/master/winapi/listboxclass.lua
[winapi.listview]: https://github.com/luapower/winapi/blob/master/winapi/listview.lua
[winapi.listviewclass]: https://github.com/luapower/winapi/blob/master/winapi/listviewclass.lua
[winapi.logfonttype]: https://github.com/luapower/winapi/blob/master/winapi/logfonttype.lua
[winapi.memory]: https://github.com/luapower/winapi/blob/master/winapi/memory.lua
[winapi.menu]: https://github.com/luapower/winapi/blob/master/winapi/menu.lua
[winapi.menuclass]: https://github.com/luapower/winapi/blob/master/winapi/menuclass.lua
[winapi.messagebox]: https://github.com/luapower/winapi/blob/master/winapi/messagebox.lua
[winapi.module]: https://github.com/luapower/winapi/blob/master/winapi/module.lua
[winapi.mouse]: https://github.com/luapower/winapi/blob/master/winapi/mouse.lua
[winapi.multimon]: https://github.com/luapower/winapi/blob/master/winapi/multimon.lua
[winapi.namespace]: https://github.com/luapower/winapi/blob/master/winapi/namespace.lua
[winapi.object]: https://github.com/luapower/winapi/blob/master/winapi/object.lua
[winapi.panelclass]: https://github.com/luapower/winapi/blob/master/winapi/panelclass.lua
[winapi.process]: https://github.com/luapower/winapi/blob/master/winapi/process.lua
[winapi.rawinput]: https://github.com/luapower/winapi/blob/master/winapi/rawinput.lua
[winapi.radiobuttonclass]: https://github.com/luapower/winapi/blob/master/winapi/radiobuttonclass.lua
[winapi.registry]: https://github.com/luapower/winapi/blob/master/winapi/registry.lua
[winapi.resource]: https://github.com/luapower/winapi/blob/master/winapi/resource.lua
[winapi.richedit]: https://github.com/luapower/winapi/blob/master/winapi/richedit.lua
[winapi.rpc]: https://github.com/luapower/winapi/blob/master/winapi/rpc.lua
[winapi.shellapi]: https://github.com/luapower/winapi/blob/master/winapi/shellapi.lua
[winapi.showcase]: https://github.com/luapower/winapi/blob/master/winapi/showcase.lua
[winapi.systemmetrics]: https://github.com/luapower/winapi/blob/master/winapi/systemmetrics.lua
[winapi.spi]: https://github.com/luapower/winapi/blob/master/winapi/spi.lua
[winapi.static]: https://github.com/luapower/winapi/blob/master/winapi/static.lua
[winapi.struct]: https://github.com/luapower/winapi/blob/master/winapi/struct.lua
[winapi.sysinfo]: https://github.com/luapower/winapi/blob/master/winapi/sysinfo.lua
[winapi.tabcontrol]: https://github.com/luapower/winapi/blob/master/winapi/tabcontrol.lua
[winapi.tabcontrolclass]: https://github.com/luapower/winapi/blob/master/winapi/tabcontrolclass.lua
[winapi.toolbar]: https://github.com/luapower/winapi/blob/master/winapi/toolbar.lua
[winapi.toolbarclass]: https://github.com/luapower/winapi/blob/master/winapi/toolbarclass.lua
[winapi.tooltip]: https://github.com/luapower/winapi/blob/master/winapi/tooltip.lua
[winapi.treeview]: https://github.com/luapower/winapi/blob/master/winapi/treeview.lua
[winapi.types]: https://github.com/luapower/winapi/blob/master/winapi/types.lua
[winapi.util]: https://github.com/luapower/winapi/blob/master/winapi/util.lua
[winapi.uuid]: https://github.com/luapower/winapi/blob/master/winapi/uuid.lua
[winapi.vobject]: https://github.com/luapower/winapi/blob/master/winapi/vobject.lua
[winapi.waitemlistclass]: https://github.com/luapower/winapi/blob/master/winapi/waitemlistclass.lua
[winapi.wcs]: https://github.com/luapower/winapi/blob/master/winapi/wcs.lua
[winapi.wgl]: https://github.com/luapower/winapi/blob/master/winapi/wgl.lua
[winapi.wglext]: https://github.com/luapower/winapi/blob/master/winapi/wglext.lua
[winapi.wglpanel]: https://github.com/luapower/winapi/blob/master/winapi/wglpanel.lua
[winapi.wglpanel_demo]: https://github.com/luapower/winapi/blob/master/winapi/wglpanel_demo.lua
[winapi.winbase]: https://github.com/luapower/winapi/blob/master/winapi/winbase.lua
[winapi.window]: https://github.com/luapower/winapi/blob/master/winapi/window.lua
[winapi.windowclass]: https://github.com/luapower/winapi/blob/master/winapi/windowclass.lua
[winapi.gdi]: https://github.com/luapower/winapi/blob/master/winapi/gdi.lua
[winapi.winnt]: https://github.com/luapower/winapi/blob/master/winapi/winnt.lua
[winapi.wintypes]: https://github.com/luapower/winapi/blob/master/winapi/wintypes.lua
[winapi.winuser]: https://github.com/luapower/winapi/blob/master/winapi/winuser.lua
[winapi.winusertypes]: https://github.com/luapower/winapi/blob/master/winapi/winusertypes.lua
