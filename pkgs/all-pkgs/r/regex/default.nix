{ stdenv
, buildPythonPackage
, fetchPyPi
}:

buildPythonPackage rec {
  name = "regex-${version}";
  version = "2016.07.21";

  src = fetchPyPi {
    package = "regex";
    inherit version;
    sha256 = "c9c98972ccfccdc9e16b10b415a78c9b0adbadcc34078e4cfdb54507617214bb";
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
