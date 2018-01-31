{ stdenv
, fetchurl
, lib
, waf

, lv2
, serd
, sord
}:

stdenv.mkDerivation rec {
  name = "sratom-0.4.6";

  src = fetchurl {
    url = "https://download.drobilla.net/${name}.tar.bz2";
    sha256 = "a4b9beaeaedc4f651beb15cd1cfedff905b0726a9010548483475ad97d941220";
  };

  nativeBuildInputs = [
    waf
  ];

  buildInputs = [
    lv2
    serd
    sord
  ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      failEarly = true;
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprint = "907D 226E 7E13 FA33 7F01  4A08 3672 782A 9BF3 68F3";
    };
  };

  meta = with lib; {
    description = "A library for serialising LV2 atoms to/from RDF";
    homepage = http://drobilla.net/software/sratom;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
