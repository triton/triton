{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
, python
}:

let
  version = "1.4.3";
in
buildPythonPackage rec {
  name = "appdirs-${version}";

  src = fetchPyPi {
    package = "appdirs";
    inherit version;
    sha256 = "9e5896d1372858f8dd3344faf4e5014d21849c756c8d5701f78f8a103b372d92";
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
    description = "Python module for determining platform-specific directories";
    homepage = https://github.com/ActiveState/appdirs;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
