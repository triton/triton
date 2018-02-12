{ stdenv
, fetchurl
, lib
, meson
, ninja
, util-macros
}:

stdenv.mkDerivation rec {
  name = "xorgproto-2018.2";

  src = fetchurl {
    url = "mirror://xorg/individual/proto/${name}.tar.bz2";
    hashOutput = false;
    sha256 = "9709c08b65d8371637605db97247782d1f0fa0bfd2111e37999088bb11996e64";
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
