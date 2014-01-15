---
project:  winapi
tagline:  ffi bindings to the Windows API
platforms: mingw32
---

[tech doc] | [dev doc] | [history]

## Scope

Windows, common controls, auxiliary objects, dialogs, message loop.

## Design

Procedural API with object API on top.

## Status

In development, not active. Currently, windows and basic controls (buttons, edits, combos, tab controls etc.),
as well as dialogs (color chooser, file open) and resource objects (image lists, fonts, cursors, etc.) are implemented,
with a fair degree of feature coverage and some cherry on top.

I also started working on a [designer][windesigner] app that would serve as feature showcase, live testing environment,
and ultimately as a GUI designer.

## Example

~~~{.lua}
winapi = require'winapi'
require'winapi.messageloop'

local main = winapi.Window{
   title = 'Demo',
   w = 600, h = 400,
   autoquit = true,
}

os.exit(winapi.MessageLoop())
~~~

## Documentation, or lack thereof

There's no method-by-method documentation, but there's a [tech doc], [dev doc], and a [narrative][history]
which should give you more context.

[tech doc]:     winapi_design.html
[dev doc]:      winapi_binding.html
[history]:      winapi_history.html

