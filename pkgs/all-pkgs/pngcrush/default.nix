{ stdenv
, fetchurl

, libpng
, zlib
}:

stdenv.mkDerivation rec {
  name = "pngcrush-1.7.92";

  src = fetchurl {
    url = "mirror://sourceforge/pmt/${name}-nolib.tar.xz";
    sha256 = "0dlwbqckv90cpvg8qhkl3nk5yb75ddi61vbpmmp9n0j6qq9lp6y4";
  };

  postPatch = ''
    # Fix hardcoded install location
    sed -i Makefile -e "s,/usr,$out,"
  '';

  makeFlags = [
    "PNGINC=${libpng}/include"
    "PNGLIB=${libpng}/lib"
    "ZINC=${zlib}/include"
    "ZLIB=${zlib}/lib"
  ];

  buildInputs = [
    libpng
    zlib
  ];

  meta = with stdenv.lib; {
    description = "Portable Network Graphics (PNG) optimizing utility";
    homepage = http://pmt.sourceforge.net/pngcrush;
    license = licenses.free; # pngcrush license
    maintainers = with maintainers; [ ];
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}
