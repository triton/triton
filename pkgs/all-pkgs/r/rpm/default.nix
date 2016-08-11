{ stdenv
, fetchurl

, bzip2
, cpio
, db
, file
, elfutils
, libarchive
, nspr
, nss
, popt
, python
, xz
, zlib
}:

stdenv.mkDerivation rec {
  name = "rpm-4.12.0.1";

  src = fetchurl {
    url = "http://rpm.org/releases/rpm-4.12.x/${name}.tar.bz2";
    sha256 = "77ddd228fc332193c874aa0b424f41db1ff8b7edbb6a338703ef747851f50229";
  };

  buildInputs = [
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
  '';

  configureFlags = [
    "--with-external-db"
    "--without-lua"
    "--enable-python"
  ];

  # Note: we don't add elfutils to buildInputs, since it provides a
  # bad `ld' and other stuff.
  NIX_CFLAGS_COMPILE = [
    "-I${nspr}/include/nspr"
    "-I${nss}/include/nss"
    "-I${elfutils}/include"
  ];

  NIX_CFLAGS_LINK = "-L${elfutils}/lib";

  preFixup = /* Configure does not remove unused variables */ ''
    sed -i $out/lib/pkgconfig/rpm.pc \
      -e 's, @WITH_LUA_LIB@,,'
  '';

  meta = with stdenv.lib; {
    description = "The RPM Package Manager";
    homepage = http://www.rpm.org/;
    license = licenses.gpl2;
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      x86_64-linux;
  };
}
