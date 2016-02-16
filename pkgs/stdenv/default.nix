# This file defines the various standard build environments.
#
# On Linux systems, the standard build environment consists of
# Nix-built instances glibc and the `standard' Unix tools, i.e., the
# Posix utilities, the GNU C compiler, and so on.  On other systems,
# we use the native libc.

{ allPackages ? import ../.., config, lib, platform, system }:

rec {

  # The native (i.e., impure) build environment.  This one uses the
  # tools installed on the system outside of the Nix environment,
  # i.e., the stuff in /bin, /usr/bin, etc.  This environment should
  # be used with care, since many Nix packages will not build properly
  # with it (e.g., because they require GNU Make).
  stdenvNative = (import ./native {
    inherit
      allPackages
      config
      system;
  }).stdenv;

  stdenvNativePkgs = allPackages {
    bootStdenv = stdenvNative;
    noSysDirs = false;
  };

  # The Nix build environment.
  stdenvNix = import ./nix {
    inherit config lib;
    stdenv = stdenvNative;
    pkgs = stdenvNativePkgs;
  };

  stdenvFreeBSD = (import ./freebsd {
    inherit
      allPackages
      config
      lib
      platform
      system;
  }).stdenvFreeBSD;

  # Linux standard environment.
  stdenvLinux = (import ./linux {
    inherit
      allPackages
      config
      lib
      platform
      system;
  }).stdenvLinux;

  # Select the appropriate stdenv for the platform `system'.
  stdenv =
    if system == "i686-linux" then
      stdenvLinux
    else if system == "x86_64-linux" then
      stdenvLinux
    else
      stdenvNative;
}
