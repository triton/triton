{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
, python

, pyparsing
, six
}:

let
  version = "16.8";
in
buildPythonPackage rec {
  name = "packaging-${version}";

  src = fetchPyPi {
    package = "packaging";
    inherit version;
    sha256 = "5d50835fdf0a7edf0b55e311b7c887786504efea1177abd7e69329a8e5ea619e";
  };

  propagatedBuildInputs = [
    pyparsing
    six
  ];

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
    description = "Core utilities for Python packages";
    homepage = https://github.com/pypa/packaging;
    license = licenses.bsd3;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
