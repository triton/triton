{ stdenv
, buildPythonPackage
, fetchPyPi

, twisted
}:

let
  version = "0.14.4";
in
buildPythonPackage {
  name = "Nevow-${version}";

  src = fetchPyPi {
    package = "Nevow";
    inherit version;
    sha256 = "2299a0d2a0c1312040705599d5d571acfea74df82b968c0b9264f6f45266cf6e";
  };

  buildInputs = [
    twisted
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
