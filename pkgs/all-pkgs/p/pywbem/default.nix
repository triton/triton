{ stdenv
, buildPythonPackage
, fetchPyPi

, m2crypto
, ply
, pyyaml
, six
}:

let
  version = "0.10.0";
in
buildPythonPackage {
  name = "pywbem-${version}";

  src = fetchPyPi {
    package = "pywbem";
    inherit version;
    sha256 = "383a62087599041fa1d6ed89c583193270a7c7cbb7b5893a0eec2f03bd5cc845";
  };

  buildInputs = [
    ply
    six
  ];

  propagatedBuildInputs = [
    m2crypto
    pyyaml
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
