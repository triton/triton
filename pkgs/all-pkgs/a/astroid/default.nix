{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, lazy-object-proxy
, six
, wrapt
}:

let
  version = "1.5.3";
in
buildPythonPackage rec {
  name = "astroid-${version}";

  src = fetchPyPi {
    package = "astroid";
    inherit version;
    sha256 = "492c2a2044adbf6a84a671b7522e9295ad2f6a7c781b899014308db25312dd35";
  };

  propagatedBuildInputs = [
    lazy-object-proxy
    six
    wrapt
  ];

  meta = with lib; {
    description = "A common base representation of python source code";
    homepage = https://github.com/PyCQA/astroid;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
