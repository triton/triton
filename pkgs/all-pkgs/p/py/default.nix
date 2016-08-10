{ stdenv
, buildPythonPackage
, fetchPyPi
}:

buildPythonPackage rec {
  name = "py-${version}";
  version = "1.4.31";

  src = fetchPyPi {
    package = "py";
    inherit version;
    sha256 = "a6501963c725fc2554dabfece8ae9a8fb5e149c0ac0a42fd2b02c5c1c57fc114";
  };

  doCheck = false;

  meta = with stdenv.lib; {
    description = "Cross-python path, ini-parsing, io, code, log facilities";
    homepage = http://bitbucket.org/pytest-dev/py/;
    licenses = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
