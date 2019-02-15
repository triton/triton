{ stdenv
, buildPythonPackage
, fetchPyPi

, pyopenssl
, twisted
}:

let
  version = "0.13.1";
in
buildPythonPackage {
  name = "foolscap-${version}";

  src = fetchPyPi {
    package = "foolscap";
    inherit version;
    sha256 = "e2773b4901430b8852da9d691e91984a5e2118da0448c192d9ec5aa81db91d6b";
  };

  buildInputs = [
    pyopenssl
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
