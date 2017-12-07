{ stdenv
, buildPythonPackage
, fetchFromGitHub
#, fetchPyPi
, lib
}:

let
  version = "2017-12-02";
in
buildPythonPackage rec {
  name = "pip-${version}";

  # FIXME: Revert back to using versioned releases once 10.x is released.
  # XXX: pip vendors outdated sources and a release has not been tagged since 2016.
  src = fetchFromGitHub {
    version = 3;
    owner = "pypa";
    repo = "pip";
    rev = "ce674d2ca1dfae136fb33df914085e56d100bc57";
    sha256 = "05f07d0364f7e4fd8de28d750359ce457b801843810ddbe335f5289363a42664";
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
