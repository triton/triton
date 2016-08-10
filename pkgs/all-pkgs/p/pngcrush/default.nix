{ stdenv
, fetchurl

, libpng
, zlib
}:

stdenv.mkDerivation rec {
  name = "pngcrush-1.8.2";

  src = fetchurl {
    url = "mirror://sourceforge/pmt/${name}-nolib.tar.xz";
    sha256 = "4a2b4a0445008f0d528cffebd143ca9b15ec41cbc5abb79ce244d6eedaf452b1";
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
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
