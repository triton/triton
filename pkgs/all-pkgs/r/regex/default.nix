{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "2017.12.12";
in
buildPythonPackage rec {
  name = "regex-${version}";

  src = fetchPyPi {
    package = "regex";
    inherit version;
    sha256 = "ee069308c2757e565cc2b6f417ba5288e76cfe4c1764b6826063f4fbd53219d7";
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
