{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, jmespath
, python-dateutil
, urllib3
}:

let
  version = "1.12.42";
in
buildPythonPackage rec {
  name = "botocore-${version}";

  src = fetchPyPi {
    package = "botocore";
    inherit version;
    sha256 = "0e495bcf2e474b82da7938b35ad2f71e28384c246b47ca131779f736621da504";
  };

  propagatedBuildInputs = [
    jmespath
    python-dateutil
    urllib3
  ];

  meta = with lib; {
    description = "The low-level, core functionality of boto 3";
    homepage = https://github.com/boto/botocore;
    license = licenses.asl20;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
