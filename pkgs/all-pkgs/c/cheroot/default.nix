{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, setuptools-scm
, six
}:

let
  version = "6.5.5";
in
buildPythonPackage rec {
  name = "cheroot-${version}";

  src = fetchPyPi {
    package = "cheroot";
    inherit version;
    sha256 = "f6a85e005adb5bc5f3a92b998ff0e48795d4d98a0fbb7edde47a7513d4100601";
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
