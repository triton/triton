{ stdenv
, buildPythonPackage
, cython
, fetchFromGitHub
, lib
, python

, py-lua-parser
}:

let
  version = "1.3.5";
in
buildPythonPackage rec {
  name = "py-lua-style-${version}";

  # Do not use PyPi sources, they don't distribute Cython code required to
  # regenerate Cython sources for the correct interpreter.
  src = fetchFromGitHub {
    version = 6;
    owner = "boolangery";
    repo = "py-lua-style";
    rev = "${version}";
    sha256 = "9b53b71ab6ca782064c0d06bbfea7101323b924a31d519ed845e0da7facb1426";
  };

  postPatch = /* Always generate cython from source, not just for sdist */ ''
    sed -i setup.py \
      -e 's/#import/import/g' \
      -e 's/#Cython/Cython/'
  '';

  nativeBuildInputs = [
    cython
  ];

  propagatedBuildInputs = [
    py-lua-parser
  ];

  disabled = python.pythonOlder "3";

  meta = with lib; {
    description = "A lua code formatter in Python";
    homepage = https://github.com/boolangery/py-lua-style;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

