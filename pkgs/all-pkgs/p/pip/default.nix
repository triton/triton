{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "19.0.1";
in
buildPythonPackage rec {
  name = "pip-${version}";

  src = fetchPyPi {
    package = "pip";
    inherit version;
    sha256 = "e81ddd35e361b630e94abeda4a1eddd36d47a90e71eb00f38f46b57f787cd1a5";
  };

  passthru = {
    inherit version;
  };

  meta = with lib; {
    description = "The PyPA recommended tool for installing Python packages";
    homepage = https://pip.pypa.io/;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
