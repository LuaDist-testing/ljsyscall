-- syscalls shared by BSD based operating systems

local require, error, assert, tonumber, tostring,
setmetatable, pairs, ipairs, unpack, rawget, rawset,
pcall, type, table, string = 
require, error, assert, tonumber, tostring,
setmetatable, pairs, ipairs, unpack, rawget, rawset,
pcall, type, table, string

local abi = require "syscall.abi"

return function(S, hh, c, C, types)

local ret64, retnum, retfd, retbool, retptr, retiter = hh.ret64, hh.retnum, hh.retfd, hh.retbool, hh.retptr, hh.retiter

local ffi = require "ffi"
local errno = ffi.errno

local h = require "syscall.helpers"

local istype, mktype, getfd = h.istype, h.mktype, h.getfd
local octal = h.octal

local t, pt, s = types.t, types.pt, types.s

-- note emulated in libc in NetBSD
if C.getdirentries then
  function S.getdirentries(fd, buf, size, basep)
    size = size or 4096
    buf = buf or t.buffer(size)
    basep = basep or t.long1()
    local ret, err = C.getdirentries(getfd(fd), buf, size, basep)
    if ret == -1 then return nil, t.error(err or errno()) end
    return t.dirents(buf, ret)
  end
end

function S.unmount(target, flags)
  return retbool(C.unmount(target, c.UMOUNT[flags]))
end

function S.revoke(path) return retbool(C.revoke(path)) end
function S.chflags(path, flags) return retbool(C.chflags(path, c.CHFLAGS[flags])) end
function S.lchflags(path, flags) return retbool(C.lchflags(path, c.CHFLAGS[flags])) end
function S.fchflags(fd, flags) return retbool(C.fchflags(getfd(fd), c.CHFLAGS[flags])) end
if C.chflagsat then
  function S.chflagsat(dirfd, path, flags, atflag)
    return retbool(C.chflagsat(c.AT_FDCWD[dirfd], path, c.CHFLAGS[flags], c.AT[atflag]))
  end
end

function S.pathconf(path, name) return retnum(C.pathconf(path, c.PC[name])) end
function S.fpathconf(fd, name) return retnum(C.fpathconf(getfd(fd), c.PC[name])) end
if C.lpathconf then
  function S.lpathconf(path, name) return retnum(C.lpathconf(path, c.PC[name])) end
end

function S.kqueue() return retfd(C.kqueue()) end

-- note osx has kevent64 too, different type
function S.kevent(kq, changelist, eventlist, timeout)
  if timeout then timeout = mktype(t.timespec, timeout) end
  local changes, changecount = nil, 0
  if changelist then changes, changecount = changelist.kev, changelist.count end
  if eventlist then
    local ret, err = C.kevent(getfd(kq), changes, changecount, eventlist.kev, eventlist.count, timeout)
    return retiter(ret, err, eventlist.kev)
  end
  return retnum(C.kevent(getfd(kq), changes, changecount, nil, 0, timeout))
end

function S.tcgetattr(fd) return S.ioctl(fd, "TIOCGETA") end
local tcsets = {
  [c.TCSA.NOW]   = "TIOCSETA",
  [c.TCSA.DRAIN] = "TIOCSETAW",
  [c.TCSA.FLUSH] = "TIOCSETAF",
}
function S.tcsetattr(fd, optional_actions, tio)
  -- TODO also implement TIOCSOFT, which needs to make a modified copy of tio
  local inc = c.TCSA[optional_actions]
  return S.ioctl(fd, tcsets[inc], tio)
end
function S.tcsendbreak(fd, duration)
  local ok, err = S.ioctl(fd, "TIOCSBRK")
  if not ok then return nil, err end
  S.nanosleep(0.4) -- BSD just does constant time
  local ok, err = S.ioctl(fd, "TIOCCBRK")
  if not ok then return nil, err end
  return true
end
function S.tcdrain(fd)
  return S.ioctl(fd, "TIOCDRAIN")
end
function S.tcflush(fd, com)
  return S.ioctl(fd, "TIOCFLUSH", c.TCFLUSH[com]) -- while defined as FREAD, FWRITE, values same
end
local posix_vdisable = octal "0377" -- TODO move to constants? check in all BSDs
function S.tcflow(fd, action)
  action = c.TCFLOW[action]
  if action == c.TCFLOW.OOFF then return S.ioctl(fd, "TIOCSTOP") end
  if action == c.TCFLOW.OON then return S.ioctl(fd, "TIOCSTART") end
  if action ~= c.TCFLOW.ION and action ~= c.TCFLOW.IOFF then return nil end
  local term, err = S.tcgetattr(fd)
  if not term then return nil, err end
  local cc
  if action == c.TCFLOW.IOFF then cc = term.VSTOP else cc = term.VSTART end
  if cc ~= posix_vdisable and not S.write(fd, t.uchar1(cc), 1) then return nil end
  return true
end
function S.issetugid() return C.issetugid() end

-- these are not in NetBSD; they are syscalls in FreeBSD, OSX, libs functions in Linux; they could be in main syscall.
if C.shm_open then
  function S.shm_open(pathname, flags, mode)
    if type(pathname) == "string" and pathname:sub(1, 1) ~= "/" then pathname = "/" .. pathname end
    return retfd(C.shm_open(pathname, c.O[flags], c.MODE[mode]))
  end
end
if C.shm_unlink then
  function S.shm_unlink(pathname) return retbool(C.shm_unlink(pathname)) end
end

return S

end

