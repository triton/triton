{ stdenv
, buildPythonPackage
, fetchPyPi

, libyaml
}:

let
  version = "3.12";
in
buildPythonPackage {
  name = "PyYAML-${version}";

  src = fetchPyPi {
    package = "PyYAML";
    inherit version;
    sha256 = "592766c6303207a20efc445587778322d7f73b161bd994f227adaa341ba212ab";
  };

  nativeBuildInputs = [
    cython
  ];

  buildInputs = [
    libyaml
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
