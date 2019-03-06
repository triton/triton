{ stdenv
, fetchurl
, lib
, util-macros

, libx11
, libxmu
, xorgproto
}:

stdenv.mkDerivation rec {
  name = "xrdb-1.2.0";

  src = fetchurl {
    url = "mirror://xorg/individual/app/${name}.tar.bz2";
    hashOutput = false;
    sha256 = "f23a65cfa1f7126040d68b6cf1e4567523edac10f8dc06f23d840d330c7c6946";
  };

  nativeBuildInputs = [
    util-macros
  ];

  buildInputs = [
    libx11
    libxmu
    xorgproto
  ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      fullOpts = {
        pgpsigUrls = map (n: "${n}.sig") src.urls;
        pgpKeyFingerprints = [
          # Alan Coopersmith
          "4A19 3C06 D35E 7C67 0FA4  EF0B A2FB 9E08 1F2D 130E"
        ];
      };
      failEarly = true;
    };
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
