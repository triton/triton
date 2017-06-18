{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "2017.06.07";
in
buildPythonPackage rec {
  name = "regex-${version}";

  src = fetchPyPi {
    package = "regex";
    inherit version;
    sha256 = "e45784bbe5a0ce4a954fbc5e0f72909798257241147271d4906bc617fd59261b";
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
