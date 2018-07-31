{ stdenv
, cmake
, fetchurl
, nasm
, ninja
}:

let
  version = "2.0.0";
in
stdenv.mkDerivation rec {
  name = "libjpeg-turbo-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/libjpeg-turbo/${version}/${name}.tar.gz";
    hashOutput = false;
    sha256 = "778876105d0d316203c928fd2a0374c8c01f755d0a00b12a1c8934aeccff8868";
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
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprint = "7D62 93CC 6378 786E 1B5C  4968 85C7 044E 033F DE16";
      inherit (src) urls outputHash outputHashAlgo;
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
