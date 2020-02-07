pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- pico8lib tables library
-- by sparr

------------------------------------------------------------------------
-- get value from table by key, with default
local function get(t, k, d)
 return t[k]~=nil and t[k] or d
end

------------------------------------------------------------------------
-- add value v to end of table t
-- supposedly faster but less safe than add(t,v)
local function add_f(t, v)
 t[#t + 1] = v
end

------------------------------------------------------------------------
-- delete value v from table t, do not preserve order
local function del_r(t, v)
 local n = #t -- inline[1,12]
 for i = 1, n do
  if (t[i] == v) t[i], t[n] = t[n], nil return
 end
end

------------------------------------------------------------------------
-- delete index i from table t, preserve order
local function del_i(t, i)
 local n = #t -- inline[1,14]
 if (i > 0 and i <= n) then -- remove[10,33]
  for j = i, n - 1 do t[j] = t[j + 1] end
  t[n] = nil
 end
end

------------------------------------------------------------------------
-- delete index i from table t, do not preserve order
local function del_ir(t,i)
 local n = #t -- inline[1,14]
 if (i > 0 and i <= n) then -- remove[10,33]
  t[i], t[n] = t[n]
 end
end

------------------------------------------------------------------------
-- delete and return the last item from table t
local function pop(t)
 local v = t[#t]
 t[#t] = nil
 return v
end

------------------------------------------------------------------------
-- copy keys and values from src to dst
-- also copy metatable if present in src
local function merge(dst, src)
 for k, v in pairs(src or {}) do
  dst[k] = copy(v)
 end
 setmetatable(dst, getmetatable(src) or getmetatable(dst))
 return dst
end

------------------------------------------------------------------------
-- creates a new table copied from o
local function copy(o)
 return type(o) == 'table' and merge({}, o) or o
end
-- creates a new table copied from o, optionally overwriting with values from t
local function copy(o, t)
 if type(o) == 'table' then
  local c=merge({}, o)
  if (t) merge(c, t)
  return c
 else
  return o
 end
end

------------------------------------------------------------------------
-- adds values from src to end of dst, in order
local function concat(dst, src)
 local n=#dst -- inline[3,11] -- n+i becomes #dst+1
 for i=1,#src do
  dst[n+i]=src[i]
 end
end