{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "2017.07.26";
in
buildPythonPackage rec {
  name = "regex-${version}";

  src = fetchPyPi {
    package = "regex";
    inherit version;
    sha256 = "b0e0c1c80e677ee351d14bdb0345c33caab6acdbaf3a41c3f34c09bbb68c8897";
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
