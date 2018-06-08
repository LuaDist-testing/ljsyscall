-- This simply returns ABI information
-- Makes it easier to substitute for non-ffi solution, eg to run tests

local require, error, assert, tonumber, tostring,
setmetatable, pairs, ipairs, unpack, rawget, rawset,
pcall, type, table, string = 
require, error, assert, tonumber, tostring,
setmetatable, pairs, ipairs, unpack, rawget, rawset,
pcall, type, table, string

local ffi = require "ffi"

local function inlibc_fn(k) return ffi.C[k] end

local abi = {
  arch = ffi.arch, -- ppc, x86, arm, x64, mips
  abi32 = ffi.abi("32bit"), -- boolean
  abi64 = ffi.abi("64bit"), -- boolean
  le = ffi.abi("le"), -- boolean
  be = ffi.abi("be"), -- boolean
  os = ffi.os:lower(), -- bsd, osx, linux
}

-- Makes no difference to us I believe
if abi.arch == "ppcspe" then abi.arch = "ppc" end

if abi.arch == "arm" and not ffi.abi("eabi") then error("only support eabi for arm") end

if abi.arch == "mips" then abi.mipsabi = "o32" end -- only one supported now

if abi.os == "bsd" or abi.os == "osx" then abi.bsd = true end -- some shared BSD functionality

-- BSD detection, we assume they all have a compatible sysctlbyname in libc, WIP
ffi.cdef[[
  int __ljsyscall_under_xen;
]]

-- Xen generally behaves like NetBSD, but our tests need to do rump-like setup; bit of a hack
if pcall(inlibc_fn, "__ljsyscall_under_xen") then abi.xen = true end

if not abi.xen and abi.os == "bsd" then
  ffi.cdef [[
  int sysctlbyname(const char *sname, void *oldp, size_t *oldlenp, const void *newp, size_t newlen);
  ]]
  local buf = ffi.new("char[32]")
  local lenp = ffi.new("unsigned long[1]", 32)
  local ok = ffi.C.sysctlbyname("kern.ostype", buf, lenp, nil, 0)
  if not ok then error("cannot identify BSD version") end
  abi.os = ffi.string(buf):lower()
end

-- you can use version 7 here
abi.netbsd = {version = 6}

-- rump params
abi.host = abi.os -- real OS, used for rump at present may change this
abi.types = "netbsd" -- you can set to linux, or monkeypatch (see tests) to use Linux types

return abi

