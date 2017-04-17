{ stdenv
, buildPythonPackage
, fetchPyPi

, pyutil
}:

let
  version = "1.4.24";
in
buildPythonPackage {
  name = "zfec-${version}";

  src = fetchPyPi {
    package = "zfec";
    inherit version;
    sha256 = "e3e99e6e67ac9af72c0f918f03d2051e17d41f48ee0134d0d2c81e7fe92749cf";
  };

  propagatedBuildInputs = [
    pyutil
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
