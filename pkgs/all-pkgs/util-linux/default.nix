{ stdenv
, fetchTritonPatch
, fetchurl
, gettext
, libxslt
, perl

, audit_lib
, libcap-ng
, ncurses
, pam
, python3
, readline
, systemd_lib
, zlib

, type ? ""
}:

let
  inherit (stdenv.lib)
    optionals
    optionalString;
in

let
  libOnly = type == "lib";

  version = base: patch: "${base}${if patch == null then "" else ".${patch}"}";

  baseUrls = base: [
    "mirror://kernel/linux/utils/util-linux/v${base}"
  ];

  tarballUrls = base: patch: map (n: "${n}/util-linux-${version base patch}.tar") (baseUrls base);

  base = "2.28";
  patch = null;
in

stdenv.mkDerivation rec {
  name = "${type}util-linux-${version base patch}";

  src = fetchurl {
    urls = map (n: "${n}.xz") (tarballUrls base patch);
    allowHashOutput = false;
    sha256 = "395847e2a18a2c317170f238892751e73a57104565344f8644090c8b091014bb";
  };

  nativeBuildInputs = [
    perl
  ] ++ optionals (!libOnly) [
    gettext
    libxslt
  ];

  buildInputs = [
    python3
    libcap-ng
  ] ++ optionals (!libOnly) [
    audit_lib
    ncurses
    pam
    readline
    systemd_lib
    zlib
  ];

  patches = [
    (fetchTritonPatch {
      rev = "b84e67b8138aa3305c7047b5affa393b7d875af2";
      file = "util-linux/fix-paths.patch";
      sha256 = "0925c16024be1927250fa32378bf6a69f37e9be2d91d9a5a7541aa54340af384";
    })
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
    echo 'myBuildLibs: $(usrlib_exec_LTLIBRARIES) $(pylibmountexec_LTLIBRARIES)' >> Makefile
    installTargets="$installTargets $(awk -F: '{ if (/^install.*(LTLIBRARIES|HEADERS)/) { printf $1 " " } }' Makefile)"
  '';

  buildFlags = optionals libOnly [
    "myBuildLibs"
  ];

  installTargets = optionals libOnly [
    "install-pkgconfigDATA"
  ];

  parallelInstall = false;

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      urls = map (n: "${n}.xz") (tarballUrls "2.28" null);
      pgpsigUrls = map (n: "${n}.sign") (tarballUrls "2.28" null);
      pgpsigSha256Urls = map (n: "${n}/sha256sums.asc") (baseUrls "2.28");
      pgpKeyFingerprint = "B0C6 4D14 301C C6EF AEDF  60E4 E4B7 1D5E EC39 C284";
      pgpDecompress = true;
      outputHash = "395847e2a18a2c317170f238892751e73a57104565344f8644090c8b091014bb";
      inherit (src) outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    homepage = http://www.kernel.org/pub/linux/utils/util-linux/;
    description = "A set of system utilities for Linux";
    platforms = platforms.linux;
    priority = 1; # lower priority than coreutils ("kill") and shadow ("login" etc.) packages
  };
}
