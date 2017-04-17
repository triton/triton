{ stdenv
, buildPythonPackage
, fetchPyPi

, zbase32
}:

let
  version = "2.0.0";
in
buildPythonPackage {
  name = "pyutil-${version}";

  src = fetchPyPi {
    package = "pyutil";
    inherit version;
    sha256 = "0ca95cb85843c5b09f7b65b5bd6c42d1940e19667b076620585ac45abe4f4fbb";
  };

  propagatedBuildInputs = [
    zbase32
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
