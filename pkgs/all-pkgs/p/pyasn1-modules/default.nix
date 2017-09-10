{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, pyasn1
}:

let
  version = "0.1.4";
in
buildPythonPackage {
  name = "pyasn1-modules-${version}";

  src = fetchPyPi {
    package = "pyasn1-modules";
    inherit version;
    sha256 = "b07c17bdb34d6f64aafea6269f2e8fb306a57473f0f38d9a6ca389d6ab30ac4a";
  };

  buildInputs = [
    pyasn1
  ];

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
