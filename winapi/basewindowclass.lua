--oo/basewindow: base class for both overlapping windows and controls.
setfenv(1, require'winapi')
require'winapi.vobject'
require'winapi.handlelist'
require'winapi.window'
require'winapi.gdi'
require'winapi.keyboard'
require'winapi.mouse'
require'winapi.monitor'

--window tracker

Windows = class(HandleList) --track window objects by their hwnd

--the active window goes nil when the app is deactivated, but if
--SetActiveWindow() is called while the app is not active, the active
--window will be set nevertheless.
function Windows:get_active_window()
	return self:find(GetActiveWindow())
end

--the difference between active window and foreground window is that
--the foreground window is always nil when the app is not active,
--even if SetActiveWindow() is called.
function Windows:get_foreground_window()
	return self:find(GetForegroundWindow())
end

function Windows:window_at(p)
	return self:find(WindowFromPoint(p))
end

function Windows:map_point(to_window, ...) --x,y or point
	return MapWindowPoint(nil, to_window.hwnd, ...)
end

function Windows:map_rect(to_window, ...) --x1,y1,x2,y2 or rect
	return MapWindowRect(nil, to_window.hwnd, ...)
end

function Windows:get_cursor_pos(in_window)
	local p = GetCursorPos()
	return in_window and self:map_point(in_window, p) or p
end

Windows = Windows'hwnd' --singleton

--message router

--by assigning your window's WNDPROC to MessageRouter.proc (either via SetWindowLong(GWL_WNDPROC) or
--via RegisterClass(), and adding your window object to the window tracker via Windows:add(window),
--your window's __handle_message() method will be called for each message destined to your window.
--This way only one ffi callback object is wasted for all windows.

MessageRouter = class(Object)

function MessageRouter:__init()
	local function dispatch(hwnd, WM, wParam, lParam)
		local window = Windows:find(hwnd)
		if window then
			return window:__handle_message(WM, wParam, lParam)
		end
		return DefWindowProc(hwnd, WM, wParam, lParam) --catch WM_CREATE etc.
	end
	self.proc = ffi.cast('WNDPROC', dispatch)
end

function MessageRouter:free()
	self.proc:free()
end

MessageRouter = MessageRouter() --singleton

--message loop

--message sent to the thread (thus the message loop) to unregister a window class after a window is destroyed.
WM_UNREGISTER_CLASS = WM_APP + 1

function ProcessMessage(msg)
	local window = Windows.active_window
	if window then
		if window.accelerators and window.accelerators.haccel then
			if TranslateAccelerator(window.hwnd, window.accelerators.haccel, msg) then --make hotkeys work
				return
			end
		end
		if not window.__wantallkeys then
			if IsDialogMessage(window.hwnd, msg) then --make tab and arrow keys work with controls
				return
			end
		end
	end
	TranslateMessage(msg) --make keyboard work
	DispatchMessage(msg) --make everything else work

	if msg.message == WM_UNREGISTER_CLASS then
		UnregisterClass(msg.wParam)
	end
end

function MessageLoop(after_process) --you can do os.exit(MessageLoop())
	local msg = types.MSG()
	while true do
		local ret = GetMessage(nil, 0, 0, msg)
		if ret == 0 then break end
		ProcessMessage(msg)
		if after_process then
			after_process(msg)
		end
	end
	return msg.signed_wParam --WM_QUIT returns 0 and an int exit code in wParam
end

function ProcessMessages(after_process)
	while true do
		local ok, msg = PeekMessage(nil, 0, 0, PM_REMOVE)
		if not ok then return end
		ProcessMessage(msg)
		if after_process then
			after_process(msg)
		end
	end
end

--base window class

BaseWindow = {
	__class_style_bitmask = bitmask{}, --windows who own their class add class style bits that are relevant to them
	__style_bitmask = bitmask{},       --subclasses add style bits that are relevant to them
	__style_ex_bitmask = bitmask{},    --subclasses add extended style bits that are relevant to them
	__defaults = {
		visible = true,
		enabled = true,
		x = 0,
		y = 0,
		min_w = 0,
		min_h = 0,
	},
	__init_properties = {},            --subclasses add after-create properties that are relevant to them
	__wm_handler_names = index{        --subclasses add messages that are relevant to them
		--lifetime
		on_destroy = WM_DESTROY,
		on_destroyed = WM_NCDESTROY,
		--movement
		on_pos_changing = WM_WINDOWPOSCHANGING,
		on_pos_changed = WM_WINDOWPOSCHANGED,
		on_moving = WM_MOVING,
		on_moved = WM_MOVE,
		on_resizing = WM_SIZING,
		on_resized = WM_SIZE,
		on_begin_sizemove = WM_ENTERSIZEMOVE,
		on_end_sizemove = WM_EXITSIZEMOVE,
		on_focus = WM_SETFOCUS,
		on_blur = WM_KILLFOCUS,
		on_enable = WM_ENABLE,
		on_show = WM_SHOWWINDOW,
		--queries
		on_help = WM_HELP,
		on_set_cursor = WM_SETCURSOR,
		--mouse events
		on_mouse_move = WM_MOUSEMOVE,
		on_mouse_over = WM_MOUSEHOVER,  --call TrackMouseEvent after the first WM_MOUSEMOVE to receive this
		on_mouse_leave = WM_MOUSELEAVE, --call TrackMouseEvent to receive this
		on_lbutton_double_click = WM_LBUTTONDBLCLK,
		on_lbutton_down = WM_LBUTTONDOWN,
		on_lbutton_up = WM_LBUTTONUP,
		on_mbutton_double_click = WM_MBUTTONDBLCLK,
		on_mbutton_down = WM_MBUTTONDOWN,
		on_mbutton_up = WM_MBUTTONUP,
		on_rbutton_double_click = WM_RBUTTONDBLCLK,
		on_rbutton_down = WM_RBUTTONDOWN,
		on_rbutton_up = WM_RBUTTONUP,
		on_xbutton_double_click = WM_XBUTTONDBLCLK,
		on_xbutton_down = WM_XBUTTONDOWN,
		on_xbutton_up = WM_XBUTTONUP,
		on_mouse_wheel = WM_MOUSEWHEEL,
		on_mouse_hwheel = WM_MOUSEHWHEEL,
		--keyboard events
		on_key_down = WM_KEYDOWN,
		on_key_up = WM_KEYUP,
		on_syskey_down = WM_SYSKEYDOWN,
		on_syskey_up = WM_SYSKEYUP,
		on_key_down_char = WM_CHAR,
		on_syskey_down_char = WM_SYSCHAR,
		on_dead_key_up_char = WM_DEADCHAR,
		on_dead_syskey_down_char = WM_SYSDEADCHAR,
		--system events
		on_timer = WM_TIMER,
		--raw input
		on_raw_input = WM_INPUT,
		on_device_change = WM_INPUT_DEVICE_CHANGE,
	},
	__wm_command_handler_names = {}, --subclasses add WM_COMMAND commands that are relevant to them
	__wm_notify_handler_names = {}, --subclasses add WM_NOTIFY codes that are relevant to them
}

BaseWindow = subclass(BaseWindow, VObject)

--subclassing (generate virtual properties for style bits and inherit settings from the superclass)

function BaseWindow:__get_class_style_bit(k)
	return self.__class_style_bitmask:getbit(GetClassStyle(self.hwnd), k)
end

function BaseWindow:__get_style_bit(k)
	return self.__style_bitmask:getbit(GetWindowStyle(self.hwnd), k)
end

function BaseWindow:__get_style_ex_bit(k)
	return self.__style_ex_bitmask:getbit(GetWindowExStyle(self.hwnd), k)
end

function BaseWindow:__set_class_style_bit(k,v)
	SetClassStyle(self.hwnd, self.__class_style_bitmask:setbit(GetClassStyle(self.hwnd), k, v))
	SetWindowPos(self.hwnd, nil, 0, 0, 0, 0, SWP_FRAMECHANGED_ONLY)
end

function BaseWindow:__set_style_bit(k,v)
	SetWindowStyle(self.hwnd, self.__style_bitmask:setbit(GetWindowStyle(self.hwnd), k, v))
	SetWindowPos(self.hwnd, nil, 0, 0, 0, 0, SWP_FRAMECHANGED_ONLY)
end

function BaseWindow:__set_style_ex_bit(k,v)
	SetWindowExStyle(self.hwnd, self.__style_ex_bitmask:set(GetWindowExStyle(self.hwnd), k, v))
	SetWindowPos(self.hwnd, nil, 0, 0, 0, 0, SWP_FRAMECHANGED_ONLY)
end

function BaseWindow:__subclass(class)
	BaseWindow.__index.__subclass(self, class)
	--generate style virtual properties from additional style bitmask fileds, if any, and inherit super's bitmask fields
	if rawget(class, '__class_style_bitmask') then
		class:__gen_vproperties(class.__class_style_bitmask.fields, class.__get_class_style_bit, class.__set_class_style_bit)
		update(class.__class_style_bitmask.fields, self.__class_style_bitmask.fields)
	end
	if rawget(class, '__style_bitmask') then
		class:__gen_vproperties(class.__style_bitmask.fields, class.__get_style_bit, class.__set_style_bit)
		update(class.__style_bitmask.fields, self.__style_bitmask.fields)
	end
	if rawget(class, '__style_ex_bitmask') then
		class:__gen_vproperties(class.__style_ex_bitmask.fields, class.__get_style_ex_bit, class.__set_style_ex_bit)
		update(class.__style_ex_bitmask.fields, self.__style_ex_bitmask.fields)
	end
	--inherit settings from the super class
	if rawget(class, '__defaults') then
		inherit(class.__defaults, self.__defaults)
	end
	if rawget(class, '__init_properties') then
		extend(class.__init_properties, self.__init_properties)
	end
	if rawget(class, '__wm_handler_names') then
		inherit(class.__wm_handler_names, self.__wm_handler_names)
	end
	if rawget(class, '__wm_command_handler_names') then
		inherit(class.__wm_command_handler_names, self.__wm_command_handler_names)
	end
	if rawget(class, '__wm_notify_handler_names') then
		inherit(class.__wm_notify_handler_names, self.__wm_notify_handler_names)
	end
end

--instantiating

function BaseWindow:__before_create(info, args) end --stub
function BaseWindow:__after_create(info, args) end --stub

function BaseWindow:__check_bitmask(name, mask, wanted, actual)
	if wanted == actual then return end
	local pp = require'pp'
	error(string.format('inconsistent %s bits\nwanted: 0x%08x %s\nactual: 0x%08x %s', name,
		wanted, pp.format(mask:get(wanted), '   '),
		actual, pp.format(mask:get(actual), '   ')))
end

function BaseWindow:__check_class_style(wanted)
	self:__check_bitmask('class style', self.__class_style_bitmask, wanted, GetClassStyle(self.hwnd))
end

function BaseWindow:__check_style(wanted)
	self:__check_bitmask('style', self.__style_bitmask, wanted, GetWindowStyle(self.hwnd))
end

function BaseWindow:__check_style_ex(wanted)
	self:__check_bitmask('ex style', self.__style_ex_bitmask, wanted, GetWindowExStyle(self.hwnd))
end

function BaseWindow:__init(info)

	--given a window handle, wrap it up in a window object, in which case we ignore info completely
	if info.hwnd then
		self.hwnd = info.hwnd
		Windows:add(self)
		return
	end

	info = inherit(info or {}, self.__defaults)

	self.__state = {}
	self.__state.min_w = info.min_w
	self.__state.min_h = info.min_h
	self.__state.max_w = info.max_w
	self.__state.max_h = info.max_h

	local args = {}
	args.x = info.x
	args.y = info.y
	args.w = info.w
	args.h = info.h
	self:__adjust_wh(args) --adjust t.w,t.h with min/max_w/h
	args.style = self.__style_bitmask:set(args.style or 0, info)
	args.style_ex = self.__style_ex_bitmask:set(args.style_ex or 0, info)
	args.style = bit.bor(args.style, info.enabled and 0 or WS_DISABLED)
	self:__before_create(info, args)

	self.hwnd = CreateWindow(args)

	--style bits WS_BORDER and WS_DLGFRAME are always set on creation, so we reset them now if we have to
	if GetWindowStyle(self.hwnd) ~= args.style then
		SetWindowStyle(self.hwnd, args.style)
		SetWindowPos(self.hwnd, nil, 0, 0, 0, 0, SWP_FRAMECHANGED_ONLY) --events are not yet routed
	end

	--style bit WS_EX_WINDOWEDGE is always set on creation, so we reset it now if we have to
	if GetWindowExStyle(self.hwnd) ~= args.style_ex then
		SetWindowExStyle(self.hwnd, args.style_ex)
		SetWindowPos(self.hwnd, nil, 0, 0, 0, 0, SWP_FRAMECHANGED_ONLY) --events are not yet routed
	end

	--make sure the style bits are consistent (windows will switch the inconsistent ones)
	self:__check_style(args.style)
	self:__check_style_ex(args.style_ex)

	self:__after_create(info, args)

	self.font = info.font or GetStockObject(DEFAULT_GUI_FONT)

	--initialize properties that are extra to CreateWindow() in the prescribed order
	for _,name in ipairs(self.__init_properties) do
		if info[name] then
			self[name] = info[name] --events are not yet routed
		end
	end

	--register the window so we can find it by hwnd and route messages back to it via MessageRouter
	Windows:add(self)

	--show the window (it is created without WS_VISIBLE to allow us to set up event routing first)
	if info.visible and not self.visible then
		self.visible = true
	end
end

--destroing

function BaseWindow:free()
	if not self.hwnd then return end
	DestroyWindow(self.hwnd)
end

function BaseWindow:WM_NCDESTROY() --after children are destroyed
	Windows:remove(self)
	disown(self.hwnd) --prevent the __gc on hwnd calling DestroyWindow again
	self.hwnd = nil
end

function BaseWindow:get_dead() return self.hwnd == nil end

--class properties

function BaseWindow:get_background() return GetClassBackground(self.hwnd) end
function BaseWindow:set_background(bg) SetClassBackground(self.hwnd, bg) end

function BaseWindow:get_cursor() return GetClassCursor(self.hwnd) end
function BaseWindow:set_cursor(cursor) SetClassCursor(self.hwnd, cursor) end

function BaseWindow:get_icon() return GetClassIcon(self.hwnd) end
function BaseWindow:set_icon(icon) SetClassIcon(self.hwnd, icon) end

function BaseWindow:get_small_icon() GetClassSmallIcon(self.hwnd) end
function BaseWindow:set_small_icon(icon) SetClassSmallIcon(self.hwnd, icon) end

--properties

function BaseWindow:get_text() return GetWindowText(self.hwnd) end
function BaseWindow:set_text(text) SetWindowText(self.hwnd, text) end

function BaseWindow:set_font(font) SetWindowFont(self.hwnd, font) end
function BaseWindow:get_font() return GetWindowFont(self.hwnd) end

function BaseWindow:get_enabled() return IsWindowEnabled(self.hwnd) end
function BaseWindow:set_enabled(enabled) EnableWindow(self.hwnd, enabled) end
function BaseWindow:enable() self.enabled = true end
function BaseWindow:disable() self.enabled = false end

function BaseWindow:get_focused() return GetFocus() == self.hwnd end
function BaseWindow:focus() SetFocus(self.hwnd) end

function BaseWindow:children()
	local t = EnumChildWindows(self.hwnd)
	local i = 0
	return function()
		i = i + 1
		return Windows:find(t[i])
	end
end

function BaseWindow:get_cursor_pos()
	return Windows:get_cursor_pos(self)
end

--visibility

--show(true|nil) = show in current state.
--show(false) = show show in current state but don't activate.
function BaseWindow:show(SW)
	SW = flags((SW == nil or SW == true) and SW_SHOW or SW == false and SW_SHOWNA or SW)
	ShowWindow(self.hwnd, SW)
	--first ShowWindow(SW_SHOW) is ignored on the first window (SW_RESTORE is not)
	if SW ~= SW_HIDE and not self.visible then
		ShowWindow(self.hwnd, SW)
		assert(self.visible)
	end
	UpdateWindow(self.hwnd)
end

function BaseWindow:hide()
	ShowWindow(self.hwnd, SW_HIDE)
end

function BaseWindow:get_is_visible() --visible and all parents are visible too
	return IsWindowVisible(self.hwnd)
end

function BaseWindow:get_visible()
	return bit.band(GetWindowStyle(self.hwnd), WS_VISIBLE) == WS_VISIBLE
end

function BaseWindow:set_visible(visible)
	if visible then self:show() else self:hide() end
end

--size constraints & parent resizing event

--custom event: on_parent_resizing()
function BaseWindow:__parent_resizing(wp)
	if self.on_parent_resizing then
		self:on_parent_resizing(wp)
	end
end

--restrict width and height to min and max constraints.
function BaseWindow:__adjust_wh(t)
	t.w = math.min(math.max(t.w, self.min_w or t.w), self.max_w or t.w)
	t.h = math.min(math.max(t.h, self.min_h or t.h), self.max_h or t.h)
end

--restrict size by min/max constraints and resize children
function BaseWindow:WM_WINDOWPOSCHANGING(wp)
	if bit.band(wp.flags, SWP_NOSIZE) ~= SWP_NOSIZE then
		self:__adjust_wh(wp)
		for child in self:children() do
			child:__parent_resizing(wp) --children can resize the parent by modifying wp
		end
		if self.on_pos_changing then
			self:on_pos_changing(wp)
		end
		return 0
	end
end

function BaseWindow:__force_resize() --force move + resize events
	local r = self.rect
	local flags = bit.bor(SWP_NOZORDER, SWP_NOOWNERZORDER, SWP_NOACTIVATE)
	SetWindowPos(self.hwnd, nil, r.x, r.y, r.w, r.h, flags)
end

function BaseWindow:set_min_w()
	self:__force_resize()
end
BaseWindow.set_min_h = BaseWindow.set_min_w
BaseWindow.set_max_w = BaseWindow.set_min_w
BaseWindow.set_max_h = BaseWindow.set_min_w

--moving and resizing

function BaseWindow:move(x, y, w, h) --use nil to assume current value
	local r = self.rect
	x = x or r.x
	y = y or r.y
	w = w or r.w
	h = h or r.h
	local move = x ~= r.x or y ~= r.y
	local resize = w ~= r.w or h ~= r.h
	if not move and not resize then return end
	local flags = bit.bor(SWP_NOZORDER, SWP_NOOWNERZORDER, SWP_NOACTIVATE,
								move and 0 or SWP_NOMOVE,
								resize and 0 or SWP_NOSIZE)
	SetWindowPos(self.hwnd, nil, x, y, w, h, flags)
end

function BaseWindow:resize(w, h)
	self:move(nil, nil, w, h)
end

function BaseWindow:get_x() return self.rect.x end
function BaseWindow:get_y() return self.rect.y end
function BaseWindow:get_w() return self.rect.w end
function BaseWindow:get_h() return self.rect.h end
function BaseWindow:set_x(x) self:move(x) end
function BaseWindow:set_y(y) self:move(nil,y) end
function BaseWindow:set_w(w) self:resize(w) end
function BaseWindow:set_h(h) self:resize(nil,h) end

--rect, screen rect, client rect

function BaseWindow:get_rect(r)
	return MapWindowRect(nil, GetParent(self.hwnd), GetWindowRect(self.hwnd, r))
end

function BaseWindow:set_rect(...) --x1,y1,x2,y2 or rect
	local r = RECT(...)
	self:move(r.x, r.y, r.w, r.h)
end

function BaseWindow:get_screen_rect(r)
	return GetWindowRect(self.hwnd, r)
end

function BaseWindow:set_screen_rect(...) --x1,y1,x2,y2 or rect
	local r = RECT(...)
	MapWindowRect(nil, GetParent(self.hwnd), r)
	self:move(r.x, r.y, r.w, r.h)
end

function BaseWindow:get_client_rect(r)
	return GetClientRect(self.hwnd, r)
end

function BaseWindow:get_client_w()
	return GetClientRect(self.hwnd).x2
end

function BaseWindow:get_client_h()
	return GetClientRect(self.hwnd).y2
end

--message routing

function BaseWindow:__handle_message(WM, wParam, lParam)
	--look for a procedural-level handler self:WM_*()
	local handler = self[WM_NAMES[WM]]
	if handler then
		local ret = handler(self, DecodeMessage(WM, wParam, lParam))
		if ret ~= nil then return ret end
	end
	--look for a hi-level handler self:on_*()
	--print(WM_NAMES[WM], self.__wm_handler_names[WM] or '')
	handler = self[self.__wm_handler_names[WM]]
	if handler then
		local ret = handler(self, DecodeMessage(WM, wParam, lParam))
		if ret ~= nil then return ret end
	end
	return self:__default_proc(WM, wParam, lParam)
end

function BaseWindow:__default_proc(WM, wParam, lParam) --controls override this and call CallWindowProc instead
	return DefWindowProc(self.hwnd, WM, wParam, lParam)
end

--WM_COMMAND routing

function BaseWindow:WM_COMMAND(kind, id, command, hwnd)
	if kind == 'control' then
		local window = Windows:find(hwnd)
		if window then --some controls (eg. combobox) create their own child windows which we don't know about)
			local handler = window[window.__wm_command_handler_names[command]]
			if handler then return handler(window) end
		end
	elseif kind == 'menu' then
		--do nothing: our menu class has MNS_NOTIFYBYPOS so we get WM_MENUCOMMAND instead
	elseif kind == 'accelerator' then
		--do nothing: top-level windows handle accelerators
	end
end

--WM_NOTIFY routing

function BaseWindow:WM_NOTIFY(hwnd, code, ...)
	local window = Windows:find(hwnd)
	if window == nil then return end --TODO: find out which window is sending these notifications (listview's header maybe)
	local handler = window[WM_NOTIFY_NAMES[code]]
	--look for a procedural-level handler self:*N_*()
	if handler then
		local ret = handler(window, ...)
		if ret ~= nil then return ret end
	end
	--look for a hi-level handler self:on_*()
	handler = window[window.__wm_notify_handler_names[code]]
	if handler then
		local ret = handler(window, ...)
		if ret ~= nil then return ret end
	end
end

--WM_COMPAREITEM routing

function BaseWindow:WM_COMPAREITEM(hwnd, ci)
	print'WM_COMPAREITEM' --TODO: see this message
	local window = Windows:find(hwnd)
	if window and window.on_compare_items then
		return window:on_compare_items(ci.i1, ci.i2)
	end
end

--hit testing

function BaseWindow:child_at(...) --x,y or point
	return Windows:find(ChildWindowFromPoint(self.hwnd, ...))
end

function BaseWindow:real_child_at(...) --x,y or point
	return Windows:find(RealChildWindowFromPoint(self.hwnd, ...))
end

function BaseWindow:child_at_recursive(...) --x,y or point
	for w in self:children() do
		local child = w:child_at_recursive(...)
		if child then return child end
	end
	return self:child_at(...)
end

function BaseWindow:real_child_at_recursive(...) --x,y or point
	for w in self:children() do
		local child = w:real_child_at_recursive(...)
		if child then return child end
	end
	return self:real_child_at(...)
end

function BaseWindow:map_point(to_window, ...) --x,y or point
	return MapWindowPoint(self.hwnd, to_window and to_window.hwnd, ...)
end

function BaseWindow:map_rect(to_window, ...) --x1,y1,x2,y2 or rect
	return MapWindowRect(self.hwnd, to_window and to_window.hwnd, ...)
end

--z-order

function BaseWindow:bring_below(window)
	SetWindowPos(self.hwnd, window.window, 0, 0, 0, 0, SWP_ZORDER_CHANGED_ONLY)
end

function BaseWindow:bring_above(window)
	SetWindowPos(self.hwnd, GetPrevSibling(window.window) or HWND_TOP, 0, 0, 0, 0, SWP_ZORDER_CHANGED_ONLY)
end

function BaseWindow:bring_to_front()
	SetWindowPos(self.hwnd, HWND_TOP, 0, 0, 0, 0, SWP_ZORDER_CHANGED_ONLY)
end

function BaseWindow:send_to_back()
	SetWindowPos(self.hwnd, HWND_BOTTOM, 0, 0, 0, 0, SWP_ZORDER_CHANGED_ONLY)
end

--monitor

function BaseWindow:get_monitor()
	return MonitorFromWindow(self.hwnd, MONITOR_DEFAULTTONEAREST)
end

--rendering

function BaseWindow:set_updating(updating)
	if not self.visible then return end
	SetRedraw(self.hwnd, not updating)
end

function BaseWindow:batch_update(f, ...) --can't change self.updating inside f
	if not self.visible or self.updating then
		f(...)
	end
	self.updating = true
	local ok,err = pcall(f,...)
	self.updating = false
	self:redraw()
	assert(ok, err)
end

function BaseWindow:redraw()
	RedrawWindow(self.hwnd, nil, bit.bor(RDW_ERASE, RDW_FRAME, RDW_INVALIDATE, RDW_ALLCHILDREN))
end

function BaseWindow:invalidate()
	InvalidateRect(self.hwnd, nil, true)
end

function BaseWindow:WM_PAINT()
	if self.on_paint then
		self.__paintstruct = types.PAINTSTRUCT(self.__paintstruct)
		local hdc = BeginPaint(self.hwnd, self.__paintstruct)
		self:on_paint(hdc)
		EndPaint(self.hwnd, self.__paintstruct)
		return 0
	end
end

--drag/drop

function BaseWindow:dragging(...)
	return DragDetect(self.hwnd, POINT(...))
end

--timer setting & routing

function BaseWindow:settimer(timeout_ms, handler, id)
	id = SetTimer(self.hwnd, id or 1, timeout_ms)
	if not self.__timers then self.__timers = {} end
	self.__timers[id] = handler
	return id
end

function BaseWindow:stoptimer(id)
	KillTimer(self.hwnd, id or 1)
	self.__timers[id] = nil
end

function BaseWindow:WM_TIMER(id)
	local callback = self.__timers and self.__timers[id]
	if callback then callback(self, id) end
end

