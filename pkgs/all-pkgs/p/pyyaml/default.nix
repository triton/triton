{ stdenv
, buildPythonPackage
, fetchPyPi

, libyaml
}:

let
  version = "3.11";
in
buildPythonPackage {
  name = "PyYAML-${version}";

  src = fetchPyPi {
    package = "PyYAML";
    inherit version;
    sha256 = "c36c938a872e5ff494938b33b14aaa156cb439ec67548fcab3535bb78b0846e8";
  };

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
