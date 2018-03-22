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

  base = "2.32";
  patch = null;
in
stdenv.mkDerivation rec {
  name = "${type}util-linux-${version base patch}";

  src = fetchurl {
    urls = map (n: "${n}.xz") (tarballUrls base patch);
    hashOutput = false;
    sha256 = "6c7397abc764e32e8159c2e96042874a190303e77adceb4ac5bd502a272a4734";
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
      rev = "95b5aeefb9393ba800c7baff2f7d787103805213";
      file = "u/util-linux/0001-Fix-paths.patch";
      sha256 = "288bf77b348b74d606acd694d6126662d11ad4cf70a69ca18eb9f500db6e0714";
    })
  ];

  # !!! It would be better to obtain the path to the mount helpers
  # (/sbin/mount.*) through an environment variable, but that's
  # somewhat risky because we have to consider that mount can setuid
  # root...
  configureFlags = [
    "--with-cap-ng"  # We can't disable this at the moment even though it isn't needed for libs
    "--enable-tunelp"
    "--enable-line"
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
    "--with-ncursesw"
    "--with-readline"
    "--with-libz"
    "--with-systemd"
    "--enable-chfn-chsh"
    "--enable-pg"
    "--disable-makeinstall-chown"
    "--disable-makeinstall-setuid"
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

  installParallel = false;

  passthru = {
    srcVerification =
      let
        base = "2.32";
        patch = null;
      in
      fetchurl {
        failEarly = true;
        urls = map (n: "${n}.xz") (tarballUrls base patch);
        pgpsigUrls = map (n: "${n}.sign") (tarballUrls base patch);
        pgpsigSha256Urls = map (n: "${n}/sha256sums.asc") (baseUrls base);
        pgpKeyFingerprint = "B0C6 4D14 301C C6EF AEDF  60E4 E4B7 1D5E EC39 C284";
        pgpDecompress = true;
        outputHash = "6c7397abc764e32e8159c2e96042874a190303e77adceb4ac5bd502a272a4734";
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
