{ stdenv
, fetchPyPi
, lib
, pip_egg
, python
, setuptools
, unzip
, wheel_egg
}:

let
  inherit (lib)
    optionals;

  version = "0.30.0";
in
stdenv.mkDerivation rec {
  name = "wheel-${version}";

  src = fetchPyPi {
    package = "wheel";
    inherit version;
    sha256 = "9515fe0a94e823fd90b08d22de45d7bde57c90edce705b22f5e1ecf7e1b653c8";
  };

  nativeBuildInputs = [
    pip_egg
    python
    setuptools
    unzip
    wheel_egg
  ];

  installPhase = ''
    mkdir -pv unique_wheel_dir
    ${python.interpreter} setup.py bdist_wheel --dist-dir=unique_wheel_dir

    # Clear PYTHONPATH so pip doesn't report wheel as being already satisfied
    # by wheel_egg.
    PYTHONPATH="${setuptools}/${python.sitePackages}" pip -v install unique_wheel_dir/*.whl \
      --no-index --prefix="$out" --no-cache --build pipUnpackTmp --no-compile

    # pip hardcodes references to the build directory in compiled files so
    # we compile all files manually.
    ${python.interpreter} -c "
    import compileall
    compileall.compile_dir('$out/${python.sitePackages}')
    "
  '';

  passthru = {
    inherit version;
  };

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
