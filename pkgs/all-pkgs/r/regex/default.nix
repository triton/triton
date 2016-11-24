{ stdenv
, buildPythonPackage
, fetchPyPi
}:

buildPythonPackage rec {
  name = "regex-${version}";
  version = "2016.11.21";

  src = fetchPyPi {
    package = "regex";
    inherit version;
    sha256 = "245258012db0792838718c67fc33107f8b940196e29aa628341956d3d903ed1f";
  };

  meta = with stdenv.lib; {
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
