{ stdenv
, buildPythonPackage
, fetchPyPi
}:

buildPythonPackage rec {
  name = "attrs-${version}";
  version = "16.0.0";

  src = fetchPyPi {
    package = "attrs";
    inherit version;
    sha256 = "de6827a454d23716442b571bb35b0efb32a1b5c1037f09cfc7aaf405c7d68abc";
  };

  meta = with stdenv.lib; {
    description = "Attributes without boilerplate";
    homepage = https://github.com/hynek/attrs;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
