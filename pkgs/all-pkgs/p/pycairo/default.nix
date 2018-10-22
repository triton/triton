{ stdenv
, fetchPyPi
, lib
, pkgs

, cairo
, python
}:

let
  version = "1.17.1";
in
stdenv.mkDerivation rec {
  name = "pycairo-${version}";

  src = fetchPyPi {
    package = "pycairo";
    inherit version;
    sha256 = "0f0a35ec923d87bc495f6753b1e540fd046d95db56a35250c44089fbce03b698";
  };

  nativeBuildInputs = [
    pkgs.meson
    pkgs.ninja
  ];

  buildInputs = [
    cairo
  ];

  mesonFlags = [
    "-Dpython=${python.interpreter}"
  ];

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
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
