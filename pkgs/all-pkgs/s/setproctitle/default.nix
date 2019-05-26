{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "1.1.10";
in
buildPythonPackage rec {
  name = "setproctitle-${version}";

  src = fetchPyPi {
    package = "setproctitle";
    inherit version;
    sha256 = "6283b7a58477dd8478fbb9e76defb37968ee4ba47b05ec1c053cb39638bd7398";
  };

  meta = with lib; {
    description = "Module to customize the process title";
    homepage = https://github.com/dvarrazzo/py-setproctitle;
    license = licenses.bsd3;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

