{ stdenv
, buildPythonPackage
, fetchPyPi

, pathlib2
, twisted
}:

let
  version = "0.6.0";
in
buildPythonPackage {
  name = "setuptools_trial-${version}";

  src = fetchPyPi {
    package = "setuptools_trial";
    inherit version;
    sha256 = "14220f8f761c48ba1e2526f087195077cf54fad7098b382ce220422f0ff59b12";
  };

  buildInputs = [
    pathlib2
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
