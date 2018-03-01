{ stdenv
, buildPythonPackage
, fetchFromGitHub
#, fetchPyPi
, lib
}:

let
  version = "2018-03-01";
in
buildPythonPackage rec {
  name = "pip-${version}";

  # FIXME: Revert back to using versioned releases once 10.x is released.
  # XXX: pip vendors outdated sources and a release has not been tagged since 2016.
  src = fetchFromGitHub {
    version = 5;
    owner = "pypa";
    repo = "pip";
    rev = "1cb99c1a6a0161d11fc5396030d88ebd45e118d4";
    sha256 = "afc0472d4fcbc69ee03ce44af87cbae81fec95976f5c788ff21c2b14ae58b8ee";
  };

  # src = fetchPyPi {
  #   package = "pip";
  #   inherit version;
  #   sha256 = "09f243e1a7b461f654c26a725fa373211bb7ff17a9300058b205c61658ca940d";
  # };

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
