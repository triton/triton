{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
, python
}:

let
  version = "1.11.0";
in
buildPythonPackage rec {
  name = "six-${version}";

  src = fetchPyPi {
    package = "six";
    inherit version;
    sha256 = "70e8a77beed4562e7f14fe23a786b54f6296e34344c23bc42f07b15018ff98e9";
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
    description = "Python 2 and 3 compatibility utilities";
    homepage = https://bitbucket.org/gutworth/six;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
