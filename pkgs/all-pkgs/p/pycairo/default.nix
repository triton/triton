{ stdenv
, buildPythonPackage
, fetchurl
, lib

, cairo
}:

let
  inherit (stdenv.lib)
    optionalString;

  version = "1.14.0";
in
buildPythonPackage rec {
  name = "pycairo-${version}";

  src = fetchurl {
    url = "https:/github.com/pygobject/pycairo/releases/download/v${version}/pycairo-${version}.tar.gz";
    hashOutput = false;
    sha256 = "6903729a473a3de2c3b914746f737e15890076feb18b59cacdcff6c032225cff";
  };

  buildInputs = [
    cairo
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      sha256Url = map (n: "${n}.sha256") src.urls;
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprint = "0EBF 782C 5D53 F7E5 FB02  A667 46BD 761F 7A49 B0EC";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    description = "Python bindings for the cairo library";
    homepage = http://cairographics.org/pycairo/;
    license = with licenses; [
      lgpl21
      lgpl3
      mpl11
    ];
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
