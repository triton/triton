{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, pytest-runner
, regex
, six

, pytest
}:

let
  inherit (lib)
    optionals;

  version = "0.9.0";
in
buildPythonPackage rec {
  name = "rebulk-${version}";

  src = fetchPyPi {
    package = "rebulk";
    inherit version;
    sha256 = "e0c69bdddccbba3ef881948ea96f1d62eda91201c306ea568a676507a30985eb";
  };

  propagatedBuildInputs = [
    pytest-runner
    regex
    six
  ] ++ optionals doCheck [
    pytest
  ];

  doCheck = false;

  meta = with lib; {
    description = "Define search patterns in bulk to perform matching on any string";
    homepage = https://github.com/Toilal/rebulk;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
