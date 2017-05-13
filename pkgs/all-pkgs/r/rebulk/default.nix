{ stdenv
, buildPythonPackage
, fetchPyPi

, pytest-runner
, regex
, six

, pytest
}:

let
  inherit (stdenv.lib)
    optionals;

  version = "0.8.2";
in
buildPythonPackage rec {
  name = "rebulk-${version}";

  src = fetchPyPi {
    package = "rebulk";
    inherit version;
    sha256 = "8c09901bda7b79a21d46faf489d67d017aa54d38bdabdb53f824068a6640401a";
  };

  propagatedBuildInputs = [
    pytest-runner
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
