{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, pytest-runner
}:

let
  version = "0.6.1";
in
buildPythonPackage rec {
  name = "mccabe-${version}";

  src = fetchPyPi {
    package = "mccabe";
    inherit version;
    sha256 = "dd8d182285a0fe56bace7f45b5e7d1a6ebcbf524e8f3bd87eb0f125271b8831f";
  };

  propagatedBuildInputs = [
    pytest-runner
  ];

  meta = with lib; {
    description = "McCabe complexity checker";
    homepage = https://github.com/pycqa/mccabe;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
