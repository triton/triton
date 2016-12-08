{ buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "2.2.0";
in
buildPythonPackage rec {
  name = "colorclass-${version}";

  src = fetchPyPi {
    package = "colorclass";
    inherit version;
    sha256 = "b05c2a348dfc1aff2d502527d78a5b7b7e2f85da94a96c5081210d8e9ee8e18b";
  };

  meta = with lib; {
    description = "ANSI color text library for Python";
    homepage = https://github.com/Robpol86/colorclass;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
