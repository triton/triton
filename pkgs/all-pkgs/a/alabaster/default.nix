{ stdenv
, buildPythonPackage
, fetchPyPi
}:

let
  version = "0.7.9";
in
buildPythonPackage {
  name = "alabaster-${version}";

  src = fetchPyPi {
    package = "alabaster";
    inherit version;
    sha256 = "47afd43b08a4ecaa45e3496e139a193ce364571e7e10c6a87ca1a4c57eb7ea08";
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
