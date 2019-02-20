{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, setuptools-scm
, six
}:

let
  version = "6.5.4";
in
buildPythonPackage rec {
  name = "cheroot-${version}";

  src = fetchPyPi {
    package = "cheroot";
    inherit version;
    sha256 = "beb8eb9eeff5746059607e81b72efd6f4ca099111dc13f8961ae9e4f63f7786b";
  };

  postPatch = ''
    grep -q 'setuptools_scm_git_archive' setup.cfg
    sed -i setup.cfg \
      -e '/setuptools_scm_git_archive/d'
  '';

  propagatedBuildInputs = [
    setuptools-scm
    six
  ];

  meta = with lib; {
    description = "Highly-optimized, pure-python HTTP server";
    homepage = https://github.com/cherrypy/cheroot;
    license = licenses.bsd3;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
