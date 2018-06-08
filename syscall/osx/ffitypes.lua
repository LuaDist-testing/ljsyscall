-- ffi definitions of OSX types

local require, error, assert, tonumber, tostring,
setmetatable, pairs, ipairs, unpack, rawget, rawset,
pcall, type, table, string = 
require, error, assert, tonumber, tostring,
setmetatable, pairs, ipairs, unpack, rawget, rawset,
pcall, type, table, string

local abi = require "syscall.abi"

local defs = {}

local function append(str) defs[#defs + 1] = str end

append [[
typedef uint16_t mode_t;
typedef uint8_t sa_family_t;
typedef uint32_t dev_t;
typedef int64_t blkcnt_t;
typedef int32_t blksize_t;
typedef int32_t suseconds_t;
typedef uint16_t nlink_t;
typedef uint64_t ino_t; // at least on recent desktop; TODO define as ino64_t
typedef long time_t;
typedef int32_t daddr_t;
typedef unsigned long clock_t;
typedef unsigned int nfds_t;
typedef uint32_t id_t; // check as not true in freebsd
typedef unsigned long tcflag_t;
typedef unsigned long speed_t;

/* actually not a struct at all in osx, just a uint32_t but for compatibility fudge it */
/* TODO this should work, otherwise need to move all sigset_t handling out of common types */
typedef struct {
  uint32_t      val[1];
} sigset_t;

typedef struct fd_set {
  int32_t fds_bits[32];
} fd_set;
struct pollfd
{
  int     fd;
  short   events;
  short   revents;
};
struct cmsghdr {
  size_t cmsg_len;
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
struct stat {
  dev_t           st_dev;
  mode_t          st_mode;
  nlink_t         st_nlink;
  ino_t           st_ino;
  uid_t           st_uid;
  gid_t           st_gid;
  dev_t           st_rdev;
  struct timespec st_atimespec;
  struct timespec st_mtimespec;
  struct timespec st_ctimespec;
  struct timespec st_birthtimespec;
  off_t           st_size;
  blkcnt_t        st_blocks;
  blksize_t       st_blksize;
  uint32_t        st_flags;
  uint32_t        st_gen;
  int32_t         st_lspare;
  int64_t         st_qspare[2];
};
union sigval {
  int     sival_int;
  void    *sival_ptr;
};
typedef struct __siginfo {
  int     si_signo;
  int     si_errno;
  int     si_code;
  pid_t   si_pid;
  uid_t   si_uid;
  int     si_status;
  void    *si_addr;
  union sigval si_value;
  long    si_band;
  unsigned long   __pad[7];
} siginfo_t;
struct sigaction {
  union {
    void (*sa_handler)(int);
    void (*sa_sigaction)(int, siginfo_t *, void *);
  } sa_handler; // renamed as in Linux definition
  sigset_t sa_mask;
  int sa_flags;
};
struct dirent {
  uint64_t  d_ino;
  uint64_t  d_seekoff;
  uint16_t  d_reclen;
  uint16_t  d_namlen;
  uint8_t   d_type;
  char      d_name[1024];
};
struct legacy_dirent {
  uint32_t d_ino;
  uint16_t d_reclen;
  uint8_t  d_type;
  uint8_t  d_namlen;
  char d_name[256];
};
struct flock {
  off_t  l_start;
  off_t  l_len;
  pid_t  l_pid;
  short  l_type;
  short  l_whence;
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
struct kevent {
  uintptr_t       ident;
  int16_t         filter;
  uint16_t        flags;
  uint32_t        fflags;
  intptr_t        data;
  void            *udata;
};

]]

local ffi = require "ffi"

ffi.cdef(table.concat(defs, ""))


