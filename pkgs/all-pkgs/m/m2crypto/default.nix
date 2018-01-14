{ stdenv
, buildPythonPackage
, fetchPyPi
, swig

, openssl
, typing
}:

let
  version = "0.27.0";
in
buildPythonPackage {
  name = "M2Crypto-${version}";

  src = fetchPyPi {
    package = "M2Crypto";
    inherit version;
    sha256 = "82317459d653322d6b37f122ce916dc91ddcd9d1b814847497ac796c4549dd68";
  };

  nativeBuildInputs = [
    swig
  ];

  buildInputs = [
    openssl
  ];

  propagatedBuildInputs = [
    typing
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
