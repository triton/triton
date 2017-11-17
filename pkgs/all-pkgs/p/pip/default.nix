{ stdenv
, buildPythonPackage
, fetchFromGitHub
#, fetchPyPi
, lib
, python
}:

let
  version = "2017-11-12";
in
buildPythonPackage rec {
  name = "pip-${version}";

  # FIXME: Revert back to using versioned releases once 10.x is released.
  # XXX: pip vendors outdated sources and a release has not been tagged since 2016.
  src = fetchFromGitHub {
    version = 3;
    owner = "pypa";
    repo = "pip";
    rev = "8f6b4c9b2d014b9a646585074612cecf51e1cc88";
    sha256 = "caeba3de3afc8ab3dfec48f6a536fe5145ac332178640956b6bad46c6cc8bb0b";
  };

  # src = fetchPyPi {
  #   package = "pip";
  #   inherit version;
  #   sha256 = "09f243e1a7b461f654c26a725fa373211bb7ff17a9300058b205c61658ca940d";
  # };

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
    description = "The PyPA recommended tool for installing Python packages";
    homepage = https://pip.pypa.io/;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
