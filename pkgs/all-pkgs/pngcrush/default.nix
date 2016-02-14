{ stdenv
, fetchurl

, libpng
, zlib
}:

stdenv.mkDerivation rec {
  name = "pngcrush-1.8.0";

  src = fetchurl {
    url = "mirror://sourceforge/pmt/${name}-nolib.tar.xz";
    sha256 = "1gv36pkar5n87703mabclrmd81ij7c4vg7bnqjhf6hf3a61h99xs";
  };

  buildInputs = [
    libpng
    zlib
  ];

  postPatch =
    /* Fix hardcoded install location */ ''
      sed -i Makefile -e "s,/usr,$out,"
    '';

  makeFlags = [
    "PNGINC=${libpng}/include"
    "PNGLIB=${libpng}/lib"
    "ZINC=${zlib}/include"
    "ZLIB=${zlib}/lib"
  ];

  meta = with stdenv.lib; {
    description = "Portable Network Graphics (PNG) optimizing utility";
    homepage = http://pmt.sourceforge.net/pngcrush;
    license = licenses.free; # pngcrush license
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
