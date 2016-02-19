# This file defines the various standard build environments.
#
# On Linux systems, the standard build environment consists of
# Nix-built instances glibc and the `standard' Unix tools, i.e., the
# Posix utilities, the GNU C compiler, and so on.  On other systems,
# we use the native libc.
{ allPackages
, lib
, targetSystem
, hostSystem
, config
} @ args:

if lib.any (x: hostSystem == x) lib.platforms.linux then
  import ./linux args
else
  import ./native args
