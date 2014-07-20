--oo/window: overlapping (aka top-level) windows.
setfenv(1, require'winapi')
require'winapi.basewindowclass'
require'winapi.menuclass'
require'winapi.color'
require'winapi.cursor'
require'winapi.waitemlistclass'

Window = subclass({
	__class_style_bitmask = bitmask{ --only static, frame styles here
		noclose = CS_NOCLOSE, --disable close button and ALT+F4
		dropshadow = CS_DROPSHADOW, --only for non-movable windows
		own_dc = CS_OWNDC, --for opengl or other purposes
		receive_double_clicks = CS_DBLCLKS, --receive double click messages
	},
	__style_bitmask = bitmask{ --only static, frame styles here
		border = WS_BORDER, 		--a frameless window is one without WS_BORDER, WS_DLGFRAME, WS_SIZEBOX and WS_EX_WINDOWEDGE
		frame = WS_DLGFRAME,    --for the titlebar to appear you need both WS_BORDER and WS_DLGFRAME
		minimize_button = WS_MINIMIZEBOX,
		maximize_button = WS_MAXIMIZEBOX,
		sizeable = WS_SIZEBOX,  --needs WS_DLGFRAME
		sysmenu = WS_SYSMENU,   --not setting this hides all buttons
		vscroll = WS_VSCROLL,
		hscroll = WS_HSCROLL,
		clip_children = WS_CLIPCHILDREN,
		clip_siblings = WS_CLIPSIBLINGS,
	},
	__style_ex_bitmask = bitmask{
		window_edge = WS_EX_WINDOWEDGE,  --needs to be the same as WS_DLGFRAME
		dialog_frame = WS_EX_DLGMODALFRAME, --double border and no system menu icon!
		help_button = WS_EX_CONTEXTHELP, --only shown if both minimize and maximize buttons are hidden
		tool_window = WS_EX_TOOLWINDOW,
		transparent = WS_EX_TRANSPARENT, --not really, better use layered and UpdateLayeredWindow()
		layered = WS_EX_LAYERED, --setting this makes a completely frameless window regardless of other styles
		control_parent = WS_EX_CONTROLPARENT, --recurse when looking for the next control with WS_TABSTOP
		activatable = negate(WS_EX_NOACTIVATE), --don't activate and don't show on taskbar (weird semantics)
		taskbar_button = WS_EX_APPWINDOW, --force showing a button on taskbar for this window
	},
	__defaults = {
		--class style bits
		noclose = false,
		dropshadow = false,
		receive_double_clicks = true,
		--window style bits
		border = true,
		frame = true,
		minimize_button = true,
		maximize_button = true,
		sizeable = true,
		sysmenu = true,
		vscroll = false,
		hscroll = false,
		clip_children = true,
		clip_siblings = true,
		--window ex style bits
		window_edge = true,
		dialog_frame = false,
		help_button = false,
		tool_window = false,
		transparent = false,
		layered = false,
		control_parent = true,
		activatable = true,
		taskbar_button = false,
		--class properties
		background = COLOR_WINDOW,
		cursor = LoadCursor(IDC_ARROW),
		--window properties
		title = '',
		x = CW_USEDEFAULT,
		y = CW_USEDEFAULT,
		w = CW_USEDEFAULT,
		h = CW_USEDEFAULT,
		autoquit = false,
		menu = nil,
	},
	__init_properties = {
		'menu',
		'autoquit', --quit the app when the window closes
	},
	__wm_handler_names = index{
		on_close = WM_CLOSE,
		on_restoring = WM_QUERYOPEN, --return false to prevent restoring from minimize state
		--system changes
		on_query_end_session = WM_QUERYENDSESSION,
		on_end_session = WM_ENDSESSION,
		on_system_color_change = WM_SYSCOLORCHANGE,
		on_settings_change = WM_SETTINGCHANGE,
		on_device_mode_change = WM_DEVMODECHANGE,
		on_fonts_change = WM_FONTCHANGE,
		on_time_change = WM_TIMECHANGE,
		on_spooler_change = WM_SPOOLERSTATUS,
		on_input_language_change = WM_INPUTLANGCHANGE,
		on_user_change = WM_USERCHANGED,
		on_display_change = WM_DISPLAYCHANGE,
	},
}, BaseWindow)

--instantiating

local function name_generator(format)
	local n = 0
	return function()
		n = n + 1
		return string.format(format, n)
	end
end
local gen_classname = name_generator'Window%d'

function Window:__before_create(info, args)
	Window.__index.__before_create(self, info, args)

	local class_args = {}
	class_args.name = gen_classname()
	class_args.style = self.__class_style_bitmask:set(class_args.style or 0, info)
	class_args.proc = MessageRouter.proc
	class_args.icon = info.icon
	class_args.small_icon = info.small_icon
	class_args.cursor = info.cursor
	class_args.background = info.background
	args.class = RegisterClass(class_args)

	args.parent = info.owner and info.owner.hwnd
	args.text = info.title
	args.style = bit.bor(args.style,
								info.state == 'minimized' and WS_MINIMIZE or 0,
								info.state == 'maximized' and WS_MAXIMIZE or 0)

	args.style_ex = bit.bor(args.style_ex, info.topmost and WS_EX_TOPMOST or 0)

	self.__state.maximized_pos = info.maximized_pos
	self.__state.maximized_size = info.maximized_size

	self.__winclass = args.class --for unregistering
	self.__winclass_style = class_args.style --for checking
end

function Window:__init(info)
	Window.__index.__init(self, info)

	self:__check_class_style(self.__winclass_style)
	self.__winclass_style = nil --we're done with this

	self.accelerators = WAItemList(self)
end

--destroying

function Window:close()
	CloseWindow(self.hwnd)
end

function Window:WM_NCDESTROY()
	Window.__index.WM_NCDESTROY(self)
	if self.menu then self.menu:free() end
	PostMessage(nil, WM_UNREGISTER_CLASS, self.__winclass)
	if self.autoquit then
		PostQuitMessage()
	end
end

--properties

Window.get_title = BaseWindow.get_text
Window.set_title = BaseWindow.set_text

function Window:get_active() return GetActiveWindow() == self.hwnd end
function Window:activate() SetActiveWindow(self.hwnd) end

--this is different than activate() in that the window flashes in the taskbar
--if its thread is not currently the active thread.
function Window:setforeground()
	SetForegroundWindow(self.hwnd)
end

function Window:get_owner()
	return Windows:find(GetWindowOwner(self.hwnd))
end

function Window:set_owner(owner)
	SetWindowOwner(self.hwnd, owner and owner.hwnd)
end

function Window:get_topmost()
	return bit.band(GetWindowExStyle(self.hwnd), WS_EX_TOPMOST) == WS_EX_TOPMOST
end

function Window:set_topmost(topmost)
	SetWindowPos(self.hwnd, topmost and HWND_TOPMOST or HWND_NOTOPMOST,
						0, 0, 0, 0, bit.bor(SWP_NOSIZE, SWP_NOMOVE, SWP_NOACTIVATE))
end

--maximize size/position constraints

function Window:WM_GETMINMAXINFO(info)
	if self.maximized_pos then info.ptMaxPosition = self.maximized_pos end
	if self.maximized_size then info.ptMaxSize = self.maximized_size end
	return 0
end

function Window:set_maximized_pos()
	self:__force_resize()
end
Window.set_maximized_size = Window.set_maximized_pos

--window state

local window_state_names = { --GetWindowPlacement distills states to these 3
	[SW_SHOWNORMAL]    = 'normal',
	[SW_SHOWMAXIMIZED] = 'maximized',
	[SW_SHOWMINIMIZED] = 'minimized',
}

function Window:get_state()
	local wp = GetWindowPlacement(self.hwnd)
	return window_state_names[wp.showCmd]
end

function Window:set_state(state)
	if state == 'normal' then
		self:shownormal()
	elseif state == 'maximized' then
		self:maximize()
	elseif state == 'minimized' then
		self:minimize()
	end
end

--maximize and activate (can't maximize without activating; WM_COMMAND SC_MAXIMIZE also activates)
function Window:maximize()
	self:show(SW_SHOWMAXIMIZED)
end

--show in normal state and activate or not
function Window:shownormal(activate)
	self:show(activate == false and SW_SHOWNOACTIVATE or SW_SHOWNORMAL)
end

--show in minimized state and deactivate or not
function Window:minimize(deactivate)
	self:show(deactivate == false and SW_SHOWMINIMIZED or SW_MINIMIZE)
end

--restore to last state and activate:
-- 1) if minimized, go to normal or maximized state, based on the value of self.restore_to_maximized
-- 2) if maximized, go to normal state
function Window:restore()
	self:show(SW_RESTORE)
end

--special case: show in current state (minimized, normal or maximized) but don't activate
function Window:show_no_activate()
	self:show(SW_SHOWNA)
end

function Window:get_minimized()
	return IsIconic(self.hwnd)
end

--self.minimized = false goes to last state (either maximized or restored, per self.restore_to_maximized)
function Window:set_minimized(min)
	if min then
		self:minimize()
	elseif self.minimized then
		self:restore()
	end
end

function Window:get_maximized()
	return IsZoomed(self.hwnd)
end

--self.maximized = false goes to normal state if maximized, or changes the restore_to_maximized flag if minimized.
function Window:set_maximized(max)
	if max then
		self:maximize()
	elseif self.minimized then
		self.restore_to_maximized = false
	else
		self:shownormal()
	end
end

--rect of the 'normal' state, regardless of current state

function Window:get_normal_rect()
	return GetWindowPlacement(self.hwnd).rcNormalPosition
end

function Window:set_normal_rect(...) --x1,y1,x2,y2 or rect
	local wp = GetWindowPlacement(self.hwnd)
	wp.rcNormalPosition = RECT(...)
	if not self.visible then wp.showCmd = SW_HIDE end --it can be SW_SHOWNORMAL and we don't want that
	SetWindowPlacement(self.hwnd, wp)
end

--get/set the behavior of the next call to restore() (only works when the window is in minimized state)

function Window:get_restore_to_maximized()
	local wp = GetWindowPlacement(self.hwnd)
	if wp.showCmd == SW_SHOWMINIMIZED then
		return bit.band(wp.flags, WPF_RESTORETOMAXIMIZED) ~= 0
	end
end

function Window:set_restore_to_maximized(yes)
	local wp = GetWindowPlacement(self.hwnd)
	if wp.showCmd ~= SW_SHOWMINIMIZED then return end
	wp.flags = yes and
		bit.bor(wp.flags, WPF_RESTORETOMAXIMIZED) or
		bit.band(wp.flags, bit.bnot(WPF_RESTORETOMAXIMIZED))
	SetWindowPlacement(self.hwnd, wp)
end

--menus

function Window:get_menu()
	return Menus:find(GetMenu(self.hwnd))
end

function Window:set_menu(menu)
	if self.menu then self.menu:__set_window(nil) end
	SetMenu(self.hwnd, menu and menu.hmenu)
	if menu then menu:__set_window(self) end
end

function Window:WM_MENUCOMMAND(menu, i)
	menu = Menus:find(menu)
	if menu.WM_MENUCOMMAND then menu:WM_MENUCOMMAND(i) end
end

--rendering

function Window:WM_CTLCOLORSTATIC(wParam, lParam)
	 --TODO: fix group box
	 do return end
	 local hBackground = CreateSolidBrush(RGB(0, 0, 0))
	 local hdc = ffi.cast('HDC', wParam)
    SetBkMode(hdc, OPAQUE)
    SetTextColor(hdc, RGB(100, 100, 0))
	 return tonumber(hBackground)
end

--accelerators

function Window:WM_COMMAND(kind, id, ...)
	if kind == 'accelerator' then
		self.accelerators:WM_COMMAND(id) --route message to individual accelerators
	end
	Window.__index.WM_COMMAND(self, kind, id, ...)
end

--events: on_activate*() and on_deactivate*() events from WM_ACTIVATE and WM_ACTIVATEAPP

function Window:WM_ACTIVATE(flag, minimized, other_hwnd)
	if flag == 'active' or flag == 'clickactive' then
		if self.on_activate then
			self:on_activate(Windows:find(other_hwnd))
		end
	elseif flag == 'inactive' then
		if self.on_deactivate then
			self:on_deactivate(Windows:find(other_hwnd))
		end
	end
end

function Window:WM_ACTIVATEAPP(flag, other_thread_id)
	if flag == 'active' then
		if self.on_activate_app then
			self:on_activate_app(other_thread_id)
		end
	elseif flag == 'inactive' then
		if self.on_deactivate_app then
			self:on_deactivate_app(other_thread_id)
		end
	end
end

--showcase

if not ... then
require'winapi.icon'
require'winapi.font'

local c = Window{title = 'Main',
	border = true, frame = true, window_edge = true, sizeable = true, control_parent = true,
	help_button = true, maximize_button = false, minimize_button = false, state = 'maximized',
	autoquit = true, w = 500, h = 300, visible = false}
c:show()

c.cursor = LoadCursor(IDC_HAND)
c.icon = LoadIconFromInstance(IDI_INFORMATION)

print('shown     ', c.visible, c.state)
c:maximize()
print('maximized ', c.visible, c.state)
c:minimize()
print('minimized ', c.visible, c.state)
c:show()
print('shown     ', c.visible, c.state)
c:restore()
print('restored  ', c.visible, c.state)
c:shownormal()
print('shownormal', c.visible, c.state)

local c3 = Window{topmost = true, title='Topmost', h = 300, w = 300, sizeable = false}

local c2 = Window{title = 'Owned by Main', frame = true, w = 500, h = 100, visible = true, owner = c,
							--taskbar_button = true --force a button on taskbar even when owned
							}
c2.min_w=200; c2.min_h=200
c2.max_w=300; c2.max_h=300

local c4 = Window{x = 400, y = 400, w = 400, h = 200,
						border = true,
						frame = false,
						window_edge = false,
						--dialog_frame = false,
						sizeable = false,
						owner = c,
						}

function c:WM_GETDLGCODE()
	return 0
	--return bit.bor(DLGC_WANTALLKEYS, DLGC_WANTCHARS, DLGC_WANTMESSAGE)
end

function c:on_key_down(vk, flags)
	print('WM_KEYDOWN', vk, flags)
end

function c:on_key_down_char(char, flags)
	print('WM_CHAR', char, flags)
end

function c:on_lbutton_double_click()
	print'double clicked'
end

c.__wantallkeys = true

c3:minimize()
c3:activate()
c3:minimize()

MessageLoop()

end

