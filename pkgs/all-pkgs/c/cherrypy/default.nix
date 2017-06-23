{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, cheroot
, portend
, setuptools-scm
, six
}:

let
  version = "10.2.2";
in
buildPythonPackage rec {
  name = "cherrypy-${version}";

  src = fetchPyPi {
    package = "CherryPy";
    inherit version;
    sha256 = "32d93334df765c7fd5d22815ab643333e850f0cc4f6d51fee62a68f23eea8ff8";
  };

  propagatedBuildInputs = [
    cheroot
    portend
    setuptools-scm
    six
  ];

  doCheck = false;

  meta = with lib; {
    description = "A pythonic, object-oriented HTTP framework";
    homepage = http://www.cherrypy.org;
    license = licenses.bsd3;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
