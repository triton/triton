{ stdenv
, buildPythonPackage
, fetchPyPi

, six
, webencodings
}:

let
  version = "0.999999999";
in
buildPythonPackage {
  name = "html5lib-${version}";

  src = fetchPyPi {
    package = "html5lib";
    inherit version;
    sha256 = "ee747c0ffd3028d2722061936b5c65ee4fe13c8e4613519b4447123fc4546298";
  };

  buildInputs = [
    six
    webencodings
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
