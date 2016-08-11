{ stdenv
, fetchurl

, libpng
, zlib
}:

stdenv.mkDerivation rec {
  name = "pngcrush-1.8.4";

  src = fetchurl {
    url = "mirror://sourceforge/pmt/${name}-nolib.tar.xz";
    sha256 = "4ef6d790677cf57f622db693337d841b60d62c044e8681299245c298bd56161a";
  };

  buildInputs = [
    libpng
    zlib
  ];

  postPatch = /* Fix hardcoded install location */ ''
    sed -i Makefile \
      -e "s,/usr,$out,"
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
