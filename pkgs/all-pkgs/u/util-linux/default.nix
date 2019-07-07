{ stdenv
, fetchTritonPatch
, fetchurl

, audit_lib
, libcap-ng
, linux-headers_triton
, libselinux
, libutempter
, ncurses
, pam
, readline
, systemd-dummy
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

  base = "2.34";
  patch = null;
in
stdenv.mkDerivation rec {
  name = "${type}util-linux-${version base patch}";

  src = fetchurl {
    urls = map (n: "${n}.xz") (tarballUrls base patch);
    hashOutput = false;
    sha256 = "743f9d0c7252b6db246b659c1e1ce0bd45d8d4508b4dfa427bbb4a3e9b9f62b5";
  };

  buildInputs = optionals (!libOnly) [
    audit_lib
    libcap-ng
    linux-headers_triton
    libselinux
    libutempter
    ncurses
    pam
    readline
    systemd_lib
    systemd-dummy
    zlib
  ];

  patches = [
    (fetchTritonPatch {
      rev = "bfc1faae133497552ebaece3efef4cecf81ae199";
      file = "u/util-linux/0001-Fix-paths.patch";
      sha256 = "5b8a5c7f1705ec5f39131a5f6b9b6e485512a8246c643248bb5d2204bcb09a9d";
    })
  ];

  configureFlags = [
    "--without-python"
    "--disable-pylibmount"
    "--enable-fs-paths-default=/var/setuid-wrappers:/run/current-system/sw/bin:/sbin:/bin"
  ] ++ (if libOnly then [
  ] else [
    "--with-selinux"
    "--with-audit"
    "--with-utempter"
    #"--with-smack"
    "--enable-tunelp"
    "--enable-line"
    "--enable-vipw"
    "--enable-newgrp"
    "--enable-chfn-chsh"
    "--enable-pg"
    "--enable-write"
    "--disable-use-tty-group"
    "--disable-makeinstall-chown"
    "--disable-makeinstall-setuid"
  ]);

  preBuild = optionalString libOnly ''
    for file in $(find . -name Makefile); do
      sed -i 's,^\(all\|install\)-am:,\1-oldam:,' "$file"
      echo 'all-am: $(LTLIBRARIES) $(HEADERS) $(pkgconfig_DATA)' >>"$file"
      echo 'install-am:' >>"$file"
      if grep -q 'install-pkgconfigDATA' "$file"; then
        echo 'install-am: install-pkgconfigDATA' >>"$file"
      fi
      sed -n 's,^\(install-.*\(LTLIBRARIES\|HEADERS\)\):.*$,\1,p' "$file" | \
        xargs echo 'install-am:' >>"$file"
    done
  '';

  installParallel = false;

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      urls = map (n: "${n}.xz") (tarballUrls "2.34" null);
      outputHash = "743f9d0c7252b6db246b659c1e1ce0bd45d8d4508b4dfa427bbb4a3e9b9f62b5";
      inherit (src) outputHashAlgo;
      fullOpts = {
        pgpsigUrls = map (n: "${n}.sign") (tarballUrls base patch);
        pgpsigSha256Urls = map (n: "${n}/sha256sums.asc") (baseUrls base);
        pgpKeyFingerprint = "B0C6 4D14 301C C6EF AEDF  60E4 E4B7 1D5E EC39 C284";
        pgpDecompress = true;
      };
    };
  };

  meta = with stdenv.lib; {
    homepage = http://www.kernel.org/pub/linux/utils/util-linux/;
    description = "A set of system utilities for Linux";
    platforms = platforms.linux;
    priority = 1; # lower priority than coreutils ("kill") and shadow ("login" etc.) packages
  };
}
