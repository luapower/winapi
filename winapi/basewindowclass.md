---
tagline: base class for windows and controls
---

This module implements the `BaseWindow` class which is the base class
for both top-level windows and controls. The module also contains the
`MessageRouter` singleton which is responsible for routing messages
to window instances, and the `Windows` singleton.

## Windows



## MessageRouter



## MessageLoop



## BaseWindow

BaseWindow is for subclassing, not for instantiation. Nevertheless,
it contains properties and methods that are common to both windows
and controls which are documented here.

## Initial properties

<div class=small>
----------------------- ----------------------------------------- -------------- ---------------------
__field__					__description__									__default__		__winapi flag__
visible						visibility											true				WS_VISIBLE
enabled						focusability										true				WS_DISABLED
x, y							position												0
w, here						size
min_w, min_h				minimum size
max_w, max_h				maximum size
----------------------- ----------------------------------------- -------------- ---------------------
</div>

## Runtime properties and methods

<div class=small>
-------------------------------------- ---------------------------------------------------------------
__field__										__description__

-------------------------------------- ---------------------------------------------------------------
</div>

## Events

<div class=small>
-------------------------------- ----------------------------------------------- ---------------------
__lifetime__							__description__											__winapi message__
on_destroy()																							WM_DESTROY
on_destroyed()																							WM_NCDESTROY
__movement__							__description__											__winapi message__
on_pos_changing																						WM_WINDOWPOSCHANGING
on_pos_changed()																						WM_WINDOWPOSCHANGED
on_moving()																								WM_MOVING
on_moved()																								WM_MOVE
on_resizing()																							WM_SIZING
on_resized()																							WM_SIZE
on_begin_sizemove()																					WM_ENTERSIZEMOVE
on_end_sizemove()																						WM_EXITSIZEMOVE
on_focus()																								WM_SETFOCUS
on_blur()																								WM_KILLFOCUS
on_enable()																								WM_ENABLE
on_show()																								WM_SHOWWINDOW
__queries__								__description__											__winapi message__
on_help()																								WM_HELP
on_set_cursor()																						WM_SETCURSOR
__mouse__()								__description__											__winapi message__
on_mouse_move()																						WM_MOUSEMOVE
on_mouse_over()						call TrackMouseEvent() to receive this				WM_MOUSEHOVER
on_mouse_leave()						call TrackMouseEvent() to receive this				WM_MOUSELEAVE
on_lbutton_double_click()																			WM_LBUTTONDBLCLK
on_lbutton_down()																						WM_LBUTTONDOWN
on_lbutton_up()																						WM_LBUTTONUP
on_mbutton_double_click()																			WM_MBUTTONDBLCLK
on_mbutton_down()																						WM_MBUTTONDOWN
on_mbutton_up()																						WM_MBUTTONUP
on_rbutton_double_click()																			WM_RBUTTONDBLCLK
on_rbutton_down()																						WM_RBUTTONDOWN
on_rbutton_up()																						WM_RBUTTONUP
on_xbutton_double_click()																			WM_XBUTTONDBLCLK
on_xbutton_down()																						WM_XBUTTONDOWN
on_xbutton_up()																						WM_XBUTTONUP
on_mouse_wheel()																						WM_MOUSEWHEEL
on_mouse_hwheel()																						WM_MOUSEHWHEEL
__keyboard__							__description__											__winapi message__
on_key_down()																							WM_KEYDOWN
on_key_up()																								WM_KEYUP
on_syskey_down()																						WM_SYSKEYDOWN
on_syskey_up()																							WM_SYSKEYUP
on_key_down_char()																					WM_CHAR
on_syskey_down_char()																				WM_SYSCHAR
on_dead_key_up_char()																				WM_DEADCHAR
on_dead_syskey_down_char()																			WM_SYSDEADCHAR
__raw() input__						__description__											__winapi message__
on_raw_input()																							WM_INPUT
on_device_change()																					WM_INPUT_DEVICE_CHANGE
__system events__						__description__											__winapi message__
on_timer()																								WM_TIMER
on_dpi_changed()																						WM_DPICHANGED
-------------------------------- ----------------------------------------------- ---------------------
</div>
