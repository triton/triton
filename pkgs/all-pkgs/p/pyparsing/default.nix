{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
, python
}:

let
  version = "2.2.0";
in
buildPythonPackage rec {
  name = "pyparsing-${version}";

  src = fetchPyPi {
    package = "pyparsing";
    inherit version;
    sha256 = "0832bcf47acd283788593e7a0f542407bd9550a55a8a8435214a1960e04bcb04";
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
    description = "Python parsing module";
    homepage = http://pyparsing.wikispaces.com/;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
