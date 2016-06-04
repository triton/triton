{ stdenv
, buildPythonPackage
, fetchPyPi

, cryptography
, six
}:

let
  version = "16.0.0";
in
buildPythonPackage {
  name = "pyOpenSSL-${version}";

  src = fetchPyPi {
    package = "pyOpenSSL";
    inherit version;
    sha256 = "363d10ee43d062285facf4e465f4f5163f9f702f9134f0a5896f134cbb92d17d";
  };

  propagatedBuildInputs = [
    cryptography
    six
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
