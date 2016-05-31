{ stdenv
, fetchPyPi
, wrapPython

, python
}:

stdenv.mkDerivation rec {
  name = "${python.executable}-setuptools-${version}";
  # 18.4 and up breaks python34Packages.characteristic and many others
  version = "21.2.2";

  src = fetchPyPi {
    package = "setuptools";
    inherit version;
    sha256 = "0792954bf85cb23cf8dc07ca2e671730badebfe7c9225889129f2427718f03c6";
  };

  buildInputs = [
    python
    wrapPython
  ];

  installPhase = ''
    dst=$out/${python.sitePackages}
    mkdir -pv $dst
    export PYTHONPATH="$dst:$PYTHONPATH"
    ${python.interpreter} setup.py install --prefix=$out
    wrapPythonPrograms
  '';

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
