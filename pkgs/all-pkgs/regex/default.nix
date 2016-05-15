{ stdenv
, buildPythonPackage
, fetchPyPi
}:

buildPythonPackage rec {
  name = "regex-${version}";
  version = "2016.05.15";

  src = fetchPyPi {
    package = "regex";
    inherit version;
    sha256 = "011b88a97ad6abd29d85791a4a6d98c10dc3e5d3d039e6cf52f2e979185cf9e4";
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
