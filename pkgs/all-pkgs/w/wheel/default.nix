{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
, python
}:

let
  inherit (lib)
    makeSearchPath
    optionals;

  version = "0.30.0";
in
buildPythonPackage rec {
  name = "wheel-${version}";

  src = fetchPyPi {
    package = "wheel";
    inherit version;
    sha256 = "9515fe0a94e823fd90b08d22de45d7bde57c90edce705b22f5e1ecf7e1b653c8";
  };

  installPhase = ''
    # Unpack into a tmp directory because `pip --upgrade` will try to remove
    # the files.
    ${python.interpreter} -c "
    import fnmatch
    import os
    import zipfile
    for file in os.listdir('unique_dist_dir/'):
      if fnmatch.fnmatch(file, '*.whl'):
        zipfile.ZipFile('unique_dist_dir/' + file).extractall('bootstrap_source_unpack')
    "

    # Use --upgrade to prevent pip from failing silently due to dependency
    # already satisfied.
    PYTHONPATH="bootstrap_source_unpack/:$PYTHONPATH" \
      ${python.interpreter} -m pip -v \
        install unique_dist_dir/*.whl \
        --upgrade \
        --no-index \
        --prefix="$out" \
        --no-cache \
        --build pipUnpackTmp \
        --no-compile
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
