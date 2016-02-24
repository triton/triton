{ stdenv
, fetchurl
, gettext
, libxslt
, perl

, libaudit
, libcap_ng
, libsystemd
, ncurses
, pam
, python3
, readline
, zlib

, type ? ""
}:

let
  libOnly = type == "lib";
  inherit (stdenv.lib)
    optionals
    optionalString;
in
stdenv.mkDerivation rec {
  name = "${type}util-linux-${version}";
  version = "2.27.1";

  src = fetchurl {
    url = "mirror://kernel/linux/utils/util-linux/v2.27/util-linux-${version}.tar.xz";
    sha256 = "1452hz5zx56a3mad8yrg5wb0vy5zi19mpjp6zx1yr6p9xp6qz08a";
  };

  nativeBuildInputs = [
    perl
  ] ++ optionals (!libOnly) [
    gettext
    libxslt
  ];

  buildInputs = [
    python3
    libcap_ng
  ] ++ optionals (!libOnly) [
    libaudit
    ncurses
    pam
    readline
    zlib
    libsystemd
  ];

  patches = [
    ./rtcwake-search-PATH-for-shutdown.patch
  ];

  #FIXME: make it also work on non-nixos?
  postPatch = ''
    # Substituting store paths would create a circular dependency on systemd
    substituteInPlace include/pathnames.h \
      --replace "/bin/login" "/run/current-system/sw/bin/login" \
      --replace "/sbin/shutdown" "/run/current-system/sw/bin/shutdown"
  '';

  # !!! It would be better to obtain the path to the mount helpers
  # (/sbin/mount.*) through an environment variable, but that's
  # somewhat risky because we have to consider that mount can setuid
  # root...
  configureFlags = [
    "--with-cap-ng"  # We can't disable this at the moment even though it isn't needed for libs
    "--enable-libmount-force-mountinfo"
    "--enable-tunelp"
    "--enable-line"
    "--enable-reset"
    "--enable-vipw"
    "--enable-newgrp"
    "--enable-write"
    "--without-smack"
    "--with-python"
    "--enable-fs-paths-default=/var/setuid-wrappers:/run/current-system/sw/bin:/sbin:/bin"
    "--disable-use-tty-group"
  ] ++ (if libOnly then [
    "--without-audit"
    "--without-udev"
    "--without-ncurses"
    "--without-readline"
    "--without-libz"
    "--without-systemd"
    "--disable-chfn-chsh"
  ] else [
    "--with-audit"
    "--with-udev"
    "--with-ncurses"
    "--with-readline"
    "--with-libz"
    "--with-systemd"
    "--enable-chfn-chsh"
  ]);

  preBuild = optionalString libOnly ''
    buildFlagsArray+=($(sed -n 's,^am__.*\(lib.*.la\)$,\1,p' Makefile | sort | uniq))
    installTargets="$installTargets $(awk -F: '{ if (/^install.*(LTLIBRARIES|HEADERS)/) { printf $1 " " } }' Makefile)"
  '';

  installTargets = optionals libOnly [
    "install-pkgconfigDATA"
  ];

  parallelInstall = false;

  meta = with stdenv.lib; {
    homepage = http://www.kernel.org/pub/linux/utils/util-linux/;
    description = "A set of system utilities for Linux";
    platforms = platforms.linux;
    priority = 6; # lower priority than coreutils ("kill") and shadow ("login" etc.) packages
  };
}
