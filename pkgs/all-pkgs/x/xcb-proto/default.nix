{ stdenv
, fetchurl
, lib
, python
}:

stdenv.mkDerivation rec {
  name = "xcb-proto-1.14";

  src = fetchurl {
    url = "mirror://xorg/individual/xcb/${name}.tar.xz";
    sha256 = "186a3ceb26f9b4a015f5a44dcc814c93033a5fc39684f36f1ecc79834416a605";
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
