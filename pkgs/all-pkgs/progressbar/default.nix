{ stdenv
, buildPythonPackage
, fetchPyPi
}:

buildPythonPackage rec {
  name = "progressbar-${version}";
  version = "2.3";

  src = fetchPyPi {
    package = "progressbar";
    inherit version;
    sha256 = "b2d38a729785149e65323381d2e6fca0a5e9615a6d8bcf10bfa8adedfc481254";
  };

  meta = with stdenv.lib; {
    description = "Text progressbar library for python";
    homepage = https://github.com/niltonvolpato/python-progressbar;
    license = licenses.lgpl3Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
