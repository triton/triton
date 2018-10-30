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

  version = "1.0.0";
in
buildPythonPackage rec {
  name = "rebulk-${version}";

  src = fetchPyPi {
    package = "rebulk";
    inherit version;
    sha256 = "1d49e4f7ef6fb874e60efccacbbe661092fabdb7770cdf7f7de4516d50535998";
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
