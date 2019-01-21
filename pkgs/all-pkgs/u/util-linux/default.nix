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

  base = "2.33";
  patch = "1";
in
stdenv.mkDerivation rec {
  name = "${type}util-linux-${version base patch}";

  src = fetchurl {
    urls = map (n: "${n}.xz") (tarballUrls base patch);
    hashOutput = false;
    sha256 = "c14bd9f3b6e1792b90db87696e87ec643f9d63efa0a424f092a5a6b2f2dbef21";
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
      rev = "95b5aeefb9393ba800c7baff2f7d787103805213";
      file = "u/util-linux/0001-Fix-paths.patch";
      sha256 = "288bf77b348b74d606acd694d6126662d11ad4cf70a69ca18eb9f500db6e0714";
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
      urls = map (n: "${n}.xz") (tarballUrls "2.33" "1");
      outputHash = "c14bd9f3b6e1792b90db87696e87ec643f9d63efa0a424f092a5a6b2f2dbef21";
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
