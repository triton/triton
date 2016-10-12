{ stdenv
, buildPythonPackage
, fetchPyPi

, pythonPackages
}:

let
  version = "1.13.1";
in
buildPythonPackage rec {
  name = "setuptools-scm-${version}";

  src = fetchPyPi {
    package = "setuptools_scm";
    inherit version;
    sha256 = "dfb59aa2c50e3e6e0bfde5267eff552e167b296cd67ef27443bbfa22fdcb7036";
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
