{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "2.0.4";
in
buildPythonPackage rec {
  name = "fusepy-${version}";

  src = fetchPyPi {
    package = "fusepy";
    inherit version;
    sha256 = "10f5c7f5414241bffecdc333c4d3a725f1d6605cae6b4eaf86a838ff49cdaf6c";
  };

  meta = with lib; {
    description = "Simple ctypes bindings for FUSE";
    homepage = https://github.com/terencehonles/fusepy;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
