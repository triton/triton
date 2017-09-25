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

  base = "2.30";
  patch = "2";
in
stdenv.mkDerivation rec {
  name = "${type}util-linux-${version base patch}";

  src = fetchurl {
    urls = map (n: "${n}.xz") (tarballUrls base patch);
    hashOutput = false;
    sha256 = "7b5be5489e9b5b7177832836467aba1c87bf0e9bcbcb5a6f35d76cd4782589dc";
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
      rev = "a1d83ec4599abadc041176fb3949a2fc33e6a8fb";
      file = "u/util-linux/fix-paths.patch";
      sha256 = "f471c78e42aa88b55924a39c0692815fc37a4814668ded26fd3b05352b9575e8";
    })
  ];

  #FIXME: make it also work on non-nixos?
  postPatch = ''
    # Substituting store paths would create a circular dependency on systemd
    sed \
      -e "s,/bin/login,/run/current-system/sw/bin/login," \
      -e "s,/sbin/shutdown,/run/current-system/sw/bin/shutdown," \
      -i include/pathnames.h

    # We can't setuid in a nixbuild
    sed -i 's, 4755 , 0755 ,g' Makefile.in
  '';

  # !!! It would be better to obtain the path to the mount helpers
  # (/sbin/mount.*) through an environment variable, but that's
  # somewhat risky because we have to consider that mount can setuid
  # root...
  configureFlags = [
    "--with-cap-ng"  # We can't disable this at the moment even though it isn't needed for libs
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
    "--with-ncursesw"
    "--with-readline"
    "--with-libz"
    "--with-systemd"
    "--enable-chfn-chsh"
    "--enable-pg"
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
      urls = map (n: "${n}.xz") (tarballUrls "2.30" "2");
      pgpsigUrls = map (n: "${n}.sign") (tarballUrls "2.30" "2");
      pgpsigSha256Urls = map (n: "${n}/sha256sums.asc") (baseUrls "2.30");
      pgpKeyFingerprint = "B0C6 4D14 301C C6EF AEDF  60E4 E4B7 1D5E EC39 C284";
      pgpDecompress = true;
      outputHash = "7b5be5489e9b5b7177832836467aba1c87bf0e9bcbcb5a6f35d76cd4782589dc";
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
