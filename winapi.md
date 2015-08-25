---
tagline: win32 windows & controls
platforms: mingw32, mingw64
---

## Scope

Windows, common controls and dialogs, message loop, system APIs,
OpenGL and cairo.

## Features

  * UTF8 Lua strings everywhere (also works with wide char buffers)
  * all calls are error-checked
  * memory management (managing ownership; allocation of in/out buffers)
  * flags can be passed as `'FLAG1 FLAG2'`
  * counting from 1 everywhere
  * object system with virtual properties (`win.title = 'hello'` sets the title)
  * anchor-based layout model for all controls
  * binding helpers for easy binding of new and future APIs
  * cairo and OpenGL widgets.

## Hello World

~~~{.lua}
winapi = require'winapi'
require'winapi.windowclass'

local main = winapi.Window{
   title = 'Good News Everyone',
   w = 600, h = 400,
   autoquit = true,
}

function main:on_close()
	print'Bye!'
end

os.exit(winapi.MessageLoop())
~~~

## Documentation

### Architecture

  * [winapi_design] - hi-level overview of the library
  * [winapi_binding] - how the binding infrastructure works
  * [winapi_history] - the reasoning behind various design decisions

### Classes

* [Object][winapi.object] - the root class
	* [VObject][winapi.vobject] - objects with virtual properties
		* [BaseWindow][winapi.basewindowclass] - base class for top-level windows and controls
			* [Window][winapi.windowclass] - final class for top level windows
				* [Control][winapi.controlclass] - base class for controls
					* [BaseButton][winapi.basebuttonclass] - base class for buttons
						* [Button][winapi.buttonclass] - push-buttons

### Functions

The "proc" layer is documented in the code, including API quirks
and empirical knowledge, so do check out the source code.

## Modules

{{module_list}}

__Tip:__ Some modules can be run as standalone scripts, which will
showcase the module's functionality.
