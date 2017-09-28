{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "8.8.2";
in
buildPythonPackage {
  name = "phonenumbers-${version}";

  src = fetchPyPi {
    package = "phonenumbers";
    inherit version;
    sha256 = "fdf626c818b04942b2df34269ab413782c0fb7490875d5f1b7958bbb61d19177";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
