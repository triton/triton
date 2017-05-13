{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "8.4.3";
in
buildPythonPackage {
  name = "phonenumbers-${version}";

  src = fetchPyPi {
    package = "phonenumbers";
    inherit version;
    sha256 = "03d942ed0cda5b81a35e846ebcc453280152b7129423b6b83342fe9caab0131f";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
