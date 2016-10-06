{ stdenv
, buildPythonPackage
, fetchPyPi

, pythonPackages
}:

let
  version = "1.13.0";
in
buildPythonPackage rec {
  name = "setuptools-scm-${version}";

  src = fetchPyPi {
    package = "setuptools_scm";
    inherit version;
    sha256 = "68fa540e443a74dad7481953d0be7ee5fdbd78f84f131e550929748824708059";
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
