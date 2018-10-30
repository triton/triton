{ stdenv
, buildPythonPackage
, fetchPyPi
, isPy2
, lib
, unzip

, py-cpuinfo
, pytest
, statistics
}:

let
  inherit (lib) optionals;

  version = "3.1.1";
in
buildPythonPackage rec {
  name = "pytest-benchmark-${version}";

  src = fetchPyPi {
    package = "pytest-benchmark";
    inherit version;
    sha256 = "185526b10b7cf1804cb0f32ac0653561ef2f233c6e50a9b3d8066a9757e36480";
  };

  nativeBuildInputs = [
    unzip
  ];

  propagatedBuildInputs = [
    py-cpuinfo
    pytest
  ] ++ optionals isPy2 /* <3.4 */ [
    statistics
  ];

  #doCheck = true;

  meta = with lib; {
    description = "py.test fixture for benchmarking code";
    homepage = https://github.com/ionelmc/pytest-benchmark;
    license = licenses.bsd3;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
