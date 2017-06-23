{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "2017.06.23";
in
buildPythonPackage rec {
  name = "regex-${version}";

  src = fetchPyPi {
    package = "regex";
    inherit version;
    sha256 = "808fde10fef1c8aa17a79a1cf9c923c9ccac443be9c6a9bb25622269f6eb647a";
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
