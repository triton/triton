{ stdenv
, fetchurl
, lib
, util-macros

, xorgproto
}:

stdenv.mkDerivation rec {
  name = "bdftopcf-1.1";

  src = fetchurl {
    url = "mirror://xorg/individual/app/${name}.tar.bz2";
    hashOutput = false;
    sha256 = "4b4df05fc53f1e98993638d6f7e178d95b31745c4568cee407e167491fd311a2";
  };

  nativeBuildInputs = [
    util-macros
  ];

  buildInputs = [
    xorgproto
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
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
