{ stdenv
, buildPythonPackage
, fetchPyPi

, pytestrunner
, regex
, six

, pytest
}:

let
  inherit (stdenv.lib)
    optionals;

  version = "0.7.4";
in
buildPythonPackage rec {
  name = "rebulk-${version}";

  src = fetchPyPi {
    package = "rebulk";
    inherit version;
    sha256 = "1bbea5ebcc18b70c5deb19ba6924fb76392d5130b0fe712e3af7a4e4bee18e21";
  };

  buildInputs = [
    pytestrunner
    regex
    six
  ] ++ optionals doCheck [
    pytest
  ];

  doCheck = false;

  meta = with stdenv.lib; {
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
