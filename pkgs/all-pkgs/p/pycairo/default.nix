{ stdenv
, buildPythonPackage
, fetchurl
, lib

, cairo
}:

let
  inherit (lib)
    optionalString;

  version = "1.15.4";
in
buildPythonPackage rec {
  name = "pycairo-${version}";

  src = fetchurl {
    url = "https:/github.com/pygobject/pycairo/releases/download/v${version}/"
      + "pycairo-${version}.tar.gz";
    hashOutput = false;
    sha256 = "ee4c3068c048230e5ce74bb8994a024711129bde1af1d76e3276c7acd81c4357";
  };

  buildInputs = [
    cairo
  ];

  # pkgconfig has a broken prefix
  preFixup = ''
    sed -i "s,prefix=.*,prefix=$out," $out/share/pkgconfig/pycairo.pc
  '';

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      sha256Url = map (n: "${n}.sha256") src.urls;
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprint = "0EBF 782C 5D53 F7E5 FB02  A667 46BD 761F 7A49 B0EC";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with lib; {
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
