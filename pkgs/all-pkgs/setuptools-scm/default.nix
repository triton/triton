{ stdenv
, buildPythonPackage
, fetchPyPi

, pythonPackages
}:

buildPythonPackage rec {
  name = "setuptools-scm-${version}";
  version = "1.11.0";

  src = fetchPyPi {
    package = "setuptools_scm";
    inherit version;
    sha256 = "0600be1762896d58c818829c30b828f02ed78df3cc73ace346ae7224689c5552";
  };

  meta = with stdenv.lib; {
    description = "Handles managing python package versions in scm metadata";
    homepage = https://bitbucket.org/pypa/setuptools_scm/;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
