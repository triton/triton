{ stdenv
, buildPythonPackage
, fetchurl
, isPy3
, lib

, cairo
}:

let
  inherit (lib)
    optionalString;

  version = "1.17.0";
in
buildPythonPackage rec {
  name = "pycairo-${version}";

  src = fetchurl {
    url = "https:/github.com/pygobject/pycairo/releases/download/v${version}/"
      + "pycairo-${version}.tar.gz";
    hashOutput = false;
    sha256 = "cdd4d1d357325dec3a21720b85d273408ef83da5f15c184f2eff3212ff236b9f";
  };

  buildInputs = [
    cairo
  ];

  # PC is no longer installed during bdist install
  # Make our own instead
  postInstall = optionalString isPy3 ''
    mkdir -p "$out"/share/pkgconfig
    includedir="$(dirname "$(find "$out" -name py3cairo.h)")"
    sed "s,@includedir@,$includedir," '${./py3cairo.pc.in}' \
      >"$out"/share/pkgconfig/py3cairo.pc
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
