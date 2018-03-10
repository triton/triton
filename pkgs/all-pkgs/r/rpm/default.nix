{ stdenv
, fetchurl
, lib

, binutils
, bzip2
, cpio
, db
, elfutils
, file
, libarchive
, nspr
, nss
, popt
, python
, xz
, zlib
}:

let
  channel = "4.14";
  version = "${channel}.1";
in
stdenv.mkDerivation rec {
  name = "rpm-${version}";

  src = fetchurl {
    # Don't use release tarballs hosted on github, upstream removes them
    # when there is a new release.
    url = "http://ftp.rpm.org/releases/rpm-${channel}.x/${name}.tar.bz2";
    multihash = "QmeWz66GYufBDJFyVPuz7ZF1X311Y3p2ELnkAFHYMfCZvu";
    sha256 = "43f40e2ccc3ca65bd3238f8c9f8399d4957be0878c2e83cba2746d2d0d96793b";
  };

  buildInputs = [
    binutils
    bzip2
    cpio
    db
    elfutils
    file
    libarchive
    nspr
    nss
    popt
    python
    xz
    zlib
  ];

  postPatch = ''
    # For Python3, the original expression evaluates as 'python3.4'
    # but we want 'python3.4m' here
    sed -i configure \
      -e 's/python''${PYTHON_VERSION}/${python.executable}/'

    sed -i '1i#include "config.h"' tools/sepdebugcrcfix.c
  '';

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--with-external-db"
    "--without-lua"
    "--enable-python"
  ];

  NIX_CFLAGS_COMPILE = [
    "-I${nspr}/include/nspr"
    "-I${nss}/include/nss"
  ];

  installFlags = [
    "localstatedir=\${TMPDIR}"
  ];

  preFixup = /* Configure does not remove unused variables */ ''
    sed -i $out/lib/pkgconfig/rpm.pc \
      -e 's, @WITH_LUA_LIB@,,'
  '';

  meta = with lib; {
    description = "The RPM Package Manager";
    homepage = http://www.rpm.org/;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
