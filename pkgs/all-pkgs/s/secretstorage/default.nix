{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, cryptography
}:

let
  version = "2.3.1";
in
buildPythonPackage {
  name = "SecretStorage-${version}";

  src = fetchPyPi {
    package = "SecretStorage";
    inherit version;
    sha256 = "3af65c87765323e6f64c83575b05393f9e003431959c9395d1791d51497f29b6";
  };

  propagatedBuildInputs = [
    cryptography
  ];

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
