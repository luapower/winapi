---
tagline: win32 windows & controls
platforms: mingw32, mingw64
---

## Scope

Windows, common controls and dialogs, message loop, support APIs,
OpenGL and cairo integration.

## Features

  * UTF8 Lua strings everywhere (also works with wide char buffers)
  * all calls are error-checked so you don't have to
  * automatic memory management (ownership management and allocation of in/out buffers)
  * flags can be passed as `'FLAG1 FLAG2'`
  * counting from 1 everywhere
  * object system with virtual properties (eg. `window.w = 500` changes a window's width)
  * Delphi-style anchor-based layout model for all controls
  * [binding infrastructure][winapi_binding] tailored to winapi conventions,
  facilitating the binding of more APIs
  * cairo and OpenGL panel widgets.

## Modules

{{module_list}}

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

> __Tip:__ The oo modules can be run as standalone scripts, which will
showcase the module's functionality.


## Documentation

There's no method-by-method documentation, but there's a
[tech doc][winapi_design], a [dev doc][winapi_binding], and a
[narrative][winapi_history] which should give you more context.
The code is also well documented IMHO, including API quirks and empirical
knowledge. Also, oo modules have a small runnable demo at the bottom of the
file which showcases the module's functionality. Run the module as a
standalone script to check it out.
