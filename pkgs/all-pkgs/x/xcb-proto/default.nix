{ stdenv
, fetchurl
, lib
, python
}:

stdenv.mkDerivation rec {
  name = "xcb-proto-1.13";

  src = fetchurl {
    url = "mirror://xorg/individual/xcb/${name}.tar.bz2";
    sha256 = "7b98721e669be80284e9bbfeab02d2d0d54cd11172b72271e47a2fe875e2bde1";
  };

  nativeBuildInputs = [
    python
  ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprints = [
        # Daniel Stone
        "A66D 805F 7C93 29B4 C5D8  2767 CCC4 F07F AC64 1EFF"
      ];
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "X C-language Bindings protocol headers";
    homepage = https://xcb.freedesktop.org;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
