--oo/notifyiconclass: system tray icons.
setfenv(1, require'winapi')
require'winapi.vobject'
require'winapi.shellapi'
require'winapi.wmapp'

NotifyIcon = class(VObject)

local last_id = 0

function NotifyIcon:__init(t)
	self.__info = NOTIFYICONDATA()
	if not t.message then
		self.__message = acquire_message_code()
	end
	local info = self.__info
	last_id = last_id + 1
	info.id = last_id
	info.message = t.message or self.__message
	info.hwnd = t.window and t.window.hwnd or t.hwnd
	info.icon = t.icon
	info.tip = t.tip
	info.state_HIDDEN = t.visible == false
	info.state_SHAREDICON = t.icon_shared
	info.info = t.info
	info.info_title = t.info_title
	info.info_flags = t.info_flags or 0
	info.info_timeout = t.info_timeout or 0
	Shell_NotifyIcon(NIM_ADD, self.__info)
end

function NotifyIcon:free()
	Shell_NotifyIcon(NIM_DELETE, self.__info)
	if self.__message then
		release_message_code(self.__message)
	end
end

function NotifyIcon:get_visible()
	return not self.__info.state_HIDDEN
end

function NotifyIcon:set_visible(visible)
	print(self.__info.state_HIDDEN)
	self.__info.state_HIDDEN = not visible
end

function NotifyIcon.__get_vproperty(class, self, k)
	if NOTIFYICONDATA.fields[k] then --publish info fields individually
		return self.__info[k]
	else
		return NotifyIcon.__index.__get_vproperty(class, self, k)
	end
end

function NotifyIcon.__set_vproperty(class, self, k, v)
	if NOTIFYICONDATA.fields[k] then --publish info fields individually
		self.__info[k] = v
		Shell_NotifyIcon(NIM_MODIFY, self.__info)
	else
		NotifyIcon.__index.__set_vproperty(class, self, k, v)
	end
end


if not ... then
require'winapi.windowclass'
require'winapi.icon'

local win = Window{visible = false, autoquit = true}

function win:on_show()
	self.notify_icon = NotifyIcon{
		window = self,
		icon = LoadIconFromInstance(IDI_INFORMATION),
	}
	local n = true
	self:settimer(1000, function()
		--self.notify_icon.icon = LoadIconFromInstance(n == true and IDI_WARNING or IDI_INFORMATION)
		self.notify_icon.visible = n
		n = not n
	end)
end

function win:on_destroy()
	self.notify_icon:free()
end

win:show()

MessageLoop()

end
