{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, markupsafe

, mock
, pytest
}:

let
  inherit (lib)
    optionals;

  version = "1.0.7";
in
buildPythonPackage rec {
  name = "mako-${version}";

  src = fetchPyPi {
    package = "Mako";
    inherit version;
    sha256 = "4e02fde57bd4abb5ec400181e4c314f56ac3e49ba4fb8b0d50bba18cb27d25ae";
  };

  nativeBuildInputs = optionals doCheck [
    mock
    pytest
  ];

  propagatedBuildInputs = [
    markupsafe
  ];

  doCheck = true;

  meta = with lib; {
    description = "Template library ";
    homepage = http://www.makotemplates.org/;
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      x86_64-linux;
  };
}
