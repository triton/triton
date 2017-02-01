{ stdenv
, fetchurl

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

stdenv.mkDerivation rec {
  name = "rpm-4.13.0";

  src = fetchurl {
    url = "https://github.com/rpm-software-management/rpm/releases/download/${name}-release/${name}.tar.bz2";
    sha256 = "221166b61584721a8ca979d7d8576078a5dadaf09a44208f69cc1b353240ba1b";
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

  meta = with stdenv.lib; {
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
