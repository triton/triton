{ stdenv
, buildPythonPackage
, fetchPyPi

, pythonPackages
}:

buildPythonPackage rec {
  name = "slimit-${version}";
  version = "0.8.1";

  src = fetchPyPi {
    package = "slimit";
    inherit version;
    type = ".zip";
    sha256 = "f433dcef899f166b207b67d91d3f7344659cb33b8259818f084167244e17720b";
  };

  propagatedBuildInputs = [
    pythonPackages.ply
  ];

  doCheck = true;

  meta = with stdenv.lib; {
    description = "JavaScript minifier";
    homepage = https://github.com/rspivak/slimit;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
