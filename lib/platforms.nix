let
  lists = import ./lists.nix;
in

rec {

  #
  ## Platform tuples
  #

  armv7b-linux = [ "armv7b-linux" ];
  armv7l-linux = [ "armv7l-linux" ];
  armv8b-linux = [ "armv8b-linux" ];
  armv8l-linux = [ "armv8l-linux" ];

  aarch64-linux = [ "aarch64-linux" ];
  aarch64_be-linux = [ "aarch64_be-linux" ];

  i686-freebsd = [ "i686-freebsd" ];
  i686-gnu = [ "i686-gnu" ];
  i686-linux = [ "i686-linux" ];
  i686-netbsd = [ "i686-netbsd" ];
  i686-openbsd = [ "i686-openbsd" ];

  mips-linux = [ "mips-linux" ];
  mipsel-linux = [ "mipsel-linux" ];
  mips64-linux = [ "mips64-linux" ];
  mips64el-linux = [ "mips64el-linux" ];

  powerpc-linux = [ "powerpc-linux" ];
  powerpcle-linux = [ "powerpcle-linux" ];
  powerpc64-linux = [ "powerpc64-linux" ];
  powerpc64le-linux = [ "powerpc64le-linux" ];

  #sparc

  x86_64-dragonflybsd = [ "x86_64-dragonflybsd" ];
  x86_64-freebsd = [ "x86_64-freebsd" ];
  x86_64-illumos = [ "x86_64-illumos" ];
  x86_64-linux = [ "x86_64-linux" ];
  x86_64-netbsd = [ "x86_64-netbsd" ];
  x86_64-openbsd = [ "x86_64-openbsd" ];

  #
  ## Kernels
  #

  dragonflybsd =
    x86_64-dragonflybsd;

  freebsd =
    #arm
    i686-freebsd
    #mips
    #powerpc
    #sparc
    ++ x86_64-freebsd;

  hurd =
    i686-gnu;

  illumos =
    #sparc
    x86_64-illumos;

  linux =
    armv7l-linux
    ++ armv8l-linux
    ++ aarch64-linux
    ++ i686-linux
    ++ mips64el-linux
    ++ powerpc-linux
    ++ powerpcle-linux
    ++ powerpc64-linux
    ++ powerpc64le-linux
    #++ sparc
    ++ x86_64-linux;

  netbsd =
    #arm
    i686-netbsd
    #mips
    #powerpc
    #sparc
    ++ x86_64-netbsd;

  openbsd =
    #arm
    i686-openbsd
    #mips
    #powerpc
    #sparc
    ++ x86_64-openbsd;

  #
  ## Architectures
  #

  armv7l =
    armv7l-linux;

  armv8l =
    armv8l-linux;

  aarch64 =
    aarch64-linux;

  aarch64_be =
    aarch64_be-linux;

  i686 =
    i686-freebsd
    ++ i686-gnu
    ++ i686-linux
    ++ i686-netbsd
    ++ i686-openbsd;

  mips =
    mips-linux;

  mipsel =
    mipsel-linux;

  mips64 =
    mips64-linux;

  mips64el =
    mips64el-linux;

  powerpc =
    powerpc-linux;

  powerpcle =
    powerpcle-linux;

  powerpc64 =
    powerpc64-linux;

  powerpc64le =
    powerpc64le-linux;

  x86_64 =
    x86_64-dragonflybsd
    ++ x86_64-freebsd
    ++ x86_64-illumos
    ++ x86_64-linux
    ++ x86_64-netbsd
    ++ x86_64-openbsd;

  #
  ## Architecture meta attributes
  #

  arm-all =
    armv7l
    ++ armv8l
    ++ aarch64
    ++ aarch64_be;

  mips-all =
    mips
    ++ mipsel
    ++ mips64
    ++ mips64el;

  powerpc-all =
    powerpc
    ++ powerpcle
    ++ powerpc64
    ++ powerpc64le;

  sparc-all = [ ];

  x86-all =
    i686
    ++ x86_64;

  #
  ## Endianness
  #

  big-endian =
    aarch64_be
    ++ mips
    ++ mips64
    ++ powerpc
    ++ powerpc64;

  little-endian =
    armv7l
    ++ armv8l
    ++ aarch64
    ++ i686
    ++ mipsel
    ++ mips64el
    ++ powerpcle
    ++ powerpc64le
    ++ x86_64;

  #
  ## All platforms
  #

  all =
    dragonflybsd
    ++ freebsd
    ++ hurd
    ++ illumos
    ++ linux
    ++ netbsd
    ++ openbsd;

  supported =
    i686-linux
    ++ x86_64-linux;

  allBut =
    platforms:
    lists.filter (x: !(builtins.elem x platforms)) supported;

  none = [ ];



  # Deprecated aliases
  darwin = [ "not-supported" ];
  cygwin = [ "not-supported" ];
  gnu = linux; /* ++ hurd ++ kfreebsd ++ ... */
  unix = supported;
}
