{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "2018.01.10";
in
buildPythonPackage rec {
  name = "regex-${version}";

  src = fetchPyPi {
    package = "regex";
    inherit version;
    sha256 = "139678fc013b75e486e580c39b4c52d085ed7362e400960f8be1711a414f16b5";
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
