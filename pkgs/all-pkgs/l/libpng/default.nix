{ stdenv
, fetchurl

, zlib
}:

let
  version = "1.6.37";
in
stdenv.mkDerivation rec {
  name = "libpng-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/libpng/libpng16/${version}/${name}.tar.xz";
    hashOutput = false;
    sha256 = "505e70834d35383537b6491e7ae8641f1a4bed1876dbfe361201fc80868d88ca";
  };

  buildInputs = [
    zlib
  ];

  patches = [
    (fetchurl {
      url = "mirror://sourceforge/libpng-apng/libpng16/${version}/${name}-apng.patch.gz";
      sha256 = "823bb2d1f09dc7dae4f91ff56d6c22b4b533e912cbd6c64e8762255e411100b6";
    })
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      fullOpts = { };
    };
  };

  meta = with stdenv.lib; {
    description = "The official reference implementation for the PNG file format with animation patch";
    homepage = http://www.libpng.org/pub/png/libpng.html;
    license = licenses.libpng;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
