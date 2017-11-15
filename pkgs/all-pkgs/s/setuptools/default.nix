{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
, pip_egg
, python
, setuptools_egg
, unzip
, wheel_egg
}:

let
  setuptools_wheel = fetchPyPi {
    package = "setuptools";
    #inherit (setuptools) version;
    inherit version;
    type = "-py2.py3-none-any.whl";
    sha256 = "bae92a71c82f818deb0b60ff1f7d764b8902cfc24187746b1aa6186918a70db3";
  };

  version = "36.7.2";
in
stdenv.mkDerivation rec {
  name = "setuptools-${version}";

  src = fetchPyPi {
    package = "setuptools";
    inherit version;
    type = ".zip";
    sha256 = "ad86fd8dd09c285c33b4c5b82bbc21d21883637faef78b0ab58fa9984847220d";
  };

  nativeBuildInputs = [
    python
    setuptools_egg
    unzip
    wheel_egg
  ];

  installPhase = ''
    mkdir -pv unique_wheel_dir
    ${python.interpreter} setup.py bdist_wheel --dist-dir=unique_wheel_dir

    # Unpack into a tmp directory because `pip --upgrade` will try to remove
    # the files.
    ${python.interpreter} -c "
    import fnmatch
    import os
    import zipfile

    for file in os.listdir('unique_wheel_dir/'):
      if fnmatch.fnmatch(file, '*.whl'):
        zipfile.ZipFile('unique_wheel_dir/' + file).extractall('bootstrap_tmp_dir')
    "

    # # Use --upgrade to prevent pip from failing silently due to dependency
    # # already satisfied.
    # PYTHONPATH="bootstrap_tmp_dir/" ${pip_egg}/bin/pip -v \
    #   install ${setuptools_wheel} \
    #   --upgrade \
    #   --no-index \
    #   --prefix="$out" \
    #   --no-cache \
    #   --build pipUnpackTmp \
    #   --no-compile

    # FIXME: using prebuilt wheel until bootstraping is fixed
    mkdir -pv $out/${python.sitePackages}
    unzip -d $out/${python.sitePackages} ${setuptools_wheel}

    ${python.interpreter} -c "
    import compileall
    try:
      # Python 3.2+ support optimization
      compileall.compile_dir('$out/${python.sitePackages}', optimize=2)
    except:
      compileall.compile_dir('$out/${python.sitePackages}')
    "
  '';

  passthru = {
    inherit version;
  };

  meta = with lib; {
    description = "Utilities to facilitate the installation of Python packages";
    homepage = http://pypi.python.org/pypi/setuptools;
    license = licenses.zpt20;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
