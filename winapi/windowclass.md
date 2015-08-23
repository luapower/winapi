---
tagline: top-level windows
---

This module implements the `Window` class which inherits from `BaseWindow`
from [winapi/basewindowclass], adding additional properties and methods
specific to top-level windows.

~~~
local winapi = require'winapi'
require'winapi.windowclass'

local win = winapi.Window(t)
~~~

Creates a top-level window. `t` is a table which can have the following
extra fields over what `BaseWindow` accepts:

<div class=small>
----------------------- ----------------------------------------- -------------- ---------------------
__field__					__description__									__default__		__winapi flag__
noclose						disable close button and ALT+F4				false				CS_NOCLOSE
dropshadow					only for non-movable windows					false				CS_DROPSHADOW
own_dc						for opengl or other purposes					false				CS_OWNDC
receive_double_clicks	receive double click messages					true				CS_DBLCLKS
border						add a border										true				WS_BORDER
frame 						add a titlebar	(needs border)					true				WS_DLGFRAME
minimize_button			add a minimize button							true				WS_MINIMIZEBOX
maximize_button			add a maximize button							true				WS_MAXIMIZEBOX
sizeable						add a resizing border (needs frame)			true				WS_SIZEBOX
sysmenu						not setting this hides all buttons			true				WS_SYSMENU
vscroll						add a vertical scrollbar						false				WS_VSCROLL
hscroll						add a horizontal scrollbar						false				WS_HSCROLL
clip_children				clip children										true				WS_CLIPCHILDREN
clip_siblings				clip siblings										true				WS_CLIPSIBLINGS
child							for tool_window + activable:false 			false				WS_CHILD
topmost						stay above all windows							false				WS_EX_TOPMOST
window_edge					needs to be the same as frame					true				WS_EX_WINDOWEDGE
dialog_frame				double border and no system menu icon		false				WS_EX_DLGMODALFRAME
help_button					needs minimize:false and maximize:false	false				WS_EX_CONTEXTHELP
tool_window					thin tool window frameless						false				WS_EX_TOOLWINDOW
transparent					better use layered instead 					false				WS_EX_TRANSPARENT
layered						layered mode (+disable all framing) 		false				WS_EX_LAYERED
control_parent				recurse when tabbing	between controls		true				WS_EX_CONTROLPARENT
activatable					activate and show on taskbar					true				WS_EX_NOACTIVATE
taskbar_button				force showing the window on taskbar			false				WS_EX_APPWINDOW
background					background color									COLOR_WINDOW
cursor						default cursor										IDC_ARROW
title							titlebar												''
x								outer position	x									CW_USEDEFAULT
y								outer position	y									CW_USEDEFAULT
w								outer width											CW_USEDEFAULT
h								outer height										CW_USEDEFAULT
autoquit						stop the loop when the window is closed	false
menu							menu bar												nil
remember_maximized_pos	maximize to last known position				false
minimized					minimized initial state							false				WS_MINIMIZE
maximized					maximized initial state							false				WS_MAXIMIZE
icon							window's icon										nil
small_icon					window's small icon								nil
owner							window's owner										nil
----------------------- ----------------------------------------- -------------- ---------------------
</div>

__NOTE:__ All CS_*, WS_* and WS_EX_* flags become properties (virtual fields)
of the window object and they can be queried and modified:

~~~{.lua}
win.title = 'Hello' --changes the window's title
print(win.title)    --prints 'Hello'
~~~

## Runtime properties and methods

<div class=small>
-------------------------------------- ---------------------------------------------------------------
__field__										__description__
close()											destroy the window
foreground -> true|false					is this the foreground window?
activate()										activate the window
setforeground()								activate the window even if the app is inactive
minimized -> true|false						get the minimized state
maximized -> true|false						get the maximized state
minimize([deactivate], [async])			minimize (deactivate defaults to true)
maximize([_], [async])						maximize and activate
shownormal([activate], [async]])			show in normal state (activate defaults to true)
restore([_], [async])						restore from minimized or maximized state and activate
normal_rect -> x, y, w, h					get the window's frame rectangle in normal state
set_normal_rect(x, y, w, h)				set the window's frame rectangle in normal state
normal_rect = r								same as above but directly assign a RECT
restore_to_maximized -> true|false		will the window unminimize to maximized state?
restore_to_maximized = true|false		set if the window should unminimize to maximized state
send_to_back([rel_to_win])					move the window below other windows or a specific window
bring_to_front([rel_to_win])				move the window above other windows or a specific window
accelerators									list of accelerators (a WAItemList)
-------------------------------------- ---------------------------------------------------------------
</div>

## Events

<div class=small>
-------------------------------- ----------------------------------------------- ---------------------
__handler__								__description__											__winapi flag__
on_close()								was closed													WM_CLOSE
on_activate()							was activated												WM_ACTIVATE
on_deactivate()						was deactivated											WM_ACTIVATE
on_activate_app()						the app was activated									WM_ACTIVATEAPP
on_deactivate_app()					the app was deactivated									WM_ACTIVATEAPP
on_nc_activate()						the non-clienta area was activated					WM_NCACTIVATE
on_nc_deactivate()					the non-clienta area was deactivated				WM_NCACTIVATE
on_minimizing(x, y)					minimizing: return false to prevent					SC_MINIMIZE
on_unminimizing()						unminimizing: return false to prevent				WM_QUERYOPEN
on_maximizing(x, y)					maximizing: return false to prevent					SC_MAXIMIZE
on_restoring(x, y) 					unmaximizing: return false to prevent				SC_RESTORE
on_menu_key(char_code)				get the 'f' in Alt+F on a '&File' menu				SC_KEYMENU
on_get_minmax_info(MINMAXINFO*)	get min/max size constraints							WM_GETMINMAXINFO
__system changes__					__description__											__winapi flag__
on_query_end_session()				logging off (return false to prevent)				WM_QUERYENDSESSION
on_end_session()						logging off	(after all apps agreed)					WM_ENDSESSION
on_system_color_change()			system colors changed									WM_SYSCOLORCHANGE
on_settings_change()					system parameters info changed						WM_SETTINGCHANGE
on_device_mode_change()				device-mode settings changed							WM_DEVMODECHANGE
on_fonts_change()						installed fonts changed									WM_FONTCHANGE
on_time_change()						system time changed										WM_TIMECHANGE
on_spooler_change()					spooler's status changed								WM_SPOOLERSTATUS
on_input_language_change()			input language changed									WM_INPUTLANGCHANGE
on_user_change()						used has logged off										WM_USERCHANGED
on_display_change()					display resolution changed								WM_DISPLAYCHANGE
-------------------------------- ----------------------------------------------- ---------------------
</div>

Example:

~~~{.lua}
function win:on_close()
	print'closed'
end
~~~

