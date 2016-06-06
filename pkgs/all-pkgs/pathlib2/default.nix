{ stdenv
, buildPythonPackage
, fetchPyPi

, six
}:

let
  version = "2.1.0";
in
buildPythonPackage {
  name = "pathlib2-${version}";

  src = fetchPyPi {
    package = "pathlib2";
    inherit version;
    sha256 = "deb3a960c1d55868dfbcac98432358b92ba89d95029cddd4040db1f27405055c";
  };

  propagatedBuildInputs = [
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
