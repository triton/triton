{ stdenv
, buildPythonPackage
, fetchPyPi
}:

buildPythonPackage rec {
  name = "regex-${version}";
  version = "2016.08.27";

  src = fetchPyPi {
    package = "regex";
    inherit version;
    sha256 = "53b97d85ebcbae7536dc24e798da114551a50de925a565ca14df17e6aa562389";
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
