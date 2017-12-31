{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, six
, webencodings
}:

let
  version = "1.0.1";
in
buildPythonPackage {
  name = "html5lib-${version}";

  src = fetchPyPi {
    package = "html5lib";
    inherit version;
    sha256 = "66cb0dcfdbbc4f9c3ba1a63fdb511ffdbd4f513b2b6d81b80cd26ce6b3fb3736";
  };

  buildInputs = [
    six
  ];

  propagatedBuildInputs = [
    webencodings
  ];

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
