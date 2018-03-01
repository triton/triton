{ stdenv
, fetchurl
, lib
, meson
, ninja
, util-macros
}:

stdenv.mkDerivation rec {
  name = "xorgproto-2018.4";

  src = fetchurl {
    url = "mirror://xorg/individual/proto/${name}.tar.bz2";
    hashOutput = false;
    sha256 = "fee885e0512899ea5280c593fdb2735beb1693ad170c22ebcc844470eec415a0";
  };

  nativeBuildInputs = [
    meson
    ninja
    util-macros
  ];

  configureFlags = [
    "-Dlegacy=false"
  ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprints = [
        # Adam Jackson
        "DD38 563A 8A82 2453 7D1F  90E4 5B8A 2D50 A0EC D0D3"
        "995E D5C8 A613 8EB0 961F  1847 4C09 DD83 CAAA 50B2"
      ];
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "X.Org protocol headers";
    homepage = https://xorg.freedesktop.org;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
