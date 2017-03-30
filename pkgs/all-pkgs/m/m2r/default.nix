{ stdenv
, buildPythonPackage
, fetchPyPi

, docutils
, mistune
}:

let
  version = "0.1.5";
in
buildPythonPackage {
  name = "m2r-${version}";

  src = fetchPyPi {
    package = "m2r";
    inherit version;
    sha256 = "3448f770aed05ca10390d0917cd51836cbf82a2f095bc91507e6291cfab03223";
  };

  buildInputs = [
    docutils
  ];

  propagatedBuildInputs = [
    mistune
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
