-- This are the types for FreeBSD

local require, error, assert, tonumber, tostring,
setmetatable, pairs, ipairs, unpack, rawget, rawset,
pcall, type, table, string = 
require, error, assert, tonumber, tostring,
setmetatable, pairs, ipairs, unpack, rawget, rawset,
pcall, type, table, string

local abi = require "syscall.abi"

local defs = {}

local function append(str) defs[#defs + 1] = str end

if abi.abi64 then
append [[
typedef int32_t clock_t;
]]
else
append [[
typedef unsigned long clock_t;
]]
end

append [[
typedef uint32_t      blksize_t;
typedef int64_t       blkcnt_t;
typedef int32_t       clockid_t;
typedef uint32_t      fflags_t;
typedef uint64_t      fsblkcnt_t;
typedef uint64_t      fsfilcnt_t;
typedef int64_t       id_t;
typedef uint32_t      ino_t;
typedef long          key_t;
typedef int32_t       lwpid_t;
typedef uint16_t      mode_t;
typedef int           accmode_t;
typedef int           nl_item;
typedef uint16_t      nlink_t;
typedef int64_t       rlim_t;
typedef uint8_t       sa_family_t;
typedef long          suseconds_t;
//typedef struct __timer  *__timer_t;
//typedef struct __mq     *__mqd_t;
typedef unsigned int  useconds_t;
typedef int           cpuwhich_t;
typedef int           cpulevel_t;
typedef int           cpusetid_t;
typedef uint32_t      dev_t;
typedef uint32_t      fixpt_t;
typedef	unsigned int  nfds_t;
typedef int64_t       daddr_t;
typedef long          time_t;
typedef unsigned int  tcflag_t;
typedef unsigned int  speed_t;

/* can be changed, TODO also should be long */
typedef uint32_t __fd_mask;
typedef struct fd_set {
  __fd_mask __fds_bits[32];
} fd_set;
typedef struct __sigset {
  uint32_t val[4]; // note renamed to match Linux
} sigset_t;
struct cmsghdr {
  socklen_t cmsg_len;
  int cmsg_level;
  int cmsg_type;
  char cmsg_data[?];
};
struct msghdr {
  void *msg_name;
  socklen_t msg_namelen;
  struct iovec *msg_iov;
  int msg_iovlen;
  void *msg_control;
  socklen_t msg_controllen;
  int msg_flags;
};
struct timespec {
  time_t tv_sec;
  long   tv_nsec;
};
struct timeval {
  time_t tv_sec;
  suseconds_t tv_usec;
};
struct sockaddr {
  uint8_t       sa_len;
  sa_family_t   sa_family;
  char          sa_data[14];
};
struct sockaddr_storage {
  uint8_t       ss_len;
  sa_family_t   ss_family;
  char          __ss_pad1[6];
  int64_t       __ss_align;
  char          __ss_pad2[128 - 2 - 8 - 6];
};
struct sockaddr_in {
  uint8_t         sin_len;
  sa_family_t     sin_family;
  in_port_t       sin_port;
  struct in_addr  sin_addr;
  int8_t          sin_zero[8];
};
struct sockaddr_in6 {
  uint8_t         sin6_len;
  sa_family_t     sin6_family;
  in_port_t       sin6_port;
  uint32_t        sin6_flowinfo;
  struct in6_addr sin6_addr;
  uint32_t        sin6_scope_id;
};
struct sockaddr_un {
  uint8_t         sun_len;
  sa_family_t     sun_family;
  char            sun_path[104];
};
struct pollfd {
  int fd;
  short events;
  short revents;
};
struct stat {
  dev_t     st_dev;
  ino_t     st_ino;
  mode_t    st_mode;
  nlink_t   st_nlink;
  uid_t     st_uid;
  gid_t     st_gid;
  dev_t     st_rdev;
  struct timespec st_atim;
  struct timespec st_mtim;
  struct timespec st_ctim;
  off_t     st_size;
  blkcnt_t  st_blocks;
  blksize_t st_blksize;
  fflags_t  st_flags;
  uint32_t  st_gen;
  int32_t   st_lspare;
  struct timespec st_birthtim;
  unsigned int :(8 / 2) * (16 - (int)sizeof(struct timespec));
  unsigned int :(8 / 2) * (16 - (int)sizeof(struct timespec));
};
struct rusage {
  struct timeval ru_utime;
  struct timeval ru_stime;
  long    ru_maxrss;
  long    ru_ixrss;
  long    ru_idrss;
  long    ru_isrss;
  long    ru_minflt;
  long    ru_majflt;
  long    ru_nswap;
  long    ru_inblock;
  long    ru_oublock;
  long    ru_msgsnd;
  long    ru_msgrcv;
  long    ru_nsignals;
  long    ru_nvcsw;
  long    ru_nivcsw;
};
struct flock {
  off_t   l_start;
  off_t   l_len;
  pid_t   l_pid;
  short   l_type;
  short   l_whence;
  int     l_sysid;
};
struct dirent {
  uint32_t d_fileno;
  uint16_t d_reclen;
  uint8_t  d_type;
  uint8_t  d_namlen;
  char     d_name[255 + 1];
};
struct termios {
  tcflag_t        c_iflag;
  tcflag_t        c_oflag;
  tcflag_t        c_cflag;
  tcflag_t        c_lflag;
  cc_t            c_cc[20];
  speed_t         c_ispeed;
  speed_t         c_ospeed;
};
struct fiodgname_arg {
  int     len;
  void    *buf;
};
struct kevent {
  uintptr_t       ident;
  short           filter;
  unsigned short  flags;
  unsigned int    fflags;
  intptr_t        data;
  void            *udata;
};
struct cap_rights {
  uint64_t cr_rights[0 + 2]; // for version 0
};
typedef struct cap_rights cap_rights_t;
]]

local s = table.concat(defs, "")

local ffi = require "ffi"
ffi.cdef(s)

