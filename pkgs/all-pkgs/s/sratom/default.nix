{ stdenv
, fetchurl
, lib
, waf

, lv2
, serd
, sord
}:

stdenv.mkDerivation rec {
  name = "sratom-0.6.0";

  src = fetchurl {
    url = "https://download.drobilla.net/${name}.tar.bz2";
    multihash = "QmRwaS73mJBCesaPCWEaN9rgGGMhrKYjGQjRkx65NyESTp";
    sha256 = "440ac2b1f4f0b7878f8b95698faa1e8f8c50929a498f68ec5d066863626a3d43";
  };

  nativeBuildInputs = [
    waf
  ];

  buildInputs = [
    lv2
    serd
    sord
  ];

  postPatch = /* Fix compatibility with newer autowaf */ ''
    sed -i wscript \
      -e 's/test=True/debug_by_default=False/'
  '';


  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      failEarly = true;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
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
