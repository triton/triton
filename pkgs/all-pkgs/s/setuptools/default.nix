{ stdenv
, buildPythonPackage
, fetchPyPi
}:

buildPythonPackage rec {
  name = "setuptools-${version}";
  # Make sure to update pkgs/p/pip/bootstrap.nix setuptools hash when updating
  version = "32.3.1";

  src = fetchPyPi {
    package = "setuptools";
    inherit version;
    type = ".zip";
    sha256 = "806bae0840429c13f6e6e44499f7c0b87f3b269fdfbd815d769569c1daa7c351";
  };

  passthru = {
    # Hash for pip bootstrap, see pkgs/p/pip/bootstrap.nix
    bootstrapSha256 = "1876d17325e5157751e004d7911c0a0c3bb257d509d9d23483ff9f2f12c84315";
  };

  meta = with stdenv.lib; {
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
