let
  lists = import ./lists.nix;
in

rec {

  #
  ## Platform tuples
  #

  aarch64-freebsd = [ "aarch64-freebsd" ];
  aarch64-linux = [ "aarch64-linux" ];
  aarch64_be-freebsd = [ "aarch64_be-freebsd" ];
  aarch64_be-linux = [ "aarch64_be-linux" ];

  armv7b-freebsd = [ "armv7b-freebsd" ];
  armv7b-linux = [ "armv7b-linux" ];
  armv7l-freebsd = [ "armv7l-freebsd" ];
  armv7l-linux = [ "armv7l-linux" ];
  armv8b-freebsd = [ "armv8b-freebsd" ];
  armv8b-linux = [ "armv8b-linux" ];
  armv8l-freebsd = [ "armv8l-freebsd" ];
  armv8l-linux = [ "armv8l-linux" ];

  i686-freebsd = [ "i686-freebsd" ];
  i686-linux = [ "i686-linux" ];

  mips-freebsd = [ "mips-freebsd" ];
  mips-linux = [ "mips-linux" ];
  mipsel-freebsd = [ "mipsel-freebsd" ];
  mipsel-linux = [ "mipsel-linux" ];
  mips64-freebsd = [ "mips64-freebsd" ];
  mips64-linux = [ "mips64-linux" ];
  mips64el-freebsd = [ "mips64el-freebsd" ];
  mips64el-linux = [ "mips64el-linux" ];

  powerpc-freebsd = [ "powerpc-freebsd" ];
  powerpc-linux = [ "powerpc-linux" ];
  powerpcle-freebsd = [ "powerpcle-freebsd" ];
  powerpcle-linux = [ "powerpcle-linux" ];
  powerpc64-freebsd = [ "powerpc64-freebsd" ];
  powerpc64-linux = [ "powerpc64-linux" ];
  powerpc64le-freebsd = [ "powerpc64le-freebsd" ];
  powerpc64le-linux = [ "powerpc64le-linux" ];

  x86_64-freebsd = [ "x86_64-freebsd" ];
  x86_64-illumos = [ "x86_64-illumos" ];
  x86_64-linux = [ "x86_64-linux" ];

  #
  ## Kernels
  #

  freebsd = [ ]
    ++ aarch64-freebsd
    ++ aarch64_be-freebsd
    ++ armv7b-freebsd
    ++ armv7l-freebsd
    ++ armv8b-freebsd
    ++ armv8l-freebsd
    ++ i686-freebsd
    ++ mips-freebsd
    ++ mipsel-freebsd
    ++ mips64-freebsd
    ++ mips64el-freebsd
    ++ powerpc-freebsd
    ++ powerpcle-freebsd
    ++ powerpc64-freebsd
    ++ powerpc64le-freebsd
    ++ x86_64-freebsd
    ;

  illumos = [ ]
    ++ x86_64-illumos
    ;

  linux = [ ]
    ++ aarch64-linux
    ++ aarch64_be-linux
    ++ armv7b-linux
    ++ armv7l-linux
    ++ armv8b-linux
    ++ armv8l-linux
    ++ i686-linux
    ++ mips-linux
    ++ mipsel-linux
    ++ mips64-linux
    ++ mips64el-linux
    ++ powerpc-linux
    ++ powerpcle-linux
    ++ powerpc64-linux
    ++ powerpc64le-linux
    ++ x86_64-linux
    ;

  #
  ## Architectures
  #

  aarch64 = [ ]
    ++ aarch64-freebsd
    ++ aarch64-linux
    ;

  aarch64_be = [ ]
    ++ aarch64_be-freebsd
    ++ aarch64_be-linux
    ;

  armv7b = [ ]
    ++ armv7b-freebsd
    ++ armv7b-linux
    ;

  armv7l = [ ]
    ++ armv7l-freebsd
    ++ armv7l-linux
    ;

  armv8b = [ ]
    ++ armv8b-freebsd
    ++ armv8b-linux
    ;

  armv8l = [ ]
    ++ armv8l-freebsd
    ++ armv8l-linux
    ;

  i686 = [ ]
    ++ i686-freebsd
    ++ i686-linux
    ;

  mips = [ ]
    ++ mips-freebsd
    ++ mips-linux
    ;

  mipsel = [ ]
    ++ mipsel-freebsd
    ++ mipsel-linux
    ;

  mips64 = [ ]
    ++ mips64-freebsd
    ++ mips64-linux
    ;

  mips64el = [ ]
    ++ mips64el-freebsd
    ++ mips64el-linux
    ;

  powerpc = [ ]
    ++ powerpc-freebsd
    ++ powerpc-linux
    ;

  powerpcle = [ ]
    ++ powerpcle-freebsd
    ++ powerpcle-linux
    ;

  powerpc64 = [ ]
    ++ powerpc64-freebsd
    ++ powerpc64-linux
    ;

  powerpc64le = [ ]
    ++ powerpc64le-linux
    ++ powerpc64le-linux
    ;

  x86_64 = [ ]
    ++ x86_64-freebsd
    ++ x86_64-illumos
    ++ x86_64-linux
    ;

  #
  ## Architecture meta attributes
  #

  arm-all = [ ]
    ++ aarch64
    ++ aarch64_be
    ++ armv7b
    ++ armv7l
    ++ armv8b
    ++ armv8l
    ;

  mips-all = [ ]
    ++ mips
    ++ mipsel
    ++ mips64
    ++ mips64el
    ;

  powerpc-all = [ ]
    ++ powerpc
    ++ powerpcle
    ++ powerpc64
    ++ powerpc64le
    ;

  x86-all = [ ]
    ++ i686
    ++ x86_64;

  #
  ## Endianness
  #

  big-endian = [ ]
    ++ aarch64_be
    ++ armv7b
    ++ armv8b
    ++ mips
    ++ mips64
    ++ powerpc
    ++ powerpc64
    ;

  little-endian = [ ]
    ++ aarch64
    ++ armv7l
    ++ armv8l
    ++ i686
    ++ mipsel
    ++ mips64el
    ++ powerpcle
    ++ powerpc64le
    ++ x86_64;

  #
  ## All platforms
  #

  all = [ ]
    ++ freebsd
    ++ illumos
    ++ linux;

  supported = [ ]
    ++ i686-linux
    ++ x86_64-linux
    ;

  none = [ ];
}
