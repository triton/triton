{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "2017.07.28";
in
buildPythonPackage rec {
  name = "regex-${version}";

  src = fetchPyPi {
    package = "regex";
    inherit version;
    sha256 = "27ab18243b1a0aa1467027be93b118c9fcd60dd2e4020da579fad3008bc4638f";
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
