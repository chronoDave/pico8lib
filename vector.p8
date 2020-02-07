pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- pico8lib vector library
-- by sparr

-- a vector is a point or direction in 2d space
-- represented by an x and y coordinate
-- vectors arithmetic represents operations on these points/directions

-- pico8 coordinate system
-- +x is east/right
-- -x is west/left
-- +y is south/down
-- -y is north/up

-- some code from https://github.com/codekitchen/pico-8-circuits

local vector
vector = setmetatable({

 __eq = function(a, b)
  return a.x == b.x and a.y == b.y
 end,

 __unm = function(a)
  return vector{ -a.x, -a.y }
 end,

 __add = function(a, b)
  return vector{ a.x + b.x, a.y + b.y }
 end,

 __sub = function(a, b)
  return vector{ a.x - b.x, a.y - b.y }
 end,

 __mul = function(a, b) 
  if (type(b) == "number") return vector{ a.x * b, a.y * b }
  if (type(a) == "number") return b * a
  return a.x * b.x + a.y * b.y -- scalar product
 end,

 crossproduct = function(a, b)
  return a.x * b.y - a.y * b.x
 end,

 __div = function(a, b)
  return vector{ a.x / b, a.y / b }
 end,

 __len = function(a)
  -- return sqrt(a.x*a.x+a.y*a.y) -- potential overflow
  if (a.x < 128 and a.y < 128) return sqrt(a.x * a.x + a.y * a.y) -- remove[25,54] slight decrease in accuracy
  local d = max(abs(a.x), abs(a.y))
  local n = abs(a.x / d * a.y / d)
  return sqrt(n * n + 1) * d
 end,
 
 __tostring = function(a)
  return "[vector:" .. tostr(a.x) .. "," .. tostr(a.y) .. "]"
 end,

 angle = function(a)
  return atan2(a.x, -a.y)
 end,

 normalize = function(a)
  return a / #a
 end,

 contained = function(a, p1, p2)
  return a.x >= p1.x and a.x <= p2.x and a.y >= p1.y and a.y <= p2.y
 end,

 dset = function(a, idx)
  dset(idx, a.x)
  dset(idx+1, a.y)
 end,

 dget = function(idx)
  return vector{dget(idx), dget(idx + 1)}
 end,

 rotate_90 = function(a)
  return vector{-a.y, a.x}
 end,

 rotate_180 = function(a)
  return -a
 end,

 rotate_270 = function(a)
  return vector{a.y, -a.x}
 end,

 rotate_degrees = function(a, angle)
  return a:rotate(angle / 360)
 end,

 rotate = function(a, angle) -- todo test
  return vector{a.x * cos(angle) + a.y * sin(angle), a.y * cos(angle) + a.x * -sin(angle)}
 end,

 from_polar = function(p) -- todo test
  return vector{p.r * cos(p.t), -p.r * sin(p.t)}
 end,

 to_polar = function(a) -- todo test
  return {r = #a, t = a:angle()}
 end,

},{

 __call=function(t, o)
  o = o or {0,0}
  return setmetatable({ x = o[1] or o.x, y = o[2] or o.y }, t)
 end

})
vector.__index = vector

------------------------------------------------------------------------
-- tests
assert(vector{2,3} == vector{2,3})
assert(vector{2,3} == -vector{-2,-3})
assert(vector{2,3} + vector{-1,2} == vector{1,5})
assert(vector{2,3} - vector{1,2} == vector{1,1})
assert(vector{2,3} * 2 == vector{4,6})
assert(2 * vector{2,3} == vector{4,6})
assert(vector{2,3} * vector{-1,2} == 4)
assert(vector{2,3}:crossproduct(vector{-1,2}) == 7)
assert(vector{2,6} / 2 == vector{1,3})
assert(#vector{3,4} == 5)
assert(vector{2,-1}:__tostring() == "[vector:2,-1]")
assert(vector{1,0}:angle() == 0)
assert(vector{2,2}:angle() == 1/8)
assert(vector{-3,0}:angle() == 1/2)
assert(vector{3,4}:normalize() == vector{3/5,4/5})
assert(vector{1,1}:contained(vector{0,0},vector{2,2}))
assert(not vector{-1,1}:contained(vector{0,0},vector{2,2}))
assert(vector{2,1}:rotate_90() == vector{-1,2})
assert(vector{2,1}:rotate_180() == vector{-2,-1})
assert(vector{2,1}:rotate_270() == vector{1,-2})
assert(#(vector{sqrt(3)/2,-0.5}:rotate_degrees(30) - vector{1,0}) < .01)
assert(#(vector{sqrt(3)/2,-0.5}:rotate(5/12) - vector{-0.5,sqrt(3)/2}) < .01)
assert(#(vector.from_polar{r=1,t=7/8} - vector{sqrt(2)/2,-sqrt(2)/2}) < .01)
assert(abs(vector{sqrt(3)/2,-0.5}:to_polar().r - 1) < .01)
assert(abs(vector{sqrt(3)/2,-0.5}:to_polar().t - 11/12) < .01)