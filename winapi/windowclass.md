---
tagline: top-level windows
---

## `require'winapi.windowclass'`

This module implements the `Window` class for creating top-level windows.
`Window` inherits from `BaseWindow` from [winapi.basewindowclass] module.

## Usage

~~~{.lua}
local winapi = require'winapi'
require'winapi.windowclass'

local win = winapi.Window{ --these are initial fields
	w = 500,
	h = 300,
	title = 'Lua rulez',
	autoquit = true,
	visible = false,
}

function win:on_close()    --this is an event handler
	print'Bye'
end

print(win.title)           --this is reading the value of a property
win.title = 'Lua rulez!'   --this is setting the value of a property
win:show()                 --this is a method call
~~~

## API

The tables below list all initial fields, properties, methods and events
specific to the `Window` class. Everything listed for `BaseWindow` in
[winapi.basewindowclass] is available too.


### Initial fields and properties

In the table below `i` means initial field, `r` means read-only property,
`rw` means read-write property.

<div class=small>
----------------------- -------- ----------------------------------------- -------------- ---------------------
__field/property__		__type__	__description__									__default__		__winapi flag__
noclose						i rw		remove the close button							false				CS_NOCLOSE
dropshadow					i rw		(for non-movable windows)						false				CS_DROPSHADOW
own_dc						i rw		own the DC											false				CS_OWNDC
receive_double_clicks	i rw		enable double click events						true				CS_DBLCLKS
border						i rw		add a border										true				WS_BORDER
frame 						i rw		add a titlebar	(needs border)					true				WS_DLGFRAME
minimize_button			i rw		add a minimize button							true				WS_MINIMIZEBOX
maximize_button			i rw		add a maximize button							true				WS_MAXIMIZEBOX
sizeable						i rw		enable resizing 									true				WS_SIZEBOX
sysmenu						i rw		add a system menu									true				WS_SYSMENU
vscroll						i rw		add a vertical scrollbar						false				WS_VSCROLL
hscroll						i rw		add a horizontal scrollbar						false				WS_HSCROLL
clip_children				i rw		clip children										true				WS_CLIPCHILDREN
clip_siblings				i rw		clip siblings										true				WS_CLIPSIBLINGS
child							i rw		(for non-activable tool windows)	 			false				WS_CHILD
topmost						i rw		stay above all windows							false				WS_EX_TOPMOST
window_edge					i rw		(needs to be the same as frame)				true				WS_EX_WINDOWEDGE
dialog_frame				i rw		double border and no sysmenu icon			false				WS_EX_DLGMODALFRAME
help_button					i rw		help button											false				WS_EX_CONTEXTHELP
tool_window					i rw		tool window frame									false				WS_EX_TOOLWINDOW
transparent					i rw		(use layered instead)		 					false				WS_EX_TRANSPARENT
layered						i rw		layered mode								 		false				WS_EX_LAYERED
control_parent				i rw		recursive tabbing	between controls			true				WS_EX_CONTROLPARENT
activatable					i rw		activate and show on taskbar					true				WS_EX_NOACTIVATE
taskbar_button				i rw		force showing on taskbar						false				WS_EX_APPWINDOW
background					i rw		background color									COLOR_WINDOW
cursor						i rw		default cursor										IDC_ARROW
title							i rw		titlebar												''
x, y							i			frame position (top-left corner)				CW_USEDEFAULT
w, h							i			frame size											CW_USEDEFAULT
autoquit						i rw		stop the loop when the window is closed	false
menu							i rw		menu bar
remember_maximized_pos	i rw		maximize to last known position				false
minimized					i r		minimized state									false				WS_MINIMIZE
maximized					i r		maximized state									false				WS_MAXIMIZE
icon							i rw		window's icon
small_icon					i rw		window's small icon
owner							i rw		window's owner
foreground					_ r		is this the foreground window?
normal_rect					_ rw		RECT: frame rect in normal state
restore_to_maximized		_ rw		unminimize to maximized state
accelerators				_ rw		WAItemList: list of of accelerators
----------------------- -------- ----------------------------------------- -------------- ---------------------
</div>


### Methods

<div class=small>
-------------------------------- ---------------------------------------------
__method__								__description__
close()									destroy the window
activate()								activate the window if the app is active
setforeground()						activate the window anyway
set_normal_rect(x, y, w, h)		set the normal_rect discretely
minimize([deactivate], [async])	minimize (deactivate: true)
maximize(nil, [async])				maximize and activate
shownormal([activate], [async])	show in normal state (activate: true)
restore(nil, [async])				restore from minimized or maximized state
send_to_back([rel_to_win])			move below other windows/specific window
bring_to_front([rel_to_win])		move above other windows/specific window
-------------------------------- ---------------------------------------------
</div>


### Events

<div class=small>
-------------------------------- -------------------------------------------- ----------------------
__event__								__description__										__winapi message__
on_close()								was closed												WM_CLOSE
on_activate()							was activated											WM_ACTIVATE
on_deactivate()						was deactivated										WM_ACTIVATE
on_activate_app()						the app was activated								WM_ACTIVATEAPP
on_deactivate_app()					the app was deactivated								WM_ACTIVATEAPP
on_nc_activate()						the non-clienta area was activated				WM_NCACTIVATE
on_nc_deactivate()					the non-clienta area was deactivated			WM_NCACTIVATE
on_minimizing(x, y)					minimizing: return false to prevent				SC_MINIMIZE
on_unminimizing()						unminimizing: return false to prevent			WM_QUERYOPEN
on_maximizing(x, y)					maximizing: return false to prevent				SC_MAXIMIZE
on_restoring(x, y) 					unmaximizing: return false to prevent			SC_RESTORE
on_menu_key(char_code)				get the 'f' in Alt+F on a '&File' menu			SC_KEYMENU
on_get_minmax_info(MINMAXINFO*)	get min/max size constraints						WM_GETMINMAXINFO
__system event__
on_query_end_session()				logging off (return false to prevent)			WM_QUERYENDSESSION
on_end_session()						logging off	(after all apps agreed)				WM_ENDSESSION
on_system_color_change()			system colors changed								WM_SYSCOLORCHANGE
on_settings_change()					system parameters info changed					WM_SETTINGCHANGE
on_device_mode_change()				device-mode settings changed						WM_DEVMODECHANGE
on_fonts_change()						installed fonts changed								WM_FONTCHANGE
on_time_change()						system time changed									WM_TIMECHANGE
on_spooler_change()					spooler's status changed							WM_SPOOLERSTATUS
on_input_language_change()			input language changed								WM_INPUTLANGCHANGE
on_user_change()						used has logged off									WM_USERCHANGED
on_display_change()					display resolution changed							WM_DISPLAYCHANGE
----------------------- --------	-------------------------------------------- ---------------------
</div>

