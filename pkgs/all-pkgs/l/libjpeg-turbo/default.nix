{ stdenv
, cmake
, fetchurl
, nasm
, ninja
}:

let
  version = "2.0.1";
in
stdenv.mkDerivation rec {
  name = "libjpeg-turbo-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/libjpeg-turbo/${version}/${name}.tar.gz";
    hashOutput = false;
    sha256 = "e5f86cec31df1d39596e0cca619ab1b01f99025a27dafdfc97a30f3a12f866ff";
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
