--ffi/struct: struct ctype wrapper

setfenv(1, require'winapi.namespace')
require'winapi.util'

local Struct = {}
local Struct_meta = {__index = Struct}

--struct virtual field setter and getter -------------------------------------

local setbit = setbit --cache

function Struct:set(cdata, field, value) --hot code
	if type(field) ~= 'string' then
		error(string.format('struct "%s" has no field of type "%s"', self.ctype, type(field)), 5)
	end
	local def = self.fields[field]
	if def then
		local name, mask, setter = unpack(def, 1, 3)
		if mask then
			cdata[self.mask] = setbit(cdata[self.mask] or 0, mask, value ~= nil)
		end
		if name then
			if setter then
				value = setter(value, cdata)
			end
			if type(value) == 'cdata' then
				pin(value, cdata)
			end
			cdata[name] = value
		else
			setter(value, cdata) --custom setter
		end
		return
	end
	--masked bitfield support.
	def = self.bitfields and self.bitfields[field]
	if def then
		--support the syntax `struct.field = {BITNAME = true|false, ...}`
		for bitname, enabled in pairs(value) do
			cdata[field..'_'..bitname] = enabled
		end
		return
	else
		--support the syntax `struct.field_BITNAME = true|false`.
		local fieldname, bitname = field:match'^([^_]+)_(.*)'
		if fieldname then
			def = self.bitfields[fieldname]
			if def then
				local datafield, maskfield, prefix = unpack(def, 1, 3)
				local mask = _M[prefix..'_'..bitname]
				if mask then
					cdata[maskfield] = setbit(cdata[maskfield] or 0, mask, value ~= nil)
					cdata[datafield] = setbit(cdata[datafield] or 0, mask, value)
					return
				end
			end
		end
	end
	error(string.format('struct "%s" has no field "%s"', self.ctype, field), 5)
end

local getbit = getbit
function Struct:get(cdata, field, value) --hot code
	if type(field) ~= 'string' then
		error(string.format('struct "%s" has no field of type "%s"', self.ctype, type(field)), 5)
	end
	local def = self.fields[field]
	if def then
		local name, mask, _, getter = unpack(def, 1, 4)
		if not mask or getbit(cdata[self.mask], mask) then
			if not name then
				if getter then
					return getter(cdata)
				else
					return true
				end
			elseif not getter then
				return cdata[name]
			else
				return getter(cdata[name], cdata)
			end
		else
			return nil
		end
	end
	--masked bitfield support
	local fieldname, bitname = field:match'^([^_]+)_(.*)'
	if fieldname then
		def = self.bitfields[fieldname]
		if def then
			local datafield, maskfield, prefix = unpack(def, 1, 3)
			local mask = _M[prefix..'_'..bitname]
			if mask then
				if getbit(cdata[maskfield] or 0, mask) then
					return getbit(cdata[datafield] or 0, mask)
				else
					return nil --masked off
				end
			end
		end
	end
	error(string.format('struct "%s" has no field "%s"', self.ctype, field), 5)
end

function Struct:setall(cdata, t)
	if not t then return end
	for field, value in pairs(t) do
		cdata[field] = value
	end
end

function Struct:setvirtual(cdata, t)
	if not t then return end
	for field in pairs(self.fields) do
		if t[field] ~= nil then
			cdata[field] = t[field]
		end
	end
end

function Struct:setdefaults(cdata)
	if not self.defaults then return end
	for field, value in pairs(self.defaults) do
		cdata[field] = value
	end
end

function Struct:clearmask(cdata) --clear all mask bits (prepare for setting data)
	if self.mask then cdata[self.mask] = 0 end
end

--struct instance constructor ------------------------------------------------

function Struct:init(cdata) end --stub

--create with a clear mask and initialized with defaults, or use existing cdata as is
function Struct:new(t)
	if type(t) == 'cdata' then return t end
	local cdata = self.ctype_cons()
	if self.size then cdata[self.size] = ffi.sizeof(cdata) end
	self:setdefaults(cdata)
	self:setall(cdata, t)
	--TODO: provide a way to make in/out buffer allocations declarative
	--instead of manually via init constructor (see winapi.filedialogs).
	self.init(cdata)
	return cdata
end

--create/use existing and set all mask bits (prepare for receiving data)
function Struct:setmask(cdata)
	if not cdata then
		cdata = self.ctype_cons()
		if self.size then cdata[self.size] = ffi.sizeof(cdata) end
	end
	if self.mask then cdata[self.mask] = self.full_mask end
	return cdata
end

Struct_meta.__call = Struct.new

function Struct:collect(cdata)
	local t = {}
	for field in pairs(self.fields) do
		t[field] = cdata[field]
	end
	return t
end

function Struct:compute_mask()
	local mask = 0
	for field, def in pairs(self.fields) do
		local bitmask = def[2]
		if bitmask then mask = bit.bor(mask, bitmask) end
	end
	return mask
end

--struct definition constructor ----------------------------------------------

local valid_struct_keys =
	index{'ctype', 'size', 'mask', 'fields', 'defaults', 'bitfields', 'init'}

local function checkdefs(s) --typecheck a struct definition
	assert(s.ctype ~= nil, 'ctype missing')
	for k,v in pairs(s) do	--check for typos in struct definition
		assert(valid_struct_keys[k], 'invalid struct key "%s"', k)
	end
	if s.fields then --check for accidentaly hidden fields
		for vname,def in pairs(s.fields) do
			local sname, mask, setter, getter = unpack(def, 1, 4)
			assert(vname ~= sname, 'virtual field "%s" not visible', vname)
		end
	end
end

function struct(s)
	checkdefs(s)
	setmetatable(s, Struct_meta)
	s.ctype_cons = ffi.typeof(s.ctype)
	if s.mask then s.full_mask = s:compute_mask() end
	ffi.metatype(s.ctype_cons, { --setup ctype for virtual fields
		__index = function(cdata,k)
			return s:get(cdata,k)
		end,
		__newindex = function(cdata,k,v)
			s:set(cdata,k,v)
		end,
	})
	return s
end

--struct field definition constructors ---------------------------------------

--sugar constructor for defining non-masked struct fields.
--t is a table of form {aliasname1, structname1, setter, getter, fieldname2, ...}.
function sfields(t)
	local dt = {}
	for i=1,#t,4 do
		assert(type(t[i]) == 'string', 'invalid sfields spec')
		assert(type(t[i+1]) == 'string', 'invalid sfields spec')
		dt[t[i]] = {
			t[i+1] ~= '' and t[i+1] or nil,
			nil,
			(type(t[i+2]) ~= 'function' or t[i+2] ~= pass) and t[i+2] or nil,
			(type(t[i+3]) ~= 'function' or t[i+3] ~= pass) and t[i+3] or nil,
		}
	end
	return dt
end

--sugar constructor for defining masked struct fields.
--t is a table of form {aliasname1, structname1, mask, setter, getter, aliasname2, ...}.
function mfields(t)
	local dt = {}
	for i=1,#t,5 do
		assert(type(t[i]) == 'string', 'invalid mfields spec')
		assert(type(t[i+1]) == 'string', 'invalid mfields spec')
		assert(type(t[i+2]) == 'number', 'invalid mfields spec')
		dt[t[i]] = {
			t[i+1] ~= '' and t[i+1] or nil,
			t[i+2] ~= 0 and t[i+2] or nil,
			t[i+3] ~= pass and t[i+3] or nil,
			t[i+4] ~= pass and t[i+4] or nil,
		}
	end
	return dt
end

--struct field setters and getters -------------------------------------------

--field setters: wcs, flags.
--field getters: mbs.

--create a struct setter for setting a fixed-size WCHAR[n] field with a Lua string.
function wc_set(field)
	return function(s, cdata)
		wcs_to(s, cdata[field])
	end
end

--create a struct getter for getting a fixed-size WCHAR[n] field as a Lua string.
function wc_get(field)
	return function(cdata)
		return mbs(ffi.cast('WCHAR*', cdata[field]))
	end
end

