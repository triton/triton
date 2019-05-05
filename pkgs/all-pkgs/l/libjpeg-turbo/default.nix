{ stdenv
, cmake
, fetchurl
, nasm
, ninja
}:

let
  version = "2.0.2";
in
stdenv.mkDerivation rec {
  name = "libjpeg-turbo-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/libjpeg-turbo/${version}/${name}.tar.gz";
    hashOutput = false;
    sha256 = "acb8599fe5399af114287ee5907aea4456f8f2c1cc96d26c28aebfdf5ee82fed";
  };

  nativeBuildInputs = [
    cmake
    nasm
    ninja
  ];

  cmakeFlags = [
    "-DENABLE_STATIC=OFF"
  ];

  passthru = {
    type = "turbo";

    srcVerification = fetchurl {
      failEarly = true;
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      fullOpts = {
        pgpsigUrls = map (n: "${n}.sig") src.urls;
        pgpKeyFingerprint = "7D62 93CC 6378 786E 1B5C  4968 85C7 044E 033F DE16";
      };
    };
  };

  meta = with stdenv.lib; {
    description = "A faster (using SIMD) libjpeg implementation";
    homepage = http://libjpeg-turbo.virtualgl.org/;
    license = licenses.ijg;
    maintainers = with maintainers; [
      codyopel
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
