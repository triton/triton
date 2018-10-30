{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "2018.08.29";
in
buildPythonPackage rec {
  name = "regex-${version}";

  src = fetchPyPi {
    package = "regex";
    inherit version;
    sha256 = "b73cea07117dca888b0c3671770b501bef19aac9c45c8ffdb5bea2cca2377b0a";
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
