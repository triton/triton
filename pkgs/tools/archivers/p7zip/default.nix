{ stdenv, fetchurl
, rarSupport ? false
}:

let
  inherit (stdenv) isDarwin;
  inherit (stdenv.lib) optionalString;
in

stdenv.mkDerivation rec {
  name = "p7zip-${version}";
  version = "9.38.1";

  src = fetchurl {
    url = "mirror://sourceforge/p7zip/p7zip_${version}_src_all.tar.bz2";
    sha256 = "15drzp2xi9zv7w55yd2hzx8q3biyhnk3fz95sd5g66wskh81jl7x";
  };

  patchPhase = optionalString (!rarSupport) ''
    sed -e '/Rar/d' -i makefile* CPP/7zip/Bundles/Format7zFree/makefile
    sed -e '/RAR/d' -i makefile* CPP/7zip/Bundles/Format7zFree/makefile
    rm -rf CPP/7zip/Compress/Rar
  '';

  makeFlags = [
    "DEST_HOME=$(out)"
  ];

  preConfigure = ''
    buildFlags=all3
  '' + optionalString isDarwin ''
    cp -f makefile.macosx_64bits makefile.machine
  '';

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "A port of the 7-zip archiver for Unix";
    homepage = http://p7zip.sourceforge.net/;
    license = (
      if rarSupport then
        licenses.unfree
      else
        licenses.lgpl21Plus
    );
    maintainers = with maintainers; [ raskin ];
    platforms = platforms.unix;
  };
}
