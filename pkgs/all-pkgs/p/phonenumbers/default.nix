{ stdenv
, buildPythonPackage
, fetchPyPi
}:

let
  version = "8.3.3";
in
buildPythonPackage {
  name = "phonenumbers-${version}";

  src = fetchPyPi {
    package = "phonenumbers";
    inherit version;
    sha256 = "91ab0962bc39d690be202839cb59b162f5296a386a972afa11ac153c7d8b7e8f";
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
