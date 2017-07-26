{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "2017.07.11";
in
buildPythonPackage rec {
  name = "regex-${version}";

  src = fetchPyPi {
    package = "regex";
    inherit version;
    sha256 = "dbda8bdc31a1c85445f1a1b29d04abda46e5c690f8f933a9cc3a85a358969616";
  };

  meta = with lib; {
    description = "Alternative regular expression module, to replace re";
    homepage = https://bitbucket.org/mrabarnett/mrab-regex;
    license = licenses.free; # python sfl
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
