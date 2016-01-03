{ stdenv
, fetchurl

, ghostscript
}:

stdenv.mkDerivation rec {
  name = "libspectre-0.2.7";

  src = fetchurl {
    url = "http://libspectre.freedesktop.org/releases/${name}.tar.gz";
    sha256 = "1v63lqc6bhhxwkpa43qmz8phqs8ci4dhzizyy16d3vkb20m846z8";
  };

  patches = [
    # Fix compatibility with newer versions of ghostscript
    ./libspectre-0.2.7-ghostscript-9.18.patch
  ];

  configureFlags = [
    "--disable-asserts"
    "--disable-checks"
    # Tests require Cairo, but Cairo depends on libspectre
    "--disable-test"
    "--disable-iso-c"
  ];

  buildInputs = [
    ghostscript
  ];

  doCheck = false;
  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "PostScript rendering library";
    homepage = http://libspectre.freedesktop.org/;
    license = stdenv.lib.licenses.gpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}
