{ stdenv
, fetchPyPi
, lib
, python
, setuptools
, unzip
}:

let
  inherit (lib)
    optionals;

  version = "0.29.0";
in
stdenv.mkDerivation rec {
  name = "wheel-${version}";

  src = fetchPyPi {
    package = "wheel";
    inherit version;
    sha256 = "1ebb8ad7e26b448e9caa4773d2357849bf80ff9e313964bcaf79cbf0201a1648";
  };

  nativeBuildInputs = [
    python
    setuptools
    unzip
  ];

  buildPhase = ''
    ${python.interpreter} setup.py bdist_wheel
  '';

  installPhase = ''
    pushd dist/
      mkdir -pv $out/${python.sitePackages}
      unzip -d $out/${python.sitePackages} wheel-*.whl
    popd
  '';

  meta = with lib; {
    description = "A built-package format for Python";
    homepage = https://bitbucket.org/pypa/wheel/;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
