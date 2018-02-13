{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "2018.02.08";
in
buildPythonPackage rec {
  name = "regex-${version}";

  src = fetchPyPi {
    package = "regex";
    inherit version;
    sha256 = "2353c0e983c4029caf32016f1dddef623c3117ac282a818468c6d2f5d541698d";
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
